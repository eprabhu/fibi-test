# CORE Scripts Sync Algorithm - Detailed Technical Documentation

> **👋 Looking for a simple explanation?** See [`SYNC_ALGORITHM_EXPLANATION_SIMPLE.md`](./SYNC_ALGORITHM_EXPLANATION_SIMPLE.md) for an easy-to-understand version.

## Overview
Automated workflow that synchronizes SQL scripts and database routines from `fibi-test` repository to `COI` repository.

---

## 🔍 **What Triggers the Sync?**

The workflow automatically runs when changes are detected in:
- ✅ **Release folders**: `Fibi-*-Release/BASE/CORE/**` (e.g., `Fibi-5.8.1-Release/BASE/CORE`)
- ✅ **Sprint folders**: `Sprint-*/BASE/CORE/**` (e.g., `Sprint-2025-12-15/BASE/CORE`)

---

## 🚫 **What is EXCLUDED?**

- ❌ **Fibi-Vanilla folder**: Scripts in `Fibi-Vanilla/FIBI_CORE` are **NOT synced**
  - *Reason: Vanilla contains base/unversioned scripts, only versioned releases/sprints are synced*

---

## 📋 **Step-by-Step Algorithm**

### **Step 1: Detection**
```
IF (files changed in Release folders OR Sprint folders):
  → Trigger sync workflow
ELSE:
  → Skip (no sync needed)
```

### **Step 2: Source Discovery**
```
Find all folders matching patterns:
  - Pattern 1: "Fibi-*-Release" (e.g., Fibi-5.8.1-Release)
  - Pattern 2: "Sprint-*" (e.g., Sprint-2025-12-15)

For each folder found:
  → Check if "BASE/CORE" subfolder exists
  → If YES: Add to sync list
  → If NO: Skip this folder
```

### **Step 3: File Collection**
```
For each valid folder (Release or Sprint):

  1. Collect CORE Scripts:
     → Copy all files from "BASE/CORE/" folder
     → Includes: YAML files, SQL scripts, configuration files

  2. Collect ROUTINES:
     → Find all YAML files in "BASE/CORE/" (PROCEDURES.yaml, FUNCTIONS.yaml, etc.)
     → Extract SQL file paths from YAML files
     → Copy referenced SQL routine files
```

### **Step 4: Destination Mapping**
```
Source Structure → COI Repository Structure

Release/Sprint Example:
  Input:  "Sprint-2025-12-15/BASE/CORE/SCRIPTS.yaml"
  Output: "coi-repo/DB/CORE/Sprint-2025-12-15/SCRIPTS.yaml"

Routines Example:
  Input:  "ROUTINES/BASE/CORE/PROCEDURES/GET_DATA.sql"
  Output: "coi-repo/DB/ROUTINES/CORE/PROCEDURES/GET_DATA.sql"
```

### **Step 5: Sync Execution**
```
For each file to sync:
  → Create destination folder structure (if needed)
  → Copy file from source to destination
  → Preserve folder hierarchy and file names
  → Log success/failure for each file
```

### **Step 6: Create Feature Branch & Pull Request**
```
IF (any files were successfully synced):
  → Create feature branch following COI naming convention: "Fibi-Dev/{category}/{feature}"
    • Sync workflow: "Fibi-Dev/core-sync/{source-branch}-{timestamp}"
    • Full sync workflow: "Fibi-Dev/full-core-sync/{source-branch}-{timestamp}"
  → Stage only files in DB/CORE/ and DB/ROUTINES/ directories
  → Create commit with sync details on feature branch
  → Push feature branch to COI repository
  → Create Pull Request from feature branch to MAIN branch (always targets main/master)
  → Add auto-sync label to PR
  → PR includes note about branch auto-deletion after merge
ELSE:
  → Skip PR creation (no changes to sync)
  → Clean up feature branch if created

Note: Feature branch will be automatically deleted after PR is merged (via repository settings)
```

---

## 📊 **Visual Flow Diagram**

