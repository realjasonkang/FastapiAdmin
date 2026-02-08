from sqlalchemy import JSON, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.base_model import ModelMixin, UserMixin


class AgentConfigModel(ModelMixin, UserMixin):
    """
    智能体配置表
    """

    __tablename__: str = "app_ai_agent_config"
    __table_args__: dict[str, str] = {"comment": "智能体配置表"}
    __loader_options__: list[str] = ["created_by", "updated_by"]

    name: Mapped[str] = mapped_column(String(100), comment="智能体名称")
    provider: Mapped[str] = mapped_column(String(50), default="openai", comment="LLM 供应商")
    model: Mapped[str] = mapped_column(String(100), comment="LLM 名称")
    api_key: Mapped[str] = mapped_column(String(500), comment="LLM API Key")
    base_url: Mapped[str | None] = mapped_column(String(500), default=None, comment="自定义 LLM API 地址")
    temperature: Mapped[float] = mapped_column(Integer, default=70, comment="温度参数 (0-100)")
    system_prompt: Mapped[str] = mapped_column(Text, comment="系统提示词")
    is_default: Mapped[bool] = mapped_column(Integer, default=0, comment="是否默认配置")
    is_active: Mapped[bool] = mapped_column(Integer, default=1, comment="是否启用")


class KnowledgeModel(ModelMixin, UserMixin):
    """
    知识库表
    """

    __tablename__: str = "app_ai_knowledge"
    __table_args__: dict[str, str] = {"comment": "知识库表"}
    __loader_options__: list[str] = ["created_by", "updated_by"]

    name: Mapped[str] = mapped_column(String(100), comment="知识库名称")
    description: Mapped[str | None] = mapped_column(String(500), default=None, comment="知识库描述")
    embedding_model: Mapped[str] = mapped_column(String(100), default="openai", comment="嵌入模型")
    chunk_size: Mapped[int] = mapped_column(Integer, default=500, comment="分块大小")
    chunk_overlap: Mapped[int] = mapped_column(Integer, default=50, comment="分块重叠大小")
    is_active: Mapped[bool] = mapped_column(Integer, default=1, comment="是否启用")


class KnowledgeDocumentModel(ModelMixin, UserMixin):
    """
    知识库文档表
    """

    __tablename__: str = "app_ai_knowledge_document"
    __table_args__: dict[str, str] = {"comment": "知识库文档表"}
    __loader_options__: list[str] = ["created_by", "updated_by"]

    knowledge_id: Mapped[int] = mapped_column(Integer, comment="知识库ID")
    title: Mapped[str] = mapped_column(String(200), comment="文档标题")
    content: Mapped[str] = mapped_column(Text, comment="文档内容")
    file_type: Mapped[str] = mapped_column(String(50), default="text", comment="文件类型")
    file_path: Mapped[str | None] = mapped_column(String(500), default=None, comment="文件路径")
    meta_data: Mapped[dict[str, str] | None] = mapped_column(JSON(), default=None, comment="元数据")
    chunk_count: Mapped[int] = mapped_column(Integer, default=0, comment="分块数量")
    is_indexed: Mapped[bool] = mapped_column(Integer, default=0, comment="是否已索引")
