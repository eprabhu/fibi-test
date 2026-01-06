# Check Your Secret Setup

## Verify Secret Exists

1. **Go to Repository Secrets**:
   - `https://github.com/eprabhu/fibi-test/settings/secrets/actions`

2. **Check for Secret**:
   - Look for: `GH_COI_PUSH_TOKEN`
   - Name must be **exactly**: `GH_COI_PUSH_TOKEN` (case-sensitive, no spaces)

3. **If Secret Doesn't Exist**:
   - Click "New repository secret"
   - Name: `GH_COI_PUSH_TOKEN`
   - Value: Your PAT token
   - Click "Add secret"

## Verify PAT Token

1. **Go to**: `https://github.com/settings/tokens`
2. **Find your token** (or create new one)
3. **Check scopes**:
   - ✅ `repo` (Full control of private repositories)

## Common Issues

### Error: "Input required and not supplied: token"

**Cause**: Secret doesn't exist or name is wrong

**Fix**:
1. Go to: `https://github.com/eprabhu/fibi-test/settings/secrets/actions`
2. Verify secret name is exactly: `GH_COI_PUSH_TOKEN`
3. If missing, add it with your PAT token

### Secret Name Mismatch

The workflow expects: `GH_COI_PUSH_TOKEN`

Check:
- No extra spaces
- Correct capitalization
- No typos

## Quick Fix

1. **Delete old secret** (if exists with wrong name)
2. **Create new secret**:
   - Name: `GH_COI_PUSH_TOKEN`
   - Value: Your PAT token (with `repo` scope)
3. **Test workflow again**

---

**Once secret is correctly set, the workflow will work!**

