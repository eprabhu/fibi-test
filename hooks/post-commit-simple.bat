@echo off
REM Simple post-commit hook for Windows Git
REM This version is more reliable for Git execution

setlocal enabledelayedexpansion

REM Change to repository root
cd /d "%~dp0..\.."

REM Get changed files from last commit
git diff-tree --no-commit-id --name-only -r HEAD > "%TEMP%\core_check.txt" 2>nul

REM Check if CORE files were changed
findstr /i "FIBI_CORE" "%TEMP%\core_check.txt" >nul
if errorlevel 1 (
    del "%TEMP%\core_check.txt" 2>nul
    exit /b 0
)

REM CORE files were changed - trigger sync
echo.
echo =========================================
echo CORE module changes detected!
echo Triggering automatic sync to COI repository...
echo =========================================
echo.

REM Run sync script
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "scripts\sync-core-to-coi.ps1"

if errorlevel 1 (
    echo.
    echo Warning: Sync failed. Run manually: powershell -ExecutionPolicy Bypass -File scripts\sync-core-to-coi.ps1
    echo.
)

del "%TEMP%\core_check.txt" 2>nul
exit /b 0

