export interface ChatMessage {
  id: string;
  type: "user" | "assistant";
  content: string;
  timestamp: number;
  loading?: boolean;
  collapsed?: boolean;
}

export interface ChatQuery {
  message: string;
  knowledge_ids?: number[];
  agent_config_id?: number;
}

export interface AgentConfig {
  id?: number;
  name: string;
  provider: string;
  model: string;
  api_key: string;
  base_url?: string;
  temperature: number;
  system_prompt: string;
  is_default?: boolean;
  is_active?: boolean;
  created_time?: string;
  updated_time?: string;
  created_by?: any;
  updated_by?: any;
}

export interface AgentConfigQuery {
  name?: string;
  provider?: string;
  is_default?: boolean;
  is_active?: boolean;
  created_time?: string[];
  updated_time?: string[];
  created_id?: number;
  updated_id?: number;
}

export interface Knowledge {
  id?: number;
  name: string;
  description?: string;
  embedding_model: string;
  chunk_size: number;
  chunk_overlap: number;
  is_active?: boolean;
  created_time?: string;
  updated_time?: string;
  created_by?: any;
  updated_by?: any;
}

export interface KnowledgeQuery {
  name?: string;
  is_active?: boolean;
  created_time?: string[];
  updated_time?: string[];
  created_id?: number;
  updated_id?: number;
}

export interface KnowledgeDocument {
  id?: number;
  knowledge_id: number;
  title: string;
  content: string;
  file_type: string;
  file_path?: string;
  metadata?: Record<string, string>;
  chunk_count?: number;
  is_indexed?: boolean;
  created_time?: string;
  updated_time?: string;
  created_by?: any;
  updated_by?: any;
}

export interface KnowledgeDocumentQuery {
  knowledge_id?: number;
  title?: string;
  file_type?: string;
  is_indexed?: boolean;
  created_time?: string[];
  created_id?: number;
}

export interface ConnectionStatus {
  connected: boolean;
  status: "connected" | "connecting" | "disconnected";
}
