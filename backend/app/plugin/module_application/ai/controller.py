from typing import Annotated

from fastapi import APIRouter, Body, Depends, Path

from app.api.v1.module_system.auth.schema import AuthSchema
from app.common.request import PaginationService
from app.common.response import ResponseSchema, StreamResponse, SuccessResponse
from app.core.base_params import PaginationQueryParam
from app.core.dependencies import AuthPermission
from app.core.logger import log
from app.core.router_class import OperationLogRoute

from .schema import (
    AgentConfigCreateSchema,
    AgentConfigOutSchema,
    AgentConfigQueryParam,
    AgentConfigUpdateSchema,
    ChatQuerySchema,
    KnowledgeCreateSchema,
    KnowledgeDocumentCreateSchema,
    KnowledgeDocumentOutSchema,
    KnowledgeDocumentQueryParam,
    KnowledgeDocumentUpdateSchema,
    KnowledgeOutSchema,
    KnowledgeQueryParam,
    KnowledgeUpdateSchema,
)
from .service import AgentConfigService, AgentService, KnowledgeService

AIRouter = APIRouter(route_class=OperationLogRoute, prefix="/ai", tags=["智能助手"])


@AIRouter.get(
    "/agent-config/detail/{id}",
    summary="获取智能体配置详情",
    description="获取智能体配置详情",
    response_model=ResponseSchema[AgentConfigOutSchema],
)
async def agent_config_detail_controller(
    id: Annotated[int, Path(description="智能体配置ID")],
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:agent-config:detail"]))],
) -> SuccessResponse:
    """
    获取智能体配置详情接口

    参数:
    - id (int): 智能体配置ID

    返回:
    - SuccessResponse: 包含智能体配置详情的响应
    """
    result_dict = await AgentConfigService.get_by_id_service(auth=auth, id=id)
    log.info(f"获取智能体配置详情成功 {id}")
    return SuccessResponse(data=result_dict, msg="获取智能体配置详情成功")


@AIRouter.get(
    "/agent-config/default",
    summary="获取默认智能体配置",
    description="获取默认智能体配置",
    response_model=ResponseSchema[AgentConfigOutSchema],
)
async def agent_config_default_controller(
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:agent-config:query"]))],
) -> SuccessResponse:
    """
    获取默认智能体配置接口

    参数:
    - auth (AuthSchema): 认证信息模型

    返回:
    - SuccessResponse: 包含默认智能体配置的响应
    """
    result_dict = await AgentConfigService.get_default_service(auth=auth)
    log.info("获取默认智能体配置成功")
    return SuccessResponse(data=result_dict, msg="获取默认智能体配置成功")


@AIRouter.get(
    "/agent-config/list",
    summary="查询智能体配置列表",
    description="查询智能体配置列表",
    response_model=ResponseSchema[list[AgentConfigOutSchema]],
)
async def agent_config_list_controller(
    page: Annotated[PaginationQueryParam, Depends()],
    search: Annotated[AgentConfigQueryParam, Depends()],
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:agent-config:query"]))],
) -> SuccessResponse:
    """
    查询智能体配置列表接口

    参数:
    - page (PaginationQueryParam): 分页查询参数模型
    - search (AgentConfigQueryParam): 查询参数模型
    - auth (AuthSchema): 认证信息模型

    返回:
    - SuccessResponse: 包含智能体配置列表的响应
    """
    result_dict = await AgentConfigService.get_list_service(auth=auth, query_params=search)
    result_dict = await PaginationService.paginate(
        data_list=result_dict["data"],
        page_no=page.page_no,
        page_size=page.page_size,
    )
    log.info("查询智能体配置列表成功")
    return SuccessResponse(data=result_dict, msg="查询智能体配置列表成功")


