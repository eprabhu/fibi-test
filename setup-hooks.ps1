# PowerShell script to install Git hooks on Windows
# This ensures hooks work properly on Windows Git

Write-Host "Installing Git hooks..." -ForegroundColor Cyan

# Check if .git/hooks directory exists
if (-not (Test-Path ".git\hooks")) {
    Write-Host "Error: .git/hooks directory not found. Are you in a Git repository?" -ForegroundColor Red
    exit 1
}

# Check if hooks directory exists
if (-not (Test-Path "hooks")) {
    Write-Host "Warning: hooks directory not found" -ForegroundColor Yellow
    exit 1
}

# Copy hooks
$hooksInstalled = $false

# Copy post-commit hook (Windows batch file)
if (Test-Path "hooks\post-commit.bat") {
    Copy-Item "hooks\post-commit.bat" ".git\hooks\post-commit.bat" -Force
    Copy-Item "hooks\post-commit.bat" ".git\hooks\post-commit" -Force
    $hooksInstalled = $true
    Write-Host "✓ Post-commit hook installed (Windows batch)" -ForegroundColor Green
}

# Copy PowerShell post-commit hook as backup
if (Test-Path "hooks\post-commit.ps1") {
    Copy-Item "hooks\post-commit.ps1" ".git\hooks\post-commit.ps1" -Force
    Write-Host "✓ PowerShell post-commit hook installed (backup)" -ForegroundColor Green
}

# Copy bash post-commit hook (for Git Bash users)
if (Test-Path "hooks\post-commit") {
    Copy-Item "hooks\post-commit" ".git\hooks\post-commit.sh" -Force
    Write-Host "✓ Bash post-commit hook installed (for Git Bash)" -ForegroundColor Green
}

if ($hooksInstalled) {
    Write-Host ""
    Write-Host "CORE Module Auto-Sync is now enabled!" -ForegroundColor Green
    Write-Host "Changes to Fibi-Vanilla/FIBI_CORE/ will automatically sync to coi/DB/CORE/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "For more information, see: CORE_SYNC_README.md" -ForegroundColor Yellow
} else {
    Write-Host "Warning: No hooks were found to install" -ForegroundColor Yellow
}

