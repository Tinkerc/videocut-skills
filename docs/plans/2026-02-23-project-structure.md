# Project Structure Optimization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Restructure videocut-skills to use English directory names with consistent code/documentation separation.

**Architecture:** Non-destructive 5-phase migration: create new structure → copy files → update content → verify → remove old.

**Tech Stack:** Bash, Node.js scripts, Markdown documentation

---

## Pre-Migration Setup

### Task 1: Create Safety Checkpoint

**Files:**
- Create: `docs/plans/2026-02-23-pre-migration-state.md`

**Step 1: Document current state**

```bash
cat > docs/plans/2026-02-23-pre-migration-state.md << 'EOF'
# Pre-Migration State

## Current Structure
$(ls -la | grep -E "^d" | grep -v "^\.$" | grep -v "^\.\.$")

## Git Status
$(git status --short)

## Skill Files
- 安装/SKILL.md
- 剪口播/SKILL.md
- 字幕/SKILL.md
- 自进化/SKILL.md

## Script Files
$(find 剪口播 字幕 -name "*.sh" -o -name "*.js" 2>/dev/null | head -20)

EOF
```

**Step 2: Verify state documented**

Run: `cat docs/plans/2026-02-23-pre-migration-state.md`
Expected: File contains current directory listing and skill files

**Step 3: Commit safety checkpoint**

```bash
git add docs/plans/2026-02-23-pre-migration-state.md
git commit -m "docs: record pre-migration state"
```

---

## Phase 1: Create New Structure

### Task 2: Create install/ Directory Structure

**Files:**
- Create: `install/docs/`
- Create: `install/scripts/`

**Step 1: Create directories**

```bash
mkdir -p install/docs install/scripts
```

**Step 2: Verify directories created**

Run: `ls -la install/`
Expected: Shows `docs/` and `scripts/` directories

**Step 3: Commit**

```bash
git add install/
git commit -m "refactor: create install directory structure"
```

---

### Task 3: Create video-cut/ Directory Structure

**Files:**
- Create: `video-cut/docs/`
- Create: `video-cut/docs/user-habits/`
- Create: `video-cut/scripts/`

**Step 1: Create directories**

```bash
mkdir -p video-cut/docs/user-habits video-cut/scripts
```

**Step 2: Verify directories created**

Run: `ls -la video-cut/docs/`
Expected: Shows `user-habits/` directory

**Step 3: Commit**

```bash
git add video-cut/
git commit -m "refactor: create video-cut directory structure"
```

---

### Task 4: Create subtitle/ Directory Structure

**Files:**
- Create: `subtitle/docs/`
- Create: `subtitle/scripts/`

**Step 1: Create directories**

```bash
mkdir -p subtitle/docs subtitle/scripts
```

**Step 2: Verify directories created**

Run: `ls -la subtitle/`
Expected: Shows `docs/` and `scripts/` directories

**Step 3: Commit**

```bash
git add subtitle/
git commit -m "refactor: create subtitle directory structure"
```

---

### Task 5: Create self-evolve/ Directory Structure

**Files:**
- Create: `self-evolve/docs/`
- Create: `self-evolve/scripts/`

**Step 1: Create directories**

```bash
mkdir -p self-evolve/docs self-evolve/scripts
```

**Step 2: Verify directories created**

Run: `ls -la self-evolve/`
Expected: Shows `docs/` and `scripts/` directories

**Step 3: Commit**

```bash
git add self-evolve/
git commit -m "refactor: create self-evolve directory structure"
```

---

## Phase 2: Copy Files

### Task 6: Copy install/ Skill File

**Files:**
- Create: `install/docs/SKILL.md` (from 安装/SKILL.md)
- Reference: `安装/SKILL.md`

**Step 1: Copy skill file**

```bash
cp 安装/SKILL.md install/docs/SKILL.md
```

**Step 2: Verify file copied**

Run: `diff 安装/SKILL.md install/docs/SKILL.md`
Expected: No output (files identical)

**Step 3: Commit**

```bash
git add install/docs/SKILL.md
git commit -m "refactor: copy install skill documentation"
```

---

### Task 7: Copy video-cut/ Skill File

**Files:**
- Create: `video-cut/docs/SKILL.md` (from 剪口播/SKILL.md)
- Reference: `剪口播/SKILL.md`