@AIRouter.post(
    "/agent-config/create",
    summary="创建智能体配置",
    description="创建智能体配置",
    response_model=ResponseSchema[AgentConfigOutSchema],
)
async def agent_config_create_controller(
    data: AgentConfigCreateSchema,
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:agent-config:create"]))],
) -> SuccessResponse:
    """
    创建智能体配置接口

    参数:
    - data (AgentConfigCreateSchema): 创建智能体配置模型
    - auth (AuthSchema): 认证信息模型

    返回:
    - SuccessResponse: 包含创建智能体配置结果的响应
    """
    result_dict = await AgentConfigService.create_service(auth=auth, data=data)
    log.info(f"创建智能体配置成功: {result_dict}")
    return SuccessResponse(data=result_dict, msg="创建智能体配置成功")


@AIRouter.put(
    "/agent-config/update/{id}",
    summary="修改智能体配置",
    description="修改智能体配置",
    response_model=ResponseSchema[AgentConfigOutSchema],
)
async def agent_config_update_controller(
    data: AgentConfigUpdateSchema,
    id: Annotated[int, Path(description="智能体配置ID")],
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:agent-config:update"]))],
) -> SuccessResponse:
    """
    修改智能体配置接口

    参数:
    - data (AgentConfigUpdateSchema): 修改智能体配置模型
    - id (int): 智能体配置ID
    - auth (AuthSchema): 认证信息模型

    返回:
    - SuccessResponse: 包含修改智能体配置结果的响应
    """
    result_dict = await AgentConfigService.update_service(auth=auth, id=id, data=data)
    log.info(f"修改智能体配置成功: {result_dict}")
    return SuccessResponse(data=result_dict, msg="修改智能体配置成功")


@AIRouter.delete(
    "/agent-config/delete",
    summary="删除智能体配置",
    description="删除智能体配置",
    response_model=ResponseSchema[None],
)
async def agent_config_delete_controller(
    ids: Annotated[list[int], Body(description="ID列表")],
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:agent-config:delete"]))],
) -> SuccessResponse:
    """
    删除智能体配置接口

    参数:
    - ids (list[int]): 智能体配置ID列表
    - auth (AuthSchema): 认证信息模型

    返回:
    - SuccessResponse: 包含删除智能体配置结果的响应
    """
    await AgentConfigService.delete_service(auth=auth, ids=ids)
    log.info(f"删除智能体配置成功: {ids}")
    return SuccessResponse(msg="删除智能体配置成功")


@AIRouter.post(
    "/chat",
    summary="智能对话",
    description="与智能助手进行对话",
)
async def chat_controller(
    query: ChatQuerySchema,
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:ai:chat"]))],
) -> StreamResponse:
    """
    智能对话接口

    参数:
    - query (ChatQuerySchema): 聊天查询模型

    返回:
    - StreamingResponse: 流式响应,每次返回一个聊天响应
    """
    user_name = auth.user.name if auth.user else "未知用户"
    log.info(f"用户 {user_name} 发起智能对话: {query.message[:50]}...")

    async def generate_response():
        try:
            async for chunk in AgentService.chat_query(query=query):
                if chunk:
                    yield (chunk.encode("utf-8") if isinstance(chunk, str) else chunk)
        except Exception as e:
            log.error(f"流式响应出错: {e!s}")
            yield f"抱歉，处理您的请求时出现了错误: {e!s}".encode()

    return StreamResponse(generate_response(), media_type="text/plain; charset=utf-8")


@AIRouter.get(
    "/knowledge/detail/{id}",
    summary="获取知识库详情",
    description="获取知识库详情",
    response_model=ResponseSchema[KnowledgeOutSchema],
)
async def knowledge_detail_controller(
    id: Annotated[int, Path(description="知识库ID")],
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:knowledge:query"]))],
) -> SuccessResponse:
    """
    获取知识库详情接口

    参数:
    - id (int): 知识库ID

    返回:
    - SuccessResponse: 包含知识库详情的响应
    """
    result_dict = await KnowledgeService.detail_service(auth=auth, id=id)
    log.info(f"获取知识库详情成功 {id}")
    return SuccessResponse(data=result_dict, msg="获取知识库详情成功")


