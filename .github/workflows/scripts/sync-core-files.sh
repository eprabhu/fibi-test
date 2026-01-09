#!/bin/bash
set -e

# This script syncs CORE files and creates PR
# It's called from GitHub Actions workflow to avoid expression length limits

echo "Syncing CORE files..."

# Create base destination directory
mkdir -p coi-repo/DB/CORE

# Handle deleted Release CORE folders
if [ "$RELEASE_DELETED" == "true" ]; then
  echo "⚠️  Handling deleted Release CORE folders..."
  DELETED_RELEASES="$DELETED_RELEASES"
  
  for RELEASE in $DELETED_RELEASES; do
    DEST_DIR="coi-repo/DB/CORE/$RELEASE"
    if [ -d "$DEST_DIR" ]; then
      echo "Removing deleted release folder: $DEST_DIR"
      rm -rf "$DEST_DIR"
      echo "✅ Removed $RELEASE from COI"
    fi
  done
fi

# Sync Release CORE folders (if changed but not deleted)
if [ "$RELEASE_CHANGED" == "true" ]; then
  echo "Syncing Release CORE folders..."
  
  # Get changed files to find which releases need syncing
  CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)
  
  # Find all unique release folders with CORE changes
  RELEASES=$(echo "$CHANGED_FILES" | grep -oP "Fibi-[^/]+-Release" | sort -u)
  
  for RELEASE in $RELEASES; do
    echo "Processing release: $RELEASE"
    
    # Check if this release folder still exists in source
    if [ ! -d "$RELEASE" ]; then
      echo "⚠️  Release folder $RELEASE no longer exists, skipping sync"
      continue
    fi
    
    # Find CORE folder in this release - ONLY BASE/CORE (not client-based CORE)
    CORE_PATH="$RELEASE/BASE/CORE"
    
    if [ -n "$CORE_PATH" ] && [ -d "$CORE_PATH" ]; then
      echo "Found CORE folder at: $CORE_PATH"
      
      # Create destination directory for this release
      DEST_DIR="coi-repo/DB/CORE/$RELEASE"
      
      # Remove existing release folder if it exists (for clean sync)
      if [ -d "$DEST_DIR" ]; then
        echo "Removing existing $RELEASE folder for clean sync..."
        rm -rf "$DEST_DIR"
      fi
      
      # Create fresh directory
      mkdir -p "$DEST_DIR"
      
      # Copy CORE folder contents (not the CORE folder itself)
      echo "Copying from $CORE_PATH to $DEST_DIR"
      cp -r "$CORE_PATH"/* "$DEST_DIR/" || true
      
      echo "✅ Synced $RELEASE CORE to $DEST_DIR"
    else
      echo "⚠️  No CORE folder found in $RELEASE"
      # If CORE folder doesn't exist in source, remove from destination
      DEST_DIR="coi-repo/DB/CORE/$RELEASE"
      if [ -d "$DEST_DIR" ]; then
        echo "Removing $RELEASE folder from COI (CORE folder deleted in source)"
        rm -rf "$DEST_DIR"
      fi
    fi
  done
fi

# Handle deleted Sprint CORE folders
if [ "$SPRINT_DELETED" == "true" ]; then
  echo "⚠️  Handling deleted Sprint CORE folders..."
  DELETED_SPRINTS_VAR="$DELETED_SPRINTS"
  
  for SPRINT in $DELETED_SPRINTS_VAR; do
    DEST_DIR="coi-repo/DB/CORE/$SPRINT"
    if [ -d "$DEST_DIR" ]; then
      echo "Removing deleted sprint folder: $DEST_DIR"
      rm -rf "$DEST_DIR"
      echo "✅ Removed $SPRINT from COI"
    fi
  done
fi

# Sync Sprint CORE folders (if changed but not deleted)
if [ "$SPRINT_CHANGED" == "true" ]; then
  echo "Syncing Sprint CORE folders..."
  
  # Get changed files to find which sprints need syncing
  CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)
  
  # Find all unique sprint folders with CORE changes
  SPRINTS=$(echo "$CHANGED_FILES" | grep -oP "Sprint-[^/]+" | sort -u)
  
  for SPRINT in $SPRINTS; do
    echo "Processing sprint: $SPRINT"
    
    # Check if this sprint folder still exists in source
    if [ ! -d "$SPRINT" ]; then
      echo "⚠️  Sprint folder $SPRINT no longer exists, skipping sync"
      continue
    fi
    
    # Find CORE folder in this sprint - ONLY BASE/CORE (not client-based CORE)
    CORE_PATH="$SPRINT/BASE/CORE"
    
    if [ -n "$CORE_PATH" ] && [ -d "$CORE_PATH" ]; then
      echo "Found CORE folder at: $CORE_PATH"
      
      # Create destination directory for this sprint
      DEST_DIR="coi-repo/DB/CORE/$SPRINT"
      
      # Remove existing sprint folder if it exists (for clean sync)
      if [ -d "$DEST_DIR" ]; then
        echo "Removing existing $SPRINT folder for clean sync..."
        rm -rf "$DEST_DIR"
      fi
      
      # Create fresh directory
      mkdir -p "$DEST_DIR"
      
      # Copy CORE folder contents (not the CORE folder itself)
      echo "Copying from $CORE_PATH to $DEST_DIR"
      cp -r "$CORE_PATH"/* "$DEST_DIR/" || true
      
      echo "✅ Synced $SPRINT CORE to $DEST_DIR"
    else
      echo "⚠️  No CORE folder found in $SPRINT"
      # If CORE folder doesn't exist in source, remove from destination
      DEST_DIR="coi-repo/DB/CORE/$SPRINT"
      if [ -d "$DEST_DIR" ]; then
        echo "Removing $SPRINT folder from COI (CORE folder deleted in source)"
        rm -rf "$DEST_DIR"
      fi
    fi
  done
fi

# Sync ROUTINES files if routines YAML files changed
if [ "$ROUTINES_YAML_CHANGED" == "true" ]; then
  echo "Syncing ROUTINES files from changed YAML files..."
  
  # Get changed routines YAML files - ONLY from BASE/CORE
  CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)
  # Filter to only BASE/CORE (exclude client-based CORE)
  ROUTINES_YAML_FILES=$(echo "$CHANGED_FILES" | grep -E 'BASE/CORE/.*\.(yaml|yml)$' | grep -E '(PROCEDURES|VIEWS|FUNCTIONS|TRIGGERS)\.(yaml|yml)$' || true)
  
  # Process each changed YAML file
  for YAML_FILE in $ROUTINES_YAML_FILES; do
    if [ ! -f "$YAML_FILE" ]; then
      echo "⚠️  YAML file $YAML_FILE not found (may have been deleted), skipping"
      continue
    fi
    
    echo "Processing YAML file: $YAML_FILE"
    
    # Extract all sqlFile paths from YAML
    # Pattern: sqlFile: followed by path: on next line
    SQL_PATHS=$(awk '/sqlFile:/{getline; if(/path:/){gsub(/.*path:[[:space:]]*/, ""); gsub(/[[:space:]]*$/, ""); if($0 != "") print}}' "$YAML_FILE" || true)
    
    if [ -z "$SQL_PATHS" ]; then
      echo "No sqlFile paths found in $YAML_FILE"
      continue
    fi
    
    # Copy each SQL file
    for SQL_PATH in $SQL_PATHS; do
      echo "Found SQL path: $SQL_PATH"
      
      # Normalize path (remove leading/trailing spaces)
      SQL_PATH=$(echo "$SQL_PATH" | xargs)
      
      # Handle different path formats - find source file
      SOURCE_FILE=""
      SQL_FILENAME=$(basename "$SQL_PATH")
      
      # Strategy 1: Try path as-is
      if [ -f "$SQL_PATH" ]; then
        SOURCE_FILE="$SQL_PATH"
        echo "Found file at (as-is): $SQL_PATH"
      fi
      
      # Strategy 2: If path starts with ROUTINES/FIBI_CORE, try ROUTINES/BASE/FIBI_CORE
      if [ -z "$SOURCE_FILE" ] && echo "$SQL_PATH" | grep -q "^ROUTINES/FIBI_CORE"; then
        BASE_PATH=$(echo "$SQL_PATH" | sed 's|^ROUTINES/FIBI_CORE|ROUTINES/BASE/FIBI_CORE|')
        if [ -f "$BASE_PATH" ]; then
          SOURCE_FILE="$BASE_PATH"
          echo "Found file at (BASE FIBI_CORE path): $BASE_PATH"
        fi
      fi
      
      # Strategy 3: If path starts with ROUTINES/CORE, try ROUTINES/BASE/CORE (common pattern)
      if [ -z "$SOURCE_FILE" ] && echo "$SQL_PATH" | grep -q "^ROUTINES/CORE"; then
        BASE_PATH=$(echo "$SQL_PATH" | sed 's|^ROUTINES/CORE|ROUTINES/BASE/CORE|')
        if [ -f "$BASE_PATH" ]; then
          SOURCE_FILE="$BASE_PATH"
          echo "Found file at (BASE path): $BASE_PATH"
        fi
      fi
      
      # Strategy 4: Try ROUTINES/BASE/ + relative path from ROUTINES/
      if [ -z "$SOURCE_FILE" ] && echo "$SQL_PATH" | grep -q "^ROUTINES/"; then
        RELATIVE_PATH=$(echo "$SQL_PATH" | sed 's|^ROUTINES/||')
        TRY_PATH="ROUTINES/BASE/$RELATIVE_PATH"
        if [ -f "$TRY_PATH" ]; then
          SOURCE_FILE="$TRY_PATH"
          echo "Found file at (BASE relative): $TRY_PATH"
        fi
      fi
      
      # Strategy 5: Find file by name in ROUTINES directories
      if [ -z "$SOURCE_FILE" ]; then
        echo "Searching for file by name: $SQL_FILENAME"
        SOURCE_FILE=$(find . -type f -name "$SQL_FILENAME" ! -path "*/.git/*" ! -path "*/coi-repo/*" | grep -E "ROUTINES.*(CORE|FIBI_CORE)" | head -1)
        if [ -n "$SOURCE_FILE" ]; then
          echo "Found by filename at: $SOURCE_FILE"
        fi
      fi
      
      # Strategy 6: Try with full path pattern (last resort)
      if [ -z "$SOURCE_FILE" ]; then
        SOURCE_FILE=$(find . -type f -path "*/$SQL_PATH" ! -path "*/.git/*" ! -path "*/coi-repo/*" | head -1)
        if [ -n "$SOURCE_FILE" ]; then
          echo "Found by path pattern at: $SOURCE_FILE"
        fi
      fi
      
      if [ -n "$SOURCE_FILE" ] && [ -f "$SOURCE_FILE" ]; then
        # Determine destination path: DB/ROUTINES/CORE/(PROCEDURES|FUNCTIONS|VIEWS)/*.sql
        SQL_FILENAME=$(basename "$SOURCE_FILE")
        
        # Extract type (PROCEDURES, FUNCTIONS, VIEWS, TRIGGERS) from source path
        ROUTINE_TYPE=""
        if echo "$SOURCE_FILE" | grep -qiE "(PROCEDURES|PROC)"; then
          ROUTINE_TYPE="PROCEDURES"
        elif echo "$SOURCE_FILE" | grep -qiE "(FUNCTIONS|FUNC)"; then
          ROUTINE_TYPE="FUNCTIONS"
        elif echo "$SOURCE_FILE" | grep -qiE "VIEWS"; then
          ROUTINE_TYPE="VIEWS"
        elif echo "$SOURCE_FILE" | grep -qiE "TRIGGERS"; then
          ROUTINE_TYPE="TRIGGERS"
        else
          # Try to extract from path structure
          if echo "$SOURCE_FILE" | grep -qE "/PROCEDURES/"; then
            ROUTINE_TYPE="PROCEDURES"
          elif echo "$SOURCE_FILE" | grep -qE "/FUNCTIONS/"; then
            ROUTINE_TYPE="FUNCTIONS"
          elif echo "$SOURCE_FILE" | grep -qE "/VIEWS/"; then
            ROUTINE_TYPE="VIEWS"
          elif echo "$SOURCE_FILE" | grep -qE "/TRIGGERS/"; then
            ROUTINE_TYPE="TRIGGERS"
          else
            # Default to FUNCTIONS if cannot determine
            ROUTINE_TYPE="FUNCTIONS"
            echo "⚠️  Could not determine routine type, defaulting to FUNCTIONS"
          fi
        fi
        
        # Build destination: DB/ROUTINES/CORE/{TYPE}/{filename}.sql
        DEST_PATH="DB/ROUTINES/CORE/$ROUTINE_TYPE/$SQL_FILENAME"
        DEST_FILE="coi-repo/$DEST_PATH"
        DEST_DIR=$(dirname "$DEST_FILE")
        
        # Create destination directory (create parent directories if needed)
        echo "Creating destination directory: $DEST_DIR"
        mkdir -p "$DEST_DIR"
        
        # Copy the file (will replace if exists)
        echo "Copying $SOURCE_FILE to $DEST_FILE"
        cp -f "$SOURCE_FILE" "$DEST_FILE" || {
          echo "⚠️  Failed to copy $SOURCE_FILE to $DEST_FILE"
          continue
        }
        echo "✅ Synced routine file: $DEST_PATH"
      else
        echo "⚠️  SQL file not found: $SQL_PATH"
        echo "   Searched paths:"
        echo "   - $SQL_PATH"
        if echo "$SQL_PATH" | grep -q "^ROUTINES/CORE"; then
          BASE_PATH=$(echo "$SQL_PATH" | sed 's|^ROUTINES/CORE|ROUTINES/BASE/CORE|')
          echo "   - $BASE_PATH"
        fi
        SQL_FILENAME=$(basename "$SQL_PATH")
        echo "   - Files named: $SQL_FILENAME"
      fi
    done
  done
  
  echo "✅ Finished syncing ROUTINES files"
  
  # Update all YAML files in COI repo to reflect new routine paths
  echo "Updating YAML files in COI repo with new routine paths..."
  cd coi-repo
  
  # Find all YAML files in DB/CORE that might reference routines
  YAML_FILES=$(find DB/CORE -type f \( -name "PROCEDURES.yaml" -o -name "PROCEDURES.yml" -o -name "FUNCTIONS.yaml" -o -name "FUNCTIONS.yml" -o -name "VIEWS.yaml" -o -name "VIEWS.yml" -o -name "TRIGGERS.yaml" -o -name "TRIGGERS.yml" \) 2>/dev/null || true)
  
  if [ -n "$YAML_FILES" ]; then
    for COI_YAML in $YAML_FILES; do
      if [ ! -f "$COI_YAML" ]; then
        continue
      fi
      
      echo "Processing YAML: $COI_YAML"
      
      # Extract all old SQL paths from YAML
      OLD_PATHS=$(awk '/sqlFile:/{getline; if(/path:/){gsub(/.*path:[[:space:]]*/, ""); gsub(/[[:space:]]*$/, ""); if($0 != "") print}}' "$COI_YAML" 2>/dev/null || true)
      
      if [ -z "$OLD_PATHS" ]; then
        continue
      fi
      
      # Update each path
      for OLD_PATH in $OLD_PATHS; do
        OLD_PATH=$(echo "$OLD_PATH" | xargs)
        
        # Skip if already using new path format
        if echo "$OLD_PATH" | grep -q "^DB/ROUTINES/CORE"; then
          continue
        fi
        
        # Extract filename and determine type
        SQL_FILENAME=$(basename "$OLD_PATH")
        
        # Determine routine type from old path or filename
        ROUTINE_TYPE="FUNCTIONS"
        if echo "$OLD_PATH" | grep -qiE "(PROCEDURES|PROC)"; then
          ROUTINE_TYPE="PROCEDURES"
        elif echo "$OLD_PATH" | grep -qiE "(FUNCTIONS|FUNC)"; then
          ROUTINE_TYPE="FUNCTIONS"
        elif echo "$OLD_PATH" | grep -qiE "VIEWS"; then
          ROUTINE_TYPE="VIEWS"
        elif echo "$OLD_PATH" | grep -qiE "TRIGGERS"; then
          ROUTINE_TYPE="TRIGGERS"
        fi
        
        # Build new path
        NEW_PATH="DB/ROUTINES/CORE/$ROUTINE_TYPE/$SQL_FILENAME"
        
        # Escape paths for sed
        OLD_PATH_ESCAPED=$(echo "$OLD_PATH" | sed 's|/|\\/|g' | sed 's|\.|\\\.|g')
        NEW_PATH_ESCAPED=$(echo "$NEW_PATH" | sed 's|/|\\/|g')
        
        # Update YAML file (try multiple patterns)
        sed -i "s|path:[[:space:]]*$OLD_PATH_ESCAPED|path: $NEW_PATH_ESCAPED|g" "$COI_YAML" 2>/dev/null || true
        sed -i "s|- path:[[:space:]]*$OLD_PATH_ESCAPED|- path: $NEW_PATH_ESCAPED|g" "$COI_YAML" 2>/dev/null || true
        sed -i "s|$OLD_PATH_ESCAPED|$NEW_PATH_ESCAPED|g" "$COI_YAML" 2>/dev/null || true
        
        echo "  Updated: $OLD_PATH -> $NEW_PATH"
      done
    done
    echo "✅ Finished updating YAML files"
  else
    echo "⚠️  No YAML files found in COI repo to update"
  fi
  
  cd ..
fi

echo "✅ CORE and ROUTINES sync completed"

