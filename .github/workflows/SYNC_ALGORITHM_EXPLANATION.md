# CORE Scripts Sync Algorithm - Executive Summary

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
  → Create feature branch: "sync/core-from-fibi-test-{source-branch}-{timestamp}"
  → Stage only files in DB/CORE/ and DB/ROUTINES/ directories
  → Create commit with sync details on feature branch
  → Push feature branch to COI repository
  → Create Pull Request from feature branch to target branch (main/master or source branch)
  → Add auto-sync label to PR
ELSE:
  → Skip PR creation (no changes to sync)
  → Clean up feature branch if created
```

---

## 📊 **Visual Flow Diagram**

```
┌─────────────────────────────────┐
│   Developer makes changes       │
│   in fibi-test repository       │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│   Workflow Triggered?           │
│   ✓ Release/BASE/CORE changed?  │
│   ✓ Sprint/BASE/CORE changed?   │
│   ✗ Fibi-Vanilla changed?       │
└──────────────┬──────────────────┘
               │ YES (if Release/Sprint)
               ▼
┌─────────────────────────────────┐
│   Discover Source Folders       │
│   • Find all Fibi-*-Release     │
│   • Find all Sprint-*           │
│   • Filter: Must have BASE/CORE │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│   Collect Files                 │
│   1. CORE scripts (YAML, SQL)   │
│   2. ROUTINES (from YAML refs)  │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│   Map to COI Structure          │
│   Source → DB/CORE/...          │
│   Routines → DB/ROUTINES/...    │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│   Copy Files                    │
│   • Create folders if needed    │
│   • Copy all files              │
│   • Verify success              │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│   Create Feature Branch         │
│   • Create branch with timestamp│
│   • Stage DB/CORE & DB/ROUTINES │
│   • Commit with metadata        │
│   • Push feature branch         │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│   Create Pull Request           │
│   • PR: feature → target branch │
│   • Add auto-sync label         │
│   • Include sync details        │
│   • Await review & approval     │
└─────────────────────────────────┘
```

---

## ✅ **Key Features**

1. **Automatic**: Runs automatically on code changes
2. **Selective**: Only syncs versioned releases/sprints, excludes Vanilla
3. **Safe**: Only modifies `DB/CORE/` and `DB/ROUTINES/` in COI
4. **PR-based**: Creates Pull Requests instead of direct pushes (follows organization culture)
5. **Reviewable**: All changes go through PR review process before merging
6. **Traceable**: Every PR includes commit with source information and workflow links
7. **Branch-aware**: Creates PRs targeting the same branch name in COI repository (or main/master)

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

5. Workflow creates feature branch and commits changes
6. Workflow pushes feature branch and creates Pull Request
7. Technical/Senior developers review and approve PR
8. PR gets merged to COI repository (following organization culture)
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

