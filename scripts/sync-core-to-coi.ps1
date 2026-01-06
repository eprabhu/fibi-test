# PowerShell script to sync CORE module from fibi-test to coi repository
# This script is called by the post-commit hook when CORE changes are detected

# Get the directory where this script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$FibiTestDir = Split-Path -Parent $ScriptDir
$CoiDir = Join-Path (Split-Path -Parent $FibiTestDir) "coi"

# Source and destination paths
$SourceCore = Join-Path $FibiTestDir "Fibi-Vanilla\FIBI_CORE"
$DestCore = Join-Path $CoiDir "DB\CORE"

# Check if COI directory exists
if (-not (Test-Path $CoiDir)) {
    Write-Host "Error: COI repository not found at $CoiDir" -ForegroundColor Red
    Write-Host "Please ensure the COI repository is cloned at the same level as fibi-test"
    exit 1
}

# Check if COI is a git repository
if (-not (Test-Path (Join-Path $CoiDir ".git"))) {
    Write-Host "Error: $CoiDir is not a Git repository" -ForegroundColor Red
    exit 1
}

# Check if source CORE directory exists
if (-not (Test-Path $SourceCore)) {
    Write-Host "Error: Source CORE directory not found at $SourceCore" -ForegroundColor Red
    exit 1
}

Write-Host "Starting CORE module synchronization..." -ForegroundColor Yellow
Write-Host "Source: $SourceCore"
Write-Host "Destination: $DestCore"

# Change to COI directory
Set-Location $CoiDir

# Check if there are uncommitted changes in COI repo
$UncommittedChanges = git status --porcelain
if ($UncommittedChanges) {
    Write-Host "Warning: COI repository has uncommitted changes" -ForegroundColor Yellow
    Write-Host "Stashing changes before sync..."
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    git stash push -m "Auto-stash before CORE sync $Timestamp"
}

# Get current branch
$CurrentBranch = git branch --show-current
if (-not $CurrentBranch) {
    # Try to checkout main or master
    $MainBranch = git branch -a | Select-String -Pattern "main|master" | Select-Object -First 1
    if ($MainBranch) {
        $BranchName = ($MainBranch -split "/")[-1].Trim()
        git checkout $BranchName
        $CurrentBranch = $BranchName
    } else {
        Write-Host "Error: Could not determine branch to use" -ForegroundColor Red
        exit 1
    }
}

# Create destination directory if it doesn't exist
if (-not (Test-Path $DestCore)) {
    New-Item -ItemType Directory -Path $DestCore -Force | Out-Null
}

# Copy all files from source to destination, preserving directory structure
Write-Host "Copying files..."
Get-ChildItem -Path $SourceCore -Recurse -File | ForEach-Object {
    $RelativePath = $_.FullName.Substring($SourceCore.Length + 1)
    $DestPath = Join-Path $DestCore $RelativePath
    $DestDir = Split-Path -Parent $DestPath
    if (-not (Test-Path $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }
    Copy-Item $_.FullName -Destination $DestPath -Force
}

# Remove files in destination that don't exist in source
Get-ChildItem -Path $DestCore -Recurse -File | ForEach-Object {
    $RelativePath = $_.FullName.Substring($DestCore.Length + 1)
    $SourcePath = Join-Path $SourceCore $RelativePath
    if (-not (Test-Path $SourcePath)) {
        Remove-Item $_.FullName -Force
    }
}

# Check if there are any changes to commit
$CoreChanges = git status --porcelain DB/CORE
if (-not $CoreChanges) {
    Write-Host "No changes detected in CORE module. Already in sync." -ForegroundColor Green
    # Restore stashed changes if any
    $StashList = git stash list
    if ($StashList -match "Auto-stash before CORE sync") {
        git stash pop
    }
    exit 0
}

# Get commit message
$CommitMsg = "Sync CORE module from fibi-test"
if ($args.Count -gt 0) {
    $CommitMsg = $args[0]
}

# Get the latest commit info from fibi-test
Set-Location $FibiTestDir
$LastCommit = git log -1 --pretty=format:"%h - %s (%an, %ar)"
Set-Location $CoiDir

# Add all CORE changes
git add DB/CORE/

# Commit the changes
Write-Host "Committing changes to COI repository..."
$FullCommitMsg = "Auto-sync CORE module from fibi-test

Source commit: $LastCommit
Synced by: $env:USERNAME at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Triggered by: Automatic sync from fibi-test repository"

git commit -m $FullCommitMsg
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to commit changes" -ForegroundColor Red
    exit 1
}

Write-Host "Successfully synced CORE module to COI repository" -ForegroundColor Green
Write-Host "Commit created in COI repository on branch: $CurrentBranch"

# Restore stashed changes if any
$StashList = git stash list
if ($StashList -match "Auto-stash before CORE sync") {
    Write-Host "Restoring stashed changes..."
    git stash pop
}

# Optionally push to remote (uncomment if you want auto-push)
# Write-Host "Pushing to remote..."
# git push origin $CurrentBranch
# if ($LASTEXITCODE -ne 0) {
#     Write-Host "Warning: Failed to push to remote. You may need to push manually." -ForegroundColor Yellow
# }

exit 0