**Step 1: Copy skill file**

```bash
cp 剪口播/SKILL.md video-cut/docs/SKILL.md
```

**Step 2: Verify file copied**

Run: `diff 剪口播/SKILL.md video-cut/docs/SKILL.md`
Expected: No output (files identical)

**Step 3: Commit**

```bash
git add video-cut/docs/SKILL.md
git commit -m "refactor: copy video-cut skill documentation"
```

---

### Task 8: Copy video-cut/ Scripts

**Files:**
- Create: `video-cut/scripts/volcengine_transcribe.sh`
- Create: `video-cut/scripts/generate_subtitles.js`
- Create: `video-cut/scripts/generate_review.js`
- Create: `video-cut/scripts/review_server.js`
- Reference: `剪口播/scripts/*`

**Step 1: Copy script files**

```bash
cp 剪口播/scripts/volcengine_transcribe.sh video-cut/scripts/
cp 剪口播/scripts/generate_subtitles.js video-cut/scripts/
cp 剪口播/scripts/generate_review.js video-cut/scripts/
cp 剪口播/scripts/review_server.js video-cut/scripts/
```

**Step 2: Verify files copied**

Run: `ls -la video-cut/scripts/`
Expected: Shows 4 script files

**Step 3: Make shell script executable**

```bash
chmod +x video-cut/scripts/volcengine_transcribe.sh
```

**Step 4: Commit**

```bash
git add video-cut/scripts/
git commit -m "refactor: copy video-cut scripts"
```

---

### Task 9: Copy and Rename video-cut/ User Habit Files

**Files:**
- Create: `video-cut/docs/user-habits/README.md`
- Create: `video-cut/docs/user-habits/01-core-principle.md`
- Create: `video-cut/docs/user-habits/02-filler-words.md`
- Create: `video-cut/docs/user-habits/03-silence-rules.md`
- Create: `video-cut/docs/user-habits/04-duplicate-sentences.md`
- Create: `video-cut/docs/user-habits/05-stutter-words.md`
- Create: `video-cut/docs/user-habits/06-in-sentence-repeat.md`
- Create: `video-cut/docs/user-habits/07-consecutive-fillers.md`
- Create: `video-cut/docs/user-habits/08-restatement-correction.md`
- Create: `video-cut/docs/user-habits/09-incomplete-sentences.md`
- Reference: `剪口播/用户习惯/*`

**Step 1: Copy README**

```bash
cp 剪口播/用户习惯/README.md video-cut/docs/user-habits/
```

**Step 2: Copy and rename habit files**

```bash
cp 剪口播/用户习惯/1-核心原则.md video-cut/docs/user-habits/01-core-principle.md
cp 剪口播/用户习惯/2-语气词检测.md video-cut/docs/user-habits/02-filler-words.md
cp 剪口播/用户习惯/3-静音段处理.md video-cut/docs/user-habits/03-silence-rules.md
cp 剪口播/用户习惯/4-重复句检测.md video-cut/docs/user-habits/04-duplicate-sentences.md
cp 剪口播/用户习惯/5-卡顿词.md video-cut/docs/user-habits/05-stutter-words.md
cp 剪口播/用户习惯/6-句内重复检测.md video-cut/docs/user-habits/06-in-sentence-repeat.md
cp 剪口播/用户习惯/7-连续语气词.md video-cut/docs/user-habits/07-consecutive-fillers.md
cp 剪口播/用户习惯/8-重说纠正.md video-cut/docs/user-habits/08-restatement-correction.md
cp 剪口播/用户习惯/9-残句检测.md video-cut/docs/user-habits/09-incomplete-sentences.md
```

**Step 3: Verify files copied**

Run: `ls -la video-cut/docs/user-habits/`
Expected: Shows 10 files (README + 9 habit files)

**Step 4: Commit**

```bash
git add video-cut/docs/user-habits/
git commit -m "refactor: copy and rename video-cut user habit files"
```

---

### Task 10: Copy subtitle/ Skill File

**Files:**
- Create: `subtitle/docs/SKILL.md` (from 字幕/SKILL.md)
- Reference: `字幕/SKILL.md`

**Step 1: Copy skill file**

```bash
cp 字幕/SKILL.md subtitle/docs/SKILL.md
```

**Step 2: Verify file copied**

