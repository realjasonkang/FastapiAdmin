# -*- coding: utf-8 -*-

from typing import Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator
from urllib.parse import urlparse
from fastapi import Query

from app.core.validator import DateTimeStr
from app.core.base_schema import BaseSchema, UserBySchema, TenantSchema, CustomerSchema


class ApplicationCreateSchema(BaseModel):
    """应用创建模型"""
    name: str = Field(..., max_length=64, description='应用名称')
    access_url: str = Field(..., max_length=255, description="访问地址")
    icon_url: Optional[str] = Field(None, max_length=300, description="应用图标URL")
    status: bool = Field(True, description="是否启用(True:启用 False:禁用)")
    description: Optional[str] = Field(default=None, max_length=255, description="描述")

    @field_validator('access_url')
    @classmethod
    def _validate_access_url(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError('访问地址不能为空')
        parsed = urlparse(v)
        if parsed.scheme not in ('http', 'https'):
            raise ValueError('访问地址必须为 http/https URL')
        return v

    @field_validator('icon_url')
    @classmethod
    def _validate_icon_url(cls, v: Optional[str]) -> Optional[str]:
        if v is None:
            return v
        v = v.strip()
        if v == "":
            return None
        parsed = urlparse(v)
        if parsed.scheme not in ('http', 'https'):
            raise ValueError('应用图标URL必须为 http/https URL')
        return v


class ApplicationUpdateSchema(ApplicationCreateSchema):
    """应用更新模型"""
    ...


class ApplicationOutSchema(ApplicationCreateSchema, BaseSchema, UserBySchema, TenantSchema, CustomerSchema):
    """应用响应模型"""
    model_config = ConfigDict(from_attributes=True)


class ApplicationQueryParam:
    """应用系统查询参数"""

    def __init__(
        self,
        name: Optional[str] = Query(None, description="应用名称"),
        status: Optional[bool] = Query(None, description="是否启用"),
        created_id: Optional[int] = Query(None, description="创建人"),
        start_time: Optional[DateTimeStr] = Query(None, description="开始时间", example="2025-01-01 00:00:00"),
        end_time: Optional[DateTimeStr] = Query(None, description="结束时间", example="2025-12-31 23:59:59"),
    ) -> None:
        
        # 模糊查询字段
        self.name = ("like", name) if name else None

        # 精确查询字段
        self.status = status
        self.created_id = created_id

        # 时间范围查询
        if start_time and end_time:
            self.created_time = ("between", (start_time, end_time))
