<template>
  <div class="main-chat">
    <ChatNavbar
      :connection-status="connectionStatus"
      :is-connected="isConnected"
      :message-count="messages.length"
      @clear-chat="handleClearChat"
      @toggle-connection="toggleConnection"
    />
    <ChatMessages
      ref="chatMessagesRef"
      :messages="messages"
      :error="error"
      @prompt-click="handlePromptClick"
      @error-close="error = ''"
    />
    <ChatInput
      :disabled="!isConnected"
      :sending="sending"
      :is-connected="isConnected"
      @send="handleSendMessage"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import ChatNavbar from "./ChatNavbar.vue";
import ChatMessages from "./ChatMessages.vue";
import ChatInput from "./ChatInput.vue";
import type { ChatMessage } from "../types";

const messages = ref<ChatMessage[]>([]);
const sending = ref(false);
const isConnected = ref(false);
const connectionStatus = ref<"connected" | "connecting" | "disconnected">("disconnected");
const error = ref("");
const chatMessagesRef = ref<InstanceType<typeof ChatMessages>>();

let ws: WebSocket | null = null;
const WS_URL = import.meta.env.VITE_APP_WS_ENDPOINT + "/api/v1/application/ai/ws";

const connectWebSocket = () => {
  if (ws?.readyState === WebSocket.OPEN) {
    return;
  }

  connectionStatus.value = "connecting";
  error.value = "";

  try {
    ws = new WebSocket(WS_URL);

    ws.onopen = () => {
      console.log("WebSocket 连接已建立");
      isConnected.value = true;
      connectionStatus.value = "connected";
      ElMessage.success("连接成功");
    };

    ws.onmessage = (event) => {
      handleWebSocketMessage({ content: event.data });
    };

    ws.onclose = (event) => {
      console.log("WebSocket 连接已关闭", event.code, event.reason);
      isConnected.value = false;
      connectionStatus.value = "disconnected";
      finishLoadingMessages();
    };

    ws.onerror = (error) => {
      console.error("WebSocket 错误:", error);
      isConnected.value = false;
      connectionStatus.value = "disconnected";
      ElMessage.error("连接失败，请检查服务器状态");
      finishLoadingMessages();
    };
  } catch (err) {
    console.error("创建 WebSocket 连接失败:", err);
    connectionStatus.value = "disconnected";
    error.value = "无法创建连接";
  }
};

const disconnectWebSocket = () => {
  if (ws) {
    ws.close(1000, "用户主动断开");
    ws = null;
  }
  isConnected.value = false;
  connectionStatus.value = "disconnected";
  finishLoadingMessages();
};

const toggleConnection = () => {
  if (isConnected.value) {
    disconnectWebSocket();
    ElMessage.info("已断开连接");
  } else {
    connectWebSocket();
  }
};

const handleWebSocketMessage = (data: any) => {
  const lastMessage = messages.value[messages.value.length - 1];

  if (lastMessage && lastMessage.type === "assistant" && lastMessage.loading) {
    lastMessage.content += data.content || data.message || "";
  } else {
    addMessage("assistant", data.content || data.message || "收到回复");
  }

  chatMessagesRef.value?.scrollToBottom();
};

const handleSendMessage = (message: string) => {
  if (!message || !isConnected.value || sending.value) {
    return;
  }

  const lastMessage = messages.value[messages.value.length - 1];
  if (lastMessage && lastMessage.type === "assistant" && lastMessage.loading) {
    lastMessage.loading = false;
  }

  addMessage("user", message);

  const loadingMessage: ChatMessage = {
    id: generateId(),
    type: "assistant",
    content: "",
    timestamp: Date.now(),
    loading: true,
  };
  messages.value.push(loadingMessage);

  sending.value = true;
  chatMessagesRef.value?.scrollToBottom();

  try {
    if (ws?.readyState === WebSocket.OPEN) {
      ws.send(message);
    } else {
      throw new Error("WebSocket 连接未建立");
    }
  } catch (err) {
    console.error("发送消息失败:", err);
    messages.value.pop();
    error.value = "发送消息失败，请检查连接状态";
    ElMessage.error("发送失败");
  } finally {
    sending.value = false;
  }
};

const addMessage = (type: "user" | "assistant", content: string) => {
  const message: ChatMessage = {
    id: generateId(),
    type,
    content,
    timestamp: Date.now(),
    collapsed: content.length > 200,
  };
  messages.value.push(message);
};

const handleClearChat = async () => {
  try {
    await ElMessageBox.confirm("确定要清空当前对话吗？此操作不可恢复。", "确认清空", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    });
    messages.value = [];
    ElMessage.success("对话已清空");
  } catch {
    ElMessage.info("已取消清空对话");
  }
};

const handlePromptClick = (prompt: string) => {
  handleSendMessage(prompt);
};

const finishLoadingMessages = () => {
  messages.value.forEach((message) => {
    if (message.type === "assistant" && message.loading) {
      message.loading = false;
      message.collapsed = message.content.length > 200;
    }
  });
};

const generateId = () => {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
};

onMounted(() => {
  connectWebSocket();
});

onUnmounted(() => {
  disconnectWebSocket();
});
</script>

<style lang="scss" scoped>
.main-chat {
  position: relative;
  display: flex;
  flex: 1;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}
</style>
