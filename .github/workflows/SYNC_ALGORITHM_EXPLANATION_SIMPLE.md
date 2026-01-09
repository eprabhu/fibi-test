# CORE Scripts Sync - Simple Explanation

## 🎯 **What Does This Do?**

**In Simple Terms:** 
When developers make changes to database scripts in the `fibi-test` repository, this system automatically copies those changes to the `coi` repository and creates a Pull Request for review.

---

## 📖 **The Simple Story**

### **1. Developer Makes Changes**
- Developer adds or updates SQL scripts in specific folders (Release folders, Sprint folders, or ROUTINES folder)
- Developer commits and pushes the changes

### **2. System Detects Changes**
- The system automatically notices: "Hey, something changed in these important folders!"
- It checks what type of files were changed

### **3. System Copies Files**
- The system copies the changed files to the `coi` repository
- Files go to the right places:
  - Scripts → `DB/CORE/` folder
  - Routines (procedures, functions, views) → `DB/ROUTINES/CORE/` folder

### **4. System Creates a Pull Request**
- Instead of directly updating the `coi` repository (which would be dangerous), the system:
  - Creates a special branch (like creating a separate copy to work on)
  - Puts all changes on that branch
  - Creates a Pull Request (PR) - like saying "Hey team, please review these changes!"

### **5. Team Reviews & Approves**
- Technical team members review the Pull Request
- They check if everything looks good
- If approved, they merge it (make it part of the main code)
- The special branch gets automatically deleted after merge

---

## ✅ **What Gets Synced?**

**Included (✅):**
- ✅ Changes in `Fibi-*-Release/BASE/CORE/` folders
- ✅ Changes in `Sprint-*/BASE/CORE/` folders  
- ✅ Changes in `ROUTINES/BASE/CORE/` folders

**Excluded (❌):**
- ❌ Files in `Fibi-Vanilla` folder (these are base/unversioned scripts)

---

## 🔄 **Two Ways to Sync**

### **Option 1: Automatic Sync** (Most Common)
- Happens automatically when files are changed
- Only syncs files that were actually changed
- Fast and efficient

### **Option 2: Full Sync** (Manual - When Needed)
- Can be manually triggered by administrators
- Syncs **everything** from all Release and Sprint folders
- Useful when you want to make sure everything is in sync

---

## 📋 **Simple Step-by-Step**

```
1. Developer changes a file
   ↓
2. System detects the change
   ↓
3. System copies file to COI repository
   ↓
4. System creates a Pull Request
   ↓
5. Team reviews the PR
   ↓
6. PR gets approved and merged
   ↓
7. Changes are now in COI repository ✅
```

---

## 💡 **Why Do We Do This?**

**Benefits:**
- ✅ **Automation**: No manual copying needed - saves time
- ✅ **Safety**: Changes go through review process before being merged
- ✅ **Traceability**: We can see exactly what changed and who changed it
- ✅ **Consistency**: Same files stay synchronized between repositories
- ✅ **Quality Control**: Team reviews ensure nothing breaks

---

## 🎯 **Real-World Example**

**Scenario:** Developer adds a new database procedure

**What Happens:**
1. Developer creates a new SQL file: `ROUTINES/BASE/CORE/PROCEDURES/NEW_PROCEDURE.sql`
2. Developer commits and pushes to `fibi-test`
3. System automatically:
   - Detects the new file
   - Copies it to `coi/DB/ROUTINES/CORE/PROCEDURES/NEW_PROCEDURE.sql`
   - Creates a Pull Request titled "🔄 Auto-sync: CORE and ROUTINES from fibi-test"
4. Team gets notified about the new PR
5. Team reviews the PR (checks if the procedure looks good)
6. If approved, PR is merged
7. New procedure is now available in COI repository ✅

**Time Saved:** Instead of manually copying files and creating PRs, it's all done automatically!

---

## 🔐 **Safety Features**

**What the System Does to Keep Things Safe:**
- ✅ Only changes files in `DB/CORE/` and `DB/ROUTINES/` folders (never touches other files)
- ✅ Creates Pull Requests instead of directly updating (so changes can be reviewed)
- ✅ Always targets the main branch (never messes with feature branches)
- ✅ Includes all details about what changed and why
- ✅ Automatically deletes temporary branches after merge (keeps things clean)

---

## 📊 **Visual Summary**

```
Developer Makes Change
         ↓
   System Detects
         ↓
   System Copies
         ↓
   Creates PR
         ↓
   Team Reviews
         ↓
   PR Approved
         ↓
   Changes Live! ✅
```

---

## ❓ **Common Questions**

**Q: Do I need to do anything?**
A: No! Once you commit and push your changes, the system handles everything automatically.

**Q: What if I make a mistake?**
A: The Pull Request review process will catch issues before they're merged. You can also fix and re-push.

**Q: How long does it take?**
A: Usually completes in 1-2 minutes. Then it waits for team review.

**Q: What if the system fails?**
A: You'll get an email notification. You can check the workflow logs to see what went wrong.

**Q: Can I skip the PR review?**
A: No, and that's a good thing! All changes must be reviewed for safety.

---

## 🎓 **Summary in One Sentence**

**"This system automatically copies database scripts from fibi-test to coi and creates a Pull Request for team review - making the sync process safe, automatic, and traceable."**

---

## 📞 **Need Help?**

If you have questions or something doesn't work as expected:
1. Check the workflow logs in GitHub Actions
2. Contact the DevOps/Infrastructure team
3. Check the detailed documentation in `SYNC_ALGORITHM_EXPLANATION.md`

