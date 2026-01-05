#!/bin/bash

# Optional script to push CORE changes from fibi-test to COI repository
# This can be used after committing CORE changes in fibi-test

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
COI_REPO_URL="https://github.com/eprabhu/coi.git"
CORE_SOURCE_PATH="Fibi-Vanilla/FIBI_CORE"
CORE_TARGET_PATH="DB/CORE"

echo -e "${GREEN}=========================================="
echo "Push CORE Module to COI Repository"
echo "==========================================${NC}"
echo ""
echo -e "${YELLOW}Note: This script pushes CORE to COI repository${NC}"
echo "The COI repository should pull these changes using:"
echo "  ./scripts/sync-core-from-fibi-test.sh"
echo ""
echo "Repository: $COI_REPO_URL"
echo "Source path: $CORE_SOURCE_PATH"
echo "Target path: $CORE_TARGET_PATH"
echo ""

read -p "Do you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo -e "${YELLOW}Current branch: ${CURRENT_BRANCH}${NC}"
echo ""

# Check if CORE path exists
if [ ! -d "$CORE_SOURCE_PATH" ]; then
    echo -e "${RED}Error: CORE source path '$CORE_SOURCE_PATH' does not exist${NC}"
    exit 1
fi

echo -e "${GREEN}Pushing CORE module to COI repository...${NC}"
echo ""

# Note: This requires the COI repo to have the subtree already set up
# The actual push should be done from COI repo using pull, not from here
echo -e "${YELLOW}Note: Direct push from fibi-test to COI is not recommended${NC}"
echo "Instead, use the sync script in COI repository to pull changes."
echo ""
echo "After committing CORE changes in fibi-test:"
echo "  1. Go to COI repository"
echo "  2. Run: ./scripts/sync-core-from-fibi-test.sh"
echo ""

