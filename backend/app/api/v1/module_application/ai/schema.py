# -*- coding: utf-8 -*-

from typing import Optional, Dict, Any, List
from pydantic import ConfigDict, Field, HttpUrl, BaseModel
from fastapi import Query

from app.core.base_schema import BaseSchema
from app.common.enums import McpLLMProvider
from app.core.base_schema import BaseSchema, UserBySchema, TenantSchema, CustomerSchema
from app.common.enums import McpType


class ChatQuerySchema(BaseModel):
    """聊天查询模型"""
    message: str = Field(..., min_length=1, max_length=4000, description="聊天消息")


class McpCreateSchema(BaseModel):
    """创建 MCP 服务器参数"""
    name: str = Field(..., max_length=50, description='MCP 名称')
    type: McpType = Field(McpType.stdio, description='MCP 类型')
    description: Optional[str] = Field(None, max_length=255, description='MCP 描述')
    url: Optional[HttpUrl] = Field(None, description='远程 SSE 地址')
    command: Optional[str] = Field(None, max_length=255, description='MCP 命令')
    args: Optional[str] = Field(None, max_length=255, description='MCP 命令参数，多个参数用英文逗号隔开')
    env: Optional[Dict[str, Any]] = Field(None, description='MCP 环境变量')


class McpUpdateSchema(McpCreateSchema):
    """更新 MCP 服务器参数"""
    ...


class McpOutSchema(McpCreateSchema, BaseSchema, UserBySchema, TenantSchema, CustomerSchema):
    """MCP 服务器详情"""
    model_config = ConfigDict(from_attributes=True)


class McpQueryParam:
    """MCP 服务器查询参数"""

    def __init__(
        self,
        name: Optional[str] = Query(None, description="MCP 名称"),
        type: Optional[int] = Query(None, description="MCP 类型"),
    ) -> None:
        
        # 模糊查询字段
        self.name = ("like", name) if name else None

        # 精确查询字段
        self.type = type


class McpChatParam(BaseSchema):
    """MCP 聊天参数"""
    pk: List[int] = Field(..., description='MCP ID 列表')
    provider: McpLLMProvider = Field(McpLLMProvider.openai, description='LLM 供应商')
    model: str = Field(..., description='LLM 名称')
    key: str = Field(..., description='LLM API Key')
    base_url: Optional[str] = Field(None, description='自定义 LLM API 地址，必须兼容 openai 供应商')
    prompt: str = Field(..., description='用户提示词')