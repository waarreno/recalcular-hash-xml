# Recalculador de Hash MD5 para PTU XML

Sistema automatizado para recalcular e atualizar o hash MD5 em arquivos XML do padrão **TISS** (Padrão para Troca de Informações na Saúde Suplementar), desenvolvido especificamente para processar arquivos PTU da Unimed.

## Sobre o Projeto

Esta ferramenta resolve o problema de inconsistência de hash MD5 em arquivos XML do padrão TISS. Quando arquivos XML são modificados manualmente ou processados por outros sistemas, o hash MD5 embutido pode ficar desatualizado, causando rejeição pelos sistemas receptores.

**O que este sistema faz:**
- Lê arquivos XML do padrão TISS (extensão `.988`)
- Extrai todos os valores de texto do XML (excluindo o próprio elemento hash)
- Calcula o hash MD5 correto seguindo as especificações do padrão TISS
- Compara com o hash atual e atualiza se necessário
- Cria backup automático antes de qualquer modificação

## Requisitos

### Modo Automático (Windows)
- **Sistema Operacional:** Windows 7 ou superior
- **PowerShell:** 3.0 ou superior (já incluído no Windows 8+)
- **Conexão com internet:** Necessária apenas na primeira execução
- **Espaço em disco:** ~30 MB para Node.js portátil

### Modo Manual (Node.js instalado)
- **Node.js:** 14.0.0 ou superior

## Instalação e Uso

### Opção 1: Modo Automático (Recomendado para Windows)

O sistema baixa e configura automaticamente tudo que é necessário:

1. **Primeira execução:** Execute `executar.bat`
   - O sistema baixará automaticamente o Node.js portátil (v22.21.0)
   - Configura o ambiente automaticamente
   - Não instala nada no Windows

2. **Execuções seguintes:** Execute `executar.bat`
   - Inicia diretamente o processamento
   - Use o modo interativo ou passe o caminho do arquivo como argumento

**Exemplos:**
```batch
:: Modo interativo (sistema pede o caminho do arquivo)
executar.bat

:: Passando o arquivo diretamente
executar.bat "C:\Documentos\protocolo.988"

:: Com caminho relativo
executar.bat arquivos\protocolo.988
```

### Opção 2: Modo Manual (Node.js instalado)

Se você já tem o Node.js instalado no sistema:

```bash
# Executar diretamente
node src/recalcular-hash.js arquivo.988

# Modo interativo
node src/recalcular-hash.js

# Modo debug (mostra detalhes da extração)
DEBUG=1 node src/recalcular-hash.js arquivo.988
```

## Estrutura do Projeto

```
recalcular-hash-xml/
│
├── src/
│   └── recalcular-hash.js      # Script principal Node.js
│
├── executar.bat                # Launcher automático Windows
├── limpar.bat                  # Script de limpeza/reset
├── package.json                # Metadados do projeto
├── LICENSE                     # Licença MIT
└── README.md                   # Este arquivo
│
├── node-portable/              # Node.js portátil (criado automaticamente)
│   ├── node.exe
│   ├── npm.cmd
│   └── ...
│
└── *.988.backup                # Backups automáticos (criados ao processar)
```

## Como Funciona

### Algoritmo de Cálculo do Hash

O sistema segue exatamente o padrão TISS para cálculo do hash MD5:

1. **Remove o elemento hash:** Localiza e remove `<ns:hash>...</ns:hash>` (qualquer namespace)
2. **Remove declarações XML:** Remove `<?xml ... ?>` do início do arquivo
3. **Remove comentários:** Remove todos os comentários `<!-- ... -->`
4. **Extrai valores:** Captura apenas o texto entre as tags, ignorando:
   - Nomes das tags
   - Atributos
   - Espaços em branco entre tags
5. **Concatena valores:** Junta todos os valores em uma única string
6. **Calcula MD5:** Gera o hash MD5 da string resultante

### Exemplo de Processamento

