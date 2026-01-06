# Quick Start: CORE Module Auto-Sync

## Setup (One-Time)

### Windows (PowerShell):
```powershell
cd fibi-test
powershell -ExecutionPolicy Bypass -File setup-hooks.ps1
```

### Linux/macOS/Git Bash:
```bash
cd fibi-test
chmod +x setup-hooks.sh
./setup-hooks.sh
```

That's it! The auto-sync is now enabled.

## How It Works

When you commit changes to **any file** in `Fibi-Vanilla/FIBI_CORE/`, the system will:

1. ✅ Detect the CORE changes
2. ✅ Automatically copy files to `coi/DB/CORE/`
3. ✅ Commit the changes in COI repository
4. ✅ Show you a success message

## Example

```bash
# Make changes to CORE module
vim Fibi-Vanilla/FIBI_CORE/DDL/my_table.sql

# Commit (sync happens automatically!)
git add Fibi-Vanilla/FIBI_CORE/DDL/my_table.sql
git commit -m "Add new table"

# Output will show:
# =========================================
# CORE module changes detected!
# Triggering automatic sync to COI repository...
# =========================================
# Successfully synced CORE module to COI repository
```

## Manual Sync (If Needed)

```bash
# Git Bash
bash scripts/sync-core-to-coi.sh

# PowerShell
powershell -ExecutionPolicy Bypass -File scripts\sync-core-to-coi.ps1
```

## Requirements

- COI repository must be cloned at: `../coi/` (same level as fibi-test)
- Both repositories must be valid Git repos
- You need write access to COI repository

## Troubleshooting

**Hook not working?**
```bash
chmod +x .git/hooks/post-commit
```

**COI repo not found?**
- Ensure COI is at: `../coi/` relative to fibi-test
- Or update path in `scripts/sync-core-to-coi.sh`

**Need more details?**
See `CORE_SYNC_README.md` for complete documentation.



