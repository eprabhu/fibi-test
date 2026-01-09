# CORE Scripts Sync - Quick Overview

## What It Does
Automatically copies SQL scripts from `fibi-test` → `COI` repository when changes are made to Release or Sprint folders.

---

## 🔄 **Simple Algorithm**

```
STEP 1: Detect Changes
  └─› Is file in "Release/BASE/CORE" or "Sprint/BASE/CORE"? 
      ├─ YES → Continue
      └─ NO  → Skip

STEP 2: Find All Folders
  └─› Scan for:
      • Fibi-*-Release folders
      • Sprint-* folders
      └─› Only process if "BASE/CORE" exists

STEP 3: Collect Files
  └─› Get:
      • All CORE scripts (YAML, SQL, configs)
      • All ROUTINES files (from YAML references)

STEP 4: Copy to COI
  └─› Map paths:
      Source: "Sprint-2025-12-15/BASE/CORE/*"
      Dest:   "coi-repo/DB/CORE/Sprint-2025-12-15/*"

STEP 5: Commit & Push
  └─› Save changes to COI repository
      └─› Same branch name as source
```

---

## ✅ **What Gets Synced**
- ✅ **Release folders**: `Fibi-*-Release/BASE/CORE/**`
- ✅ **Sprint folders**: `Sprint-*/BASE/CORE/**`

## ❌ **What is Excluded**
- ❌ **Fibi-Vanilla**: `Fibi-Vanilla/FIBI_CORE/**` (base/unversioned scripts)

---

## 📊 **Visual Flow**

```
Developer Changes → Workflow Triggered → Find Folders → Collect Files → Copy to COI → Commit & Push
```

---

## 🎯 **Key Points**
1. **Automatic**: Runs on code changes (no manual trigger needed)
2. **Safe**: Only modifies `DB/CORE/` and `DB/ROUTINES/` in COI
3. **Selective**: Excludes Vanilla, includes Releases/Sprints
4. **Traceable**: Every sync creates a commit with source info

---

## 📝 **Real Example**

**Input:**
```
fibi-test/
  └─ Sprint-2025-12-15/
      └─ BASE/
          └─ CORE/
              └─ SCRIPTS.yaml (NEW)
```

**Output:**
```
coi-repo/
  └─ DB/
      └─ CORE/
          └─ Sprint-2025-12-15/
              └─ SCRIPTS.yaml (COPIED)
```

---

## ⏱️ **Timing**
- **Trigger**: On every push to `fibi-test`
- **Execution**: ~1-3 minutes
- **Frequency**: As needed (only when relevant files change)

