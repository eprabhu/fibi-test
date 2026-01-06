@echo off
REM Wrapper script to ensure hook executes properly
REM This file should be copied to .git/hooks/post-commit

REM Log hook execution (for debugging)
echo [HOOK] Post-commit hook executed at %date% %time% >> "%TEMP%\git-hook-log.txt"

REM Call the actual hook script
call "%~dp0post-commit.bat"

exit /b %errorlevel%

