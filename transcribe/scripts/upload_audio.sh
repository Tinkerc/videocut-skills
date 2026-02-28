#!/bin/bash
#
# 上传音频文件到 uguu.se 获取公网 URL
#
# 用法: ./upload_audio.sh <audio.mp3>
# 输出: https://h.uguu.se/xxx.mp3
#

AUDIO_FILE="$1"

if [ -z "$AUDIO_FILE" ]; then
  echo "❌ 用法: ./upload_audio.sh <audio.mp3>"
  exit 1
fi

if [ ! -f "$AUDIO_FILE" ]; then
  echo "❌ 找不到文件: $AUDIO_FILE"
  exit 1
fi

echo "📤 上传音频文件: $AUDIO_FILE"

# 上传并解析响应
RESPONSE=$(curl -s -F "files[]=@$AUDIO_FILE" https://uguu.se/upload)

# 提取 URL
URL=$(echo "$RESPONSE" | grep -o '"url":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$URL" ]; then
  echo "❌ 上传失败，响应:"
  echo "$RESPONSE"
  exit 1
fi

echo "✅ 上传成功"
echo "$URL"
