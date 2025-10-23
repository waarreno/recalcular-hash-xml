@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ╔═══════════════════════════════════════════╗
echo ║  RECALCULADOR DE HASH MD5 PARA PTU/XML    ║
echo ╚═══════════════════════════════════════════╝
echo.

REM Define diretórios
set "SCRIPT_DIR=%~dp0"
set "NODE_DIR=%SCRIPT_DIR%node-portable"
set "NODE_EXE=%NODE_DIR%\node.exe"
set "NPM_CMD=%NODE_DIR%\npm.cmd"
set "NODE_VERSION=22.21.0"
set "NODE_DOWNLOAD=https://nodejs.org/dist/v%NODE_VERSION%/node-v%NODE_VERSION%-win-x64.zip"
set "NODE_ZIP=%SCRIPT_DIR%node-portable.zip"

REM Verifica se Node.js portável já existe
if exist "%NODE_EXE%" (
    echo [√] Node.js portavel encontrado
    goto CHECK_DEPENDENCIES
)

echo [i] Node.js portavel nao encontrado
echo [i] Baixando Node.js v%NODE_VERSION% portatil...
echo.

REM Baixa Node.js usando PowerShell
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; Write-Host '[...] Baixando Node.js...'; try { Invoke-WebRequest -Uri '%NODE_DOWNLOAD%' -OutFile '%NODE_ZIP%' -UseBasicParsing; Write-Host '[√] Download concluido'; } catch { Write-Host '[X] Erro no download: ' $_.Exception.Message; exit 1 } }"

if errorlevel 1 (
    echo.
    echo [X] Falha ao baixar Node.js
    pause
    exit /b 1
)

if not exist "%NODE_ZIP%" (
    echo [X] Arquivo de download nao encontrado
    pause
    exit /b 1
)

echo [i] Extraindo Node.js...

REM Extrai o arquivo ZIP usando PowerShell
powershell -Command "& { $ProgressPreference = 'SilentlyContinue'; Write-Host '[...] Extraindo arquivos...'; try { Expand-Archive -Path '%NODE_ZIP%' -DestinationPath '%SCRIPT_DIR%temp-node' -Force; Write-Host '[√] Extracao concluida'; } catch { Write-Host '[X] Erro na extracao: ' $_.Exception.Message; exit 1 } }"

if errorlevel 1 (
    echo [X] Falha ao extrair Node.js
    del "%NODE_ZIP%" 2>nul
    pause
    exit /b 1
)

REM Move os arquivos da subpasta para o diretório node-portable
echo [i] Organizando arquivos...
if exist "%SCRIPT_DIR%temp-node\node-v%NODE_VERSION%-win-x64" (
    move "%SCRIPT_DIR%temp-node\node-v%NODE_VERSION%-win-x64" "%NODE_DIR%" >nul
) else (
    REM Caso a estrutura seja diferente, move o primeiro diretório encontrado
    for /d %%i in ("%SCRIPT_DIR%temp-node\*") do (
        move "%%i" "%NODE_DIR%" >nul
        goto MOVE_DONE
    )
)
:MOVE_DONE

REM Limpa arquivos temporários
rmdir /s /q "%SCRIPT_DIR%temp-node" 2>nul
del "%NODE_ZIP%" 2>nul

if not exist "%NODE_EXE%" (
    echo [X] Erro: Node.exe nao encontrado apos extracao
    pause
    exit /b 1
)

echo [√] Node.js portatil instalado com sucesso
echo.

:CHECK_DEPENDENCIES
REM Verifica se o package.json existe
if not exist "%SCRIPT_DIR%package.json" (
    echo [i] Criando package.json...
    (
        echo {
        echo   "name": "recalcular-hash-xml",
        echo   "version": "1.0.0",
        echo   "description": "Recalculador de hash MD5 para arquivos XML TISS",
        echo   "main": "recalcular-hash.js",
        echo   "dependencies": {}
        echo }
    ) > "%SCRIPT_DIR%package.json"
    echo [√] package.json criado
)

REM Verifica se node_modules existe
if exist "%SCRIPT_DIR%node_modules" (
    echo [√] Dependencias ja instaladas
    goto RUN_SCRIPT
)

echo [i] Instalando dependencias...
echo.

REM Instala dependências usando npm portátil
cd /d "%SCRIPT_DIR%"
"%NODE_EXE%" "%NODE_DIR%\node_modules\npm\bin\npm-cli.js" install

if errorlevel 1 (
    echo.
    echo [!] Aviso: Falha ao instalar dependencias via npm
    echo [i] Continuando mesmo assim (dependencias podem nao ser necessarias)
    echo.
) else (
    echo.
    echo [√] Dependencias instaladas
    echo.
)

:RUN_SCRIPT
REM Verifica se o script principal existe
if not exist "%SCRIPT_DIR%recalcular-hash.js" (
    echo [X] Erro: Arquivo recalcular-hash.js nao encontrado
    pause
    exit /b 1
)

REM Executa o script
echo [i] Executando aplicacao...
echo.
echo ═══════════════════════════════════════════
echo.

"%NODE_EXE%" "%SCRIPT_DIR%recalcular-hash.js" %*

echo.
echo ═══════════════════════════════════════════
echo.
pause