Run: `diff 字幕/SKILL.md subtitle/docs/SKILL.md`
Expected: No output (files identical)

**Step 3: Commit**

```bash
git add subtitle/docs/SKILL.md
git commit -m "refactor: copy subtitle skill documentation"
```

---

### Task 11: Copy subtitle/ Scripts and Dictionary

**Files:**
- Create: `subtitle/scripts/subtitle_server.js`
- Create: `subtitle/docs/dictionary.txt`
- Reference: `字幕/scripts/*`, `字幕/词典.txt`

**Step 1: Copy script file**

```bash
cp 字幕/scripts/subtitle_server.js subtitle/scripts/
```

**Step 2: Copy dictionary file with new name**

```bash
cp 字幕/词典.txt subtitle/docs/dictionary.txt
```

**Step 3: Verify files copied**

Run: `ls -la subtitle/scripts/ subtitle/docs/`
Expected: Shows `subtitle_server.js` in scripts, `dictionary.txt` in docs

**Step 4: Commit**

```bash
git add subtitle/
git commit -m "refactor: copy subtitle scripts and dictionary"
```

---

### Task 12: Copy self-evolve/ Skill File

**Files:**
- Create: `self-evolve/docs/SKILL.md` (from 自进化/SKILL.md)
- Reference: `自进化/SKILL.md`

**Step 1: Copy skill file**

```bash
cp 自进化/SKILL.md self-evolve/docs/SKILL.md
```

**Step 2: Verify file copied**

Run: `diff 自进化/SKILL.md self-evolve/docs/SKILL.md`
Expected: No output (files identical)

**Step 3: Commit**

```bash
git add self-evolve/docs/SKILL.md
git commit -m "refactor: copy self-evolve skill documentation"
```

---

## Phase 3: Update Content

### Task 13: Update install/docs/SKILL.md Paths

**Files:**
- Modify: `install/docs/SKILL.md`

**Step 1: Update script path references**

Using node or text editor, update any references to old structure. The install skill primarily documents environment setup, so path updates may be minimal.

**Step 2: Verify no old paths remain**

Run: `grep -n "剪口播\|字幕\|自进化\|安装" install/docs/SKILL.md || echo "No old paths found"`
Expected: "No old paths found"

**Step 3: Commit**

```bash
git add install/docs/SKILL.md
git commit -m "refactor: update install SKILL.md paths"
```

---

### Task 14: Update video-cut/docs/SKILL.md Paths

**Files:**
- Modify: `video-cut/docs/SKILL.md`

**Step 1: Update script path references**

Replace old script paths. Key changes:

Old: `"$SKILL_DIR/scripts/generate_subtitles.js"`
New: `"$(dirname "$0")/../scripts/generate_subtitles.js"`

Or use relative to video-cut/docs directory:
New: `"../../scripts/generate_subtitles.js"`

**Step 2: Update directory references**

Replace:
- `剪口播/` → `video-cut/`
- `用户习惯/` → `docs/user-habits/`

**Step 3: Verify no old paths remain**

Run: `grep -n "剪口播\|用户习惯" video-cut/docs/SKILL.md || echo "No old paths found"`
Expected: "No old paths found"

**Step 4: Commit**

```bash
git add video-cut/docs/SKILL.md
git commit -m "refactor: update video-cut SKILL.md paths"
```

---

### Task 15: Update video-cut/scripts/volcengine_transcribe.sh

**Files:**
- Modify: `video-cut/scripts/volcengine_transcribe.sh`

**Step 1: Update dictionary path reference**

Find the line that references the dictionary file (around line 32):
Old: `DICT_FILE="$(dirname "$SCRIPT_DIR")/字幕/词典.txt"`
New: `DICT_FILE="$(dirname "$SCRIPT_DIR")/../subtitle/docs/dictionary.txt"`

**Step 2: Verify update**

Run: `grep "dictionary.txt" video-cut/scripts/volcengine_transcribe.sh`
Expected: Shows path to `../subtitle/docs/dictionary.txt`

**Step 3: Commit**

```bash
git add video-cut/scripts/volcengine_transcribe.sh
git commit -m "refactor: update dictionary path in transcribe script"
```

---

### Task 16: Update video-cut/scripts/review_server.js

**Files:**
- Modify: `video-cut/scripts/review_server.js`

