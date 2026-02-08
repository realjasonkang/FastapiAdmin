<template>
  <div class="app-container">
    <div class="search-container">
      <el-form
        ref="queryFormRef"
        :model="queryFormData"
        :inline="true"
        label-suffix=":"
        @submit.prevent="handleQuery"
      >
        <el-form-item prop="name" label="智能体名称">
          <el-input v-model="queryFormData.name" placeholder="请输入智能体名称" clearable />
        </el-form-item>
        <el-form-item prop="provider" label="供应商">
          <el-select
            v-model="queryFormData.provider"
            placeholder="请选择供应商"
            style="width: 150px"
            clearable
          >
            <el-option label="OpenAI" value="openai" />
            <el-option label="Deepseek" value="deepseek" />
            <el-option label="Azure" value="azure" />
            <el-option label="Anthropic" value="anthropic" />
          </el-select>
        </el-form-item>
        <el-form-item prop="is_default" label="是否默认">
          <el-select
            v-model="queryFormData.is_default"
            placeholder="请选择"
            style="width: 150px"
            clearable
          >
            <el-option :value="true" label="是" />
            <el-option :value="false" label="否" />
          </el-select>
        </el-form-item>
        <el-form-item prop="is_active" label="状态">
          <el-select
            v-model="queryFormData.is_active"
            placeholder="请选择状态"
            style="width: 150px"
            clearable
          >
            <el-option :value="true" label="启用" />
            <el-option :value="false" label="停用" />
          </el-select>
        </el-form-item>
        <el-form-item class="search-buttons">
          <el-button type="primary" icon="search" native-type="submit">查询</el-button>
          <el-button icon="refresh" @click="handleResetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-card class="data-table">
      <template #header>
        <div class="card-header">
          <span>
            <el-tooltip content="管理AI智能体配置，包括模型、API Key等配置。">
              <QuestionFilled class="w-4 h-4 mx-1" />
            </el-tooltip>
            智能体配置列表
          </span>
        </div>
      </template>

      <div class="data-table__toolbar">
        <div class="data-table__toolbar--left">
          <el-row :gutter="10">
            <el-col :span="1.5">
              <el-button type="success" icon="plus" @click="handleOpenDialog('create')">
                新增
              </el-button>
            </el-col>
            <el-col :span="1.5">
              <el-button
                type="danger"
                icon="delete"
                :disabled="selectIds.length === 0"
                @click="handleDelete(selectIds)"
              >
                批量删除
              </el-button>
            </el-col>
          </el-row>
        </div>
        <div class="data-table__toolbar--right">
          <el-row :gutter="10">
            <el-col :span="1.5">
              <el-tooltip content="刷新">
                <el-button type="primary" icon="refresh" circle @click="handleRefresh" />
              </el-tooltip>
            </el-col>
          </el-row>
        </div>
      </div>

      <el-table
        ref="dataTableRef"
        v-loading="loading"
        :data="pageTableData"
        highlight-current-row
        class="data-table__content"
        border
        stripe
        height="390"
        max-height="390"
        @selection-change="handleSelectionChange"
      >
        <template #empty>
          <el-empty :image-size="80" description="暂无数据" />
        </template>
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column type="index" fixed label="序号" width="60">
          <template #default="scope">
            {{ (queryFormData.page_no - 1) * queryFormData.page_size + scope.$index + 1 }}
          </template>
        </el-table-column>
        <el-table-column label="智能体名称" prop="name" min-width="120" />
        <el-table-column label="供应商" prop="provider" min-width="100">
          <template #default="scope">
            <el-tag>{{ scope.row.provider }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="模型" prop="model" min-width="150" show-overflow-tooltip />
        <el-table-column label="温度参数" prop="temperature" min-width="80" />
        <el-table-column label="是否默认" prop="is_default" min-width="80">
          <template #default="scope">
            <el-tag :type="scope.row.is_default ? 'success' : 'info'">
              {{ scope.row.is_default ? "是" : "否" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" prop="is_active" min-width="80">
          <template #default="scope">
            <el-tag :type="scope.row.is_active ? 'success' : 'danger'">
              {{ scope.row.is_active ? "启用" : "停用" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" prop="created_time" min-width="180" />
        <el-table-column fixed="right" label="操作" align="center" min-width="200">
          <template #default="scope">
            <el-button
              type="info"
              size="small"
              link
              icon="document"
              @click="handleOpenDialog('detail', scope.row.id)"
            >
              详情
            </el-button>
            <el-button
              type="primary"
              size="small"
              link
              icon="edit"
              @click="handleOpenDialog('update', scope.row.id)"
            >
              编辑
            </el-button>
            <el-button
              type="danger"
              size="small"
              link
              icon="delete"
              @click="handleDelete([scope.row.id])"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <template #footer>
        <pagination
          v-model:total="total"
          v-model:page="queryFormData.page_no"
          v-model:limit="queryFormData.page_size"
          @pagination="loadingData"
        />
      </template>
    </el-card>

    <el-dialog
      v-model="dialogVisible.visible"
      :title="dialogVisible.title"
      @close="handleCloseDialog"
    >
      <template v-if="dialogVisible.type === 'detail'">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="智能体名称" :span="2">
            {{ detailFormData.name }}
          </el-descriptions-item>
          <el-descriptions-item label="供应商">
            {{ detailFormData.provider }}
          </el-descriptions-item>
          <el-descriptions-item label="模型">
            {{ detailFormData.model }}
          </el-descriptions-item>
          <el-descriptions-item label="API地址">
            {{ detailFormData.base_url || "-" }}
          </el-descriptions-item>
          <el-descriptions-item label="温度参数">
            {{ detailFormData.temperature }}
          </el-descriptions-item>
          <el-descriptions-item label="是否默认">
            <el-tag :type="detailFormData.is_default ? 'success' : 'info'">
              {{ detailFormData.is_default ? "是" : "否" }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="detailFormData.is_active ? 'success' : 'danger'">
              {{ detailFormData.is_active ? "启用" : "停用" }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="系统提示词" :span="2">
            <div class="prompt-content">{{ detailFormData.system_prompt }}</div>
          </el-descriptions-item>
          <el-descriptions-item label="创建时间" :span="2">
            {{ detailFormData.created_time }}
          </el-descriptions-item>
          <el-descriptions-item label="更新时间" :span="2">
            {{ detailFormData.updated_time }}
          </el-descriptions-item>
        </el-descriptions>
      </template>
      <template v-else>
        <el-form
          ref="dataFormRef"
          :model="formData"
          :rules="rules"
          label-suffix=":"
          label-width="120px"
        >
          <el-form-item prop="name" label="智能体名称">
            <el-input v-model="formData.name" placeholder="请输入智能体名称" />
          </el-form-item>
          <el-form-item prop="provider" label="供应商">
            <el-select v-model="formData.provider" placeholder="请选择供应商" style="width: 100%">
              <el-option label="OpenAI" value="openai" />
              <el-option label="Deepseek" value="deepseek" />
              <el-option label="Azure" value="azure" />
              <el-option label="Anthropic" value="anthropic" />
            </el-select>
          </el-form-item>
          <el-form-item prop="model" label="模型">
            <el-input v-model="formData.model" placeholder="请输入模型名称，如：gpt-4" />
          </el-form-item>
          <el-form-item prop="api_key" label="API Key">
            <el-input
              v-model="formData.api_key"
              type="password"
              placeholder="请输入API Key"
              show-password
            />
          </el-form-item>
          <el-form-item prop="base_url" label="API地址">
            <el-input v-model="formData.base_url" placeholder="请输入自定义API地址（可选）" />
          </el-form-item>
          <el-form-item prop="temperature" label="温度参数">
            <el-slider
              v-model="formData.temperature"
              :min="0"
              :max="2"
              :step="0.1"
              :marks="{ 0: '0', 1: '1', 2: '2' }"
            />
          </el-form-item>
          <el-form-item prop="system_prompt" label="系统提示词">
            <el-input
              v-model="formData.system_prompt"
              type="textarea"
              :rows="6"
              placeholder="请输入系统提示词"
            />
          </el-form-item>
          <el-form-item prop="is_default" label="是否默认">
            <el-switch v-model="formData.is_default" />
          </el-form-item>
          <el-form-item prop="is_active" label="状态">
            <el-switch v-model="formData.is_active" />
          </el-form-item>
        </el-form>
      </template>
      <template #footer>
        <el-button @click="handleCloseDialog">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { QuestionFilled } from "@element-plus/icons-vue";
import AiAPI from "@/api/module_application/ai";
import type { AgentConfigTable, AgentConfigForm } from "@/api/module_application/ai";

const queryFormRef = ref();
const dataFormRef = ref();
const dataTableRef = ref();

const loading = ref(false);
const pageTableData = ref<AgentConfigTable[]>([]);
const total = ref(0);
const selectIds = ref<number[]>([]);

const queryFormData = reactive({
  page_no: 1,
  page_size: 10,
  name: "",
  provider: "",
  is_default: undefined as boolean | undefined,
  is_active: undefined as boolean | undefined,
});

const dialogVisible = reactive({
  visible: false,
  title: "",
  type: "create" as "create" | "update" | "detail",
  id: 0,
});

const formData = reactive<AgentConfigForm>({
  name: "",
  provider: "openai",
  model: "",
  api_key: "",
  base_url: "",
  temperature: 0.7,
  system_prompt: "你是一个有用的AI助手，可以帮助用户回答问题和提供帮助。请用中文回答用户的问题。",
  is_default: false,
  is_active: true,
});

const detailFormData = reactive<AgentConfigTable>({
  name: "",
  provider: "",
  model: "",
  api_key: "",
  base_url: "",
  temperature: 0.7,
  system_prompt: "",
  is_default: false,
  is_active: true,
});

const rules = {
  name: [{ required: true, message: "请输入智能体名称", trigger: "blur" }],
  provider: [{ required: true, message: "请选择供应商", trigger: "change" }],
  model: [{ required: true, message: "请输入模型名称", trigger: "blur" }],
  api_key: [{ required: true, message: "请输入API Key", trigger: "blur" }],
  temperature: [{ required: true, message: "请输入温度参数", trigger: "blur" }],
  system_prompt: [{ required: true, message: "请输入系统提示词", trigger: "blur" }],
};

const loadingData = async () => {
  loading.value = true;
  try {
    const res = await AiAPI.listAgentConfig(queryFormData);
    if (res.data?.code === 0 || res.data?.success === true) {
      pageTableData.value = res.data.data?.items || [];
      total.value = res.data.data?.total || 0;
    }
  } catch (error) {
    console.error("获取智能体配置列表失败:", error);
  } finally {
    loading.value = false;
  }
};

const handleQuery = () => {
  queryFormData.page_no = 1;
  loadingData();
};

const handleResetQuery = () => {
  queryFormRef.value?.resetFields();
  queryFormData.page_no = 1;
  loadingData();
};

const handleRefresh = () => {
  loadingData();
};

const handleSelectionChange = (selection: AgentConfigTable[]) => {
  selectIds.value = selection.map((item) => item.id!);
};

const handleOpenDialog = async (type: "create" | "update" | "detail", id?: number) => {
  dialogVisible.type = type;
  dialogVisible.id = id || 0;

  if (type === "create") {
    dialogVisible.title = "新增智能体配置";
    Object.assign(formData, {
      name: "",
      provider: "openai",
      model: "",
      api_key: "",
      base_url: "",
      temperature: 0.7,
      system_prompt:
        "你是一个有用的AI助手，可以帮助用户回答问题和提供帮助。请用中文回答用户的问题。",
      is_default: false,
      is_active: true,
    });
  } else if (id) {
    const res = await AiAPI.detailAgentConfig(id);
    if (res.data?.code === 0 || res.data?.success === true) {
      if (type === "update") {
        dialogVisible.title = "编辑智能体配置";
        Object.assign(formData, res.data.data);
      } else {
        dialogVisible.title = "智能体配置详情";
        Object.assign(detailFormData, res.data.data);
      }
    }
  }

  dialogVisible.visible = true;
};

const handleCloseDialog = () => {
  dialogVisible.visible = false;
  dataFormRef.value?.resetFields();
};

const handleSubmit = async () => {
  const isValid = await dataFormRef.value?.validate();
  if (!isValid) {
    return;
  }

  try {
    let res;
    if (dialogVisible.type === "create") {
      res = await AiAPI.createAgentConfig(formData);
    } else {
      res = await AiAPI.updateAgentConfig(dialogVisible.id, formData);
    }

    if (res.data?.code === 0 || res.data?.success === true) {
      ElMessage.success(dialogVisible.type === "create" ? "创建成功" : "更新成功");
      handleCloseDialog();
      loadingData();
    } else {
      ElMessage.error(res.data?.msg || "操作失败");
    }
  } catch (error: any) {
    console.error("提交失败:", error);
    ElMessage.error(error.message || "网络错误，请稍后重试");
  }
};

const handleDelete = async (ids: number[]) => {
  try {
    await ElMessageBox.confirm("确定要删除选中的智能体配置吗？此操作不可恢复。", "确认删除", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    });

    const res = await AiAPI.deleteAgentConfig(ids);
    if (res.data?.code === 0 || res.data?.success === true) {
      ElMessage.success("删除成功");
      loadingData();
    }
  } catch (error) {
    if (error !== "cancel") {
      console.error("删除失败:", error);
    }
  }
};

onMounted(() => {
  loadingData();
});
</script>

<style lang="scss" scoped>
.prompt-content {
  white-space: pre-wrap;
  word-break: break-all;
}
</style>
