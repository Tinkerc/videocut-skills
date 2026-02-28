#!/bin/bash

##############################################################################
# 火山引擎转录脚本
# 功能：提交转录任务并查询结果
# 用法: bash curl.sh "https://example.com/audio.mp3" [output_prefix]
##############################################################################

set -e

# API 配置
API_KEY="${VOLCENGINE_API_KEY:-b6008019-23a0-480d-a750-4d246aa24752}"
SUBMIT_URL="https://openspeech.bytedance.com/api/v3/auc/bigmodel/submit"
QUERY_URL="https://openspeech.bytedance.com/api/v3/auc/bigmodel/query"
RESOURCE_ID="volc.seedasr.auc"  # 豆包录音文件识别模型 2.0

# 参数
AUDIO_URL="$1"
OUTPUT_PREFIX="${2:-volcengine_result}"

if [[ -z "$AUDIO_URL" ]]; then
    echo "❌ 用法: $0 <audio_url> [output_prefix]"
    echo "示例: $0 https://n.uguu.se/AxLiSrjP.mp3 my_result"
    echo "      输出: my_result.json, my_result.md"
    exit 1
fi

# 生成唯一请求 ID（即任务 ID）
REQUEST_ID=$(uuidgen 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")

# 输出文件
OUTPUT_JSON="${OUTPUT_PREFIX}.json"
OUTPUT_MD="${OUTPUT_PREFIX}.md"

echo "🎤 提交火山引擎转录任务..."
echo "   音频 URL: $AUDIO_URL"
echo "   任务 ID: $REQUEST_ID"

# 提交任务
echo ""
echo "📤 提交任务..."
SUBMIT_HEADERS=$(curl -s -i -X POST "$SUBMIT_URL" \
    -H "Content-Type: application/json" \
    -H "x-api-key: $API_KEY" \
    -H "X-Api-Resource-Id: $RESOURCE_ID" \
    -H "X-Api-Request-Id: $REQUEST_ID" \
    -H "X-Api-Sequence: -1" \
    -d "{
        \"user\": {\"uid\": \"test\"},
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

# 提取响应头信息
STATUS_CODE=$(echo "$SUBMIT_HEADERS" | grep -i "X-Api-Status-Code:" | tr -d '\r' | awk '{print $2}')
STATUS_MESSAGE=$(echo "$SUBMIT_HEADERS" | grep -i "X-Api-Message:" | tr -d '\r' | cut -d' ' -f2-)
LOG_ID=$(echo "$SUBMIT_HEADERS" | grep -i "X-Tt-Logid:" | tr -d '\r' | awk '{print $2}')

echo "   Log ID: $LOG_ID"
echo "   状态码: $STATUS_CODE"
echo "   消息: $STATUS_MESSAGE"

if [[ "$STATUS_CODE" != "20000000" ]]; then
    echo "❌ 提交失败"
    echo "完整响应:"
    echo "$SUBMIT_HEADERS"
    exit 1
fi

echo "✅ 任务提交成功"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  任务 ID: $REQUEST_ID"
echo "  使用此 ID 可查询任务状态"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 轮询查询结果
echo "⏳ 等待转录完成..."
POLL_INTERVAL=3
MAX_ATTEMPTS=100
ATTEMPT=0
START_TIME=$(date +%s)

while true; do
    ATTEMPT=$((ATTEMPT + 1))

    # 查询结果
    QUERY_RESPONSE=$(curl -s -X POST "$QUERY_URL" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $API_KEY" \
        -H "X-Api-Resource-Id: $RESOURCE_ID" \
        -H "X-Api-Request-Id: $REQUEST_ID" \
        -d "{}")

    # 获取状态
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
            END_TIME=$(date +%s)
            ELAPSED=$((END_TIME - START_TIME))

            echo "   ✅ 转录完成! (尝试 $ATTEMPT 次, 耗时 ${ELAPSED}秒)"
            echo ""

            # 保存 JSON
            echo "$QUERY_RESPONSE" | jq '.' > "$OUTPUT_JSON" 2>/dev/null || echo "$QUERY_RESPONSE" > "$OUTPUT_JSON"

            # 生成 Markdown 报告
            echo "📝 生成转录报告..."
            cat > "$OUTPUT_MD" << EOF
# 火山引擎转录结果

## 任务信息

| 项目 | 内容 |
|------|------|
| 任务 ID | \`$REQUEST_ID\` |
| Log ID | \`$LOG_ID\` |
| 音频 URL | $AUDIO_URL |
| 完成时间 | $(date '+%Y-%m-%d %H:%M:%S') |
| 轮询次数 | $ATTEMPT |
| 总耗时 | ${ELAPSED} 秒 |

---

## 识别文本

EOF

            # 提取并添加识别文本
            if command -v jq &> /dev/null; then
                TEXT=$(echo "$QUERY_RESPONSE" | jq -r '.result.text // empty')
                if [[ -n "$TEXT" ]]; then
                    echo "$TEXT" >> "$OUTPUT_MD"
                fi
            else
                echo "(需要安装 jq 来提取文本)" >> "$OUTPUT_MD"
            fi

            # 添加 utterances 信息
            echo "" >> "$OUTPUT_MD"
            echo "---" >> "$OUTPUT_MD"
            echo "" >> "$OUTPUT_MD"
            echo "## 分句详情" >> "$OUTPUT_MD"
            echo "" >> "$OUTPUT_MD"

            if command -v jq &> /dev/null; then
                # 提取 utterances 并格式化为表格
                UTTERANCE_COUNT=$(echo "$QUERY_RESPONSE" | jq -r '.result.utterances | length' 2>/dev/null || echo "0")
                echo "共 $UTTERANCE_COUNT 个分句" >> "$OUTPUT_MD"
                echo "" >> "$OUTPUT_MD"
                echo "| 序号 | 时间范围 | 文本 |" >> "$OUTPUT_MD"
                echo "|------|----------|------|" >> "$OUTPUT_MD"

                echo "$QUERY_RESPONSE" | jq -r '.result.utterances[]? | "\(.start_time/1000 | floor // 0)s - \(.end_time/1000 | ceil // 0)s | \(.text // "")"' 2>/dev/null | nl -w2 -s'. | ' | sed 's/^\s*//' | awk '{
                    gsub(/^[0-9]+\.\s*/, "| & | ")
                    print $0 " |"
                }' >> "$OUTPUT_MD" 2>/dev/null || echo "| - | - | 无法解析 |" >> "$OUTPUT_MD"
            else
                echo "(需要安装 jq 来提取分句信息)" >> "$OUTPUT_MD"
            fi

            # 添加原始 JSON 链接
            echo "" >> "$OUTPUT_MD"
            echo "---" >> "$OUTPUT_MD"
            echo "" >> "$OUTPUT_MD"
            echo "## 原始数据" >> "$OUTPUT_MD"
            echo "" >> "$OUTPUT_MD"
            echo "完整 JSON 结果保存在: \`$(basename "$OUTPUT_JSON")\`" >> "$OUTPUT_MD"

            echo "💾 JSON 已保存到: $OUTPUT_JSON"
            echo "💾 Markdown 已保存到: $OUTPUT_MD"
            echo ""

            # 显示识别文本预览
            if command -v jq &> /dev/null; then
                TEXT=$(echo "$QUERY_RESPONSE" | jq -r '.result.text // empty')
                if [[ -n "$TEXT" ]]; then
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo "  识别文本预览:"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                    echo "$TEXT"
                    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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
            exit 1
            ;;
    esac

    if [[ $ATTEMPT -ge $MAX_ATTEMPTS ]]; then
        echo "❌ 超时: 已尝试 $MAX_ATTEMPTS 次"
        exit 1
    fi

    sleep "$POLL_INTERVAL"
done
