<template>
  <div :class="['message-group', message.type]">
    <div class="message-avatar">
      <div v-if="message.type === 'user'" class="user-avatar">
        <el-icon><User /></el-icon>
      </div>
      <div v-else class="ai-avatar">
        <el-icon><ChatDotRound /></el-icon>
      </div>
    </div>
    <div class="message-content">
      <div class="message-header">
        <strong class="sender-name">
          {{ message.type === "user" ? "You" : "FA助手" }}
        </strong>
      </div>
      <div class="message-body">
        <el-button
          v-if="message.content.length > 200"
          text
          size="small"
          :icon="message.collapsed ? ArrowDown : ArrowUp"
          class="fold-button"
          @click="handleToggleFold"
        >
          {{ message.collapsed ? "展开" : "收起" }}
        </el-button>
        <div
          class="message-text"
          :class="{ collapsed: message.collapsed }"
          v-html="formattedContent"
        ></div>
        <div
          v-if="message.type === 'assistant' && message.loading && !message.content"
          class="typing-indicator"
        >
          <div class="typing-dots">
            <span></span>
            <span></span>
            <span></span>
          </div>
        </div>
      </div>
      <div v-if="!message.loading" class="message-actions">
        <el-button text size="small" :icon="CopyDocument" @click="handleCopy"></el-button>
        <el-button
          v-if="message.type === 'assistant'"
          text
          size="small"
          :icon="RefreshLeft"
        ></el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { ElMessage } from "element-plus";
import {
  User,
  ChatDotRound,
  CopyDocument,
  RefreshLeft,
  ArrowDown,
  ArrowUp,
} from "@element-plus/icons-vue";
import MarkdownIt from "markdown-it";
import markdownItHighlightjs from "markdown-it-highlightjs";
import hljs from "highlight.js";
import "highlight.js/styles/atom-one-light.css";
import type { ChatMessage } from "../types";

interface Props {
  message: ChatMessage;
}

interface Emits {
  (e: "toggle-fold"): void;
}

const props = defineProps<Props>();
const emit = defineEmits<Emits>();

const md: MarkdownIt = new MarkdownIt({
  html: true,
  linkify: true,
  typographer: true,
  breaks: true,
  highlight(str: string, lang: string): string {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return `<pre class="hljs"><code>${hljs.highlight(str, { language: lang, ignoreIllegals: true }).value}</code></pre>`;
      } catch {
        return `<pre class="hljs"><code>${md.utils.escapeHtml(str)}</code></pre>`;
      }
    }
    return `<pre class="hljs"><code>${md.utils.escapeHtml(str)}</code></pre>`;
  },
}).use(markdownItHighlightjs);

const defaultRender =
  md.renderer.rules.link_open ||
  function (tokens: any[], idx: number, options: any, env: any, self: any) {
    return self.renderToken(tokens, idx, options, env, self);
  };

md.renderer.rules.link_open = function (
  tokens: any[],
  idx: number,
  options: any,
  env: any,
  self: any
) {
  tokens[idx].attrPush(["target", "_blank"]);
  tokens[idx].attrPush(["rel", "noopener noreferrer"]);
  return defaultRender(tokens, idx, options, env, self);
};

const formattedContent = computed(() => {
  if (!props.message.content) return "";
  return md.render(props.message.content);
});

const handleToggleFold = () => {
  emit("toggle-fold");
};

const handleCopy = async () => {
  try {
    await navigator.clipboard.writeText(props.message.content);
    ElMessage.success("已复制到剪贴板");
  } catch {
    const textArea = document.createElement("textarea");
    textArea.value = props.message.content;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand("copy");
    document.body.removeChild(textArea);
    ElMessage.success("已复制到剪贴板");
  }
};
</script>

<style lang="scss" scoped>
.message-group {
  display: flex;
  gap: 16px;
  margin-bottom: 32px;

  .message-avatar {
    flex-shrink: 0;

    .user-avatar {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 32px;
      height: 32px;
      font-size: 14px;
      color: white;
      background: var(--el-color-primary);
      border-radius: 6px;
    }

    .ai-avatar {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 32px;
      height: 32px;
      font-size: 14px;
      color: white;
      background: var(--el-color-success);
      border-radius: 6px;
    }
  }

  .message-content {
    flex: 1;
    min-width: 0;

    .message-header {
      margin-bottom: 8px;

      .sender-name {
        font-size: 14px;
        font-weight: 600;
        color: var(--el-text-color-primary);
      }
    }

    .message-body {
      .fold-button {
        padding: 0;
        margin-bottom: 8px;
        font-size: 12px;
        color: var(--el-text-color-secondary);

        &:hover {
          color: var(--el-color-primary);
        }
      }

      .message-text {
        font-size: 15px;
        line-height: 1.6;
        color: var(--el-text-color-primary);
        word-wrap: break-word;
        transition: all 0.3s ease;

        &.collapsed {
          position: relative;
          max-height: 120px;
          overflow: hidden;

          &::after {
            position: absolute;
            right: 0;
            bottom: 0;
            left: 0;
            height: 60px;
            content: "";
            background: linear-gradient(transparent, var(--el-bg-color));
          }
        }

        :deep(pre) {
          padding: 12px;
          margin: 12px 0;
          overflow-x: auto;
          background: var(--el-fill-color-light);
          border-radius: 6px;

          code {
            font-family: "Courier New", Courier, monospace;
            font-size: 13px;
          }
        }

        :deep(code) {
          padding: 2px 6px;
          font-family: "Courier New", Courier, monospace;
          font-size: 13px;
          background: var(--el-fill-color-light);
          border-radius: 3px;
        }

        :deep(p) {
          margin: 8px 0;
        }

        :deep(ul),
        :deep(ol) {
          padding-left: 24px;
          margin: 8px 0;
        }

        :deep(li) {
          margin: 4px 0;
        }

        :deep(a) {
          color: var(--el-color-primary);
          text-decoration: none;

          &:hover {
            text-decoration: underline;
          }
        }

        :deep(blockquote) {
          padding: 8px 16px;
          margin: 12px 0;
          background: var(--el-fill-color-light);
          border-left: 4px solid var(--el-color-primary);
        }

        :deep(table) {
          width: 100%;
          margin: 12px 0;
          border-collapse: collapse;

          th,
          td {
            padding: 8px 12px;
            border: 1px solid var(--el-border-color-light);
          }

          th {
            font-weight: 600;
            background: var(--el-fill-color-light);
          }
        }
      }

      .typing-indicator {
        display: flex;
        align-items: center;
        padding: 8px 0;

        .typing-dots {
          display: flex;
          gap: 4px;

          span {
            width: 8px;
            height: 8px;
            background: var(--el-text-color-secondary);
            border-radius: 50%;
            animation: typing 1.4s infinite ease-in-out;

            &:nth-child(1) {
              animation-delay: 0s;
            }

            &:nth-child(2) {
              animation-delay: 0.2s;
            }

            &:nth-child(3) {
              animation-delay: 0.4s;
            }
          }
        }
      }
    }

    .message-actions {
      display: flex;
      gap: 8px;
      margin-top: 8px;
    }
  }
}

@keyframes typing {
  0%,
  60%,
  100% {
    transform: translateY(0);
  }
  30% {
    transform: translateY(-4px);
  }
}
</style>
