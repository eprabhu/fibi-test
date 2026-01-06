# CORE Module Auto-Sync

## Simple Solution: GitHub Actions

This automatically syncs CORE module changes from `fibi-test` to `coi` repository.

## How It Works

1. You commit and push changes to `Fibi-Vanilla/FIBI_CORE/` using GitHub Desktop
2. GitHub Actions automatically detects the push
3. It copies the CORE files to the COI repository
4. Commits and pushes to COI (visible in GitHub/Chrome)

## Setup (One Time)

1. **Commit the workflow file**:
   - File: `.github/workflows/sync-core-to-coi.yml`
   - Commit and push using GitHub Desktop

2. **Enable Actions** (if needed):
   - Go to: `https://github.com/eprabhu/fibi-test/settings/actions`
   - Under "Workflow permissions", select "Read and write permissions"
   - Save

That's it! Now it works automatically.

## Usage

Just commit and push CORE changes normally using GitHub Desktop. The sync happens automatically.

## Verify

- Go to Actions tab: `https://github.com/eprabhu/fibi-test/actions`
- Check COI repository: `https://github.com/eprabhu/coi`

---

**That's all you need!** Simple and automatic. 🚀

