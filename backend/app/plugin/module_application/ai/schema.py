
from fastapi import Query
from pydantic import BaseModel, ConfigDict, Field

from app.common.enums import QueueEnum
from app.core.base_schema import BaseSchema, UserBySchema
from app.core.validator import DateTimeStr


class ChatQuerySchema(BaseModel):
    """聊天查询模型"""

    message: str = Field(..., min_length=1, max_length=4000, description="聊天消息")
    knowledge_ids: list[int] | None = Field(None, description="知识库ID列表，用于RAG检索")
    agent_config_id: int | None = Field(None, description="智能体配置ID，用于指定使用的智能体配置")


class AgentConfigSchema(BaseModel):
    """智能体配置参数"""

    provider: str = Field("openai", description="LLM 供应商")
    model: str = Field(..., description="LLM 名称")
    api_key: str = Field(..., description="LLM API Key")
    base_url: str | None = Field(None, description="自定义 LLM API 地址")
    temperature: float = Field(0.7, description="温度参数，控制随机性")
    system_prompt: str = Field("你是一个有用的AI助手，可以帮助用户回答问题和提供帮助。请用中文回答用户的问题。", description="系统提示词")


class AgentConfigCreateSchema(BaseModel):
    """创建智能体配置参数"""

    name: str = Field(..., max_length=100, description="智能体名称")
    provider: str = Field("openai", max_length=50, description="LLM 供应商")
    model: str = Field(..., max_length=100, description="LLM 名称")
    api_key: str = Field(..., max_length=500, description="LLM API Key")
    base_url: str | None = Field(None, max_length=500, description="自定义 LLM API 地址")
    temperature: float = Field(0.7, ge=0.0, le=2.0, description="温度参数，控制随机性")
    system_prompt: str = Field(
        "你是一个有用的AI助手，可以帮助用户回答问题和提供帮助。请用中文回答用户的问题。",
        description="系统提示词",
    )
    is_default: bool = Field(False, description="是否默认配置")
    is_active: bool = Field(True, description="是否启用")


class AgentConfigUpdateSchema(BaseModel):
    """更新智能体配置参数"""

    name: str | None = Field(None, max_length=100, description="智能体名称")
    provider: str | None = Field(None, max_length=50, description="LLM 供应商")
    model: str | None = Field(None, max_length=100, description="LLM 名称")
    api_key: str | None = Field(None, max_length=500, description="LLM API Key")
    base_url: str | None = Field(None, max_length=500, description="自定义 LLM API 地址")
    temperature: float | None = Field(None, ge=0.0, le=2.0, description="温度参数，控制随机性")
    system_prompt: str | None = Field(None, description="系统提示词")
    is_default: bool | None = Field(None, description="是否默认配置")
    is_active: bool | None = Field(None, description="是否启用")


class AgentConfigOutSchema(AgentConfigCreateSchema, BaseSchema, UserBySchema):
    """智能体配置详情"""

    model_config = ConfigDict(from_attributes=True)


class AgentConfigQueryParam:
    """智能体配置查询参数"""

    def __init__(
        self,
        name: str | None = Query(None, description="智能体名称"),
        provider: str | None = Query(None, description="LLM 供应商"),
        is_default: bool | None = Query(None, description="是否默认配置"),
        is_active: bool | None = Query(None, description="是否启用"),
        created_time: list[DateTimeStr] | None = Query(
            None,
            description="创建时间范围",
            examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"],
        ),
        updated_time: list[DateTimeStr] | None = Query(
            None,
            description="更新时间范围",
            examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"],
        ),
        created_id: int | None = Query(None, description="创建人"),
        updated_id: int | None = Query(None, description="更新人"),
    ) -> None:
        self.name = (QueueEnum.like.value, name)
        self.provider = (QueueEnum.eq.value, provider)
        self.is_default = (QueueEnum.eq.value, is_default)
        self.is_active = (QueueEnum.eq.value, is_active)
        self.created_id = (QueueEnum.eq.value, created_id)
        self.updated_id = (QueueEnum.eq.value, updated_id)

        if created_time and len(created_time) == 2:
            self.created_time = (QueueEnum.between.value, (created_time[0], created_time[1]))
        if updated_time and len(updated_time) == 2:
            self.updated_time = (QueueEnum.between.value, (updated_time[0], updated_time[1]))


