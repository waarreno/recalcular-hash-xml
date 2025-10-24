@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ==================================================
echo                LIMPEZA DO SISTEMA
echo           Recalculador de Hash MD5 XML
echo   (c) 2025 Wárreno Hendrick Costa Lima Guimarães
echo ==================================================
echo.

set "PROJETO_DIR=%~dp0"
set "NODE_DIR=%PROJETO_DIR%node-portable"

echo [AVISO] Este script ira:
echo   - Remover o Node.js portatil instalado
echo   - Remover o package-lock.json
echo   - Limpar arquivos temporarios
echo   - Preparar para uma nova instalacao
echo.
echo Arquivos do projeto NAO serao afetados.
echo.

REM Pedir confirmacao
set /p "CONFIRMA=Deseja continuar? (S/N): "
if /i not "%CONFIRMA%"=="S" (
    echo.
    echo Operacao cancelada pelo usuario.
    echo.
    pause
    exit /b 0
)

echo.
echo [1/4] Removendo Node.js portatil...
if exist "%NODE_DIR%" (
    echo [INFO] Removendo: %NODE_DIR%
    rmdir /S /Q "%NODE_DIR%" 2>nul
    if exist "%NODE_DIR%" (
        echo [ERRO] Nao foi possivel remover completamente.
        echo Tente fechar todos os programas e execute novamente.
        pause
        exit /b 1
    )
    echo [OK] Node.js portatil removido!
) else (
    echo [INFO] Node.js portatil nao encontrado ou ja removido.
)

echo.
echo [2/4] Limpando node_modules - se existir...
if exist "%PROJETO_DIR%node_modules" (
    echo [INFO] Removendo: node_modules
    rmdir /S /Q "%PROJETO_DIR%node_modules" 2>nul
    echo [OK] node_modules removido!
) else (
    echo [INFO] node_modules nao encontrado ou ja removido.
)

echo.
echo [3/4] Removendo package-lock.json...
if exist "%PROJETO_DIR%package-lock.json" (
    echo [INFO] Removendo: package-lock.json
    del "%PROJETO_DIR%package-lock.json" 2>nul
    echo [OK] package-lock.json removido!
) else (
    echo [INFO] package-lock.json nao encontrado ou ja removido.
)

echo.
echo [4/4] Limpando arquivos temporarios...
REM Limpar possiveis arquivos temporarios
del "%TEMP%\node-*.zip" 2>nul
if exist "%TEMP%\nodejs-extract" rmdir /S /Q "%TEMP%\nodejs-extract" 2>nul
echo [OK] Limpeza concluida!

echo.
echo ==================================================
echo           LIMPEZA CONCLUIDA COM SUCESSO
echo ==================================================
echo.
echo Sistema limpo e pronto para reinstalacao.
echo.
echo ==================================================
echo.
pause
exit /b 0