```
┌─────────────────────────────────────────────────────────────┐
│   Developer makes changes & pushes to fibi-test repository  │
│   • Changes in Release folders                              │
│   • Changes in Sprint folders                               │
│   • Changes in ROUTINES/BASE/CORE/**                        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│   GitHub Actions Workflow Triggered                         │
│   Checks path patterns:                                     │
│   ✓ Fibi-*-Release/**/CORE/**                              │
│   ✓ Fibi-*-Release/**/ROUTINES/**                          │
│   ✓ Sprint-*/**/CORE/**                                    │
│   ✓ Sprint-*/**/ROUTINES/**                                │
│   ✓ ROUTINES/BASE/CORE/**                                  │
│   ✗ Fibi-Vanilla/** (EXCLUDED)                             │
└────────────────────┬────────────────────────────────────────┘
                     │ Match Found?
                     ▼
                ┌────┴────┐
                │   NO    │
                └────┬────┘
                     │
                     ▼
           ┌──────────────────┐
           │  Workflow Skipped│
           └──────────────────┘
                     │
        ┌────────────┘
        │
        │ YES
        ▼
┌─────────────────────────────────────────────────────────────┐
│   Step 1: Checkout & Load Configuration                     │
│   • Checkout fibi-test repository (full history)            │
│   • Load sync-config.yml                                    │
│   • Extract: repo names, paths, branch patterns             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│   Step 2: Detect Base Commit                                │
│   • Check if merge commit (HEAD^2 exists)                   │
│   → If MERGE: Use HEAD^1 (first parent)                     │
│   → If REGULAR: Use HEAD~1 (previous commit)                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│   Step 3: Detect Changed Files                              │
│   • Compare: BASE_COMMIT vs HEAD                            │
│   • Identify change type:                                   │
│     → Release CORE changes                                  │
│     → Sprint CORE changes                                   │
│     → ROUTINES YAML changes                                 │
│     → Direct ROUTINES/BASE/CORE/** changes                  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
                ┌────┴────┐
           ┌────┤ Changes │────┐
           │    │ Found?  │    │
           │    └────┬────┘    │
           │         │         │
           │ NO      │ YES     │
           ▼         ▼         ▼
    ┌──────────┐   │    ┌──────────────────────────────────┐
    │   Skip   │   │    │ Step 4: Clone COI Repository     │
    │ Workflow │   │    │ • Clone destination repo          │
    └──────────┘   │    │ • Checkout main/master branch     │
                   │    │ • Create feature branch:          │
                   │    │   Fibi-Dev/{category}/{branch}-   │
                   │    │   {timestamp}                     │
                   │    └───────────┬───────────────────────┘
                   │                │
                   │                ▼
                   │    ┌──────────────────────────────────┐
                   │    │ Step 5: Sync Files                │
                   │    │                                   │
                   │    │ ┌──────────────────────────────┐ │
                   │    │ │ A. Release CORE Folders       │ │
                   │    │ │    Source: Fibi-*-Release/    │ │
                   │    │ │            BASE/CORE/**       │ │
                   │    │ │    Dest:   DB/CORE/           │ │
                   │    │ │            {Release-Name}/**  │ │
                   │    │ └───────────┬──────────────────┘ │
                   │    │             │                    │
                   │    │ ┌───────────▼──────────────────┐ │
                   │    │ │ B. Sprint CORE Folders        │ │
                   │    │ │    Source: Sprint-*/          │ │
                   │    │ │            BASE/CORE/**       │ │
                   │    │ │    Dest:   DB/CORE/           │ │
                   │    │ │            {Sprint-Name}/**   │ │
                   │    │ └───────────┬──────────────────┘ │
                   │    │             │                    │
                   │    │ ┌───────────▼──────────────────┐ │
                   │    │ │ C. Routines from YAML         │ │
                   │    │ │    • Parse PROCEDURES.yaml    │ │
                   │    │ │    • Parse FUNCTIONS.yaml     │ │
                   │    │ │    • Parse VIEWS.yaml         │ │
                   │    │ │    • Parse TRIGGERS.yaml      │ │
                   │    │ │    • Extract SQL file paths   │ │
                   │    │ │    • Copy SQL files to:       │ │
                   │    │ │      DB/ROUTINES/CORE/{TYPE}/ │ │
                   │    │ └───────────┬──────────────────┘ │
                   │    │             │                    │
                   │    │ ┌───────────▼──────────────────┐ │
                   │    │ │ D. Direct Routines            │ │
                   │    │ │    Source: ROUTINES/BASE/     │ │
                   │    │ │            CORE/PROCEDURES/*. │ │
                   │    │ │            sql (or FUNCTIONS/ │ │
                   │    │ │            VIEWS/TRIGGERS)    │ │
                   │    │ │    Dest:   DB/ROUTINES/CORE/  │ │
                   │    │ │            PROCEDURES/*.sql   │ │
                   │    │ └───────────┬──────────────────┘ │
                   │    │             │                    │
                   │    └─────────────┴────────────────────┘
                   │                │
                   │                ▼
                   │    ┌──────────────────────────────────┐
                   │    │ Step 6: Update YAML Paths         │
                   │    │ • Update old paths in YAML files  │
                   │    │ • Use new DB/ROUTINES/CORE paths  │
                   │    └───────────┬───────────────────────┘
                   │                │
                   │                ▼
                   │    ┌──────────────────────────────────┐
                   │    │ Step 7: Stage Changes             │
                   │    │ • git add DB/CORE/**              │
                   │    │ • git add DB/ROUTINES/**          │
                   │    │ • Safety check: Only allow        │
                   │    │   DB/CORE & DB/ROUTINES           │
                   │    └───────────┬───────────────────────┘
                   │                │
                   │                ▼
                   │    ┌───────────┴───────┐
                   │    │   Has Changes?    │
                   │    └───────┬───────────┘
                   │            │
                   │        ┌───┴───┐
                   │        │       │
                   │      NO│       │YES
                   │        │       │
                   │        ▼       ▼
                   │   ┌────────┐  │
                   │   │Delete  │  │
                   │   │Branch  │  │
                   │   │& Exit  │  │
                   │   └────────┘  │
                   │                │
                   │                ▼
                   │    ┌──────────────────────────────────┐
                   │    │ Step 8: Commit Changes            │
                   │    │ • Commit message includes:        │
                   │    │   - Source commit SHA             │
                   │    │   - Source branch name            │
                   │    │   - Source repository             │
                   │    │   - Workflow run ID               │
                   │    │   - Triggered by user             │
                   │    └───────────┬───────────────────────┘
                   │                │
                   │                ▼
                   │    ┌──────────────────────────────────┐
                   │    │ Step 9: Push Feature Branch       │
                   │    │ • Push to COI repository          │
                   │    │ • Branch: Fibi-Dev/{category}/    │
                   │    │            {source-branch}-       │
                   │    │            {timestamp}            │
                   │    └───────────┬───────────────────────┘
                   │                │
                   │                ▼
                   │    ┌──────────────────────────────────┐
                   │    │ Step 10: Create Pull Request      │
                   │    │ • Via GitHub API                  │
                   │    │ • Base: main/master (always)      │
                   │    │ • Head: feature branch            │
                   │    │ • Add labels: auto-sync           │
                   │    │ • PR body includes:               │
                   │    │   - Source information            │
                   │    │   - Changed files summary         │
                   │    │   - Review checklist              │
                   │    │   - Note about auto-delete        │
                   │    └───────────┬───────────────────────┘
                   │                │
                   │                ▼
                   │    ┌──────────────────────────────────┐
                   │    │ Step 11: PR Created Successfully  │
                   │    │ • PR link generated               │
                   │    │ • Ready for review                │
                   │    │ • Team reviews & approves         │
                   │    │ • PR merged to main               │
                   │    │ • Feature branch auto-deleted     │
                   │    │   (via repo settings)             │
                   │    └───────────────────────────────────┘
                   │
                   └───────────────────────────────┘
                     
                     
┌─────────────────────────────────────────────────────────────┐
│   Full Sync Workflow (Manual Trigger)                       │
│   ─────────────────────────────────────                     │
│   • Manually triggered via workflow_dispatch                │
│   • Syncs ALL Release folders                               │
│   • Syncs ALL Sprint folders                                │
│   • Syncs ALL Routines files                                │
│   • Creates PR with label: full-sync                        │
│   • Same PR creation process as above                       │
└─────────────────────────────────────────────────────────────┘
```

