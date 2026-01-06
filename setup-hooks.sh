#!/bin/bash
echo "Installing Git hooks..."

# Check if .git/hooks directory exists
if [ ! -d ".git/hooks" ]; then
    echo "Error: .git/hooks directory not found. Are you in a Git repository?"
    exit 1
fi

# Copy all hooks
if [ -d "hooks" ]; then
    cp hooks/* .git/hooks/ 2>/dev/null || true
    chmod +x .git/hooks/*
    echo "Hooks installed successfully!"
    
    # Verify post-commit hook for CORE sync
    if [ -f ".git/hooks/post-commit" ]; then
        echo "✓ Post-commit hook installed (CORE auto-sync enabled)"
    fi
else
    echo "Warning: hooks directory not found"
fi

echo ""
echo "CORE Module Auto-Sync is now enabled!"
echo "Changes to Fibi-Vanilla/FIBI_CORE/ will automatically sync to coi/DB/CORE/"
echo ""
echo "For more information, see: CORE_SYNC_README.md"
