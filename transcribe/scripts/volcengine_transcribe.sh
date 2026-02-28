#!/bin/bash
#
# 火山引擎语音识别（v3 API - 异步模式）
#
# 用法: ./volcengine_transcribe.sh <audio_url> [output_file]
# 输出: volcengine_result.json
#
# API 文档: https://openspeech.bytedance.com/api/v3/auc/bigmodel/submit
#

set -e

AUDIO_URL="$1"
OUTPUT_FILE="${2:-volcengine_result.json}"

if [ -z "$AUDIO_URL" ]; then
  echo "❌ 用法: ./volcengine_transcribe.sh <audio_url> [output_file]"
  exit 1
fi

# 获取 API Key
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$(dirname "$(dirname "$SCRIPT_DIR")")/.env"

# 优先从环境变量获取，否则从 .env 文件
API_KEY="${VOLCENGINE_API_KEY:-}"

if [ -z "$API_KEY" ] && [ -f "$ENV_FILE" ]; then
  API_KEY=$(grep VOLCENGINE_API_KEY "$ENV_FILE" | cut -d'=' -f2)
fi

if [ -z "$API_KEY" ]; then
  echo "❌ 未找到 VOLCENGINE_API_KEY"
  echo "请设置环境变量或在 .env 文件中配置"
  exit 1
fi

echo "🎤 提交火山引擎转录任务..."
echo "   音频 URL: $AUDIO_URL"

# 生成请求 ID（UUID）
REQUEST_ID=$(uuidgen 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())" 2>/dev/null || openssl rand -hex 16 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "d1906027-5b55-4856-8e18-27f26344e724")
echo "   请求 ID: $REQUEST_ID"

SUBMIT_URL="https://openspeech.bytedance.com/api/v3/auc/bigmodel/submit"
QUERY_URL="https://openspeech.bytedance.com/api/v3/auc/bigmodel/query"
RESOURCE_ID="volc.seedasr.auc"

# 步骤1: 提交任务
echo ""
echo "📤 提交任务..."

# 使用 -i 获取响应头
SUBMIT_RESPONSE=$(curl -s -i -X POST "$SUBMIT_URL" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -H "X-Api-Resource-Id: $RESOURCE_ID" \
  -H "X-Api-Request-Id: $REQUEST_ID" \
  -H "X-Api-Sequence: -1" \
  -d "{
    \"user\": {\"uid\": \"videocut-skills\"},
    \"audio\": {
      \"url\": \"$AUDIO_URL\",
      \"format\": \"mp3\",
      \"codec\": \"raw\",
      \"rate\": 16000,
      \"bits\": 16,
      \"channel\": 1
    },
    \"request\": {
      \"model_name\": \"bigmodel\",
      \"enable_itn\": true,
      \"enable_punc\": true,
      \"enable_ddc\": false,
      \"enable_speaker_info\": false,
      \"enable_channel_split\": false,
      \"show_utterances\": true,
      \"vad_segment\": false
    }
  }")

# 从响应头提取状态码（去除 \r）
STATUS_CODE=$(echo "$SUBMIT_RESPONSE" | grep -i "X-Api-Status-Code:" | tr -d '\r' | awk '{print $2}')
STATUS_MESSAGE=$(echo "$SUBMIT_RESPONSE" | grep -i "X-Api-Message:" | tr -d '\r' | cut -d' ' -f2-)
LOG_ID=$(echo "$SUBMIT_RESPONSE" | grep -i "X-Tt-Logid:" | tr -d '\r' | awk '{print $2}')

echo "   Log ID: $LOG_ID"
echo "   状态码: $STATUS_CODE"
echo "   消息: $STATUS_MESSAGE"

# 检查提交是否成功
if [ "$STATUS_CODE" != "20000000" ]; then
  echo "❌ 提交失败"
  echo "完整响应:"
  echo "$SUBMIT_RESPONSE"
  exit 1
fi

echo "✅ 任务提交成功"
echo ""

# 步骤2: 轮询结果
echo "⏳ 等待转录完成..."

MAX_ATTEMPTS=100  # 最多等待约5分钟（每3秒查一次）
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  ATTEMPT=$((ATTEMPT + 1))

  # 查询结果（请求体为空 JSON {}）
  QUERY_RESPONSE=$(curl -s -X POST "$QUERY_URL" \
    -H "Content-Type: application/json" \
    -H "x-api-key: $API_KEY" \
    -H "X-Api-Resource-Id: $RESOURCE_ID" \
    -H "X-Api-Request-Id: $REQUEST_ID" \
    -d "{}")

  # 获取查询响应头用于状态检查
  QUERY_HEADERS=$(curl -s -i -X POST "$QUERY_URL" \
    -H "Content-Type: application/json" \
    -H "x-api-key: $API_KEY" \
    -H "X-Api-Resource-Id: $RESOURCE_ID" \
    -H "X-Api-Request-Id: $REQUEST_ID" \
    -d "{}")

  QUERY_STATUS=$(echo "$QUERY_HEADERS" | grep -i "X-Api-Status-Code:" | tr -d '\r' | awk '{print $2}')

  case "$QUERY_STATUS" in
    20000000)
      # 成功
      echo "   ✅ 转录完成! (尝试 $ATTEMPT 次)"
      echo "$QUERY_RESPONSE" | jq '.' > "$OUTPUT_FILE" 2>/dev/null || echo "$QUERY_RESPONSE" > "$OUTPUT_FILE"
      echo "💾 结果已保存到: $OUTPUT_FILE"
      echo ""

      # 显示识别文本
      if command -v jq &> /dev/null; then
        TEXT=$(echo "$QUERY_RESPONSE" | jq -r '.result.text // empty')
        if [ -n "$TEXT" ]; then
          echo "📝 识别文本预览:"
          echo "$TEXT" | head -c 200
          echo "..."
        fi
      fi
      exit 0
      ;;
    20000001)
      # 处理中
      echo "   ⏳ 正在处理... ($ATTEMPT/$MAX_ATTEMPTS)"
      ;;
    20000002)
      # 队列中
      echo "   📥 队列中... ($ATTEMPT/$MAX_ATTEMPTS)"
      ;;
    *)
      # 错误
      echo "❌ 查询失败，状态码: $QUERY_STATUS"
      echo "响应: $QUERY_RESPONSE"
      echo "响应头:"
      echo "$QUERY_HEADERS"
      exit 1
      ;;
  esac

  sleep 3
done

echo ""
echo "❌ 超时: 已尝试 $MAX_ATTEMPTS 次"
exit 1
