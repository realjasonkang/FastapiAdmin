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
        <el-form-item prop="knowledge_id" label="知识库">
          <el-select
            v-model="queryFormData.knowledge_id"
            placeholder="请选择知识库"
            style="width: 150px"
            clearable
          >
            <el-option
              v-for="item in knowledgeList"
              :key="item.id"
              :label="item.name"
              :value="item.id ?? 0"
            />
          </el-select>
        </el-form-item>
        <el-form-item prop="title" label="文档标题">
          <el-input v-model="queryFormData.title" placeholder="请输入文档标题" clearable />
        </el-form-item>
        <el-form-item prop="file_type" label="文件类型">
          <el-select
            v-model="queryFormData.file_type"
            placeholder="请选择文件类型"
            style="width: 150px"
            clearable
          >
            <el-option label="文本" value="text" />
            <el-option label="Markdown" value="markdown" />
            <el-option label="PDF" value="pdf" />
            <el-option label="Word" value="word" />
          </el-select>
        </el-form-item>
        <el-form-item prop="is_indexed" label="索引状态">
          <el-select
            v-model="queryFormData.is_indexed"
            placeholder="请选择索引状态"
            style="width: 150px"
            clearable
          >
            <el-option :value="true" label="已索引" />
            <el-option :value="false" label="未索引" />
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
            <el-tooltip content="管理知识库中的文档，用于RAG检索增强。">
              <QuestionFilled class="w-4 h-4 mx-1" />
            </el-tooltip>
            知识库文档列表
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
        <el-table-column label="文档标题" prop="title" min-width="200" show-overflow-tooltip />
        <el-table-column label="知识库" prop="knowledge_id" min-width="120">
          <template #default="scope">
            {{ getKnowledgeName(scope.row.knowledge_id) }}
          </template>
        </el-table-column>
        <el-table-column label="文件类型" prop="file_type" min-width="100">
          <template #default="scope">
            <el-tag>{{ scope.row.file_type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="分块数量" prop="chunk_count" min-width="80" />
        <el-table-column label="索引状态" prop="is_indexed" min-width="80">
          <template #default="scope">
            <el-tag :type="scope.row.is_indexed ? 'success' : 'warning'">
              {{ scope.row.is_indexed ? "已索引" : "未索引" }}
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
      width="800px"
      @close="handleCloseDialog"
    >
      <template v-if="dialogVisible.type === 'detail'">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="文档标题" :span="2">
            {{ detailFormData.title }}
          </el-descriptions-item>
          <el-descriptions-item label="知识库">
            {{ getKnowledgeName(detailFormData.knowledge_id) }}
          </el-descriptions-item>
          <el-descriptions-item label="文件类型">
            {{ detailFormData.file_type }}
          </el-descriptions-item>
          <el-descriptions-item label="分块数量">
            {{ detailFormData.chunk_count }}
          </el-descriptions-item>
          <el-descriptions-item label="索引状态">
            <el-tag :type="detailFormData.is_indexed ? 'success' : 'warning'">
              {{ detailFormData.is_indexed ? "已索引" : "未索引" }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="文档内容" :span="2">
            <div class="document-content">{{ detailFormData.content }}</div>
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
          <el-form-item prop="knowledge_id" label="知识库">
            <el-select
              v-model="formData.knowledge_id"
              placeholder="请选择知识库"
              style="width: 100%"
            >
              <el-option
                v-for="item in knowledgeList"
                :key="item.id"
                :label="item.name"
                :value="item.id ?? 0"
              />
            </el-select>
          </el-form-item>
          <el-form-item prop="title" label="文档标题">
            <el-input v-model="formData.title" placeholder="请输入文档标题" />
          </el-form-item>
          <el-form-item prop="content" label="文档内容">
            <el-input
              v-model="formData.content"
              type="textarea"
              :rows="12"
              placeholder="请输入文档内容"
            />
          </el-form-item>
          <el-form-item prop="file_type" label="文件类型">
            <el-select
              v-model="formData.file_type"
              placeholder="请选择文件类型"
              style="width: 100%"
            >
              <el-option label="文本" value="text" />
              <el-option label="Markdown" value="markdown" />
              <el-option label="PDF" value="pdf" />
              <el-option label="Word" value="word" />
            </el-select>
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
import type { DocumentTable, DocumentForm, KnowledgeTable } from "@/api/module_application/ai";

const queryFormRef = ref();
const dataFormRef = ref();
const dataTableRef = ref();

const loading = ref(false);
const pageTableData = ref<DocumentTable[]>([]);
const total = ref(0);
const selectIds = ref<number[]>([]);
const knowledgeList = ref<KnowledgeTable[]>([]);

const queryFormData = reactive({
  page_no: 1,
  page_size: 10,
  knowledge_id: undefined as number | undefined,
  title: "",
  file_type: "",
  is_indexed: undefined as boolean | undefined,
});

const dialogVisible = reactive({
  visible: false,
  title: "",
  type: "create" as "create" | "update" | "detail",
  id: 0,
});

const formData = reactive<DocumentForm>({
  knowledge_id: undefined,
  title: "",
  content: "",
  file_type: "text",
});

const detailFormData = reactive<DocumentTable>({
  knowledge_id: 0,
  title: "",
  content: "",
  file_type: "text",
  chunk_count: 0,
  is_indexed: false,
});

const rules = {
  knowledge_id: [{ required: true, message: "请选择知识库", trigger: "change" }],
  title: [{ required: true, message: "请输入文档标题", trigger: "blur" }],
  content: [{ required: true, message: "请输入文档内容", trigger: "blur" }],
  file_type: [{ required: true, message: "请选择文件类型", trigger: "change" }],
};

const loadKnowledgeList = async () => {
  try {
    const res = await AiAPI.listKnowledge({ page_no: 1, page_size: 10 });
    if (res.data?.code === 0 || res.data?.success === true) {
      knowledgeList.value = res.data.data?.items || [];
    }
  } catch (error) {
    console.error("获取知识库列表失败:", error);
  }
};

const getKnowledgeName = (id: number) => {
  const knowledge = knowledgeList.value.find((item) => item.id === id);
  return knowledge?.name || "-";
};

const loadingData = async () => {
  loading.value = true;
  try {
    const res = await AiAPI.listDocument(queryFormData);
    if (res.data?.code === 0 || res.data?.success === true) {
      pageTableData.value = res.data.data?.items || [];
      total.value = res.data.data?.total || 0;
    }
  } catch (error) {
    console.error("获取知识库文档列表失败:", error);
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

const handleSelectionChange = (selection: DocumentTable[]) => {
  selectIds.value = selection.map((item) => item.id!);
};

const handleOpenDialog = async (type: "create" | "update" | "detail", id?: number) => {
  dialogVisible.type = type;
  dialogVisible.id = id || 0;

  if (type === "create") {
    dialogVisible.title = "新增知识库文档";
    Object.assign(formData, {
      knowledge_id: undefined,
      title: "",
      content: "",
      file_type: "text",
    });
  } else if (id) {
    const res = await AiAPI.detailDocument(id);
    if (res.data?.code === 0 || res.data?.success === true) {
      if (type === "update") {
        dialogVisible.title = "编辑知识库文档";
        Object.assign(formData, res.data.data);
      } else {
        dialogVisible.title = "知识库文档详情";
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
      res = await AiAPI.createDocument(formData);
    } else {
      res = await AiAPI.updateDocument(dialogVisible.id, formData);
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
    await ElMessageBox.confirm("确定要删除选中的知识库文档吗？此操作不可恢复。", "确认删除", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    });

    const res = await AiAPI.deleteDocument(ids);
    if (res.data?.code === 0 || res.data?.success === true) {
      ElMessage.success("删除成功");
      loadingData();
    } else {
      ElMessage.error(res.data?.msg || "删除失败");
    }
  } catch (error: any) {
    if (error !== "cancel") {
      console.error("删除失败:", error);
      ElMessage.error(error.message || "删除失败");
    }
  }
};

onMounted(() => {
  loadKnowledgeList();
  loadingData();
});
</script>

<style lang="scss" scoped>
.document-content {
  white-space: pre-wrap;
  word-break: break-all;
}
</style>
