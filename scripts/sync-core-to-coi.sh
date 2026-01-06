#!/bin/bash

# Script to sync CORE module from fibi-test to coi repository
# This script is called by the post-commit hook when CORE changes are detected

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIBI_TEST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
COI_DIR="$(cd "$FIBI_TEST_DIR/../coi" && pwd)"

# Source and destination paths
SOURCE_CORE="$FIBI_TEST_DIR/Fibi-Vanilla/FIBI_CORE"
DEST_CORE="$COI_DIR/DB/CORE"

# Check if COI directory exists
if [ ! -d "$COI_DIR" ]; then
    echo -e "${RED}Error: COI repository not found at $COI_DIR${NC}"
    echo "Please ensure the COI repository is cloned at the same level as fibi-test"
    exit 1
fi

# Check if COI is a git repository
if [ ! -d "$COI_DIR/.git" ]; then
    echo -e "${RED}Error: $COI_DIR is not a Git repository${NC}"
    exit 1
fi

# Check if source CORE directory exists
if [ ! -d "$SOURCE_CORE" ]; then
    echo -e "${RED}Error: Source CORE directory not found at $SOURCE_CORE${NC}"
    exit 1
fi

echo -e "${YELLOW}Starting CORE module synchronization...${NC}"
echo "Source: $SOURCE_CORE"
echo "Destination: $COI_DIR/DB/CORE"

# Change to COI directory
cd "$COI_DIR" || exit 1

# Check if there are uncommitted changes in COI repo
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}Warning: COI repository has uncommitted changes${NC}"
    echo "Stashing changes before sync..."
    git stash push -m "Auto-stash before CORE sync $(date +%Y%m%d_%H%M%S)"
fi

# Ensure we're on the correct branch (default to main/master)
CURRENT_BRANCH=$(git branch --show-current)
if [ -z "$CURRENT_BRANCH" ]; then
    # Try to checkout main or master
    if git show-ref --verify --quiet refs/heads/main; then
        git checkout main
        CURRENT_BRANCH="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        git checkout master
        CURRENT_BRANCH="master"
    else
        echo -e "${RED}Error: Could not determine branch to use${NC}"
        exit 1
    fi
fi

# Create destination directory if it doesn't exist
mkdir -p "$DEST_CORE"

# Copy all files from source to destination, preserving directory structure
echo "Copying files..."
rsync -av --delete \
    --exclude='.git' \
    --exclude='*.tmp' \
    "$SOURCE_CORE/" "$DEST_CORE/"

# Check if there are any changes to commit
if [ -z "$(git status --porcelain DB/CORE)" ]; then
    echo -e "${GREEN}No changes detected in CORE module. Already in sync.${NC}"
    # Restore stashed changes if any
    if git stash list | grep -q "Auto-stash before CORE sync"; then
        git stash pop
    fi
    exit 0
fi

# Get commit message from fibi-test (if available)
COMMIT_MSG="Sync CORE module from fibi-test"
if [ -n "$1" ]; then
    COMMIT_MSG="$1"
fi

# Get the latest commit info from fibi-test
cd "$FIBI_TEST_DIR" || exit 1
LAST_COMMIT=$(git log -1 --pretty=format:"%h - %s (%an, %ar)")
cd "$COI_DIR" || exit 1

# Add all CORE changes
git add DB/CORE/

# Commit the changes
echo "Committing changes to COI repository..."
git commit -m "Auto-sync CORE module from fibi-test

Source commit: $LAST_COMMIT
Synced by: $(whoami) at $(date '+%Y-%m-%d %H:%M:%S')
Triggered by: Automatic sync from fibi-test repository" || {
    echo -e "${RED}Error: Failed to commit changes${NC}"
    exit 1
}

echo -e "${GREEN}Successfully synced CORE module to COI repository${NC}"
echo "Commit created in COI repository on branch: $CURRENT_BRANCH"

# Restore stashed changes if any
if git stash list | grep -q "Auto-stash before CORE sync"; then
    echo "Restoring stashed changes..."
    git stash pop
fi

# Optionally push to remote (uncomment if you want auto-push)
# echo "Pushing to remote..."
# git push origin "$CURRENT_BRANCH" || {
#     echo -e "${YELLOW}Warning: Failed to push to remote. You may need to push manually.${NC}"
# }

exit 0

