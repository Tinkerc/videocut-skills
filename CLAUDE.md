# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Videocut Skills is a video editing agent built with Claude Code Skills, designed specifically for talking head (口播) videos. It uses semantic understanding to identify speech errors, pauses, and repetitions that traditional video editors cannot detect.

## Skill Routing

When a user invokes a command, route to the appropriate skill:

| Trigger | Skill | Purpose |
|---------|-------|---------|
| 安装, 环境准备, 初始化 | `install/` | First-time environment setup |
| 转录视频, 生成字幕, 提取字幕 | `transcribe/` | Extract audio, transcribe, generate Markdown subtitles |
| 剪口播, 处理视频, 识别口误 | `video-cut/` | Transcribe and identify speech errors |
| 加字幕, 烧录字幕, 字幕 | `subtitle/` | Generate and burn subtitles |
| 更新规则, 记录反馈, 改进skill | `self-evolve/` | Learn from user feedback |

## Architecture

### Data Flow

```
Video → Audio Extraction → Upload (uguu.se) → Volcengine ASR
                                                           ↓
                                                   subtitles_words.json
                                                           ↓
                                                   AI Analysis (Claude)
                                                           ↓
                                                   auto_selected.json
                                                           ↓
                                                   review.html (human review)
                                                           ↓
                                                   delete_segments.json
                                                           ↓
                                                   FFmpeg filter_complex
                                                           ↓
                                                   Cut video
```

### Key File: subtitles_words.json

The core data structure that flows through the entire pipeline:

```json
[
  {"text": "大", "start": 0.12, "end": 0.2, "isGap": false},
  {"text": "", "start": 6.78, "end": 7.48, "isGap": true}
]
```

- `isGap: true` = silence/pause segment
- `isGap: false` = spoken word
- `start/end` = timestamps in seconds

### Output Directory Structure

```
output/
└── YYYY-MM-DD_视频名/
    ├── video-cut/
    │   ├── 1_转录/
    │   │   ├── audio.mp3
    │   │   ├── volcengine_result.json
    │   │   └── subtitles_words.json
    │   ├── 2_分析/
    │   │   ├── readable.txt
    │   │   ├── auto_selected.json
    │   │   └── 口误分析.md
    │   └── 3_审核/
    │       └── review.html
    └── subtitle/
        └── ...
```

## Common Commands

### Environment Setup

```bash
# Check dependencies
node -v
ffmpeg -version

# Configure API Key (in project root)
echo "VOLCENGINE_API_KEY=your_key" >> .claude/skills/.env
```

### Transcription (Volcengine)

```bash
cd video-cut/1_转录
# Extract audio
ffmpeg -i "file:视频.mp4" -vn -acodec libmp3lame -y audio.mp3

# Upload to uguu.se
curl -s -F "files[]=@audio.mp3" https://uguu.se/upload

# Transcribe
bash ../../scripts/volcengine_transcribe.sh "https://h.uguu.se/xxx.mp3"
```

### Generate Subtitles

```bash
node ../../scripts/generate_subtitles.js volcengine_result.json
# Output: subtitles_words.json
```

### Video Cutting

```bash
# Start review server
node ../../scripts/review_server.js 8899 "视频.mp4"

# Manual cut (if needed)
bash ../../scripts/cut_video.sh "视频.mp4" "delete_segments.json" "输出.mp4"
```

### Subtitle Burning

```bash
node ../subtitle/scripts/subtitle_server.js 8898 "视频.mp4"
```

## AI Analysis Guidelines

### Sentence Segmentation (Critical!)

Before analyzing speech errors, you **must** segment the transcription into sentences:

```bash
# Split by gaps >= 0.5s
node -e "
const data = require('subtitles_words.json');
let sentences = [];
let curr = { text: '', startIdx: -1, endIdx: -1 };

data.forEach((w, i) => {
  const isLongGap = w.isGap && (w.end - w.start) >= 0.5;
  if (isLongGap) {
    if (curr.text.length > 0) sentences.push({...curr});
    curr = { text: '', startIdx: -1, endIdx: -1 };
  } else if (!w.isGap) {
    if (curr.startIdx === -1) curr.startIdx = i;
    curr.text += w.text;
    curr.endIdx = i;
  }
});
if (curr.text.length > 0) sentences.push(curr);

// Save for analysis
require('fs').writeFileSync('sentences.txt', sentences.map((s,i) =>
  i + '|' + s.startIdx + '-' + s.endIdx + '|' + s.text
).join('\\n'));
"
```

