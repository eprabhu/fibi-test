@echo off
REM Windows batch file wrapper for post-commit hook
REM This ensures the hook works on Windows Git

setlocal enabledelayedexpansion

REM Get the directory where this hook is located
set "HOOK_DIR=%~dp0"
set "REPO_ROOT=%HOOK_DIR%..\.."
set "SYNC_SCRIPT=%REPO_ROOT%\scripts\sync-core-to-coi.ps1"

REM Check if sync script exists
if not exist "%SYNC_SCRIPT%" (
    echo Warning: Sync script not found at %SYNC_SCRIPT%
    exit /b 0
)

REM Get the list of files changed in the last commit
git diff-tree --no-commit-id --name-only -r HEAD > "%TEMP%\git_changed_files.txt"

REM Check if any CORE module files were changed
set "CORE_CHANGED=0"
for /f "delims=" %%f in ('type "%TEMP%\git_changed_files.txt"') do (
    echo %%f | findstr /i "FIBI_CORE" >nul
    if !errorlevel! equ 0 (
        set "CORE_CHANGED=1"
        goto :found
    )
)

:found
del "%TEMP%\git_changed_files.txt" 2>nul

REM If CORE module was changed, trigger sync
if "!CORE_CHANGED!"=="1" (
    echo.
    echo =========================================
    echo CORE module changes detected!
    echo Triggering automatic sync to COI repository...
    echo =========================================
    echo.
    
    REM Get commit message for reference
    for /f "delims=" %%m in ('git log -1 --pretty=format:"%%s"') do set "COMMIT_MSG=%%m"
    
    REM Run the sync script using PowerShell
    powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%SYNC_SCRIPT%" "!COMMIT_MSG!"
    
    if !errorlevel! equ 0 (
        echo.
        echo =========================================
        echo CORE sync completed successfully!
        echo =========================================
        echo.
    ) else (
        echo.
        echo =========================================
        echo Warning: CORE sync encountered an error
        echo You may need to sync manually using:
        echo   powershell -ExecutionPolicy Bypass -File "%SYNC_SCRIPT%"
        echo =========================================
        echo.
    )
)

endlocal
exit /b 0

