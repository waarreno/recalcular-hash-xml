@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ===============================================
echo   RECALCULADOR DE HASH MD5 PARA PTU XML
echo ===============================================
echo.

REM Define diretorios
set "SCRIPT_DIR=%~dp0"
set "NODE_DIR=%SCRIPT_DIR%node-portable"
set "NODE_EXE=%NODE_DIR%\node.exe"
set "NPM_CMD=%NODE_DIR%\npm.cmd"
set "NODE_VERSION=22.11.0"
set "NODE_DOWNLOAD=https://nodejs.org/dist/v%NODE_VERSION%/node-v%NODE_VERSION%-win-x64.zip"
set "NODE_ZIP=%SCRIPT_DIR%node-portable.zip"

REM Verifica se Node.js portavel ja existe
if exist "%NODE_EXE%" (
    echo [OK] Node.js portavel encontrado
    goto CHECK_DEPENDENCIES
)

echo [INFO] Node.js portavel nao encontrado
echo [INFO] Baixando Node.js v%NODE_VERSION% portatil...
echo.

REM Baixa Node.js usando PowerShell
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; Write-Host '[...] Baixando Node.js...'; try { Invoke-WebRequest -Uri '%NODE_DOWNLOAD%' -OutFile '%NODE_ZIP%' -UseBasicParsing; Write-Host '[OK] Download concluido'; } catch { Write-Host '[ERRO] Erro no download: ' $_.Exception.Message; exit 1 } }"

if errorlevel 1 (
    echo.
    echo [ERRO] Falha ao baixar Node.js
    pause
    exit /b 1
)

if not exist "%NODE_ZIP%" (
    echo [ERRO] Arquivo de download nao encontrado
    pause
    exit /b 1
)

echo [INFO] Extraindo Node.js...

REM Extrai o arquivo ZIP usando PowerShell
powershell -Command "& { $ProgressPreference = 'SilentlyContinue'; Write-Host '[...] Extraindo arquivos...'; try { Expand-Archive -Path '%NODE_ZIP%' -DestinationPath '%SCRIPT_DIR%temp-node' -Force; Write-Host '[OK] Extracao concluida'; } catch { Write-Host '[ERRO] Erro na extracao: ' $_.Exception.Message; exit 1 } }"

if errorlevel 1 (
    echo [ERRO] Falha ao extrair Node.js
    del "%NODE_ZIP%" 2>nul
    pause
    exit /b 1
)

REM Move os arquivos da subpasta para o diretorio node-portable
echo [INFO] Organizando arquivos...
if exist "%SCRIPT_DIR%temp-node\node-v%NODE_VERSION%-win-x64" (
    move "%SCRIPT_DIR%temp-node\node-v%NODE_VERSION%-win-x64" "%NODE_DIR%" >nul
) else (
    REM Caso a estrutura seja diferente, move o primeiro diretorio encontrado
    for /d %%i in ("%SCRIPT_DIR%temp-node\*") do (
        move "%%i" "%NODE_DIR%" >nul
        goto MOVE_DONE
    )
)
:MOVE_DONE

REM Limpa arquivos temporarios
rmdir /s /q "%SCRIPT_DIR%temp-node" 2>nul
del "%NODE_ZIP%" 2>nul

if not exist "%NODE_EXE%" (
    echo [ERRO] Node.exe nao encontrado apos extracao
    pause
    exit /b 1
)

echo [OK] Node.js portatil instalado com sucesso
echo.

:CHECK_DEPENDENCIES
REM Verifica se o package.json existe
if not exist "%SCRIPT_DIR%package.json" (
    echo [INFO] Criando package.json...
    (
        echo {
        echo   "name": "recalcular-hash-xml",
        echo   "version": "1.0.0",
        echo   "description": "Recalculador de hash MD5 para arquivos XML TISS",
        echo   "main": "src/recalcular-hash.js",
        echo   "dependencies": {}
        echo }
    ) > "%SCRIPT_DIR%package.json"
    echo [OK] package.json criado
)

REM Verifica se node_modules existe
if exist "%SCRIPT_DIR%node_modules" (
    echo [OK] Dependencias ja instaladas
    goto RUN_SCRIPT
)

echo [INFO] Instalando dependencias...
echo.

REM Instala dependencias usando npm portatil
cd /d "%SCRIPT_DIR%"
"%NODE_EXE%" "%NODE_DIR%\node_modules\npm\bin\npm-cli.js" install

if errorlevel 1 (
    echo.
    echo [AVISO] Falha ao instalar dependencias via npm
    echo [INFO] Continuando mesmo assim - dependencias podem nao ser necessarias
    echo.
) else (
    echo.
    echo [OK] Dependencias instaladas
    echo.
)

:RUN_SCRIPT
REM Verifica se o script principal existe
if not exist "%SCRIPT_DIR%src\recalcular-hash.js" (
    echo [ERRO] Arquivo src\recalcular-hash.js nao encontrado
    echo.
    echo Certifique-se de que a estrutura do projeto esta correta:
    echo   - src\recalcular-hash.js
    echo   - package.json
    echo.
    pause
    exit /b 1
)

REM Executa o script
echo [INFO] Executando aplicacao...
echo.
echo ===============================================
echo.

"%NODE_EXE%" "%SCRIPT_DIR%src\recalcular-hash.js" %*

echo.
echo ===============================================
echo.
pause