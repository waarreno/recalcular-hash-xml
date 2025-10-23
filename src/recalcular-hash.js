#!/usr/bin/env node

const fs = require('fs');
const crypto = require('crypto');
const readline = require('readline');

/**
 * Calcula o hash MD5 de uma string
 * @param {string} content - Conteúdo para calcular o hash
 * @returns {string} Hash MD5 em hexadecimal
 */
function calcularMD5(content) {
    return crypto.createHash('md5').update(content, 'utf8').digest('hex');
}

/**
 * Extrai todos os valores de texto dos elementos XML, exceto o elemento hash
 * Remove todas as tags, atributos e espaços em branco, mantendo apenas os valores
 * @param {string} xmlContent - Conteúdo XML
 * @returns {string} String concatenada com todos os valores
 */
function extrairValoresXML(xmlContent) {
    // Primeiro, remove o elemento hash completamente
    let conteudoSemHash = xmlContent.replace(/<[^:>]*:?hash>.*?<\/[^:>]*:?hash>/gs, '');
    
    // Remove a declaração XML
    conteudoSemHash = conteudoSemHash.replace(/<\?xml[^?]*\?>/g, '');
    
    // Remove comentários XML
    conteudoSemHash = conteudoSemHash.replace(/<!--.*?-->/gs, '');
    
    // Extrai o conteúdo entre tags, ignorando as tags em si
    const valores = [];
    
    // Remove todas as tags, mas mantém o conteúdo
    // Esta regex captura o conteúdo entre > e <
    let conteudoLimpo = conteudoSemHash.replace(/<[^>]+>/g, '|');
    
    // Divide pelos delimitadores e filtra valores vazios ou apenas espaços
    const partes = conteudoLimpo.split('|')
        .map(parte => parte.trim())
        .filter(parte => parte.length > 0);
    
    // Concatena todos os valores
    return partes.join('');
}

/**
 * Substitui o conteúdo do elemento <q1:hash> com o novo hash
 * @param {string} xmlContent - Conteúdo XML original
 * @param {string} novoHash - Novo hash calculado
 * @returns {string} XML com hash atualizado
 */
function substituirHash(xmlContent, novoHash) {
    const hashRegex = /(<[^:>]*:?hash>).*?(<\/[^:>]*:?hash>)/gs;
    return xmlContent.replace(hashRegex, `$1${novoHash}$2`);
}

/**
 * Cria backup do arquivo original
 * @param {string} caminhoArquivo - Caminho do arquivo original
 * @returns {string} Caminho do arquivo de backup
 */
function criarBackup(caminhoArquivo) {
    const caminhoBackup = `${caminhoArquivo}.backup`;
    fs.copyFileSync(caminhoArquivo, caminhoBackup);
    console.log(`✓ Backup criado: ${caminhoBackup}`);
    return caminhoBackup;
}

/**
 * Processa o arquivo XML recalculando o hash
 * @param {string} caminhoArquivo - Caminho do arquivo a processar
 */
function processarArquivo(caminhoArquivo) {
    console.log('\n=== RECALCULANDO HASH MD5 ===\n');
    console.log(`Arquivo: ${caminhoArquivo}`);

    // Verificar se o arquivo existe
    if (!fs.existsSync(caminhoArquivo)) {
        console.error(`✗ Erro: Arquivo não encontrado: ${caminhoArquivo}`);
        process.exit(1);
    }

    // Ler o conteúdo do arquivo
    const conteudoOriginal = fs.readFileSync(caminhoArquivo, 'utf8');
    console.log(`✓ Arquivo lido (${conteudoOriginal.length} caracteres)`);

    // Extrair o hash atual
    const hashAtualMatch = conteudoOriginal.match(/<[^:>]*:?hash>(.*?)<\/[^:>]*:?hash>/s);
    const hashAtual = hashAtualMatch ? hashAtualMatch[1].trim() : 'não encontrado';
    console.log(`Hash atual: ${hashAtual}`);

    // Extrair a string para cálculo do hash
    console.log('Extraindo valores do XML...');
    const stringParaHash = extrairValoresXML(conteudoOriginal);
    console.log(`✓ String extraída (${stringParaHash.length} caracteres)`);
    
    // Mostrar primeiros e últimos caracteres para debug
    if (process.env.DEBUG) {
        console.log('\n--- DEBUG ---');
        console.log('Primeiros 100 caracteres:', stringParaHash.substring(0, 100));
        console.log('Últimos 100 caracteres:', stringParaHash.substring(stringParaHash.length - 100));
        console.log('String completa:', stringParaHash);
        console.log('--- FIM DEBUG ---\n');
    }
    
    // Calcular novo hash
    const novoHash = calcularMD5(stringParaHash);
    console.log(`Novo hash:  ${novoHash}`);

    // Verificar se o hash mudou
    if (hashAtual === novoHash) {
        console.log('\n✓ O hash está correto. Nenhuma alteração necessária.');
        return;
    }

    console.log('\n! Hash diferente detectado. Atualizando arquivo...');

    // Criar backup
    criarBackup(caminhoArquivo);

    // Substituir hash no conteúdo original
    const conteudoAtualizado = substituirHash(conteudoOriginal, novoHash);

    // Salvar arquivo atualizado
    fs.writeFileSync(caminhoArquivo, conteudoAtualizado, 'utf8');
    console.log(`✓ Arquivo atualizado com sucesso!`);
    
    console.log('\n=== PROCESSO CONCLUÍDO ===\n');
}

/**
 * Solicita o caminho do arquivo ao usuário
 */
async function solicitarArquivo() {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });

    return new Promise((resolve) => {
        rl.question('Digite o caminho do arquivo XML: ', (resposta) => {
            rl.close();
            resolve(resposta.trim());
        });
    });
}

/**
 * Função principal
 */
async function main() {
    console.log('╔═══════════════════════════════════════════╗');
    console.log('║  RECALCULADOR DE HASH MD5 PARA XML       ║');
    console.log('║     Sistema Unimed/TISS - PTU 3.0        ║');
    console.log('╚═══════════════════════════════════════════╝\n');

    // Verificar se foi passado arquivo como argumento
    let caminhoArquivo = process.argv[2];

    // Se não foi passado, solicitar interativamente
    if (!caminhoArquivo) {
        caminhoArquivo = await solicitarArquivo();
    }

    if (!caminhoArquivo) {
        console.error('✗ Erro: Nenhum arquivo especificado.');
        console.log('\nUso:');
        console.log('  node recalcular-hash.js <caminho-do-arquivo>');
        console.log('  ou execute sem argumentos para modo interativo');
        console.log('\nOpções:');
        console.log('  DEBUG=1 node recalcular-hash.js <arquivo>  - Mostra string extraída');
        process.exit(1);
    }

    // Processar o arquivo
    try {
        processarArquivo(caminhoArquivo);
    } catch (erro) {
        console.error(`\n✗ Erro ao processar arquivo: ${erro.message}`);
        console.error(erro.stack);
        process.exit(1);
    }
}

// Executar
main();