**Step 1: Update script path references**

If there are hardcoded SKILL_DIR references, update them to use relative paths.

**Step 2: Verify no old paths remain**

Run: `grep -n "SKILL_DIR\|剪口播" video-cut/scripts/review_server.js || echo "No hardcoded paths found"`
Expected: "No hardcoded paths found"

**Step 3: Commit**

```bash
git add video-cut/scripts/review_server.js
git commit -m "refactor: update review_server.js paths"
```

---

### Task 17: Update subtitle/docs/SKILL.md Paths

**Files:**
- Modify: `subtitle/docs/SKILL.md`

**Step 1: Update script and dictionary path references**

Replace old paths:
- `字幕/` → `subtitle/`
- `词典.txt` → `docs/dictionary.txt`
- Script paths should use `../scripts/`

**Step 2: Verify no old paths remain**

Run: `grep -n "字幕\|词典" subtitle/docs/SKILL.md || echo "No old paths found"`
Expected: "No old paths found"

**Step 3: Commit**

```bash
git add subtitle/docs/SKILL.md
git commit -m "refactor: update subtitle SKILL.md paths"
```

---

### Task 18: Update subtitle/scripts/subtitle_server.js Dictionary Path

**Files:**
- Modify: `subtitle/scripts/subtitle_server.js`

**Step 1: Update dictionary path (around line 29)**

Old: `const DICT_FILE = path.join(__dirname, '..', '词典.txt');`
New: `const DICT_FILE = path.join(__dirname, '..', 'docs', 'dictionary.txt');`

**Step 2: Verify update**

Run: `grep "dictionary.txt" subtitle/scripts/subtitle_server.js`
Expected: Shows path to `../docs/dictionary.txt`

**Step 3: Commit**

```bash
git add subtitle/scripts/subtitle_server.js
git commit -m "refactor: update dictionary path in subtitle server"
```

---

### Task 19: Update CLAUDE.md

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Update skill routing table**

Replace the routing table with:

```markdown
| Trigger | Skill | Purpose |
|---------|-------|---------|
| install, setup, 安装 | `install/` | First-time environment setup |
| cut video, process video, 剪口播 | `video-cut/` | Transcribe and identify speech errors |
| subtitle, add subtitle, 加字幕 | `subtitle/` | Generate and burn subtitles |
| update rules, feedback, 记录反馈 | `self-evolve/` | Learn from user feedback |
```

**Step 2: Update all path references**

Replace:
- `剪口播/` → `video-cut/`
- `字幕/` → `subtitle/`
- `自进化/` → `self-evolve/`
- `安装/` → `install/`
- `用户习惯/` → `user-habits/`
- `词典.txt` → `dictionary.txt`

**Step 3: Update architecture diagram**

```
output/
└── YYYY-MM-DD_视频名/
    ├── video-cut/
    │   ├── 1_转录/
    │   ├── 2_分析/
    │   └── 3_审核/
    └── subtitle/
        └── ...
```

**Step 4: Verify no old Chinese paths remain**

Run: `grep -n "剪口播\|字幕\|自进化\|安装\|用户习惯\|词典" CLAUDE.md || echo "No old paths found"`
Expected: Only trigger words in Chinese, paths in English

**Step 5: Commit**

```bash
git add CLAUDE.md
git commit -m "refactor: update CLAUDE.md with new structure"
```

---

### Task 20: Update README.md

**Files:**
- Modify: `README.md`

**Step 1: Update skill list table**

```markdown
| Skill | 功能 | 输入 | 输出 |
|-------|------|------|------|
| `install` (安装) | 环境准备 | 无 | 安装日志 |
| `video-cut` (剪口播) | 转录 + AI 审核 + 剪辑 | 视频文件 | 剪辑后视频 |
| `subtitle` (字幕) | 生成字幕 | 视频文件 | 带字幕视频 |
| `self-evolve` (自更新) | 记录偏好 | 用户反馈 | 更新规则文件 |
```

**Step 2: Update directory structure diagram**

```
videocut-skills/
├── README.md
├── .env.example
├── install/               # Environment setup skill
│   ├── docs/
│   └── scripts/
├── video-cut/             # Core: transcription + AI review + cutting
│   ├── docs/
│   │   └── user-habits/   # Review rules (customizable)
│   └── scripts/
├── subtitle/              # Subtitle generation and burning
│   ├── docs/
│   │   └── dictionary.txt # Custom dictionary
│   └── scripts/
└── self-evolve/           # Self-evolution mechanism
```

