---
name: videocut:提交
description: 提交剪辑 skills 代码到 Git。触发词：提交skill、提交代码、push skill、保存skill
---

<!--
input: 无
output: git commit + push
pos: 工具 skill
-->

# 提交 Skills

> 将剪辑 skills 的改动提交到 Git 仓库

## 仓库信息

- **路径**: `/Users/chengfeng/Desktop/AIos/剪辑Agent/.claude/skills/`
- **远程**: `https://github.com/Ceeon/videocut-skills.git`
- **分支**: `main`

## 执行步骤

```bash
cd /Users/chengfeng/Desktop/AIos/剪辑Agent/.claude/skills/

# 1. 查看改动
git status
git diff --stat

# 2. 添加文件（逐个添加，不用 git add -A）
git add <changed files>

# 3. 提交（中文 commit message，格式参考历史）
git commit -m "feat/fix/refactor: 简要描述"

# 4. 推送
git push origin main
```

## Commit Message 规范

参考仓库历史风格：
- `feat: 新功能描述`
- `fix: 修复描述`
- `refactor: 重构描述`
- 正文用中文，简明扼要
