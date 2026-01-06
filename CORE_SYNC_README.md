# CORE Module Auto-Sync Documentation

## Overview

This repository includes an automatic synchronization mechanism that keeps the CORE module in sync between the `fibi-test` and `coi` repositories. When changes are committed to the CORE module in `fibi-test`, they are automatically copied to the `coi` repository.

## How It Works

1. **Post-Commit Hook**: A Git post-commit hook (`hooks/post-commit`) monitors every commit in the `fibi-test` repository.

2. **Change Detection**: The hook checks if any files in the `Fibi-Vanilla/FIBI_CORE/` directory were modified in the commit.

3. **Automatic Sync**: If CORE changes are detected, the sync script (`scripts/sync-core-to-coi.sh` or `scripts/sync-core-to-coi.ps1`) is automatically triggered.

4. **File Copying**: The sync script copies all files from `fibi-test/Fibi-Vanilla/FIBI_CORE/` to `coi/DB/CORE/`, preserving the directory structure.

5. **Auto-Commit**: The script automatically commits the changes to the COI repository with a descriptive commit message.

## Setup Instructions

### Prerequisites

1. Both repositories must be cloned at the same directory level:
   ```
   workspace/
   ├── fibi-test/
   └── coi/
   ```

2. The COI repository must be a valid Git repository with a remote configured.

### Installation

#### For Git Bash / Linux / macOS:

1. Make the setup script executable:
   ```bash
   chmod +x setup-hooks.sh
   ```

2. Run the setup script:
   ```bash
   ./setup-hooks.sh
   ```

This will install all hooks including the post-commit hook for CORE synchronization.

#### For Windows PowerShell:

1. The hooks will be automatically installed when you run `setup-hooks.sh` in Git Bash.

2. Alternatively, manually copy the hooks:
   ```powershell
   Copy-Item hooks\post-commit.ps1 .git\hooks\post-commit.ps1
   ```

## Manual Sync

If you need to manually sync the CORE module without making a commit:

### Using Git Bash:
```bash
bash scripts/sync-core-to-coi.sh
```

### Using PowerShell:
```powershell
powershell -ExecutionPolicy Bypass -File scripts\sync-core-to-coi.ps1
```

## How It Works - Detailed Flow

### Scenario: Developer Prabhu commits DB changes in CORE module

1. **Developer commits changes**:
   ```bash
   cd fibi-test
   git add Fibi-Vanilla/FIBI_CORE/DDL/some_table.sql
   git commit -m "Add new table to CORE module"
   ```

2. **Post-commit hook triggers**:
   - Hook detects that files in `FIBI_CORE` were changed
   - Displays notification message

3. **Sync script executes**:
   - Checks if COI repository exists and is accessible
   - Stashes any uncommitted changes in COI repo (if any)
   - Copies all files from `fibi-test/Fibi-Vanilla/FIBI_CORE/` to `coi/DB/CORE/`
   - Checks for differences
   - If changes exist, commits them to COI repository
   - Restores any stashed changes

4. **Result**:
   - Changes are now in both repositories
   - COI repository has a new commit with message: "Auto-sync CORE module from fibi-test"

## Configuration

### Changing Source/Destination Paths

If your directory structure is different, edit the sync script:

**For Bash script** (`scripts/sync-core-to-coi.sh`):
```bash
SOURCE_CORE="$FIBI_TEST_DIR/Fibi-Vanilla/FIBI_CORE"
DEST_CORE="$COI_DIR/DB/CORE"
```

**For PowerShell script** (`scripts/sync-core-to-coi.ps1`):
```powershell
$SourceCore = Join-Path $FibiTestDir "Fibi-Vanilla\FIBI_CORE"
$DestCore = Join-Path $CoiDir "DB\CORE"
```

### Enabling Auto-Push

By default, the sync script does NOT automatically push to the remote repository. To enable auto-push:

1. Open the sync script (`sync-core-to-coi.sh` or `sync-core-to-coi.ps1`)
2. Find the commented section at the end:
   ```bash
   # Optionally push to remote (uncomment if you want auto-push)
   # git push origin "$CURRENT_BRANCH"
   ```
3. Uncomment those lines

**Warning**: Auto-push will push changes immediately after syncing. Make sure you have proper access controls and review processes in place.

## Troubleshooting

### Hook Not Executing

1. **Check if hook is installed**:
   ```bash
   ls -la .git/hooks/post-commit
   ```

2. **Check hook permissions**:
   ```bash
   chmod +x .git/hooks/post-commit
   ```

3. **Verify hook content**:
   ```bash
   cat .git/hooks/post-commit
   ```

### Sync Script Fails

1. **Check COI repository path**:
   - Ensure COI is cloned at the same level as fibi-test
   - Verify the path in the sync script matches your setup

2. **Check Git status in COI**:
   - The script will stash uncommitted changes, but conflicts may occur
   - Manually resolve any conflicts in COI repository

3. **Check file permissions**:
   - Ensure you have read access to fibi-test CORE files
   - Ensure you have write access to COI CORE directory

### "COI repository not found" Error

- Verify that the COI repository is cloned at: `../coi/` relative to fibi-test
- Or update the path in the sync script to match your directory structure

### "Not a Git repository" Error

- Ensure the COI directory is a valid Git repository
- Run `git init` in the COI directory if needed (though this shouldn't be necessary)

## Best Practices

1. **Review Before Committing**: Always review your CORE changes before committing, as they will automatically sync to COI.

2. **Test Changes**: Test your changes in fibi-test before committing to ensure they work correctly.

3. **Commit Messages**: Use descriptive commit messages in fibi-test, as they will be referenced in the COI commit.

4. **Branch Management**: The sync script works on the current branch in COI. Make sure you're on the correct branch before committing in fibi-test.

5. **Backup**: Consider backing up important changes before major syncs.

## Limitations

1. **One-Way Sync**: This is a one-way sync from fibi-test → coi. Changes made directly in COI will not sync back to fibi-test.

2. **No Conflict Resolution**: The script does not handle merge conflicts. If COI has conflicting changes, manual intervention is required.

3. **Branch Awareness**: The script syncs to the current branch in COI. Make sure you're on the correct branch.

4. **Remote Push**: By default, changes are not automatically pushed to remote. You need to push manually or enable auto-push.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the sync script logs/output
3. Contact the repository maintainers

## Example Workflow

```bash
# 1. Developer Prabhu makes changes to CORE module
cd fibi-test
vim Fibi-Vanilla/FIBI_CORE/DDL/new_feature.sql

# 2. Stage and commit changes
git add Fibi-Vanilla/FIBI_CORE/DDL/new_feature.sql
git commit -m "Add new feature to CORE module"

# 3. Post-commit hook automatically triggers
# Output:
# =========================================
# CORE module changes detected!
# Triggering automatic sync to COI repository...
# =========================================
# Starting CORE module synchronization...
# Copying files...
# Committing changes to COI repository...
# Successfully synced CORE module to COI repository

# 4. Changes are now in both repositories
cd ../coi
git log -1
# Shows: "Auto-sync CORE module from fibi-test"
```

