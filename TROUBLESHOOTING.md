# Troubleshooting CORE Sync Issues

## Issue: Changes not syncing to COI repository

### Quick Fix

1. **Reinstall the hooks** (Windows):
   ```powershell
   cd fibi-test
   powershell -ExecutionPolicy Bypass -File setup-hooks.ps1
   ```

2. **Or manually copy the hook**:
   ```powershell
   Copy-Item hooks\post-commit.bat .git\hooks\post-commit -Force
   ```

3. **Test the sync manually**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\sync-core-to-coi.ps1
   ```

### Common Issues and Solutions

#### 1. Hook Not Executing

**Symptoms**: Commits complete but no sync happens

**Check**:
```powershell
# Verify hook exists
Test-Path .git\hooks\post-commit

# Check hook content
Get-Content .git\hooks\post-commit -First 5
```

**Solution**:
- Reinstall hooks using `setup-hooks.ps1`
- Ensure you're using Windows Git (not Git Bash for commits)
- Check if hook has execute permissions

#### 2. PowerShell Execution Policy Error

**Symptoms**: Error about execution policy when hook runs

**Solution**:
```powershell
# Set execution policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### 3. COI Repository Not Found

**Symptoms**: Error "COI repository not found"

**Check**:
```powershell
# Verify COI is at correct location
Test-Path ..\coi\.git
```

**Solution**:
- Ensure COI is cloned at same level as fibi-test:
  ```
  workspace/
  ├── fibi-test/
  └── coi/
  ```
- Or update path in `scripts/sync-core-to-coi.ps1`

#### 4. Sync Script Fails Silently

**Symptoms**: Hook runs but sync doesn't happen

**Debug**:
```powershell
# Run sync manually with verbose output
powershell -ExecutionPolicy Bypass -File scripts\sync-core-to-coi.ps1

# Check COI repository status
cd ..\coi
git status
git log -1
```

**Solution**:
- Check for merge conflicts in COI
- Ensure you have write permissions to COI
- Check if COI has uncommitted changes blocking the sync

#### 5. Hook is Bash Script on Windows

**Symptoms**: Hook file exists but doesn't execute (bash script on Windows)

**Solution**:
- Use the Windows batch file hook: `hooks\post-commit.bat`
- Reinstall using `setup-hooks.ps1` which installs the correct hook for Windows

### Testing the Hook

1. **Make a test change**:
   ```powershell
   cd fibi-test
   # Create a test file in CORE
   echo "test" > Fibi-Vanilla\FIBI_CORE\test_sync.txt
   git add Fibi-Vanilla\FIBI_CORE\test_sync.txt
   git commit -m "Test CORE sync"
   ```

2. **Check output**: You should see sync messages

3. **Verify in COI**:
   ```powershell
   cd ..\coi
   git log -1
   # Should show "Auto-sync CORE module from fibi-test"
   ```

### Manual Sync (If Hook Fails)

If the hook doesn't work, you can sync manually:

```powershell
cd fibi-test
powershell -ExecutionPolicy Bypass -File scripts\sync-core-to-coi.ps1
```

### Debug Mode

To see what's happening, check:

1. **Git hook output**: Look at commit output for sync messages
2. **COI repository**: Check if commits are being created
3. **Sync script logs**: Run manually to see detailed output

### Still Not Working?

1. Check Git version: `git --version`
2. Verify both repos are valid Git repos: `git status` in both
3. Check file paths match your structure
4. Review the sync script for path issues
5. Try running sync script manually to see specific errors

