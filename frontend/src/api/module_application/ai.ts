import request from "@/utils/request";

const API_PATH = "/application/ai";

const AiAPI = {
  listAgentConfig(query?: AgentConfigPageQuery) {
    return request<ApiResponse<PageResult<AgentConfigTable[]>>>({
      url: `${API_PATH}/agent-config/list`,
      method: "get",
      params: query,
    });
  },

  detailAgentConfig(id: number) {
    return request<ApiResponse<AgentConfigTable>>({
      url: `${API_PATH}/agent-config/detail/${id}`,
      method: "get",
    });
  },

  defaultAgentConfig() {
    return request<ApiResponse<AgentConfigTable>>({
      url: `${API_PATH}/agent-config/default`,
      method: "get",
    });
  },

  createAgentConfig(body: AgentConfigForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/agent-config/create`,
      method: "post",
      data: body,
    });
  },

  updateAgentConfig(id: number, body: AgentConfigForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/agent-config/update/${id}`,
      method: "put",
      data: body,
    });
  },

  deleteAgentConfig(body: number[]) {
    return request<ApiResponse>({
      url: `${API_PATH}/agent-config/delete`,
      method: "delete",
      data: body,
    });
  },

  listKnowledge(query?: KnowledgePageQuery) {
    return request<ApiResponse<PageResult<KnowledgeTable[]>>>({
      url: `${API_PATH}/knowledge/list`,
      method: "get",
      params: query,
    });
  },

  detailKnowledge(id: number) {
    return request<ApiResponse<KnowledgeTable>>({
      url: `${API_PATH}/knowledge/detail/${id}`,
      method: "get",
    });
  },

  createKnowledge(body: KnowledgeForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/knowledge/create`,
      method: "post",
      data: body,
    });
  },

  updateKnowledge(id: number, body: KnowledgeForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/knowledge/update/${id}`,
      method: "put",
      data: body,
    });
  },

  deleteKnowledge(body: number[]) {
    return request<ApiResponse>({
      url: `${API_PATH}/knowledge/delete`,
      method: "delete",
      data: body,
    });
  },

  listDocument(query?: DocumentPageQuery) {
    return request<ApiResponse<PageResult<DocumentTable[]>>>({
      url: `${API_PATH}/document/list`,
      method: "get",
      params: query,
    });
  },

  detailDocument(id: number) {
    return request<ApiResponse<DocumentTable>>({
      url: `${API_PATH}/document/detail/${id}`,
      method: "get",
    });
  },

  createDocument(body: DocumentForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/document/create`,
      method: "post",
      data: body,
    });
  },

  updateDocument(id: number, body: DocumentForm) {
    return request<ApiResponse>({
      url: `${API_PATH}/document/update/${id}`,
      method: "put",
      data: body,
    });
  },

  deleteDocument(body: number[]) {
    return request<ApiResponse>({
      url: `${API_PATH}/document/delete`,
      method: "delete",
      data: body,
    });
  },
};

export default AiAPI;

export interface AgentConfigPageQuery extends PageQuery {
  name?: string;
  provider?: string;
  is_default?: boolean;
  is_active?: boolean;
  created_time?: string[];
  updated_time?: string[];
  created_id?: number;
  updated_id?: number;
}

export interface AgentConfigTable extends BaseType {
  name: string;
  provider: string;
  model: string;
  api_key: string;
  base_url?: string;
  temperature: number;
  system_prompt: string;
  is_default?: boolean;
  is_active?: boolean;
  created_by?: CommonType;
  updated_by?: CommonType;
}

export interface AgentConfigForm extends BaseFormType {
  name?: string;
  provider?: string;
  model?: string;
  api_key?: string;
  base_url?: string;
  temperature?: number;
  system_prompt?: string;
  is_default?: boolean;
  is_active?: boolean;
}

export interface KnowledgePageQuery extends PageQuery {
  name?: string;
  is_active?: boolean;
  created_time?: string[];
  updated_time?: string[];
  created_id?: number;
  updated_id?: number;
}

export interface KnowledgeTable extends BaseType {
  name: string;
  description?: string;
  embedding_model: string;
  chunk_size: number;
  chunk_overlap: number;
  is_active?: boolean;
  created_by?: CommonType;
  updated_by?: CommonType;
}

export interface KnowledgeForm extends BaseFormType {
  name?: string;
  description?: string;
  embedding_model?: string;
  chunk_size?: number;
  chunk_overlap?: number;
  is_active?: boolean;
}

export interface DocumentPageQuery extends PageQuery {
  knowledge_id?: number;
  title?: string;
  file_type?: string;
  is_indexed?: boolean;
  created_time?: string[];
  created_id?: number;
}

export interface DocumentTable extends BaseType {
  knowledge_id: number;
  title: string;
  content: string;
  file_type: string;
  file_path?: string;
  metadata?: Record<string, string>;
  chunk_count: number;
  is_indexed: boolean;
  created_by?: CommonType;
  updated_by?: CommonType;
}

export interface DocumentForm extends BaseFormType {
  knowledge_id?: number;
  title?: string;
  content?: string;
  file_type?: string;
  file_path?: string;
  metadata?: Record<string, string>;
  chunk_count?: number;
  is_indexed?: boolean;
}