@AIRouter.get(
    "/knowledge/list",
    summary="查询知识库列表",
    description="查询知识库列表",
    response_model=ResponseSchema[list[KnowledgeOutSchema]],
)
async def knowledge_list_controller(
    page: Annotated[PaginationQueryParam, Depends()],
    search: Annotated[KnowledgeQueryParam, Depends()],
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:knowledge:query"]))],
) -> SuccessResponse:
    """
    查询知识库列表接口

    参数:
    - page (PaginationQueryParam): 分页查询参数模型
    - search (KnowledgeQueryParam): 查询参数模型
    - auth (AuthSchema): 认证信息模型

    返回:
    - SuccessResponse: 包含知识库列表的响应
    """
    result_dict_list = await KnowledgeService.list_service(
        auth=auth, search=search, order_by=page.order_by
    )
    result_dict = await PaginationService.paginate(
        data_list=result_dict_list,
        page_no=page.page_no,
        page_size=page.page_size,
    )
    log.info("查询知识库列表成功")
    return SuccessResponse(data=result_dict, msg="查询知识库列表成功")


@AIRouter.post(
    "/knowledge/create",
    summary="创建知识库",
    description="创建知识库",
    response_model=ResponseSchema[KnowledgeOutSchema],
)
async def knowledge_create_controller(
    data: KnowledgeCreateSchema,
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:knowledge:create"]))],
) -> SuccessResponse:
    """
    创建知识库接口

    参数:
    - data (KnowledgeCreateSchema): 创建知识库模型
    - auth (AuthSchema): 认证信息模型

    返回:
    - SuccessResponse: 包含创建知识库结果的响应
    """
    result_dict = await KnowledgeService.create_service(auth=auth, data=data)
    log.info(f"创建知识库成功: {result_dict}")
    return SuccessResponse(data=result_dict, msg="创建知识库成功")


@AIRouter.put(
    "/knowledge/update/{id}",
    summary="修改知识库",
    description="修改知识库",
    response_model=ResponseSchema[KnowledgeOutSchema],
)
async def knowledge_update_controller(
    data: KnowledgeUpdateSchema,
    id: Annotated[int, Path(description="知识库ID")],
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:knowledge:update"]))],
) -> SuccessResponse:
    """
    修改知识库接口

    参数:
    - data (KnowledgeUpdateSchema): 修改知识库模型
    - id (int): 知识库ID
    - auth (AuthSchema): 认证信息模型

    返回:
    - SuccessResponse: 包含修改知识库结果的响应
    """
    result_dict = await KnowledgeService.update_service(auth=auth, id=id, data=data)
    log.info(f"修改知识库成功: {result_dict}")
    return SuccessResponse(data=result_dict, msg="修改知识库成功")


@AIRouter.delete(
    "/knowledge/delete",
    summary="删除知识库",
    description="删除知识库",
    response_model=ResponseSchema[None],
)
async def knowledge_delete_controller(
    ids: Annotated[list[int], Body(description="ID列表")],
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:knowledge:delete"]))],
) -> SuccessResponse:
    """
    删除知识库接口

    参数:
    - ids (list[int]): 知识库ID列表
    - auth (AuthSchema): 认证信息模型

    返回:
    - SuccessResponse: 包含删除知识库结果的响应
    """
    await KnowledgeService.delete_service(auth=auth, ids=ids)
    log.info(f"删除知识库成功: {ids}")
    return SuccessResponse(msg="删除知识库成功")


@AIRouter.get(
    "/document/detail/{id}",
    summary="获取知识库文档详情",
    description="获取知识库文档详情",
    response_model=ResponseSchema[KnowledgeDocumentOutSchema],
)
async def document_detail_controller(
    id: Annotated[int, Path(description="文档ID")],
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:document:query"]))],
) -> SuccessResponse:
    """
    获取知识库文档详情接口

    参数:
    - id (int): 文档ID

    返回:
    - SuccessResponse: 包含文档详情的响应
    """
    result_dict = await KnowledgeService.document_detail_service(auth=auth, id=id)
    log.info(f"获取知识库文档详情成功 {id}")
    return SuccessResponse(data=result_dict, msg="获取知识库文档详情成功")


