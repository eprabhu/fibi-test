# PAT Token Setup Guide

## Creating PAT Token

1. **Go to GitHub Settings**:
   - `https://github.com/settings/tokens`
   - Click "Generate new token (classic)"

2. **Configure Token**:
   - **Note**: `COI Sync Token` (or any name you prefer)
   - **Expiration**: Choose your preference (90 days, 1 year, or no expiration)
   - **Scopes**: Check these boxes:
     - ✅ `repo` (Full control of private repositories)
       - This includes: repo:status, repo_deployment, public_repo, repo:invite, security_events

3. **Generate Token**:
   - Click "Generate token"
   - **IMPORTANT**: Copy the token immediately (you won't see it again!)

## Adding Token as Secret

1. **Go to Repository Settings**:
   - `https://github.com/eprabhu/fibi-test/settings/secrets/actions`

2. **Add Secret**:
   - Click "New repository secret"
   - **Name**: `GH_COI_PUSH_TOKEN`
   - **Value**: Paste your PAT token
   - Click "Add secret"

## Verify Token Permissions

The token needs these permissions:
- ✅ **repo** scope (full control)
- ✅ Access to both repositories:
  - `eprabhu/fibi-test` (read)
  - `eprabhu/coi` (write/push)

## Troubleshooting Permission Errors

### Error: "Permission denied" or "Authentication failed"

**Check:**
1. Token name is exactly: `GH_COI_PUSH_TOKEN` (case-sensitive)
2. Token has `repo` scope enabled
3. Token is not expired
4. Token has access to `eprabhu/coi` repository

**Fix:**
- Regenerate token with `repo` scope
- Update secret in repository settings
- Make sure token name matches exactly

### Error: "Resource not accessible"

**Check:**
- Token has access to COI repository
- COI repository exists and is accessible
- Token hasn't been revoked

**Fix:**
- Ensure token has `repo` scope
- Verify COI repository is accessible
- Regenerate token if needed

## Testing Token

After adding the token:
1. Make a change to CORE
2. Commit and push
3. Check Actions tab
4. Should see workflow running without permission errors

## Security Notes

- ✅ Token is stored as a secret (encrypted)
- ✅ Only accessible to GitHub Actions
- ✅ Not visible in logs
- ⚠️ Keep token secure - don't share it
- ⚠️ Regenerate if compromised

---

**Once token is added, the workflow should work!** 🚀

