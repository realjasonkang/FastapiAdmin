# -*- coding: utf-8 -*-

from pydantic import BaseModel, ConfigDict, Field
from typing import Optional
from fastapi import Query

from app.core.validator import DateTimeStr


class OnlineOutSchema(BaseModel):
    """
    在线用户对应pydantic模型
    """

    model_config = ConfigDict(from_attributes=True)

    name: str = Field(..., description='用户名称')
    session_id: str = Field(..., description='会话编号')
    user_id: int = Field(..., description='用户ID')
    user_name: str = Field(..., description='用户名')
    tenant_name: Optional[str] = Field(default=None, description='租户名称')
    ipaddr: Optional[str] = Field(default=None, description='登陆IP地址')
    login_location: Optional[str] = Field(default=None, description='登录所属地')
    os: Optional[str] = Field(default=None, description='操作系统')
    browser: Optional[str] = Field(default=None, description='浏览器')
    login_time: Optional[DateTimeStr] = Field(default=None, description='登录时间')
    login_type: Optional[str] = Field(default=None, description='登录类型 PC端 | 移动端')


class OnlineQueryParam:
    """在线用户查询参数"""

    def __init__(
        self,
        name: Optional[str] = Query(None, description="登录名称"), 
        ipaddr: Optional[str] = Query(None, description="登陆IP地址"),
        login_location: Optional[str] = Query(None, description="登录所属地"),
    ) -> None:
        
        # 模糊查询字段
        self.name = ("like", f"%{name}%") if name else None
        self.login_location = ("like", f"%{login_location}%") if login_location else None
        self.ipaddr = ("like", f"%{ipaddr}%") if ipaddr else None
