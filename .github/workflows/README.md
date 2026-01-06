# GitHub Actions Workflow: CORE Sync

## Overview

This GitHub Actions workflow automatically syncs CORE module changes from `fibi-test` to `coi` repository when you push changes using GitHub Desktop.

## How It Works

1. **Trigger**: When you push to `main` or `master` branch
2. **Detection**: Checks if any files in `Fibi-Vanilla/FIBI_CORE/` were changed
3. **Sync**: If CORE files changed, copies them to `coi/DB/CORE/`
4. **Commit**: Creates a commit in COI repository
5. **Push**: Pushes changes to COI remote repository

## Setup

### Step 1: Ensure Workflow File Exists

The workflow file should be at:
```
.github/workflows/sync-core-to-coi.yml
```

### Step 2: Push the Workflow File

1. Commit the workflow file to your repository
2. Push to GitHub using GitHub Desktop

### Step 3: Verify It Works

1. Make a change to any file in `Fibi-Vanilla/FIBI_CORE/`
2. Commit and push using GitHub Desktop
3. Go to the "Actions" tab in GitHub
4. You should see the workflow running
5. Check the COI repository - changes should appear there

## Workflow Details

- **Runs on**: Ubuntu (GitHub Actions runner)
- **Trigger**: Push to main/master branch
- **Only runs if**: CORE files (`Fibi-Vanilla/FIBI_CORE/**`) are changed
- **Permissions**: Uses `GITHUB_TOKEN` (automatically provided)

## Troubleshooting

### Workflow Not Running

1. Check if workflow file is in `.github/workflows/` directory
2. Ensure workflow file is committed and pushed
3. Check GitHub Actions tab for any errors

### Sync Not Happening

1. Verify CORE files were actually changed in your commit
2. Check Actions tab for workflow logs
3. Ensure COI repository exists and is accessible

### Permission Errors

- The workflow uses `GITHUB_TOKEN` which has permissions to your repositories
- If you get permission errors, you may need to add a Personal Access Token (PAT) as a secret

## Advantages Over Git Hooks

✅ Works with GitHub Desktop  
✅ Works with any Git client  
✅ Syncs to remote automatically  
✅ Visible in GitHub Actions tab  
✅ No local setup required  
✅ Works for all team members  

## Manual Sync (If Needed)

If you need to sync manually:

```powershell
cd fibi-test
powershell -ExecutionPolicy Bypass -File scripts\sync-core-to-coi.ps1
cd ..\coi
git push origin main
```

