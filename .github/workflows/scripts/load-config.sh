#!/bin/bash
# Script to load configuration from sync-config.yml
# This script parses the YAML config file and exports variables for use in other scripts

CONFIG_FILE=".github/workflows/config/sync-config.yml"

# Function to read YAML config using basic bash parsing
load_config() {
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "⚠️  Configuration file not found: $CONFIG_FILE"
    echo "Using default values..."
    export CONFIG_LOADED=false
    return 1
  fi
  
  # Source repository config
  export SOURCE_REPO_NAME=$(grep -A 2 "source:" "$CONFIG_FILE" | grep "name:" | sed 's/.*name:[[:space:]]*"\([^"]*\)".*/\1/' || echo "eprabhu/fibi-test")
  export SOURCE_DEFAULT_BRANCH=$(grep -A 3 "source:" "$CONFIG_FILE" | grep "default_branch:" | sed 's/.*default_branch:[[:space:]]*"\([^"]*\)".*/\1/' || echo "main")
  
  # Destination repository config
  export DEST_REPO_NAME=$(grep -A 2 "destination:" "$CONFIG_FILE" | grep "name:" | sed 's/.*name:[[:space:]]*"\([^"]*\)".*/\1/' || echo "eprabhu/coi")
  export DEST_DEFAULT_BRANCH=$(grep -A 3 "destination:" "$CONFIG_FILE" | grep "default_branch:" | sed 's/.*default_branch:[[:space:]]*"\([^"]*\)".*/\1/' || echo "main")
  
  # Git config
  export GIT_TOKEN_SECRET=$(grep "access_token_secret:" "$CONFIG_FILE" | sed 's/.*access_token_secret:[[:space:]]*"\([^"]*\)".*/\1/' || echo "GH_COI_PUSH_TOKEN")
  export GIT_USER_NAME=$(grep -A 2 "user:" "$CONFIG_FILE" | grep "name:" | sed 's/.*name:[[:space:]]*"\([^"]*\)".*/\1/' || echo "github-actions[bot]")
  export GIT_USER_EMAIL=$(grep -A 2 "user:" "$CONFIG_FILE" | grep "email:" | sed 's/.*email:[[:space:]]*"\([^"]*\)".*/\1/' || echo "github-actions[bot]@users.noreply.github.com")
  
  # Branch config
  export FEATURE_BRANCH_PREFIX=$(grep "feature_branch_prefix:" "$CONFIG_FILE" | sed 's/.*feature_branch_prefix:[[:space:]]*"\([^"]*\)".*/\1/' || echo "Fibi-Dev")
  export INCREMENTAL_SYNC_CATEGORY=$(grep -A 3 "categories:" "$CONFIG_FILE" | grep "incremental_sync:" | sed 's/.*incremental_sync:[[:space:]]*"\([^"]*\)".*/\1/' || echo "core-sync")
  export FULL_SYNC_CATEGORY=$(grep -A 3 "categories:" "$CONFIG_FILE" | grep "full_sync:" | sed 's/.*full_sync:[[:space:]]*"\([^"]*\)".*/\1/' || echo "full-core-sync")
  
  # Destination directories
  export DEST_CORE_DIR=$(grep -A 1 "destination_directories:" "$CONFIG_FILE" | grep "core:" | sed 's/.*core:[[:space:]]*"\([^"]*\)".*/\1/' || echo "DB/CORE")
  export DEST_ROUTINES_DIR=$(grep -A 2 "destination_directories:" "$CONFIG_FILE" | grep "routines:" | sed 's/.*routines:[[:space:]]*"\([^"]*\)".*/\1/' || echo "DB/ROUTINES/CORE")
  export DEST_PROCEDURES_DIR=$(grep -A 5 "routines_types:" "$CONFIG_FILE" | grep "procedures:" | sed 's/.*procedures:[[:space:]]*"\([^"]*\)".*/\1/' || echo "DB/ROUTINES/CORE/PROCEDURES")
  export DEST_FUNCTIONS_DIR=$(grep -A 5 "routines_types:" "$CONFIG_FILE" | grep "functions:" | sed 's/.*functions:[[:space:]]*"\([^"]*\)".*/\1/' || echo "DB/ROUTINES/CORE/FUNCTIONS")
  export DEST_VIEWS_DIR=$(grep -A 5 "routines_types:" "$CONFIG_FILE" | grep "views:" | sed 's/.*views:[[:space:]]*"\([^"]*\)".*/\1/' || echo "DB/ROUTINES/CORE/VIEWS")
  export DEST_TRIGGERS_DIR=$(grep -A 5 "routines_types:" "$CONFIG_FILE" | grep "triggers:" | sed 's/.*triggers:[[:space:]]*"\([^"]*\)".*/\1/' || echo "DB/ROUTINES/CORE/TRIGGERS")
  
  # Advanced settings
  export MAX_BRANCH_NAME_LENGTH=$(grep "max_branch_name_length:" "$CONFIG_FILE" | sed 's/.*max_branch_name_length:[[:space:]]*\([0-9]*\).*/\1/' || echo "100")
  export DEBUG_MODE=$(grep "debug:" "$CONFIG_FILE" | grep -q "true" && echo "true" || echo "false")
  
  export CONFIG_LOADED=true
  
  if [ "$DEBUG_MODE" = "true" ]; then
    echo "✅ Configuration loaded:"
    echo "  Source Repo: $SOURCE_REPO_NAME"
    echo "  Destination Repo: $DEST_REPO_NAME"
    echo "  Git Token Secret: $GIT_TOKEN_SECRET"
    echo "  Feature Branch Prefix: $FEATURE_BRANCH_PREFIX"
  fi
}

# Load config when script is sourced
load_config

