---
name: videocut:字幕
description: 字幕生成与烧录。火山引擎转录→词典纠错→审核→烧录。触发词：加字幕、生成字幕、字幕
---

<!--
input: 视频文件
output: 带字幕视频
pos: 后置 skill，剪辑完成后调用

架构守护者：一旦我被修改，请同步更新：
1. ../README.md 的 Skill 清单
2. /CLAUDE.md 路由表
-->

# 字幕

> 转录 → 纠错 → 审核 → 烧录

## 流程

```
1. 提取音频 + 上传
    ↓
2. 火山引擎转录（字级别时间戳）
    ↓
3. 词典纠错 + 分句（≤15字/行）
    ↓
4. 输出字幕稿（纯文本，一句一行）
    ↓
【用户审核修改】
    ↓
5. 用户给回修改后的文本
    ↓
6. 匹配时间戳 → 生成 SRT
    ↓
7. 烧录字幕（FFmpeg）
```

## 转录

使用火山引擎语音识别，输出字级别时间戳。

```bash
# 1. 提取音频
ffmpeg -i "file:video.mp4" -vn -acodec libmp3lame -y audio.mp3

# 2. 上传到 uguu.se
curl -s -F "files[]=@audio.mp3" https://uguu.se/upload

# 3. 火山引擎转录
./scripts/volcengine_transcribe.sh "https://h.uguu.se/xxx.mp3"
```

输出 `volcengine_result.json`，包含字级别时间戳。

---

## 字幕规范

| 规则 | 说明 |
|------|------|
| 一屏一行 | 不换行，不堆叠 |
| ≤15字/行 | 超过15字必须拆分（4:3竖屏） |
| 句尾无标点 | `你好` 不是 `你好。` |
| 句中保留标点 | `先点这里，再点那里` |
| NO.1 写法 | `number one` → `NO.1` |

---

## 词典纠错

读取 `词典.txt`，每行一个正确写法：

```
skills
Claude
iPhone
NO.1
```

自动识别变体：`claude` → `Claude`

---

## 字幕稿格式

**我给用户的**（纯文本，≤15字/行）：

```
今天给大家分享一个技巧
很多人可能不知道
其实这个功能
藏在设置里面
你只要点击这里
就能看到了
```

**用户修改后给回我**，我再匹配时间戳生成 SRT。

---

## 时间戳匹配

将用户修改后的字幕稿与火山引擎的字级别时间戳对齐：

1. 读取 `subtitles_words.json` 的逐字时间戳
2. 字幕稿每行与转录文本做匹配
3. 根据匹配位置提取 start/end 时间
4. 生成 SRT 格式

---

## 烧录字幕

```bash
ffmpeg -i "file:video.mp4" \
  -vf "subtitles='video.srt':force_style='FontSize=18,FontName=PingFang SC,PrimaryColour=&H00ffff,OutlineColour=&H000000,Outline=2,Alignment=2,MarginV=30'" \
  -c:a copy \
  -y "file:video-字幕.mp4"
```

| 参数 | 说明 |
|------|------|
| FontSize=18 | 字号（可调到24/32） |
| FontName=PingFang SC | 苹方字体 |
| PrimaryColour=&H00ffff | 黄色文字（BGR格式） |
| OutlineColour=&H000000 | 黑色描边 |
| Outline=2 | 描边粗细 |
| Alignment=2 | 底部居中 |
| MarginV=30 | 底部边距 |

**注意**：文件名含冒号需加 `file:` 前缀。

---

## 样式

默认：**18号黄字、黑色描边、底部居中**

| 样式 | PrimaryColour | 说明 |
|------|---------------|------|
| 黄字（默认） | &H00ffff | 醒目，推荐 |
| 白字 | &Hffffff | 传统样式 |

用户可说：
- "字大一点" → FontSize=24
- "白色字幕" → PrimaryColour=&Hffffff

---

## 输出

```
video_字幕稿.txt   # 纯文本，用户编辑
video.srt          # 字幕文件
video-字幕.mp4     # 带字幕视频
```
