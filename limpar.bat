@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
echo ╔═════════════════════════════════╗
echo ║            LIMPEZA              ║
echo ║  Recalculador de Hash MD5 XML   ║
echo ╚═════════════════════════════════╝
echo.
set "PROJETO_DIR=%~dp0"
set "NODE_DIR=%PROJETO_DIR%node-portable"
echo [AVISO] Este script irá:
echo   - Remover o Node.js portátil instalado
echo   - Remover o package-lock.json
echo   - Limpar arquivos temporários
echo   - Preparar para uma nova instalação
echo.
echo Arquivos do projeto NÃO serão afetados.
echo.
REM Pedir confirmação
set /p "CONFIRMA=Deseja continuar? (S/N): "
if /i not "%CONFIRMA%"=="S" (
    echo.
    echo Operação cancelada pelo usuário.
    echo.
    pause
    exit /b 0
)
echo.
echo [1/4] Removendo Node.js portátil...
if exist "%NODE_DIR%" (
    echo [INFO] Removendo: %NODE_DIR%
    rmdir /S /Q "%NODE_DIR%" 2>nul
    if exist "%NODE_DIR%" (
        echo [ERRO] Não foi possível remover completamente.
        echo Tente fechar todos os programas e execute novamente.
        pause
        exit /b 1
    )
    echo [OK] Node.js portátil removido!
) else (
    echo [INFO] Node.js portátil não estava instalado.
)
echo.
echo [2/4] Limpando node_modules (se existir)...
if exist "%PROJETO_DIR%node_modules" (
    echo [INFO] Removendo: node_modules
    rmdir /S /Q "%PROJETO_DIR%node_modules" 2>nul
    echo [OK] node_modules removido!
) else (
    echo [INFO] node_modules não encontrado.
)
echo.
echo [3/4] Removendo package-lock.json...
if exist "%PROJETO_DIR%package-lock.json" (
    echo [INFO] Removendo: package-lock.json
    del "%PROJETO_DIR%package-lock.json" 2>nul
    echo [OK] package-lock.json removido!
) else (
    echo [INFO] package-lock.json não encontrado.
)
echo.
echo [4/4] Limpando arquivos temporários...
REM Limpar possíveis arquivos temporários
del "%TEMP%\node-*.zip" 2>nul
if exist "%TEMP%\nodejs-extract" rmdir /S /Q "%TEMP%\nodejs-extract" 2>nul
echo [OK] Limpeza concluída!
echo.
echo ╔══════════════════════╗
echo ║  LIMPEZA CONCLUÍDA   ║
echo ╚══════════════════════╝
echo.
echo Sistema limpo e pronto para reinstalação.
echo.
echo ═══════════════════════════════════════════════════════════
echo.
pause
exit /b 0