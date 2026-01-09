# Sync Configuration

This directory contains the configuration file for the sync workflows between `fibi-test` and `coi` repositories.

## Configuration File

**File**: `sync-config.yml`

This YAML file centralizes all configuration settings for the sync workflows, making it easy to manage:

- Repository names and branches
- Git access tokens (secret names)
- Destination directory paths
- Branch naming conventions
- PR labels and titles
- Email notification settings
- Exclusion rules

## Usage

The configuration is automatically loaded by the sync scripts using the `load-config.sh` helper script. All scripts source this configuration at the beginning to get the required settings.

## Configuration Structure

### Repositories
```yaml
repositories:
  source:
    name: "eprabhu/fibi-test"
    default_branch: "main"
  
  destination:
    name: "eprabhu/coi"
    default_branch: "main"
```

### Git Configuration
```yaml
git:
  access_token_secret: "GH_COI_PUSH_TOKEN"  # Secret name in GitHub Secrets
  user:
    name: "github-actions[bot]"
    email: "github-actions[bot]@users.noreply.github.com"
```

### Branch Configuration
```yaml
branches:
  feature_branch_prefix: "Fibi-Dev"
  categories:
    incremental_sync: "core-sync"
    full_sync: "full-core-sync"
```

### Sync Paths
```yaml
sync_paths:
  destination_directories:
    core: "DB/CORE"
    routines: "DB/ROUTINES/CORE"
```

## How to Modify Configuration

1. Edit the `sync-config.yml` file
2. Commit and push the changes
3. The next workflow run will automatically use the new configuration

## Important Notes

- **Git Token**: The `access_token_secret` value should match the secret name in your GitHub repository settings (Settings → Secrets and variables → Actions)
- **Branch Names**: Changes to branch naming will affect how feature branches are created
- **Paths**: Changes to destination directories will affect where files are synced

## Example Configuration Values

- **Source Repository**: `eprabhu/fibi-test`
- **Destination Repository**: `eprabhu/coi`
- **Source Branch**: `main` (or current branch)
- **Destination Branch**: `main` (target for PRs)
- **Git Access Token Secret**: `GH_COI_PUSH_TOKEN`
- **Destination Core Directory**: `DB/CORE`
- **Destination Routines Directory**: `DB/ROUTINES/CORE`

