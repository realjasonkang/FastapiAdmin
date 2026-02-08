<template>
  <div class="chat-navbar">
    <div class="navbar-left">
      <h2>FA智能助手</h2>
    </div>
    <div class="navbar-right">
      <div class="connection-status">
        <el-icon :class="['status-icon', connectionStatus]">
          <Connection v-if="connectionStatus === 'connected'" />
          <Loading v-else-if="connectionStatus === 'connecting'" />
          <Warning v-else />
        </el-icon>
        <span class="status-text">{{ connectionStatusText }}</span>
      </div>
      <el-button v-if="hasMessages" text :icon="Delete" @click="handleClearChat">
        清空对话
      </el-button>
      <el-button text :icon="Setting" @click="handleToggleConnection">
        {{ isConnected ? "断开连接" : "重新连接" }}
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { Connection, Loading, Warning, Delete, Setting } from "@element-plus/icons-vue";

interface Props {
  connectionStatus: "connected" | "connecting" | "disconnected";
  isConnected: boolean;
  messageCount: number;
}

interface Emits {
  (e: "clear-chat"): void;
  (e: "toggle-connection"): void;
}

const props = defineProps<Props>();
const emit = defineEmits<Emits>();

const connectionStatusText = computed(() => {
  switch (props.connectionStatus) {
    case "connected":
      return "已连接";
    case "connecting":
      return "连接中...";
    case "disconnected":
      return "未连接";
    default:
      return "未知状态";
  }
});

const hasMessages = computed(() => props.messageCount > 0);

const handleClearChat = () => {
  emit("clear-chat");
};

const handleToggleConnection = () => {
  emit("toggle-connection");
};
</script>

<style lang="scss" scoped>
.chat-navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 24px;
  background: var(--el-bg-color);
  border-bottom: 1px solid var(--el-border-color-light);

  .navbar-left {
    h2 {
      margin: 0;
      font-size: 18px;
      font-weight: 600;
      color: var(--el-text-color-primary);
    }
  }

  .navbar-right {
    display: flex;
    gap: 16px;
    align-items: center;

    .connection-status {
      display: flex;
      gap: 8px;
      align-items: center;
      font-size: 12px;

      .status-icon {
        &.connected {
          color: var(--el-color-success);
        }
        &.connecting {
          color: var(--el-color-warning);
        }
        &.disconnected {
          color: var(--el-color-danger);
        }
      }

      .status-text {
        color: var(--el-text-color-secondary);
      }
    }
  }
}
</style>
