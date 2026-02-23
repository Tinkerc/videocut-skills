# Project Structure Optimization Design

**Date:** 2026-02-23
**Author:** Claude Code
**Status:** Approved

## Overview

Restructure videocut-skills to use English directory names, consistent code/documentation separation, and improve maintainability and new contributor onboarding.

## Goals

1. **New contributor onboarding** - Make it easier for someone new to understand the codebase
2. **Skill maintainability** - Easier to update individual skills without breaking others
3. **CLI/automation friendly** - Remove Chinese names from paths

## Current Pain Points

- Hard to find which file does what (scripts and docs mixed)
- Skill boundaries are fuzzy
- Chinese directory names (剪口播, 字幕) make CLI/automation awkward

## Proposed Structure

```
videocut-skills/
├── README.md                    # Updated with new structure
├── CLAUDE.md                    # Updated skill routing
│
├── install/                     # 安装 → install
│   ├── docs/
│   │   ├── SKILL.md
│   │   └── README.md
│   └── scripts/
│
├── video-cut/                   # 剪口播 → video-cut
│   ├── docs/
│   │   ├── SKILL.md
│   │   ├── README.md
│   │   └── user-habits/
│   │       ├── README.md
│   │       ├── 01-core-principle.md
│   │       ├── 02-filler-words.md
│   │       ├── 03-silence-rules.md
│   │       ├── 04-duplicate-sentences.md
│   │       ├── 05-stutter-words.md
│   │       ├── 06-in-sentence-repeat.md
│   │       ├── 07-consecutive-fillers.md
│   │       ├── 08-restatement-correction.md
│   │       └── 09-incomplete-sentences.md
│   └── scripts/
│       ├── volcengine_transcribe.sh
│       ├── generate_subtitles.js
│       ├── generate_review.js
│       └── review_server.js
│
├── subtitle/                    # 字幕 → subtitle
│   ├── docs/
│   │   ├── SKILL.md
│   │   ├── README.md
│   │   └── dictionary.txt
│   └── scripts/
│       └── subtitle_server.js
│
└── self-evolve/                 # 自进化 → self-evolve
    ├── docs/
    │   ├── SKILL.md
    │   └── README.md
    └── scripts/
```

## File Mappings

### Directory Renames

| Old | New |
|-----|-----|
| `安装/` | `install/` |
| `剪口播/` | `video-cut/` |
| `字幕/` | `subtitle/` |
| `自进化/` | `self-evolve/` |

### Habit File Renames

| Old Filename | New Filename |
|--------------|--------------|
| `1-核心原则.md` | `01-core-principle.md` |
| `2-语气词检测.md` | `02-filler-words.md` |
| `3-静音段处理.md` | `03-silence-rules.md` |
| `4-重复句检测.md` | `04-duplicate-sentences.md` |
| `5-卡顿词.md` | `05-stutter-words.md` |
| `6-句内重复检测.md` | `06-in-sentence-repeat.md` |
| `7-连续语气词.md` | `07-consecutive-fillers.md` |
| `8-重说纠正.md` | `08-restatement-correction.md` |
| `9-残句检测.md` | `09-incomplete-sentences.md` |

## Content Updates Required

### SKILL.md Files
- Update all script path references to use new structure

### CLAUDE.md
- Update skill routing table with new skill names
- Update all path references in examples

### README.md
- Update directory references in examples and diagrams

### Script Files
- `review_server.js`: Update SKILL_DIR references
- `subtitle_server.js`: Update dictionary path to `../docs/dictionary.txt`
- `volcengine_transcribe.sh`: Update dictionary path reference

## Migration Strategy

### Phase 1: Create New Structure (Safe)
Create all new directories before copying files.

### Phase 2: Copy Files (Non-Destructive)
Copy all files to new locations. Keep old structure intact.

### Phase 3: Update Content
Update all path references in SKILL.md, CLAUDE.md, README.md, and scripts.

### Phase 4: Verification
- Check all files exist
- Verify no broken references
- Test skill invocation

### Phase 5: Remove Old Structure
Only after successful verification.

### Rollback Plan
Keep old directories until verification passes. Quick rollback: remove new directories, old structure remains.

## Success Criteria

1. ✅ No Chinese directory names remain
2. ✅ All skills have `docs/` and `scripts/` (where applicable)
3. ✅ No broken file references
4. ✅ README.md and CLAUDE.md are updated
5. ✅ All user-habit files are numbered and in English

## Trade-offs

| Pro | Con |
|-----|-----|
| Clean English names | Breaking change for existing users |
| Clear code/docs separation | One-time migration effort |
| Better CLI/automation support | Need to update documentation |
| Easier onboarding | - |
