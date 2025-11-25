# -*- coding: utf-8 -*-

from typing import Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator
from fastapi import Query

from app.core.validator import DateTimeStr
from app.core.base_schema import BaseSchema, UserBySchema, TenantSchema


class PositionCreateSchema(BaseModel):
    """岗位创建模型"""
    name: str = Field(..., max_length=40, description="岗位名称")
    order: Optional[int] = Field(default=1, ge=1, description='显示排序')
    status: bool = Field(default=True, description="是否启用(True:启用 False:禁用)")
    description: Optional[str] = Field(default=None, max_length=255, description="描述")

    @field_validator('name')
    @classmethod
    def _validate_name(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError('岗位名称不能为空')
        return v


class PositionUpdateSchema(PositionCreateSchema):
    """岗位更新模型"""
    ...


class PositionOutSchema(PositionCreateSchema, BaseSchema, UserBySchema, TenantSchema):
    """岗位信息响应模型"""
    model_config = ConfigDict(from_attributes=True)
    ...


class PositionQueryParam:
    """岗位管理查询参数"""

    def __init__(
        self,
        name: Optional[str] = Query(None, description="岗位名称"),
        status: Optional[bool] = Query(None, description="是否可用"),
        created_id: Optional[int] = Query(None, description="创建人"),
        start_time: Optional[DateTimeStr] = Query(None, description="开始时间", example="2025-01-01 00:00:00"),
        end_time: Optional[DateTimeStr] = Query(None, description="结束时间", example="2025-12-31 23:59:59"),
    ) -> None:
        
        # 模糊查询字段
        self.name = ("like", name)

        # 精确查询字段
        self.created_id = created_id
        self.status = status
        
        # 时间范围查询
        if start_time and end_time:
            self.created_time = ("between", (start_time, end_time))