**XML Original:**
```xml
<?xml version="1.0"?>
<root>
  <hash>abc123</hash>
  <dados>
    <valor>123</valor>
    <texto>teste</texto>
  </dados>
</root>
```

**String Extraída para Hash:**
```
123teste
```

**Resultado:** Hash MD5 da string "123teste"

## Saída do Sistema

### Exemplo de Execução Bem-Sucedida

```
╔═══════════════════════════════════════════╗
║  RECALCULADOR DE HASH MD5 PARA PTU XML    ║
╚═══════════════════════════════════════════╝

Digite o caminho do arquivo XML: protocolo.988

=== RECALCULANDO HASH MD5 ===

Arquivo: protocolo.988
✓ Arquivo lido (45230 caracteres)
Hash atual: 5d41402abc4b2a76b9719d911017c592
Extraindo valores do XML...
✓ String extraída (43180 caracteres)
Novo hash:  ed076287532e86365e841e92bfc50d8c

! Hash diferente detectado. Atualizando arquivo...
✓ Backup criado: protocolo.988.backup
✓ Arquivo atualizado com sucesso!

=== PROCESSO CONCLUÍDO ===
```

### Exemplo quando Hash está Correto

```
=== RECALCULANDO HASH MD5 ===

Arquivo: protocolo.988
✓ Arquivo lido (45230 caracteres)
Hash atual: ed076287532e86365e841e92bfc50d8c
✓ String extraída (43180 caracteres)
Novo hash:  ed076287532e86365e841e92bfc50d8c

✓ O hash está correto. Nenhuma alteração necessária.
```

## Funcionalidades Avançadas

### Modo Debug

Para visualizar detalhes do processamento:

```bash
DEBUG=1 node src/recalcular-hash.js arquivo.988
```

Exibe:
- String completa extraída do XML
- Primeiros 100 caracteres da string
- Últimos 100 caracteres da string
- Informações detalhadas de cada etapa

### Backup Automático

O sistema **sempre** cria um backup antes de modificar qualquer arquivo:
- Nome do backup: `[arquivo-original].backup`
- Exemplo: `protocolo.988` → `protocolo.988.backup`
- O backup contém o arquivo original completo
- Se já existir um backup, ele é sobrescrito

## Limpeza do Sistema

Para remover o Node.js portátil e reiniciar a instalação:

```batch
limpar.bat
```

Este script remove:
- Node.js portátil (`node-portable/`)
- `node_modules/` (se existir)
- `package-lock.json` (se existir)
- Arquivos temporários

**Importante:** Os arquivos do projeto e seus backups `.backup` **não são afetados**.

## Solução de Problemas

### "Node.js não encontrado"

**Solução:** Execute `executar.bat` - ele baixará automaticamente o Node.js portátil.

### "Erro ao baixar Node.js"

**Causas possíveis:**
- Sem conexão com internet
- Firewall bloqueando o download
- Proxy corporativo

**Soluções:**
1. Verifique sua conexão com internet
2. Execute como administrador (clique direito → "Executar como administrador")
3. Baixe manualmente:
   - Acesse: https://nodejs.org/dist/v22.21.0/node-v22.21.0-win-x64.zip
   - Extraia o conteúdo
   - Renomeie a pasta para `node-portable`
   - Coloque no mesmo diretório do `executar.bat`

### "Erro ao processar arquivo"

**Causas possíveis:**
- Arquivo não é um XML válido
- Arquivo não contém elemento `<hash>`
- Arquivo corrompido

**Soluções:**
1. Verifique se o arquivo é um XML válido
2. Abra o arquivo em um editor de texto e confirme que contém `<hash>`
3. Execute em modo debug para mais informações: `DEBUG=1 node src/recalcular-hash.js arquivo.988`

### "Hash continua incorreto após atualização"

**Possíveis causas:**
- Sistema receptor usa algoritmo diferente
- Encoding do arquivo está incorreto
- Necessário incluir/excluir elementos adicionais

