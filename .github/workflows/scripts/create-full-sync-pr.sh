#!/bin/bash
set -e

# This script creates PR after full sync
# It's called from GitHub Actions workflow to avoid expression length limits

# Load configuration
source .github/workflows/scripts/load-config.sh

# Use config values or defaults
GIT_USER_NAME="${GIT_USER_NAME:-github-actions[bot]}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-github-actions[bot]@users.noreply.github.com}"
DEST_DEFAULT_BRANCH="${DEST_DEFAULT_BRANCH:-main}"
DEST_CORE_DIR="${DEST_CORE_DIR:-DB/CORE}"
DEST_ROUTINES_DIR="${DEST_ROUTINES_DIR:-DB/ROUTINES/CORE}"
FEATURE_BRANCH_PREFIX="${FEATURE_BRANCH_PREFIX:-Fibi-Dev}"
FULL_SYNC_CATEGORY="${FULL_SYNC_CATEGORY:-full-core-sync}"
MAX_BRANCH_NAME_LENGTH="${MAX_BRANCH_NAME_LENGTH:-100}"

cd coi-repo
git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"

# Source branch name already available from env

# Always target main branch for PR (from config)
# Determine which default branch exists in COI repository
TARGET_BRANCH="$DEST_DEFAULT_BRANCH"
if ! git ls-remote --heads origin "$TARGET_BRANCH" | grep -q "$TARGET_BRANCH"; then
  # Try alternative branch name
  ALTERNATIVE_BRANCH="master"
  if [ "$TARGET_BRANCH" = "main" ]; then
    ALTERNATIVE_BRANCH="master"
  else
    ALTERNATIVE_BRANCH="main"
  fi
  
  if git ls-remote --heads origin "$ALTERNATIVE_BRANCH" | grep -q "$ALTERNATIVE_BRANCH"; then
    TARGET_BRANCH="$ALTERNATIVE_BRANCH"
    echo "Using alternative branch: $TARGET_BRANCH"
  else
    echo "⚠️  ERROR: Neither '$DEST_DEFAULT_BRANCH' nor '$ALTERNATIVE_BRANCH' branch found in COI repository!"
    exit 1
  fi
fi

echo "PR will target branch: $TARGET_BRANCH (main branch as per organization requirement)"

# Checkout target branch first to get latest changes
echo "Fetching latest from origin..."
git fetch origin "$TARGET_BRANCH" || git fetch origin || true

echo "Checking out target branch: $TARGET_BRANCH"
git checkout "$TARGET_BRANCH"
git pull origin "$TARGET_BRANCH" || true

# Configure remote URL with token (use config for repo name)
DEST_REPO_NAME="${DEST_REPO_NAME:-eprabhu/coi}"
git remote set-url origin https://x-access-token:$GH_COI_PUSH_TOKEN@github.com/${DEST_REPO_NAME}.git

# Create feature branch name following COI repo naming convention from config
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
# Format: {prefix}/{category}/{source-branch}-{timestamp}
# Clean source branch name for use in branch path
CLEAN_SOURCE_BRANCH=$(echo "$SOURCE_BRANCH_NAME" | sed 's/[^a-zA-Z0-9._-]/-/g')
FEATURE_BRANCH="${FEATURE_BRANCH_PREFIX}/${FULL_SYNC_CATEGORY}/${CLEAN_SOURCE_BRANCH}-${TIMESTAMP}"
# Ensure branch name doesn't exceed reasonable length
FEATURE_BRANCH=$(echo "$FEATURE_BRANCH" | cut -c1-${MAX_BRANCH_NAME_LENGTH})

echo "Creating feature branch: $FEATURE_BRANCH"
git checkout -b "$FEATURE_BRANCH" || {
  echo "Feature branch may already exist, checking out..."
  git checkout "$FEATURE_BRANCH"
  git merge "$TARGET_BRANCH" || true
}

# STRICTLY ONLY modify configured directories
# Add CORE changes (scripts YAML files)
if [ -d "$DEST_CORE_DIR" ]; then
  git add "$DEST_CORE_DIR/" || true
fi

# Add ROUTINES changes (SQL files)
if [ -d "$DEST_ROUTINES_DIR" ]; then
  git add "$DEST_ROUTINES_DIR/" || true
fi

# Safety check: Verify we're only staging configured directories
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")
UNAUTHORIZED_FILES=$(echo "$STAGED_FILES" | grep -v "^${DEST_CORE_DIR}/" | grep -v "^${DEST_ROUTINES_DIR}/" | grep -v "^$" || true)