### Speech Error Detection Priority

1. **Silence >1s** → Delete
2. **Incomplete sentences** → Delete (half-spoken + silence)
3. **Duplicate sentences** → Delete shorter (开头≥5字相同)
4. **In-sentence repetition** → Delete first part (A+middle+A pattern)
5. **Stutter words** → Delete first part (那个那个, 就是就是)
6. **Restatement/correction** → Delete first part (partial repeat, negation)
7. **Filler words** → Mark for manual review (嗯, 啊, 呃)

### Core Principle

**删前保后** (Delete earlier, keep later): When something is restated, the later version is usually more complete.

## Important Technical Details

### File Paths with Colons

When video filenames contain colons (e.g., `2026:01:26 task.mp4`), FFmpeg requires `file:` prefix:

```bash
ffmpeg -i "file:2026:01:26 task.mp4" ...
```

### FFmpeg Cutting Strategy

Uses `filter_complex` with:
- `trim` + `setpts` for video
- `atrim` + `asetpts` for audio
- `acrossfade` to eliminate audio pops at cut points
- Buffer expansion (50ms) to remove breaths/cutoff sounds

```bash
# Key parameters
BUFFER_MS=50      # Extend cut range
CROSSFADE_MS=30   # Audio crossfade
```

### Hardware Encoder Detection

The review server (`review_server.js`) automatically detects and uses hardware encoders:
- macOS: `h264_videotoolbox`
- Windows: `h264_nvenc` (NVIDIA), `h264_qsv` (Intel), `h264_amf` (AMD)
- Linux: `h264_nvenc`, `h264_vaapi`
- Fallback: `libx264` (software)

### Volcengine Hot Words

The transcription script (`volcengine_transcribe.sh`) automatically loads custom vocabulary from `subtitle/docs/dictionary.txt` as hot words to improve recognition accuracy.

## User Habit Rules

Located in `video-cut/docs/user-habits/`:
- `01-core-principle.md` - Delete earlier, keep later
- `02-filler-words.md` - Filler word detection
- `03-silence-rules.md` - Silence threshold rules
- `04-duplicate-sentences.md` - Duplicate sentence detection
- `05-stutter-words.md` - Stutter word patterns
- `06-in-sentence-repeat.md` - In-sentence repetition patterns
- `07-consecutive-fillers.md` - Consecutive filler words
- `08-restatement-correction.md` - Restatement/correction patterns
- `09-incomplete-sentences.md` - Incomplete sentence detection

## Self-Evolution Pattern

When user provides feedback ("记住这个", "更新规则", etc.):

1. **DO NOT ask** what the problem is
2. Analyze context to identify the issue
3. Read the full target file
4. Integrate the rule into the **main content** (not just append to feedback log)
5. Feedback log should only record **events**, not rules

Example:
```markdown
## 新增章节：XXX
（整合规则到这里）

## 反馈记录
### 2026-01-14
- 审查稿标记了静音，但剪辑时漏删（事件记录）
```

## Subtitle Workflows

### Auto-Proofreading Rules

After Volcengine transcription, AI must manually proofread for:

| Misrecognized | Correct | Type |
|---------------|---------|------|
| 成风 | 成峰 | 同音字 |
| 正特/整特 | Agent | 误识别 |
| IT就 | Agent就 | 发音相似 |
| cloud code | Claude Code | 发音相似 |
| Schill/skill | skills | 发音相似 |
| 剪口拨/剪口波 | 剪口播 | 同音字 |
| 自净化/资金化 | 自进化 | 同音字 |
| 减口播 | 剪口播 | 同音字 |

### Subtitle Format

- One line per screen (no line breaks)
- No trailing punctuation: `你好` not `你好。`
- Keep internal punctuation: `先点这里，再点那里`