@AIRouter.get(
    "/document/list",
    summary="查询知识库文档列表",
    description="查询知识库文档列表",
    response_model=ResponseSchema[list[KnowledgeDocumentOutSchema]],
)
async def document_list_controller(
    page: Annotated[PaginationQueryParam, Depends()],
    search: Annotated[KnowledgeDocumentQueryParam, Depends()],
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:document:query"]))],
) -> SuccessResponse:
    """
    查询知识库文档列表接口

    参数:
    - page (PaginationQueryParam): 分页查询参数模型
    - search (KnowledgeDocumentQueryParam): 查询参数模型
    - auth (AuthSchema): 认证信息模型

    返回:
    - SuccessResponse: 包含文档列表的响应
    """
    result_dict_list = await KnowledgeService.document_list_service(
        auth=auth, search=search, order_by=page.order_by
    )
    result_dict = await PaginationService.paginate(
        data_list=result_dict_list,
        page_no=page.page_no,
        page_size=page.page_size,
    )
    log.info("查询知识库文档列表成功")
    return SuccessResponse(data=result_dict, msg="查询知识库文档列表成功")


@AIRouter.post(
    "/document/create",
    summary="创建知识库文档",
    description="创建知识库文档",
    response_model=ResponseSchema[KnowledgeDocumentOutSchema],
)
async def document_create_controller(
    data: KnowledgeDocumentCreateSchema,
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:document:create"]))],
) -> SuccessResponse:
    """
    创建知识库文档接口

    参数:
    - data (KnowledgeDocumentCreateSchema): 创建文档模型
    - auth (AuthSchema): 认证信息模型

    返回:
    - SuccessResponse: 包含创建文档结果的响应
    """
    result_dict = await KnowledgeService.document_create_service(auth=auth, data=data)
    log.info(f"创建知识库文档成功: {result_dict}")
    return SuccessResponse(data=result_dict, msg="创建知识库文档成功")


@AIRouter.put(
    "/document/update/{id}",
    summary="修改知识库文档",
    description="修改知识库文档",
    response_model=ResponseSchema[KnowledgeDocumentOutSchema],
)
async def document_update_controller(
    data: KnowledgeDocumentUpdateSchema,
    id: Annotated[int, Path(description="文档ID")],
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:document:update"]))],
) -> SuccessResponse:
    """
    修改知识库文档接口

    参数:
    - data (KnowledgeDocumentUpdateSchema): 修改文档模型
    - id (int): 文档ID
    - auth (AuthSchema): 认证信息模型

    返回:
    - SuccessResponse: 包含修改文档结果的响应
    """
    result_dict = await KnowledgeService.document_update_service(auth=auth, id=id, data=data)
    log.info(f"修改知识库文档成功: {result_dict}")
    return SuccessResponse(data=result_dict, msg="修改知识库文档成功")


@AIRouter.delete(
    "/document/delete",
    summary="删除知识库文档",
    description="删除知识库文档",
    response_model=ResponseSchema[None],
)
async def document_delete_controller(
    ids: Annotated[list[int], Body(description="ID列表")],
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_application:document:delete"]))],
) -> SuccessResponse:
    """
    删除知识库文档接口

    参数:
    - ids (list[int]): 文档ID列表
    - auth (AuthSchema): 认证信息模型

    返回:
    - SuccessResponse: 包含删除文档结果的响应
    """
    await KnowledgeService.document_delete_service(auth=auth, ids=ids)
    log.info(f"删除知识库文档成功: {ids}")
    return SuccessResponse(msg="删除知识库文档成功")