if [ -n "$UNAUTHORIZED_FILES" ]; then
  echo "⚠️  WARNING: Attempted to stage files outside $DEST_CORE_DIR/ and $DEST_ROUTINES_DIR/:"
  echo "$UNAUTHORIZED_FILES"
  echo "Resetting unauthorized files..."
  git reset HEAD $UNAUTHORIZED_FILES 2>/dev/null || true
fi

# Check if there are any changes to commit
CHANGES=$(git status --porcelain "$DEST_CORE_DIR" 2>/dev/null || echo "")
if [ -d "$DEST_ROUTINES_DIR" ]; then
  CHANGES="$CHANGES $(git status --porcelain "$DEST_ROUTINES_DIR/" 2>/dev/null || echo "")"
fi
CHANGES=$(echo "$CHANGES" | xargs)

if [ -n "$CHANGES" ]; then
  echo "Committing changes to feature branch..."
  # Use GitHub context values from env (already extracted above)
  COMMIT_MSG="Full sync: CORE and ROUTINES from fibi-test"$'\n'$'\n'"Full sync performed via workflow_dispatch"$'\n'"Source commit: $GITHUB_SHA"$'\n'"Target branch: $TARGET_BRANCH"$'\n'"Source repository: $GITHUB_REPOSITORY"$'\n'"Workflow run: $GITHUB_RUN_ID"$'\n'"Triggered by: $GITHUB_ACTOR"
  git commit -m "$COMMIT_MSG"
  
  echo "Pushing feature branch: $FEATURE_BRANCH to COI repository..."
  git push origin "$FEATURE_BRANCH" || git push -u origin "$FEATURE_BRANCH" || {
    echo "⚠️  Failed to push feature branch"
    exit 1
  }
  
  echo "✅ Feature branch pushed successfully"
  
  # Create Pull Request using GitHub API
  echo "Creating Pull Request..."
  PR_TITLE="🔄 Full Sync: CORE and ROUTINES from fibi-test ($SOURCE_BRANCH_NAME)"
  
  # Use GitHub context variables from env (already extracted above)
  WORKFLOW_URL="https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
  
  # Build PR body by writing to file first
  {
    echo "## 🔄 Full Sync CORE and ROUTINES from fibi-test"
    echo ""
    echo "This PR was automatically created by the full sync workflow (manual trigger)."
    echo ""
    echo "### Source Information"
    echo "- **Source Repository**: $GITHUB_REPOSITORY"
    echo "- **Source Branch**: \`$SOURCE_BRANCH_NAME\`"
    echo "- **Source Commit**: \`$GITHUB_SHA\`"
    echo "- **Workflow Run**: [View Run]($WORKFLOW_URL)"
    echo "- **Triggered by**: @$GITHUB_ACTOR"
    echo ""
    echo "### Changes"
    echo "This PR performs a **full sync** of all CORE scripts and ROUTINES from:"
    echo "- All Release folders: \`Fibi-*-Release/BASE/CORE/**\`"
    echo "- All Sprint folders: \`Sprint-*/BASE/CORE/**\`"
    echo "- All direct ROUTINES: \`ROUTINES/BASE/CORE/**\` (PROCEDURES, FUNCTIONS, VIEWS, TRIGGERS)"
    echo ""
    echo "### Review Checklist"
    echo "- [ ] Review all CORE script changes in \`$DEST_CORE_DIR/\`"
    echo "- [ ] Review all ROUTINES changes in \`$DEST_ROUTINES_DIR/\`"
    echo "- [ ] Verify file paths are correct"
    echo "- [ ] Check for any breaking changes"
    echo "- [ ] Verify all Release and Sprint folders are synced correctly"
    echo ""
    echo "### Note"
    echo "This PR only modifies files in \`$DEST_CORE_DIR/\` and \`$DEST_ROUTINES_DIR/\` directories. No other files are affected."
    echo ""
    echo "**This is a full sync - all Release and Sprint folders are included.**"
    echo ""
    echo "### Branch Management"
    echo "⚠️  **This feature branch will be automatically deleted after PR is merged.**"
  } > /tmp/pr_body.txt
  PR_BODY=$(cat /tmp/pr_body.txt)
  
  # Escape PR body for JSON
  PR_BODY_ESCAPED=$(echo "$PR_BODY" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
  
  # Create PR using GitHub API (always targeting main branch)
  echo "Preparing PR creation request..."
  echo "Feature branch: $FEATURE_BRANCH"
  echo "Target branch: $TARGET_BRANCH"
  echo "PR Title: $PR_TITLE"
  
  PR_JSON="{\"title\":\"$PR_TITLE\",\"body\":\"$PR_BODY_ESCAPED\",\"head\":\"$FEATURE_BRANCH\",\"base\":\"$TARGET_BRANCH\"}"
  
  echo "Sending PR creation request to GitHub API..."
    # Use destination repo from config if available
    DEST_REPO_NAME="${DEST_REPO_NAME:-eprabhu/coi}"
    
    PR_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token $GH_COI_PUSH_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$PR_JSON" \
      https://api.github.com/repos/${DEST_REPO_NAME}/pulls 2>&1)
  
  # Note: Branch auto-deletion on merge should be configured in repository settings
  # Settings → Branches → Automatically delete head branches
  
  HTTP_CODE=$(echo "$PR_RESPONSE" | tail -n1)
  PR_BODY_RESPONSE=$(echo "$PR_RESPONSE" | sed '$d')
  
  echo "HTTP Response Code: $HTTP_CODE"
  echo "API Response: $PR_BODY_RESPONSE"
  
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    PR_URL=$(echo "$PR_BODY_RESPONSE" | grep -o '"html_url":"[^"]*' | cut -d'"' -f4 || echo "")
    PR_NUMBER=$(echo "$PR_BODY_RESPONSE" | grep -o '"number":[0-9]*' | cut -d':' -f2 || echo "")
    
    echo "✅ Pull Request created successfully"
    if [ -n "$PR_URL" ]; then
      echo "🔗 PR Link: $PR_URL"
      
      # Try to add label if PR number is available
                if [ -n "$PR_NUMBER" ]; then
                  DEST_REPO_NAME="${DEST_REPO_NAME:-eprabhu/coi}"
                  curl -s -X POST \
                    -H "Accept: application/vnd.github.v3+json" \
                    -H "Authorization: token $GH_COI_PUSH_TOKEN" \
                    -H "Content-Type: application/json" \
                    -d '{"labels":["auto-sync","full-sync"]}' \
                    https://api.github.com/repos/${DEST_REPO_NAME}/issues/$PR_NUMBER/labels > /dev/null || true
                fi
    fi
  elif [ "$HTTP_CODE" = "422" ]; then
    # PR might already exist, try to find it
              DEST_REPO_NAME="${DEST_REPO_NAME:-eprabhu/coi}"
              DEST_REPO_OWNER=$(echo "$DEST_REPO_NAME" | cut -d'/' -f1)
              
              EXISTING_PR_RESPONSE=$(curl -s \
                -H "Accept: application/vnd.github.v3+json" \
                -H "Authorization: token $GH_COI_PUSH_TOKEN" \
                "https://api.github.com/repos/${DEST_REPO_NAME}/pulls?head=${DEST_REPO_OWNER}:$FEATURE_BRANCH&base=$TARGET_BRANCH&state=open")
              
              EXISTING_PR_URL=$(echo "$EXISTING_PR_RESPONSE" | grep -o '"html_url":"[^"]*' | head -1 | cut -d'"' -f4 || echo "")
              
              if [ -n "$EXISTING_PR_URL" ]; then
                echo "⚠️  Pull Request already exists"
                echo "🔗 Existing PR Link: $EXISTING_PR_URL"
              else
                echo "⚠️  Failed to create PR (HTTP $HTTP_CODE). Response: $PR_BODY_RESPONSE"
                echo "🔗 Please create PR manually: https://github.com/${DEST_REPO_NAME}/compare/$TARGET_BRANCH...$FEATURE_BRANCH"
                echo "PR Title: $PR_TITLE"
              fi
            else
              DEST_REPO_NAME="${DEST_REPO_NAME:-eprabhu/coi}"
              echo "⚠️  Failed to create PR (HTTP $HTTP_CODE). Response: $PR_BODY_RESPONSE"
              echo "🔗 Please create PR manually: https://github.com/${DEST_REPO_NAME}/compare/$TARGET_BRANCH...$FEATURE_BRANCH"
              echo "PR Title: $PR_TITLE"
            fi
else
  echo "No changes to commit. Already in sync."
  # Delete feature branch if no changes
  git checkout "$TARGET_BRANCH" || true
  git branch -D "$FEATURE_BRANCH" || true
  git push origin --delete "$FEATURE_BRANCH" || true
fi