**Solução:**
1. Execute em modo debug: `DEBUG=1 node src/recalcular-hash.js arquivo.988`
2. Consulte a documentação técnica do sistema receptor
3. Verifique o encoding do arquivo (deve ser UTF-8)

## Casos de Uso

### Uso Individual
```batch
executar.bat meu-protocolo.988
```

### Processamento em Lote
Crie um script batch para processar múltiplos arquivos:

```batch
@echo off
for %%f in (*.988) do (
    echo Processando: %%f
    executar.bat "%%f"
    echo.
)
pause
```

### Integração com Outros Sistemas
Use como parte de um pipeline:

```bash
# Processar arquivo antes de enviar
node src/recalcular-hash.js protocolo.988

# Verificar se teve sucesso
if %ERRORLEVEL% EQU 0 (
    echo Hash atualizado com sucesso
    # Enviar arquivo...
)
```

## Especificações Técnicas

### Formato de Arquivo Suportado
- **Padrão:** TISS (Troca de Informações na Saúde Suplementar)
- **Extensão:** Geralmente `.988` ou `.xml`
- **Encoding:** UTF-8 (recomendado)
- **Estrutura:** XML bem-formado com elemento `<hash>` ou `<ns:hash>`

### Algoritmo de Hash
- **Tipo:** MD5
- **Encoding:** UTF-8
- **Formato de saída:** Hexadecimal (32 caracteres)

### Limitações Conhecidas
- Arquivos muito grandes (>100MB) podem demorar alguns segundos
- Requer que o XML seja bem-formado (não processa XML inválido)
- O elemento hash pode usar qualquer namespace

## Informações do Projeto

### Versão
**1.0.0** - Outubro 2025

### Autor
**Wárreno Hendrick Costa Lima Guimarães**
Coordenador de Contas Médicas

### Licença
MIT License - Veja o arquivo [LICENSE](LICENSE) para detalhes.

Copyright (c) 2025 Warreno Hendrick Costa Lima Guimaraes

### Desenvolvido para
Área de Contas Médicas da Unimed Cerrado

## Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

### Reportando Bugs

Ao reportar bugs, inclua:
- Versão do Windows
- Mensagem de erro completa
- Arquivo de exemplo (se possível)
- Saída em modo debug

## Referências e Documentação

### Padrão TISS
- **ANS (Agência Nacional de Saúde Suplementar):** https://www.ans.gov.br/
- **Padrão TISS:** Consulte a documentação oficial da ANS para especificações técnicas

### Sistema PTU Unimed
- **Manual do PTU:** Consulte a documentação fornecida pela Unimed do Brasil
- **Suporte técnico:** Entre em contato com o suporte técnico da sua operadora Unimed

## FAQ (Perguntas Frequentes)

**P: O sistema modifica meu arquivo original?**
R: Sim, após criar um backup com extensão `.backup`. O arquivo original é modificado apenas se o hash estiver incorreto.

**P: Posso usar em produção?**
R: Sim, o sistema cria backups automáticos e foi testado extensivamente. Ainda assim, recomenda-se manter backups adicionais.

**P: Funciona com outros padrões além do TISS?**
R: O algoritmo é genérico para XML, mas foi otimizado para o padrão TISS. Pode funcionar com outros padrões que usem hash MD5 similar.

**P: Preciso de acesso à internet sempre?**
R: Não, apenas na primeira execução para baixar o Node.js portátil. Após isso, funciona offline.

**P: Posso mover o projeto para outro computador?**
R: Sim, copie toda a pasta incluindo `node-portable/`. O sistema funcionará sem necessidade de reconfiguração.

**P: O que fazer se o sistema receptor ainda rejeita o arquivo?**
R: Verifique:
1. Se o sistema receptor usa o mesmo algoritmo de hash
2. O encoding do arquivo (UTF-8)
3. Se há elementos adicionais que devem ser incluídos/excluídos
4. Consulte a documentação técnica do sistema receptor

---

**Desenvolvido com ❤️ para a área de Contas Médicas da Unimed Cerrado**