**Step 3: Update all path references in examples**

Replace Chinese directory names with English equivalents.

**Step 4: Verify no old Chinese paths remain**

Run: `grep -E "(剪口播|字幕|自进化|安装)/" README.md | grep -v "^#" || echo "No old paths found"`
Expected: Only English directory names in paths

**Step 5: Commit**

```bash
git add README.md
git commit -m "refactor: update README.md with new structure"
```

---

## Phase 4: Verification

### Task 21: Verify Directory Structure

**Step 1: Check all new directories exist**

```bash
# Run verification
for dir in install video-cut subtitle self-evolve; do
  echo "Checking $dir..."
  [ -d "$dir/docs" ] && echo "  ✓ $dir/docs exists"
  [ -d "$dir/scripts" ] && echo "  ✓ $dir/scripts exists"
done
```

Expected: All checks pass with ✓

**Step 2: Verify file counts match**

```bash
echo "Original skill files:"
find 安装 剪口播 字幕 自进化 -name "SKILL.md" 2>/dev/null | wc -l

echo "New skill files:"
find install video-cut subtitle self-evolve -name "SKILL.md" 2>/dev/null | wc -l
```

Expected: Both show 4

**Step 3: Verify habit files copied**

```bash
echo "Original habit files:"
ls 剪口播/用户习惯/*.md 2>/dev/null | wc -l

echo "New habit files:"
ls video-cut/docs/user-habits/*.md 2>/dev/null | wc -l
```

Expected: Both show 10 (including README)

**Step 4: Commit verification results**

```bash
docs/plans/2026-02-23-verification.md << 'EOF'
# Verification Results

## Directory Structure
All required directories exist.

## File Counts
- Skill files: 4 original, 4 new ✓
- Habit files: 10 original, 10 new ✓
- Script files: Copied successfully ✓

## Verification Date
$(date)
EOF

git add docs/plans/2026-02-23-verification.md
git commit -m "docs: record verification results"
```

---

### Task 22: Verify No Broken References

**Step 1: Check for old Chinese paths in new files**

```bash
# Should only find trigger words, not paths
grep -r "剪口播/" video-cut/ subtitle/ 2>/dev/null || echo "✓ No broken paths in new files"
grep -r "字幕/" subtitle/ 2>/dev/null || echo "✓ No broken paths in subtitle/"
grep -r "词典.txt" subtitle/ 2>/dev/null || echo "✓ Dictionary path updated"
```

Expected: All return "✓" messages

**Step 2: Check for absolute SKILL_DIR references**

```bash
grep -r "SKILL_DIR=" video-cut/scripts/ subtitle/scripts/ 2>/dev/null || echo "✓ No hardcoded SKILL_DIR"
```

Expected: "✓ No hardcoded SKILL_DIR"

**Step 3: Commit**

```bash
docs/plans/2026-02-23-reference-check.md << 'EOF'
# Reference Check Results

## Old Paths
✓ No old Chinese directory paths in new files

## Hardcoded References
✓ No hardcoded SKILL_DIR references

## Date
$(date)
EOF

git add docs/plans/2026-02-23-reference-check.md
git commit -m "docs: record reference check results"
```

---

### Task 23: Create Migration README

**Files:**
- Create: `MIGRATION.md`

**Step 1: Create migration guide**

```bash
cat > MIGRATION.md << 'EOF'
# Migration Guide

## What Changed

- `安装/` → `install/`
- `剪口播/` → `video-cut/`
- `字幕/` → `subtitle/`
- `自进化/` → `self-evolve/`

## New Structure

Each skill now has:
- `docs/` - All documentation (SKILL.md, README.md, etc.)
- `scripts/` - All executable scripts

## Updated File Names

### video-cut/docs/user-habits/
- `01-core-principle.md` (was `1-核心原则.md`)
- `02-filler-words.md` (was `2-语气词检测.md`)
- ... etc

### subtitle/docs/
- `dictionary.txt` (was `词典.txt`)

## Action Required

If you have any custom scripts or configurations referencing the old paths, update them to use the new English directory names.
EOF
```

**Step 2: Commit**