---

## ✅ **Key Features**

1. **Automatic**: Runs automatically on code changes
2. **Selective**: Only syncs versioned releases/sprints, excludes Vanilla
3. **Safe**: Only modifies `DB/CORE/` and `DB/ROUTINES/` in COI
4. **PR-based**: Creates Pull Requests instead of direct pushes (follows organization culture)
5. **Reviewable**: All changes go through PR review process before merging
6. **Traceable**: Every PR includes commit with source information and workflow links
7. **Main branch target**: Always creates PRs targeting main/master branch (not source branch)
8. **Branch naming**: Follows COI repository convention: `Fibi-Dev/{category}/{feature}`
9. **Auto-cleanup**: Feature branches are automatically deleted after PR merge

---

## 📝 **Example Scenario**

**Scenario**: Developer adds new procedure in Sprint folder

```
1. Developer creates: Sprint-2025-12-15/BASE/CORE/PROCEDURES.yaml
   → Workflow detects change ✅

2. Workflow finds: Sprint-2025-12-15/BASE/CORE/ exists ✅

3. Workflow copies:
   - Source: Sprint-2025-12-15/BASE/CORE/PROCEDURES.yaml
   - Dest: coi-repo/DB/CORE/Sprint-2025-12-15/PROCEDURES.yaml

4. Workflow finds SQL file referenced in YAML:
   - Source: ROUTINES/BASE/CORE/PROCEDURES/NEW_PROC.sql
   - Dest: coi-repo/DB/ROUTINES/CORE/PROCEDURES/NEW_PROC.sql

5. Workflow creates feature branch (following Fibi-Dev/*/* naming) and commits changes
6. Workflow pushes feature branch to COI repository
7. Workflow creates Pull Request targeting MAIN branch (not source branch)
8. Technical/Senior developers review and approve PR in COI repository
9. PR gets merged to main branch in COI repository
10. Feature branch is automatically deleted after merge (via repository settings)
```

---

## 🔐 **Safety Checks**

- ✅ Only stages files in `DB/CORE/` and `DB/ROUTINES/` directories
- ✅ Never modifies other parts of COI repository
- ✅ Validates files exist before copying
- ✅ Logs all operations for audit trail

---

## ⚠️ **Important Notes**

1. **Fibi-Vanilla is excluded**: Base/unversioned scripts are NOT synced
2. **Only BASE/CORE**: Client-specific CORE folders (e.g., JHU/CORE) are NOT synced
3. **Branch matching**: Syncs to same branch name in COI as in fibi-test
4. **Full sync available**: Manual workflow can sync all Release/Sprint folders at once

