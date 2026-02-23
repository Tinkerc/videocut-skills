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
- `03-silence-rules.md` (was `3-静音段处理.md`)
- `04-duplicate-sentences.md` (was `4-重复句检测.md`)
- `05-stutter-words.md` (was `5-卡顿词.md`)
- `06-in-sentence-repeat.md` (was `6-句内重复检测.md`)
- `07-consecutive-fillers.md` (was `7-连续语气词.md`)
- `08-restatement-correction.md` (was `8-重说纠正.md`)
- `09-incomplete-sentences.md` (was `9-残句检测.md`)

### subtitle/docs/
- `dictionary.txt` (was `词典.txt`)

## Action Required

If you have any custom scripts or configurations referencing the old paths, update them to use the new English directory names.

## Migration Date
2026-02-23