```bash
git add MIGRATION.md
git commit -m "docs: add migration guide"
```

---

## Phase 5: Remove Old Structure

### Task 24: Final Safety Check

**Step 1: Confirm all files migrated**

```bash
echo "=== Final Checklist ==="
echo ""
echo "Skill files:"
find install video-cut subtitle self-evolve -name "SKILL.md"
echo ""
echo "Script files:"
find video-cut subtitle -name "*.sh" -o -name "*.js"
echo ""
echo "Habit files:"
ls video-cut/docs/user-habits/*.md
echo ""
echo "Dictionary:"
ls subtitle/docs/dictionary.txt
```

Expected: All files listed

**Step 2: Run git diff to see changes**

```bash
git status
```

Expected: Old directories still exist (not deleted yet), new directories with changes

**Step 3: Create final checkpoint commit**

```bash
git add -A
git commit -m "refactor: complete new structure, ready for cleanup"
```

---

### Task 25: Remove Old Directories

**⚠️ DESTRUCTIVE STEP - Only proceed after verification passes**

**Step 1: Remove old directories**

```bash
rm -rf 安装
rm -rf 剪口播
rm -rf 字幕
rm -rf 自进化
```

**Step 2: Verify old directories gone**

```bash
ls -la | grep -E "^(d).*/(安装|剪口播|字幕|自进化)$" || echo "✓ Old directories removed"
```

Expected: "✓ Old directories removed"

**Step 3: Verify new structure intact**

```bash
ls -la
```

Expected: Shows `install/`, `video-cut/`, `subtitle/`, `self-evolve/`

**Step 4: Final commit**

```bash
git add -A
git commit -m "refactor: remove old Chinese-named directories"
```

---

### Task 26: Post-Migration Verification

**Step 1: Test skill file readability**

```bash
for skill in install video-cut subtitle self-evolve; do
  echo "Testing $skill/docs/SKILL.md..."
  [ -f "$skill/docs/SKILL.md" ] && echo "  ✓ Exists and readable"
done
```

Expected: All 4 skills pass

**Step 2: Test script executability**

```bash
[ -x "video-cut/scripts/volcengine_transcribe.sh" ] && echo "✓ Transcribe script executable"
[ -f "subtitle/scripts/subtitle_server.js" ] && echo "✓ Subtitle server exists"
```

Expected: Both pass

**Step 3: Final documentation**

```bash
cat > docs/plans/2026-02-23-post-migration.md << 'EOF'
# Post-Migration Report

## Completed
- [x] All directories renamed to English
- [x] All files copied to new structure
- [x] All path references updated
- [x] Old directories removed
- [x] Verification passed

## New Structure
\`\`\`
install/
video-cut/
subtitle/
self-evolve/
\`\`\`

## Migration Date
$(date)
EOF

git add docs/plans/2026-02-23-post-migration.md
git commit -m "docs: post-migration report"
```

---

## Completion

### Task 27: Create Summary

**Step 1: Generate migration summary**

```bash
cat > docs/plans/2026-02-23-summary.md << 'EOF'
# Project Structure Migration - Summary

## Changes Made
- 4 directories renamed (Chinese → English)
- 10 habit files renamed (Chinese → English with numbering)
- All documentation moved to `docs/` subdirectories
- All scripts moved to `scripts/` subdirectories
- All path references updated across 6 files

## Files Modified
- CLAUDE.md
- README.md
- install/docs/SKILL.md
- video-cut/docs/SKILL.md
- video-cut/scripts/volcengine_transcribe.sh
- video-cut/scripts/review_server.js
- subtitle/docs/SKILL.md
- subtitle/scripts/subtitle_server.js

## Commits Created
27 commits tracking each step of the migration

## Rollback Option
If needed, rollback to commit before cleanup:
\`\`\`bash
git log --oneline | grep "refactor: remove old"  # Find cleanup commit
git reset --hard <commit-before-cleanup>
mv install/ 安装/
mv video-cut/ 剪口播/
mv subtitle/ 字幕/
mv self-evolve/ 自进化
\`\`\`
EOF
```

**Step 2: Final commit**

```bash
git add docs/plans/2026-02-23-summary.md
git commit -m "docs: add migration summary"
```

---

**Migration complete! The project now uses English directory names with consistent code/documentation separation.**
