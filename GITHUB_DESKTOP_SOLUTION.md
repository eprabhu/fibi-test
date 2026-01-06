# Solution for GitHub Desktop Users

## Problem

**GitHub Desktop does NOT execute Git hooks** on Windows. This means the automatic sync hook won't work when you commit using GitHub Desktop.

## Solution: GitHub Actions Workflow


## How It Works

1. ✅ You commit and push using GitHub Desktop
2. ✅ GitHub Actions detects the push
3. ✅ Checks if CORE files were changed
4. ✅ Automatically syncs to COI repository
5. ✅ Pushes changes to COI remote (visible in Chrome/GitHub)

## Setup Instructions

### Step 1: Commit and Push the Workflow File

The workflow file is already created at:
```
.github/workflows/sync-core-to-coi.yml
```

**In GitHub Desktop:**
1. You should see the new workflow file in your changes
2. Commit it with message: "Add GitHub Actions workflow for CORE sync"
3. Push to GitHub

### Step 2: Verify Workflow is Active

1. Go to your GitHub repository in Chrome: `https://github.com/eprabhu/fibi-test`
2. Click on the **"Actions"** tab
3. You should see the workflow listed: "Sync CORE Module to COI"

### Step 3: Test It

1. **Make a change** to any file in `Fibi-Vanilla/FIBI_CORE/`
2. **Commit** using GitHub Desktop
3. **Push** using GitHub Desktop
4. **Go to Actions tab** - you'll see the workflow running
5. **Check COI repository** in Chrome - changes will appear there!

## What Happens When You Push

```
Your Push (GitHub Desktop)
    ↓
GitHub Actions Detects Push
    ↓
Checks: Did CORE files change?
    ↓ YES
Syncs Files to COI Repository
    ↓
Commits in COI Repository
    ↓
Pushes to COI Remote
    ↓
✅ Visible in Chrome/GitHub!
```

## Advantages

✅ **Works with GitHub Desktop** - No hooks needed!  
✅ **Automatic** - Happens on every push  
✅ **Visible** - See it running in Actions tab  
✅ **Remote Sync** - Pushes to GitHub (visible in Chrome)  
✅ **Team-Wide** - Works for everyone  
✅ **No Local Setup** - Just push the workflow file  

## Manual Sync (If Needed)

If you need to sync manually before pushing:

### Option 1: PowerShell Script (Local)
```powershell
cd D:\GIT-workspace\test\fibi-test
powershell -ExecutionPolicy Bypass -File scripts\sync-core-to-coi.ps1
cd ..\coi
git push origin main
```

### Option 2: GitHub Actions (Automatic)
Just push your changes - GitHub Actions will handle it!

## Troubleshooting

### Workflow Not Running

1. **Check Actions Tab**: Go to `https://github.com/eprabhu/fibi-test/actions`
2. **Verify Workflow File**: Ensure `.github/workflows/sync-core-to-coi.yml` exists
3. **Check Branch**: Workflow only runs on `main` or `master` branch

### Sync Not Happening

1. **Check if CORE files changed**: Workflow only runs if `Fibi-Vanilla/FIBI_CORE/**` files changed
2. **Check Actions Logs**: Click on the workflow run to see detailed logs
3. **Verify COI Repository**: Ensure `eprabhu/coi` repository exists and is accessible

### Permission Errors

- The workflow uses `GITHUB_TOKEN` which should have access
- If you get permission errors, you may need to:
  1. Go to Repository Settings → Actions → General
  2. Under "Workflow permissions", ensure "Read and write permissions" is selected

## Workflow File Location

The workflow is at:
```
fibi-test/.github/workflows/sync-core-to-coi.yml
```

## Next Steps

1. ✅ **Commit the workflow file** (if not already committed)
2. ✅ **Push to GitHub** using GitHub Desktop
3. ✅ **Make a test change** to CORE and push
4. ✅ **Watch it sync automatically** in Actions tab
5. ✅ **Verify in COI repository** (Chrome/GitHub)

## Summary

**Before**: Git hooks (didn't work with GitHub Desktop)  
**Now**: GitHub Actions (works perfectly with GitHub Desktop!)

Just commit and push - the sync happens automatically! 🎉

