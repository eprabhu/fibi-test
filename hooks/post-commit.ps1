# PowerShell post-commit hook to automatically sync CORE module changes to COI repository
# This hook is triggered after every commit in fibi-test

# Get the directory where this hook is located
$HookDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent (Split-Path -Parent $HookDir)
$SyncScript = Join-Path $RepoRoot "scripts\sync-core-to-coi.ps1"

# Check if sync script exists
if (-not (Test-Path $SyncScript)) {
    Write-Host "Warning: Sync script not found at $SyncScript"
    exit 0  # Don't fail the commit if sync script is missing
}

# Get the list of files changed in the last commit
$ChangedFiles = git diff-tree --no-commit-id --name-only -r HEAD

# Check if any CORE module files were changed
$CoreChanged = $false
foreach ($file in $ChangedFiles) {
    # Check if file is in FIBI_CORE directory (case-insensitive)
    if ($file -match "FIBI_CORE|Fibi-Vanilla\\FIBI_CORE") {
        $CoreChanged = $true
        break
    }
}

# If CORE module was changed, trigger sync
if ($CoreChanged) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "CORE module changes detected!" -ForegroundColor Yellow
    Write-Host "Triggering automatic sync to COI repository..." -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Get commit message for reference
    $CommitMsg = git log -1 --pretty=format:"%s"
    
    # Run the sync script
    & powershell.exe -ExecutionPolicy Bypass -File $SyncScript $CommitMsg
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "=========================================" -ForegroundColor Cyan
        Write-Host "CORE sync completed successfully!" -ForegroundColor Green
        Write-Host "=========================================" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "=========================================" -ForegroundColor Cyan
        Write-Host "Warning: CORE sync encountered an error" -ForegroundColor Yellow
        Write-Host "You may need to sync manually using:" -ForegroundColor Yellow
        Write-Host "  powershell -ExecutionPolicy Bypass -File $SyncScript" -ForegroundColor Yellow
        Write-Host "=========================================" -ForegroundColor Cyan
        Write-Host ""
    }
}

exit 0  # Always exit successfully to not block the commit

