---
name: videocut:转录
description: 视频转字幕 Markdown。提取音频、上传、火山引擎转录、生成可读字幕文件。触发词：转录视频、生成字幕、提取字幕
---

<!--
input: 视频文件 (*.mp4)
output: transcription.md (字幕 Markdown 文件)
pos: 前置流程，只负责转录不剪辑

架构守护者：一旦我被修改，请同步更新：
1. ../../README.md 的 Skill 清单
2. ../../CLAUDE.md 路由表
-->

# 转录 v1

> 视频音频提取 + 火山引擎转录 → Markdown 字幕文件

## 快速使用

```
用户: 把这个视频转录成字幕
用户: 生成这个视频的字幕文件
用户: 提取视频字幕
```

## 输出目录结构

```
output/
└── YYYY-MM-DD_视频名/
    └── transcribe/
        ├── audio.mp3
        ├── volcengine_result.json
        ├── subtitles_words.json
        └── transcription.md
```

## 流程

```
1. 提取音频 (ffmpeg)
    ↓
2. 上传获取公网 URL (uguu.se)
    ↓
3. 火山引擎 API 转录
    ↓
4. 生成字级别字幕 (subtitles_words.json)
    ↓
5. 转换为 Markdown 格式 (transcription.md)
```

## 执行步骤

### 步骤 0: 创建输出目录

```bash
# 变量设置
VIDEO_PATH="/path/to/视频.mp4"
VIDEO_NAME=$(basename "$VIDEO_PATH" .mp4)
DATE=$(date +%Y-%m-%d)
BASE_DIR="output/${DATE}_${VIDEO_NAME}/transcribe"

mkdir -p "$BASE_DIR"
cd "$BASE_DIR"
```

### 步骤 1: 提取音频

```bash
# 文件名有冒号需加 file: 前缀
ffmpeg -i "file:$VIDEO_PATH" -vn -acodec libmp3lame -y audio.mp3
```

### 步骤 2: 上传获取公网 URL

```bash
SKILL_DIR="$(dirname "$0")/.."
AUDIO_URL=$(bash "$SKILL_DIR/scripts/upload_audio.sh" audio.mp3)
# 输出: https://h.uguu.se/xxx.mp3
```

### 步骤 3: 火山引擎转录（v3 API）

```bash
bash "$SKILL_DIR/scripts/volcengine_transcribe.sh" "$AUDIO_URL"
# 输出: volcengine_result.json
```

> **API 版本**: 使用火山引擎 v3 API (`/api/v3/auc/bigmodel/*`)，需要以下头部：
> - `x-api-key`: API 认证密钥
> - `X-Api-Resource-Id`: volc.seedasr.auc
> - `X-Api-Request-Id`: 自动生成的 UUID

### 步骤 4: 生成字级别字幕

```bash
node "$SKILL_DIR/scripts/generate_subtitles.js" volcengine_result.json
# 输出: subtitles_words.json
```

### 步骤 5: 生成 Markdown 字幕

```bash
node "$SKILL_DIR/scripts/generate_markdown.js" subtitles_words.json transcription.md
# 输出: transcription.md
```

## 数据格式

### subtitles_words.json

```json
[
  {"text": "大", "start": 0.12, "end": 0.2, "isGap": false},
  {"text": "", "start": 6.78, "end": 7.48, "isGap": true}
]
```

### transcription.md 输出格式

```markdown
# 视频字幕

## 00:00 - 00:15
大家好，我是张三。今天来讲一下视频剪辑。

## 00:17 - 00:32
首先我们需要准备一些工具...

...
```

## 配置

### 火山引擎 API Key

```bash
# 在项目根目录创建 .claude/skills/.env
echo "VOLCENGINE_API_KEY=your_key" > .claude/skills/.env
```
