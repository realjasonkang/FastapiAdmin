# -*- coding: utf-8 -*-

from typing import Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator
from fastapi import Query

from app.core.validator import DateTimeStr
from app.core.base_schema import BaseSchema


class ParamsCreateSchema(BaseModel):
    """配置创建模型"""
    config_name: str = Field(..., max_length=500, description="参数名称")
    config_key: str = Field(..., max_length=500, description="参数键名")
    config_value: Optional[str] = Field(default=None, description="参数键值")
    config_type: bool = Field(default=False, description="系统内置(True:是 False:否)")
    status: bool = Field(default=True, description="状态(True:正常 False:停用)")
    description: Optional[str] = Field(default=None, max_length=500, description="描述")


    @field_validator('config_key')
    @classmethod
    def _validate_config_key(cls, v: str) -> str:
        v = v.strip().lower()
        import re
        if not re.match(r'^[a-z][a-z0-9_.-]*$', v):
            raise ValueError('参数键名必须以小写字母开头，仅包含小写字母/数字/_.-')
        return v


class ParamsUpdateSchema(ParamsCreateSchema):
    """配置更新模型"""
    ...


class ParamsOutSchema(ParamsCreateSchema, BaseSchema):
    """配置响应模型"""
    model_config = ConfigDict(from_attributes=True)


class ParamsQueryParam:
    """配置管理查询参数"""

    def __init__(
            self,
            config_name: Optional[str] = Query(None, description="配置名称"),
            config_key: Optional[str] = Query(None, description="配置键名"),
            config_type: Optional[bool] = Query(None, description="系统内置((True:是 False:否))"),
            start_time: Optional[DateTimeStr] = Query(None, description="开始时间", example="2025-01-01 00:00:00"),
            end_time: Optional[DateTimeStr] = Query(None, description="结束时间", example="2025-12-31 23:59:59"),
    ) -> None:

        # 模糊查询字段
        self.config_name = ("like", config_name)
        self.config_key = ("like", config_key)

        # 精确查询字段
        self.config_type = config_type

        # 时间范围查询
        if start_time and end_time:
            self.created_time = ("between", (start_time, end_time))


