# 剪口播 v2 脚本

## 脚本列表

| 脚本 | 说明 | 输入 | 输出 |
|------|------|------|------|
| `volcengine_transcribe.sh` | 调用火山引擎 API | 音频 URL | `volcengine_result.json` |
| `generate_subtitles.js` | 提取字级别字幕 | `volcengine_result.json` | `subtitles_words.json` |
| `generate_review.js` | 生成审核网页 | 字幕 + 预选 | `review.html` |
| `review_server.js` | 审核服务器 | 视频文件 | 启动 HTTP 服务 |
| `cut_video.sh` | 执行剪辑 | 视频 + 删除列表 | 输出视频 |

## 完整流程

```bash
# 1. 提取音频（文件名有冒号需加 file: 前缀）
ffmpeg -i "file:source.mp4" -vn -acodec libmp3lame -y audio.mp3

# 2. 上传获取公网 URL（uguu.se 火山引擎访问快）
curl -s -F "files[]=@audio.mp3" https://uguu.se/upload
# 返回: {"success":true,"files":[{"url":"https://h.uguu.se/xxx.mp3"}]}

# 3. 调用火山引擎 API
./volcengine_transcribe.sh "https://h.uguu.se/xxx.mp3"

# 4. 生成字幕
node generate_subtitles.js volcengine_result.json

# 5. AI 审核（Claude 手动分析，禁止脚本）
# 详见 SKILL.md 步骤4 和 用户习惯/ 目录

# 6. 生成审核网页
node generate_review.js subtitles_words.json auto_selected.json audio.mp3

# 7. 启动审核服务器
node review_server.js 8899 source.mp4
# 打开 http://localhost:8899

# 8. 网页中确认删除列表，点击「执行剪辑」
# 或手动执行: ./cut_video.sh source.mp4 delete_segments.json output.mp4
```

## 配置

### 火山引擎 API Key

```bash
cd .claude/skills
cp .env.example .env
# 编辑 .env 填入 VOLCENGINE_API_KEY=xxx
```

## 数据格式

### subtitles_words.json

```json
[
  {"text": "大", "start": 0.12, "end": 0.2, "isGap": false},
  {"text": "", "start": 6.78, "end": 7.48, "isGap": true}
]
```

### auto_selected.json

```json
[72, 85, 120]  // 索引数组，Claude 手动分析生成
```

### delete_segments.json

```json
[
  {"start": 39.1, "end": 39.86},
  {"start": 120.5, "end": 121.2}
]
```
