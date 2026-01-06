# Troubleshooting GitHub Actions Sync

## If Actions Not Running

### 1. Check Actions Tab
Go to: `https://github.com/eprabhu/fibi-test/actions`

- Do you see the workflow listed?
- Do you see any runs?
- Any error messages?

### 2. Enable Actions (If Not Enabled)
1. Go to: `https://github.com/eprabhu/fibi-test/settings/actions`
2. Under "Actions permissions":
   - Select "Allow all actions and reusable workflows"
3. Under "Workflow permissions":
   - Select "Read and write permissions"
   - Check "Allow GitHub Actions to create and approve pull requests"
4. Click **Save**

### 3. Check Workflow File
- File must be at: `.github/workflows/sync-core-to-coi.yml`
- Must be committed and pushed
- Check: `git ls-files .github/workflows/`

### 4. Check Branch
- Workflow only runs on `main` or `master` branch
- Make sure you're pushing to the correct branch

### 5. Check File Paths
- Workflow only runs if files in `Fibi-Vanilla/FIBI_CORE/**` are changed
- If you changed other files, workflow won't run

## Manual Test

1. Make a small change to: `Fibi-Vanilla/FIBI_CORE/CONF/arg_value_lookup.sql`
2. Commit and push
3. Check Actions tab - should see workflow running
4. Wait ~30 seconds
5. Check COI repository - changes should be there

## Common Issues

### "Workflow not found"
- Workflow file not committed/pushed
- Fix: Commit and push `.github/workflows/sync-core-to-coi.yml`

### "Permission denied"
- Actions permissions not set
- Fix: Enable "Read and write permissions" in Settings → Actions

### "No changes detected"
- Files already synced
- Or workflow didn't detect CORE changes
- Check: Did you change files in `Fibi-Vanilla/FIBI_CORE/`?

### Workflow runs but no sync
- Check workflow logs in Actions tab
- Look for error messages
- Verify COI repository exists and is accessible

## Quick Fix

1. **Re-commit workflow file**:
   ```bash
   git add .github/workflows/sync-core-to-coi.yml
   git commit -m "Fix workflow"
   git push
   ```

2. **Enable Actions** (see step 2 above)

3. **Test with a CORE change**

## Still Not Working?

Check the Actions tab for specific error messages. The logs will tell you exactly what's wrong.

