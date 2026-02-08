<template>
  <div class="app-container">
    <el-tabs v-model="activeTab" type="border-card">
      <el-tab-pane label="智能对话" name="chat">
        <ChatView />
      </el-tab-pane>
      <el-tab-pane label="智能体配置" name="agent">
        <AgentConfigView />
      </el-tab-pane>
      <el-tab-pane label="知识库" name="knowledge">
        <KnowledgeView />
      </el-tab-pane>
      <el-tab-pane label="知识库文档" name="document">
        <KnowledgeDocumentView />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import ChatView from "./components/ChatView.vue";
import AgentConfigView from "./components/AgentConfigView.vue";
import KnowledgeView from "./components/KnowledgeView.vue";
import KnowledgeDocumentView from "./components/KnowledgeDocumentView.vue";

const activeTab = ref("chat");
</script>

<style lang="scss" scoped>
.app-container {
  :deep(.el-tabs) {
    display: flex;
    flex-direction: column;
    height: 100%;

    .el-tabs__content {
      flex: 1;
      overflow: hidden;

      .el-tab-pane {
        height: 100%;
        overflow: auto;
      }
    }
  }
}
</style>
