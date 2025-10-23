# Recalculador de Hash MD5 para PTU XML

Sistema para recalcular e atualizar automaticamente o hash MD5 em arquivos PTU XML do padrão TISS (Padrão para Troca de Informações na Saúde Suplementar), especificamente para o sistema Unimed/PTU.

## 📋 Descrição

Este projeto fornece uma ferramenta automatizada que:

- ✅ Lê arquivos XML do padrão TISS
- ✅ Extrai todos os valores do XML (exceto o elemento hash)
- ✅ Calcula o hash MD5 correto
- ✅ Compara com o hash atual
- ✅ Atualiza o arquivo se necessário
- ✅ Cria backup automático antes de modificar

## 🚀 Como Usar

### Opção 1: Interface Gráfica (Windows)

1. **Execute o arquivo `executar.bat`**
2. Na primeira execução, o sistema irá:
   - Baixar automaticamente o Node.js portátil
   - Configurar o ambiente
   - Instalar dependências (se necessário)
3. Digite o caminho do arquivo XML quando solicitado
4. Aguarde o processamento

### Opção 2: Linha de Comando

```bash
# Com caminho do arquivo
executar.bat caminho/para/arquivo.988

# Modo interativo
executar.bat
```

### Opção 3: Node.js Direto

```bash
# Instalar dependências (se necessário)
npm install

# Executar
node src/recalcular-hash.js caminho/para/arquivo.988

# Modo interativo
node src/recalcular-hash.js

# Modo debug (mostra string extraída)
DEBUG=1 node src/recalcular-hash.js arquivo.988
```

## 📁 Estrutura do Projeto

```
recalcular-hash-xml/
│
├── src/
│   ├── recalcular-hash.js     # Script principal
│   └── (arquivos fonte)
│
├── executar.bat               # Executável Windows
├── limpar.bat                 # Script de limpeza
├── package.json               # Configuração do projeto
├── README.md                  # Este arquivo
│
├── node-portable/             # Node.js portátil (criado automaticamente)
└── *.988.backup               # Backups automáticos
```

## 🔧 Requisitos

### Para uso com .bat (Windows)
- Windows 7 ou superior
- PowerShell 3.0 ou superior
- Conexão com internet (apenas primeira execução)

### Para uso direto com Node.js
- Node.js 14.0.0 ou superior

## 🛠️ Funcionalidades

### Cálculo do Hash
O sistema:
1. Remove o elemento `<hash>` do XML
2. Remove declarações XML e comentários
3. Extrai apenas os valores de texto entre as tags
4. Concatena todos os valores
5. Calcula o MD5 da string resultante

### Backup Automático
Antes de modificar qualquer arquivo, o sistema cria automaticamente um backup com a extensão `.backup`.

### Modo Debug
Use a variável de ambiente `DEBUG=1` para visualizar:
- String completa extraída do XML
- Primeiros e últimos 100 caracteres
- Informações detalhadas do processamento

## 🧹 Limpeza

Para remover o Node.js portátil e reiniciar a instalação:

```bash
limpar.bat
```

Este script irá:
- Remover o Node.js portátil instalado
- Limpar node_modules
- Remover package-lock.json
- Limpar arquivos temporários
- **NÃO afeta** os arquivos do projeto

## 📝 Exemplo de Uso

```
╔══════════════════════════════════════════╗
║  RECALCULADOR DE HASH MD5 PARA PTU XML   ║
╚══════════════════════════════════════════╝

Digite o caminho do arquivo XML: C:\Arquivos\protocolo.xml

=== RECALCULANDO HASH MD5 ===

Arquivo: C:\Arquivos\protocolo.xml
✓ Arquivo lido (15847 caracteres)
Hash atual: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
✓ String extraída (14523 caracteres)
Novo hash:  x9y8z7w6v5u4t3s2r1q0p9o8n7m6l5k4

! Hash diferente detectado. Atualizando arquivo...
✓ Backup criado: C:\Arquivos\protocolo.xml.backup
✓ Arquivo atualizado com sucesso!

=== PROCESSO CONCLUÍDO ===
```

## ⚠️ Avisos Importantes

- **Sempre faça backup** dos seus arquivos antes de processar
- O sistema cria backups automaticamente, mas é recomendado manter cópias adicionais
- O arquivo original será modificado após a confirmação
- Verifique se o hash atualizado é aceito pelo sistema receptor

## 🐛 Solução de Problemas

### "Node.js não encontrado"
Execute o arquivo `.bat` que baixará automaticamente a versão portátil.

### "Erro ao processar arquivo"
- Verifique se o arquivo é um XML válido
- Confirme se o arquivo contém um elemento `<hash>`
- Execute em modo debug para mais informações

### "Falha ao baixar Node.js"
- Verifique sua conexão com internet
- Tente executar como administrador
- Execute o script `limpar.bat` e tente novamente

## 🧑‍💻 Autor

**Wárreno Hendrick Costa Lima Guimarães**

Coordenador de Contas Médicas

## 📄 Licença

MIT License - Sinta-se livre para usar e modificar este projeto.

## 🤝 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para:
- Reportar bugs
- Sugerir melhorias
- Enviar pull requests

## 📞 Suporte

Para questões específicas sobre o padrão TISS ou integração com sistemas Unimed/PTU, consulte a documentação oficial da ANS (Agência Nacional de Saúde Suplementar) e Manual do PTU da Unimed do Brasil.

---

**Versão:** 1.0.0  
**Última atualização:** Outubro 2025

Feito com ❤️ para a área de Contas Médicas da Unimed Cerrado