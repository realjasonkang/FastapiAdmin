from collections.abc import AsyncGenerator
from typing import Any
from collections.abc import AsyncGenerator
from typing import Any

from langchain_core.messages import HumanMessage, SystemMessage
from langchain_openai import ChatOpenAI

from app.api.v1.module_system.auth.schema import AuthSchema
from app.core.exceptions import CustomException
from app.config.setting import settings
from app.core.logger import log

from .crud import McpCRUD
from .schema import (
    ChatQuerySchema,
    McpCreateSchema,
    McpOutSchema,
    McpQueryParam,
    McpUpdateSchema,
)

class McpService:
    """MCP服务层"""

    @classmethod
    async def detail_service(cls, auth: AuthSchema, id: int) -> dict[str, Any]:
        """
        获取MCP服务器详情

        参数:
        - auth (AuthSchema): 认证信息模型
        - id (int): MCP服务器ID

        返回:
        - dict[str, Any]: MCP服务器详情字典
        """
        obj = await McpCRUD(auth).get_by_id_crud(id=id)
        if not obj:
            raise CustomException(msg="MCP 服务器不存在")
        return McpOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def list_service(
        cls,
        auth: AuthSchema,
        search: McpQueryParam | None = None,
        order_by: list[dict[str, str]] | None = None,
    ) -> list[dict[str, Any]]:
        """
        列表查询MCP服务器

        参数:
        - auth (AuthSchema): 认证信息模型
        - search (McpQueryParam | None): 查询参数模型
        - order_by (list[dict[str, str]] | None): 排序参数列表

        返回:
        - list[dict[str, Any]]: MCP服务器详情字典列表
        """
        search_dict = search.__dict__ if search else None
        obj_list = await McpCRUD(auth).get_list_crud(search=search_dict, order_by=order_by)
        return [McpOutSchema.model_validate(obj).model_dump() for obj in obj_list]

    @classmethod
    async def create_service(cls, auth: AuthSchema, data: McpCreateSchema) -> dict[str, Any]:
        """
        创建MCP服务器

        参数:
        - auth (AuthSchema): 认证信息模型
        - data (McpCreateSchema): 创建MCP服务器模型

        返回:
        - dict[str, Any]: 创建的MCP服务器详情字典
        """
        obj = await McpCRUD(auth).get_by_name_crud(name=data.name)
        if obj:
            raise CustomException(msg="创建失败，MCP 服务器已存在")
        obj = await McpCRUD(auth).create_crud(data=data)
        return McpOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def update_service(
        cls, auth: AuthSchema, id: int, data: McpUpdateSchema
    ) -> dict[str, Any]:
        """
        更新MCP服务器

        参数:
        - auth (AuthSchema): 认证信息模型
        - id (int): MCP服务器ID
        - data (McpUpdateSchema): 更新MCP服务器模型

        返回:
        - dict[str, Any]: 更新的MCP服务器详情字典
        """
        obj = await McpCRUD(auth).get_by_id_crud(id=id)
        if not obj:
            raise CustomException(msg="更新失败，该数据不存在")
        exist_obj = await McpCRUD(auth).get_by_name_crud(name=data.name)
        if exist_obj and exist_obj.id != id:
            raise CustomException(msg="更新失败，MCP 服务器名称重复")
        obj = await McpCRUD(auth).update_crud(id=id, data=data)
        return McpOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def delete_service(cls, auth: AuthSchema, ids: list[int]) -> None:
        """
        批量删除MCP服务器

        参数:
        - auth (AuthSchema): 认证信息模型
        - ids (list[int]): MCP服务器ID列表

        返回:
        - None
        """
        if len(ids) < 1:
            raise CustomException(msg="删除失败，删除对象不能为空")
        for id in ids:
            obj = await McpCRUD(auth).get_by_id_crud(id=id)
            if not obj:
                raise CustomException(msg="删除失败，该数据不存在")
        await McpCRUD(auth).delete_crud(ids=ids)

    @classmethod
    async def chat_query(cls, query: ChatQuerySchema) -> AsyncGenerator[str, Any]:
        """
        处理聊天查询

        参数:
        - query (ChatQuerySchema): 聊天查询模型

        返回:
        - AsyncGenerator[str, None]: 异步生成器,每次返回一个聊天响应
        """
        # 创建MCP客户端实例
        lll_model = ChatOpenAI(
            api_key=lambda: settings.OPENAI_API_KEY,
            model=settings.OPENAI_MODEL,
            base_url=settings.OPENAI_BASE_URL,
            temperature=0.7,
            streaming=True,
        )

        system_prompt = (
            """你是一个有用的AI助手，可以帮助用户回答问题和提供帮助。请用中文回答用户的问题。"""
        )

        messages = [
            SystemMessage(content=system_prompt),
            HumanMessage(content=query.message),
        ]

        try:
            # 使用LangChain的流式响应
            async for chunk in lll_model.astream(messages):
                yield chunk.text

        except Exception as e:
            log.debug(f"关闭AIClient时发生异常(预期行为，服务可能正在关闭): {e}")
            
            status_code = getattr(e, "status_code", None)
            body = getattr(e, "body", None)
            message = None
            error_type = None
            error_code = None
            try:
                if isinstance(body, dict) and "error" in body:
                    err = body.get("error") or {}
                    error_type = err.get("type")
                    error_code = err.get("code")
                    message = err.get("message")
            except Exception:
                raise CustomException(f"解析 OpenAI 错误失败: {e!s}")

            text = str(e)
            msg = message or text

            # 特定错误映射
            # 欠费/账户状态异常
            if (
                (error_code == "Arrearage")
                or (error_type == "Arrearage")
                or ("in good standing" in (msg or ""))
            ):
                raise ValueError("账户欠费或结算异常，访问被拒绝。请检查账号状态或更换有效的 API Key。")
            # 鉴权失败
            if status_code == 401 or "invalid api key" in msg.lower():
                raise ValueError("鉴权失败，API Key 无效或已过期。请检查系统配置中的 API Key。")
            # 权限不足或被拒绝
            if status_code == 403 or error_type in {
                "PermissionDenied",
                "permission_denied",
            }:
                raise ValueError("访问被拒绝，权限不足或账号受限。请检查账户权限设置。")
            # 配额不足或限流
            if status_code == 429 or error_type in {
                "insufficient_quota",
                "rate_limit_exceeded",
            }:
                raise ValueError("请求过于频繁或配额已用尽。请稍后重试或提升账户配额。")
            # 客户端错误
            if status_code == 400:
                raise ValueError(f"请求参数错误或服务拒绝：{message or '请检查输入内容。'}")
            # 服务端错误
            if status_code in {500, 502, 503, 504}:
                raise ValueError("服务暂时不可用，请稍后重试。")

            # 默认兜底
            raise CustomException(f"处理您的请求时出现错误：{msg}")