class KnowledgeCreateSchema(BaseModel):
    """创建知识库参数"""

    name: str = Field(..., max_length=100, description="知识库名称")
    description: str | None = Field(None, max_length=500, description="知识库描述")
    embedding_model: str = Field("openai", max_length=100, description="嵌入模型")
    chunk_size: int = Field(500, ge=100, le=2000, description="分块大小")
    chunk_overlap: int = Field(50, ge=0, le=500, description="分块重叠大小")
    is_active: bool = Field(True, description="是否启用")


class KnowledgeUpdateSchema(KnowledgeCreateSchema):
    """更新知识库参数"""


class KnowledgeOutSchema(KnowledgeCreateSchema, BaseSchema, UserBySchema):
    """知识库详情"""

    model_config = ConfigDict(from_attributes=True)


class KnowledgeQueryParam:
    """知识库查询参数"""

    def __init__(
        self,
        name: str | None = Query(None, description="知识库名称"),
        is_active: bool | None = Query(None, description="是否启用"),
        created_time: list[DateTimeStr] | None = Query(
            None,
            description="创建时间范围",
            examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"],
        ),
        updated_time: list[DateTimeStr] | None = Query(
            None,
            description="更新时间范围",
            examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"],
        ),
        created_id: int | None = Query(None, description="创建人"),
        updated_id: int | None = Query(None, description="更新人"),
    ) -> None:
        self.name = (QueueEnum.like.value, name)
        self.is_active = (QueueEnum.eq.value, is_active)
        self.created_id = (QueueEnum.eq.value, created_id)
        self.updated_id = (QueueEnum.eq.value, updated_id)

        if created_time and len(created_time) == 2:
            self.created_time = (QueueEnum.between.value, (created_time[0], created_time[1]))
        if updated_time and len(updated_time) == 2:
            self.updated_time = (QueueEnum.between.value, (updated_time[0], updated_time[1]))


class KnowledgeDocumentCreateSchema(BaseModel):
    """创建知识库文档参数"""

    knowledge_id: int = Field(..., description="知识库ID")
    title: str = Field(..., max_length=200, description="文档标题")
    content: str = Field(..., description="文档内容")
    file_type: str = Field("text", max_length=50, description="文件类型")
    file_path: str | None = Field(None, max_length=500, description="文件路径")
    meta_data: dict[str, str] | None = Field(None, description="元数据")


class KnowledgeDocumentUpdateSchema(BaseModel):
    """更新知识库文档参数"""

    title: str | None = Field(None, max_length=200, description="文档标题")
    content: str | None = Field(None, description="文档内容")
    meta_data: dict[str, str] | None = Field(None, description="元数据")
    chunk_count: int | None = Field(None, description="分块数量")
    is_indexed: bool | None = Field(None, description="是否已索引")

    model_config = ConfigDict(extra="allow")


class KnowledgeDocumentOutSchema(KnowledgeDocumentCreateSchema, BaseSchema, UserBySchema):
    """知识库文档详情"""

    chunk_count: int = Field(..., description="分块数量")
    is_indexed: bool = Field(..., description="是否已索引")

    model_config = ConfigDict(from_attributes=True)


class KnowledgeDocumentQueryParam:
    """知识库文档查询参数"""

    def __init__(
        self,
        knowledge_id: int | None = Query(None, description="知识库ID"),
        title: str | None = Query(None, description="文档标题"),
        file_type: str | None = Query(None, description="文件类型"),
        is_indexed: bool | None = Query(None, description="是否已索引"),
        created_time: list[DateTimeStr] | None = Query(
            None,
            description="创建时间范围",
            examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"],
        ),
        created_id: int | None = Query(None, description="创建人"),
    ) -> None:
        self.knowledge_id = (QueueEnum.eq.value, knowledge_id)
        self.title = (QueueEnum.like.value, title)
        self.file_type = (QueueEnum.eq.value, file_type)
        self.is_indexed = (QueueEnum.eq.value, is_indexed)
        self.created_id = (QueueEnum.eq.value, created_id)

        if created_time and len(created_time) == 2:
            self.created_time = (QueueEnum.between.value, (created_time[0], created_time[1]))


class RAGQuerySchema(BaseModel):
    """RAG检索查询参数"""

    query: str = Field(..., description="检索查询")
    knowledge_ids: list[int] = Field(..., description="知识库ID列表")
    top_k: int = Field(3, ge=1, le=10, description="返回最相关的文档数量")
