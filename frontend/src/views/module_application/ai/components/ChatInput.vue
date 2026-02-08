<template>
  <div class="chat-input">
    <div class="input-wrapper">
      <div class="input-container">
        <el-input
          v-model="inputMessage"
          :placeholder="placeholder"
          :disabled="disabled || sending"
          type="textarea"
          :rows="1"
          :autosize="{ minRows: 1, maxRows: 6 }"
          resize="none"
          class="message-input"
          @keydown.enter.exact.prevent="handleSend"
          @keydown.shift.enter.exact="handleShiftEnter"
        />
        <el-button
          :disabled="!inputMessage.trim() || disabled || sending"
          :loading="sending"
          class="send-button"
          type="primary"
          circle
          @click="handleSend"
        >
          <el-icon><Promotion /></el-icon>
        </el-button>
      </div>
      <div class="input-footer">
        <span class="input-hint">按 Enter 发送消息，Shift + Enter 换行</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { Promotion } from "@element-plus/icons-vue";

interface Props {
  disabled?: boolean;
  sending?: boolean;
  isConnected?: boolean;
}

interface Emits {
  (e: "send", message: string): void;
}

const props = withDefaults(defineProps<Props>(), {
  disabled: false,
  sending: false,
  isConnected: true,
});

const emit = defineEmits<Emits>();

const inputMessage = ref("");

const placeholder = computed(() => {
  return props.isConnected ? "向FA助手发送消息..." : "请先连接到服务器";
});

const handleSend = () => {
  const message = inputMessage.value.trim();
  if (!message || props.disabled || props.sending) {
    return;
  }
  emit("send", message);
  inputMessage.value = "";
};

const handleShiftEnter = () => {
  inputMessage.value += "\n";
};

defineExpose({
  focus: () => {
    const input = document.querySelector(".message-input textarea") as HTMLTextAreaElement;
    input?.focus();
  },
});
</script>

<style lang="scss" scoped>
.chat-input {
  position: absolute;
  right: 0;
  bottom: 0;
  left: 0;
  background: var(--el-bg-color);
  border-top: 1px solid var(--el-border-color-light);

  .input-wrapper {
    max-width: 800px;
    padding: 16px 24px;
    margin: 0 auto;

    .input-container {
      display: flex;
      gap: 12px;
      align-items: flex-end;

      .message-input {
        flex: 1;

        :deep(.el-textarea__inner) {
          padding-right: 40px;
          resize: none;
        }
      }

      .send-button {
        flex-shrink: 0;
        width: 40px;
        height: 40px;
      }
    }

    .input-footer {
      margin-top: 8px;
      text-align: center;

      .input-hint {
        font-size: 12px;
        color: var(--el-text-color-secondary);
      }
    }
  }
}
</style>
