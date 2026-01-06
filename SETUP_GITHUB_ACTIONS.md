# Setup Guide: GitHub Actions for CORE Sync

## Quick Start

### Step 1: Commit and Push the Workflow

1. **Open GitHub Desktop**
2. You should see these new files:
   - `.github/workflows/sync-core-to-coi.yml`
   - `.github/workflows/README.md`
   - `GITHUB_DESKTOP_SOLUTION.md`
3. **Commit** with message: "Add GitHub Actions workflow for automatic CORE sync"
4. **Push** to GitHub

### Step 2: Enable GitHub Actions (If Not Already Enabled)

1. Go to: `https://github.com/eprabhu/fibi-test`
2. Click **Settings** → **Actions** → **General**
3. Under "Workflow permissions", select:
   - ✅ **Read and write permissions**
   - ✅ **Allow GitHub Actions to create and approve pull requests**
4. Click **Save**

### Step 3: Test It!

1. **Make a change** to any file in `Fibi-Vanilla/FIBI_CORE/`
   - Example: Edit `Fibi-Vanilla/FIBI_CORE/CONF/arg_value_lookup.sql`
2. **Commit** in GitHub Desktop
3. **Push** in GitHub Desktop
4. **Go to Actions tab**: `https://github.com/eprabhu/fibi-test/actions`
5. **Watch the workflow run** - it should complete in ~30 seconds
6. **Check COI repository**: `https://github.com/eprabhu/coi`
   - You should see a new commit: "Auto-sync CORE module from fibi-test"

## How It Works

```
You Push (GitHub Desktop)
    ↓
GitHub Actions Triggered
    ↓
Checks: CORE files changed?
    ↓ YES
Syncs to COI Repository
    ↓
Commits & Pushes to COI
    ↓
✅ Visible in GitHub/Chrome!
```

## Troubleshooting

### Workflow Not Running

**Check:**
1. Go to Actions tab: `https://github.com/eprabhu/fibi-test/actions`
2. Is the workflow file committed and pushed?
3. Are you pushing to `main` or `master` branch?

**Fix:**
- Ensure workflow file is in `.github/workflows/` directory
- Commit and push the workflow file
- Make sure you're on main/master branch

### Permission Errors

**Error:** "Permission denied" or "Resource not accessible"

**Fix:**
1. Go to Repository Settings → Actions → General
2. Under "Workflow permissions":
   - Select "Read and write permissions"
   - Check "Allow GitHub Actions to create and approve pull requests"
3. Save changes

**If still failing:**
- You may need to create a Personal Access Token (PAT)
- See "Advanced Setup" below

### Sync Not Happening

**Check:**
1. Did you change files in `Fibi-Vanilla/FIBI_CORE/`?
2. Check Actions logs for errors
3. Verify COI repository exists: `https://github.com/eprabhu/coi`

**Fix:**
- Workflow only runs if CORE files are changed
- Check the workflow logs in Actions tab
- Ensure COI repository is accessible

## Advanced Setup (If Needed)

### Using Personal Access Token (PAT)

If `GITHUB_TOKEN` doesn't have permission to push to COI:

1. **Create PAT:**
   - Go to: `https://github.com/settings/tokens`
   - Click "Generate new token (classic)"
   - Name: "COI Sync Token"
   - Scopes: Select `repo` (full control)
   - Generate and copy the token

2. **Add as Secret:**
   - Go to: `https://github.com/eprabhu/fibi-test/settings/secrets/actions`
   - Click "New repository secret"
   - Name: `COI_SYNC_TOKEN`
   - Value: Paste your PAT
   - Add secret

3. **Update Workflow:**
   - Edit `.github/workflows/sync-core-to-coi.yml`
   - Change `token: ${{ secrets.GITHUB_TOKEN }}` to `token: ${{ secrets.COI_SYNC_TOKEN }}`
   - Commit and push

## Verification Checklist

- [ ] Workflow file committed and pushed
- [ ] Actions tab shows the workflow
- [ ] Made a test change to CORE
- [ ] Pushed the change
- [ ] Workflow ran successfully
- [ ] Changes appear in COI repository

## What Gets Synced

**Source:** `fibi-test/Fibi-Vanilla/FIBI_CORE/`  
**Destination:** `coi/DB/CORE/`

All files and subdirectories are synced:
- DDL/
- DML/
- CONF/
- CONF_LOOKUP/
- All YAML files
- All SQL files

## Workflow Details

- **Trigger:** Push to main/master branch
- **Condition:** Only if CORE files changed
- **Runs on:** Ubuntu (GitHub Actions runner)
- **Duration:** ~30-60 seconds
- **Cost:** Free for public repos, included in GitHub Free plan

## Benefits

✅ Works with GitHub Desktop  
✅ Automatic on every push  
✅ No local setup required  
✅ Works for entire team  
✅ Visible in Actions tab  
✅ Pushes to remote (visible in Chrome)  

## Support

If you encounter issues:
1. Check Actions tab for error logs
2. Verify workflow file syntax
3. Check repository permissions
4. See `GITHUB_DESKTOP_SOLUTION.md` for more details

---

**Ready to go!** Just commit and push the workflow file, then test with a CORE change! 🚀

