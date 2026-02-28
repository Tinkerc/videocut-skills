#!/usr/bin/env node
/**
 * 将字级别字幕转换为 Markdown 格式
 *
 * 用法: node generate_markdown.js <subtitles_words.json> [输出文件名]
 * 输出: transcription.md (默认)
 */

const fs = require('fs');

const jsonFile = process.argv[2] || 'subtitles_words.json';
const outputFile = process.argv[3] || 'transcription.md';

if (!fs.existsSync(jsonFile)) {
  console.error('❌ 找不到文件:', jsonFile);
  process.exit(1);
}

const words = JSON.parse(fs.readFileSync(jsonFile, 'utf8'));

// 1. 先分句（按静音 >= 0.5秒 切分）
const sentences = [];
let curr = { text: '', start: null, end: null };

words.forEach((w) => {
  const isLongGap = w.isGap && (w.end - w.start) >= 0.5;

  if (isLongGap) {
    if (curr.text.length > 0) {
      sentences.push({...curr});
    }
    curr = { text: '', start: null, end: null };
  } else if (!w.isGap) {
    if (curr.start === null) curr.start = w.start;
    curr.text += w.text;
    curr.end = w.end;
  }
});

// 处理最后一句
if (curr.text.length > 0) {
  sentences.push(curr);
}

console.log('句子数量:', sentences.length);

// 2. 格式化时间 (秒 → MM:SS 或 SS.s)
function formatTime(seconds) {
  const mins = Math.floor(seconds / 60);
  const secs = (seconds % 60).toFixed(1);
  if (mins > 0) {
    return `${mins}:${String(Math.floor(secs)).padStart(2, '0')}`;
  }
  return secs;
}

// 3. 生成 Markdown 内容
let markdown = '# 视频字幕\n\n';
markdown += `*生成时间: ${new Date().toLocaleString('zh-CN')}*\n\n`;
markdown += `*共 ${sentences.length} 句*\n\n`;
markdown += '---\n\n';

sentences.forEach((s, i) => {
  const timeRange = `${formatTime(s.start)} - ${formatTime(s.end)}`;
  markdown += `## ${timeRange}\n\n`;
  markdown += `${s.text}\n\n`;
});

// 4. 保存文件
fs.writeFileSync(outputFile, markdown, 'utf8');
console.log('✅ 已生成:', outputFile);
