from collections.abc import AsyncGenerator
from typing import Any

from langchain_core.documents import Document
from langchain_core.messages import HumanMessage, SystemMessage
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

from app.api.v1.module_system.auth.schema import AuthSchema
from app.config.setting import settings
from app.core.exceptions import CustomException
from app.core.logger import log

from .chroma import chroma_manager
from .crud import AgentConfigCRUD, KnowledgeCRUD, KnowledgeDocumentCRUD
from .schema import (
    AgentConfigCreateSchema,
    AgentConfigOutSchema,
    AgentConfigSchema,
    AgentConfigUpdateSchema,
    ChatQuerySchema,
    KnowledgeCreateSchema,
    KnowledgeDocumentCreateSchema,
    KnowledgeDocumentOutSchema,
    KnowledgeDocumentUpdateSchema,
    KnowledgeOutSchema,
    KnowledgeQueryParam,
    KnowledgeUpdateSchema,
)


class AgentConfigService:
    """智能体配置服务层"""

    @classmethod
    async def get_by_id_service(
        cls, auth: AuthSchema, id: int
    ) -> dict[str, Any]:
        """
        获取智能体配置详情

        参数:
        - auth (AuthSchema): 认证信息模型
        - id (int): 智能体配置ID

        返回:
        - dict[str, Any]: 智能体配置详情字典
        """
        obj = await AgentConfigCRUD(auth).get_by_id_crud(id=id)
        if not obj:
            raise CustomException(msg="智能体配置不存在")
        return AgentConfigOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def get_default_service(
        cls, auth: AuthSchema
    ) -> dict[str, Any]:
        """
        获取默认智能体配置

        参数:
        - auth (AuthSchema): 认证信息模型

        返回:
        - dict[str, Any]: 智能体配置详情字典
        """
        obj = await AgentConfigCRUD(auth).get_default_crud()
        if not obj:
            raise CustomException(msg="默认智能体配置不存在")
        return AgentConfigOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def get_list_service(
        cls, auth: AuthSchema, query_params: Any
    ) -> dict[str, Any]:
        """
        列表查询智能体配置

        参数:
        - auth (AuthSchema): 认证信息模型
        - query_params (Any): 查询参数

        返回:
        - dict[str, Any]: 智能体配置列表字典
        """
        search = {}
        if query_params.name:
            search["name"] = query_params.name
        if query_params.provider:
            search["provider"] = query_params.provider
        if query_params.is_default is not None:
            search["is_default"] = query_params.is_default
        if query_params.is_active is not None:
            search["is_active"] = query_params.is_active
        if query_params.created_id:
            search["created_id"] = query_params.created_id
        if query_params.updated_id:
            search["updated_id"] = query_params.updated_id
        if hasattr(query_params, "created_time") and query_params.created_time:
            search["created_time"] = query_params.created_time
        if hasattr(query_params, "updated_time") and query_params.updated_time:
            search["updated_time"] = query_params.updated_time

        objs = await AgentConfigCRUD(auth).get_list_crud(
            search=search, order_by=[{"id": "desc"}]
        )
        data = [AgentConfigOutSchema.model_validate(obj).model_dump() for obj in objs]
        return {"total": len(data), "data": data}

    @classmethod
    async def create_service(
        cls, auth: AuthSchema, data: AgentConfigCreateSchema
    ) -> dict[str, Any]:
        """
        创建智能体配置

        参数:
        - auth (AuthSchema): 认证信息模型
        - data (AgentConfigCreateSchema): 创建智能体配置模型

        返回:
        - dict[str, Any]: 创建的智能体配置字典
        """
        if data.is_default:
            existing_default = await AgentConfigCRUD(auth).get_default_crud()
            if existing_default:
                update_data = AgentConfigUpdateSchema.model_construct(is_default=False)
                await AgentConfigCRUD(auth).update_crud(id=existing_default.id, data=update_data)

        obj = await AgentConfigCRUD(auth).create_crud(data=data)
        if not obj:
            raise CustomException(msg="创建智能体配置失败")
        return AgentConfigOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def update_service(
        cls, auth: AuthSchema, id: int, data: AgentConfigUpdateSchema
    ) -> dict[str, Any]:
        """
        更新智能体配置

        参数:
        - auth (AuthSchema): 认证信息模型
        - id (int): 智能体配置ID
        - data (AgentConfigUpdateSchema): 更新智能体配置模型

        返回:
        - dict[str, Any]: 更新的智能体配置字典
        """
        obj = await AgentConfigCRUD(auth).get_by_id_crud(id=id)
        if not obj:
            raise CustomException(msg="智能体配置不存在")

        if data.is_default:
            existing_default = await AgentConfigCRUD(auth).get_default_crud()
            if existing_default and existing_default.id != id:
                update_data = AgentConfigUpdateSchema.model_construct(is_default=False)
                await AgentConfigCRUD(auth).update_crud(id=existing_default.id, data=update_data)

        obj = await AgentConfigCRUD(auth).update_crud(id=id, data=data)
        if not obj:
            raise CustomException(msg="更新智能体配置失败")
        return AgentConfigOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def delete_service(cls, auth: AuthSchema, ids: list[int]) -> None:
        """
        批量删除智能体配置

        参数:
        - auth (AuthSchema): 认证信息模型
        - ids (list[int]): 智能体配置ID列表

        返回:
        - None
        """
        await AgentConfigCRUD(auth).delete_crud(ids=ids)


class RAGService:
    """RAG 检索增强生成服务层"""

    @classmethod
    async def retrieve_documents(
        cls,
        query: str,
        knowledge_ids: list[int],
        top_k: int = 3,
        auth: AuthSchema | None = None,
    ) -> list[Document]:
        """
        从知识库中检索相关文档

        参数:
        - query (str): 查询文本
        - knowledge_ids (list[int]): 知识库ID列表
        - top_k (int): 返回最相关的文档数量
        - auth (AuthSchema | None): 认证信息模型

        返回:
        - list[Document]: 相关文档列表
        """
        embeddings = OpenAIEmbeddings(
            api_key=lambda: settings.OPENAI_API_KEY,
            base_url=settings.OPENAI_BASE_URL,
        )

        query_embedding = await embeddings.aembed_query(query)

        results = chroma_manager.query_documents(
            query_embeddings=[query_embedding],
            n_results=top_k,
            where={"knowledge_id": {"$in": knowledge_ids}},
        )

        documents = []
        if results and "documents" in results and len(results["documents"]) > 0:
            for i, doc_content in enumerate(results["documents"][0]):
                metadata = results["metadatas"][0][i] if "metadatas" in results and len(results["metadatas"]) > 0 else {}
                documents.append(
                    Document(
                        page_content=doc_content,
                        metadata=metadata,
                    )
                )

        return documents

    @classmethod
    def format_context(cls, documents: list[Document]) -> str:
        """
        格式化检索到的文档为上下文

        参数:
        - documents (list[Document]): 文档列表

        返回:
        - str: 格式化的上下文文本
        """
        if not documents:
            return "没有找到相关的知识库内容。"

        context_parts = []
        for i, doc in enumerate(documents, 1):
            title = doc.metadata.get("title", "未知文档")
            content = doc.page_content
            context_parts.append(f"[文档 {i}] {title}\n{content}")

        return "\n\n".join(context_parts)


class AgentService:
    """智能体服务层"""

    @classmethod
    async def chat_query(
        cls, query: ChatQuerySchema, config: AgentConfigSchema | None = None
    ) -> AsyncGenerator[str, Any]:
        """
        处理聊天查询

        参数:
        - query (ChatQuerySchema): 聊天查询模型
        - config (AgentConfigSchema | None): 智能体配置模型

        返回:
        - AsyncGenerator[str, None]: 异步生成器,每次返回一个聊天响应
        """
        if config is None:
            config = AgentConfigSchema(
                provider="openai",
                model=settings.OPENAI_MODEL,
                api_key=settings.OPENAI_API_KEY,
                base_url=settings.OPENAI_BASE_URL,
                temperature=0.7,
                system_prompt="你是一个有用的AI助手，可以帮助用户回答问题和提供帮助。请用中文回答用户的问题。",
            )

        system_prompt = config.system_prompt

        if query.knowledge_ids:
            retrieved_docs = await RAGService.retrieve_documents(
                query=query.message,
                knowledge_ids=query.knowledge_ids,
                top_k=3,
            )
            context = RAGService.format_context(retrieved_docs)
            system_prompt = f"""{config.system_prompt}

以下是从知识库中检索到的相关内容，请参考这些内容回答用户的问题：

{context}

如果检索到的内容与问题无关，请忽略这些内容，直接回答用户的问题。"""

        llm = ChatOpenAI(
            api_key=lambda: config.api_key,
            model=config.model,
            base_url=config.base_url,
            temperature=config.temperature,
            streaming=True,
        )

        messages = [
            SystemMessage(content=system_prompt),
            HumanMessage(content=query.message),
        ]

        try:
            async for chunk in llm.astream(messages):
                yield chunk.text

        except Exception as e:
            log.debug(f"关闭 LLM 客户端时发生异常(预期行为，服务可能正在关闭): {e}")

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

            if (
                (error_code == "Arrearage")
                or (error_type == "Arrearage")
                or ("in good standing" in (msg or ""))
            ):
                raise ValueError(
                    "账户欠费或结算异常，访问被拒绝。请检查账号状态或更换有效的 API Key。"
                )
            if status_code == 401 or "invalid api key" in msg.lower():
                raise ValueError("鉴权失败，API Key 无效或已过期。请检查系统配置中的 API Key。")
            if status_code == 403 or error_type in {
                "PermissionDenied",
                "permission_denied",
            }:
                raise ValueError("访问被拒绝，权限不足或账号受限。请检查账户权限设置。")
            if status_code == 429 or error_type in {
                "insufficient_quota",
                "rate_limit_exceeded",
            }:
                raise ValueError("请求过于频繁或配额已用尽。请稍后重试或提升账户配额。")
            if status_code == 400:
                raise ValueError(f"请求参数错误或服务拒绝：{message or '请检查输入内容。'}")
            if status_code in {500, 502, 503, 504}:
                raise ValueError("服务暂时不可用，请稍后重试。")

            raise CustomException(f"处理您的请求时出现错误：{msg}")


class KnowledgeService:
    """知识库服务层"""

    @classmethod
    async def detail_service(cls, auth: AuthSchema, id: int) -> dict[str, Any]:
        """
        获取知识库详情

        参数:
        - auth (AuthSchema): 认证信息模型
        - id (int): 知识库ID

        返回:
        - dict[str, Any]: 知识库详情字典
        """
        obj = await KnowledgeCRUD(auth).get_by_id_crud(id=id)
        if not obj:
            raise CustomException(msg="知识库不存在")
        return KnowledgeOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def list_service(
        cls,
        auth: AuthSchema,
        search: KnowledgeQueryParam | None = None,
        order_by: list[dict[str, str]] | None = None,
    ) -> list[dict[str, Any]]:
        """
        列表查询知识库

        参数:
        - auth (AuthSchema): 认证信息模型
        - search (KnowledgeQueryParam | None): 查询参数模型
        - order_by (list[dict[str, str]] | None): 排序参数列表

        返回:
        - list[dict[str, Any]]: 知识库详情字典列表
        """
        search_dict = search.__dict__ if search else None
        obj_list = await KnowledgeCRUD(auth).get_list_crud(search=search_dict, order_by=order_by)
        return [KnowledgeOutSchema.model_validate(obj).model_dump() for obj in obj_list]

    @classmethod
    async def create_service(cls, auth: AuthSchema, data: KnowledgeCreateSchema) -> dict[str, Any]:
        """
        创建知识库

        参数:
        - auth (AuthSchema): 认证信息模型
        - data (KnowledgeCreateSchema): 创建知识库模型

        返回:
        - dict[str, Any]: 创建的知识库详情字典
        """
        obj = await KnowledgeCRUD(auth).get_by_name_crud(name=data.name)
        if obj:
            raise CustomException(msg="创建失败，知识库已存在")
        obj = await KnowledgeCRUD(auth).create_crud(data=data)
        return KnowledgeOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def update_service(
        cls, auth: AuthSchema, id: int, data: KnowledgeUpdateSchema
    ) -> dict[str, Any]:
        """
        更新知识库

        参数:
        - auth (AuthSchema): 认证信息模型
        - id (int): 知识库ID
        - data (KnowledgeUpdateSchema): 更新知识库模型

        返回:
        - dict[str, Any]: 更新的知识库详情字典
        """
        obj = await KnowledgeCRUD(auth).get_by_id_crud(id=id)
        if not obj:
            raise CustomException(msg="更新失败，该数据不存在")
        exist_obj = await KnowledgeCRUD(auth).get_by_name_crud(name=data.name)
        if exist_obj and exist_obj.id != id:
            raise CustomException(msg="更新失败，知识库名称重复")
        obj = await KnowledgeCRUD(auth).update_crud(id=id, data=data)
        return KnowledgeOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def delete_service(cls, auth: AuthSchema, ids: list[int]) -> None:
        """
        批量删除知识库

        参数:
        - auth (AuthSchema): 认证信息模型
        - ids (list[int]): 知识库ID列表

        返回:
        - None
        """
        if len(ids) < 1:
            raise CustomException(msg="删除失败，删除对象不能为空")
        for id in ids:
            obj = await KnowledgeCRUD(auth).get_by_id_crud(id=id)
            if not obj:
                raise CustomException(msg="删除失败，该数据不存在")
        await KnowledgeCRUD(auth).delete_crud(ids=ids)

    @classmethod
    async def document_detail_service(cls, auth: AuthSchema, id: int) -> dict[str, Any]:
        """
        获取知识库文档详情

        参数:
        - auth (AuthSchema): 认证信息模型
        - id (int): 文档ID

        返回:
        - dict[str, Any]: 文档详情字典
        """
        obj = await KnowledgeDocumentCRUD(auth).get_by_id_crud(id=id)
        if not obj:
            raise CustomException(msg="文档不存在")
        return KnowledgeDocumentOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def document_list_service(
        cls,
        auth: AuthSchema,
        search: Any | None = None,
        order_by: list[dict[str, str]] | None = None,
    ) -> list[dict[str, Any]]:
        """
        列表查询知识库文档

        参数:
        - auth (AuthSchema): 认证信息模型
        - search (Any | None): 查询参数模型
        - order_by (list[dict[str, str]] | None): 排序参数列表

        返回:
        - list[dict[str, Any]]: 文档详情字典列表
        """
        search_dict = search.__dict__ if search else None
        obj_list = await KnowledgeDocumentCRUD(auth).get_list_crud(
            search=search_dict, order_by=order_by
        )
        return [KnowledgeDocumentOutSchema.model_validate(obj).model_dump() for obj in obj_list]

    @classmethod
    async def document_create_service(
        cls, auth: AuthSchema, data: KnowledgeDocumentCreateSchema
    ) -> dict[str, Any]:
        """
        创建知识库文档

        参数:
        - auth (AuthSchema): 认证信息模型
        - data (KnowledgeDocumentCreateSchema): 创建文档模型

        返回:
        - dict[str, Any]: 创建的文档详情字典
        """
        knowledge = await KnowledgeCRUD(auth).get_by_id_crud(id=data.knowledge_id)
        if not knowledge:
            raise CustomException(msg="创建失败，知识库不存在")

        obj = await KnowledgeDocumentCRUD(auth).create_crud(data=data)
        if not obj:
            raise CustomException(msg="创建文档失败")

        try:
            text_splitter = RecursiveCharacterTextSplitter(
                chunk_size=knowledge.chunk_size,
                chunk_overlap=knowledge.chunk_overlap,
            )
            chunks = text_splitter.split_text(data.content)

            if settings.OPENAI_API_KEY and settings.OPENAI_BASE_URL:
                try:
                    embeddings = OpenAIEmbeddings(
                        model=settings.OPENAI_MODEL,
                    )

                    chunk_embeddings = await embeddings.aembed_documents(chunks)

                    ids = []
                    documents = []
                    metadatas = []
                    for i, chunk in enumerate(chunks):
                        chunk_id = f"{obj.id}_chunk_{i}"
                        ids.append(chunk_id)
                        documents.append(chunk)
                        metadatas.append(
                            {
                                "document_id": obj.id,
                                "knowledge_id": obj.knowledge_id,
                                "title": obj.title,
                                "chunk_index": i,
                            }
                        )

                    chroma_manager.add_documents(
                        ids=ids,
                        embeddings=chunk_embeddings,
                        documents=documents,
                        metadatas=metadatas,
                    )

                    update_data = KnowledgeDocumentUpdateSchema.model_construct(
                        chunk_count=len(chunks), is_indexed=True
                    )
                except Exception as e:
                    log.warning(f"嵌入生成失败，使用虚拟嵌入: {e!s}")
                    chunk_embeddings = [[0.0] * 1536 for _ in chunks]

                    ids = []
                    documents = []
                    metadatas = []
                    for i, chunk in enumerate(chunks):
                        chunk_id = f"{obj.id}_chunk_{i}"
                        ids.append(chunk_id)
                        documents.append(chunk)
                        metadatas.append(
                            {
                                "document_id": obj.id,
                                "knowledge_id": obj.knowledge_id,
                                "title": obj.title,
                                "chunk_index": i,
                            }
                        )

                    chroma_manager.add_documents(
                        ids=ids,
                        embeddings=chunk_embeddings,
                        documents=documents,
                        metadatas=metadatas,
                    )

                    update_data = KnowledgeDocumentUpdateSchema.model_construct(
                        chunk_count=len(chunks), is_indexed=True
                    )
            else:
                log.info("未配置嵌入模型，跳过向量索引")
                update_data = KnowledgeDocumentUpdateSchema.model_construct(
                    chunk_count=len(chunks), is_indexed=False
                )

            await KnowledgeDocumentCRUD(auth).update_crud(id=obj.id, data=update_data)

            updated_obj = await KnowledgeDocumentCRUD(auth).get_by_id_crud(id=obj.id)
            return KnowledgeDocumentOutSchema.model_validate(updated_obj).model_dump()
        except CustomException:
            raise
        except Exception as e:
            log.error(f"创建知识库文档时发生错误: {e!s}")
            raise CustomException(msg=f"创建知识库文档失败: {e!s}")

    @classmethod
    async def document_update_service(
        cls, auth: AuthSchema, id: int, data: KnowledgeDocumentUpdateSchema
    ) -> dict[str, Any]:
        """
        更新知识库文档

        参数:
        - auth (AuthSchema): 认证信息模型
        - id (int): 文档ID
        - data (KnowledgeDocumentUpdateSchema): 更新文档模型

        返回:
        - dict[str, Any]: 更新的文档详情字典
        """
        obj = await KnowledgeDocumentCRUD(auth).get_by_id_crud(id=id)
        if not obj:
            raise CustomException(msg="更新失败，该数据不存在")

        content_changed = data.content is not None and data.content != obj.content

        if content_changed:
            chunk_ids = [f"{obj.id}_chunk_{i}" for i in range(obj.chunk_count or 0)]
            chroma_manager.delete_documents(ids=chunk_ids)

        obj = await KnowledgeDocumentCRUD(auth).update_crud(id=id, data=data)
        if not obj:
            raise CustomException(msg="更新文档失败")

        if content_changed and obj.content:
            knowledge = await KnowledgeCRUD(auth).get_by_id_crud(id=obj.knowledge_id)
            if knowledge:
                text_splitter = RecursiveCharacterTextSplitter(
                    chunk_size=knowledge.chunk_size,
                    chunk_overlap=knowledge.chunk_overlap,
                )
                chunks = text_splitter.split_text(obj.content)

                if settings.OPENAI_API_KEY and settings.OPENAI_BASE_URL:
                    try:
                        embeddings = OpenAIEmbeddings(
                            api_key=lambda: settings.OPENAI_API_KEY,
                            base_url=settings.OPENAI_BASE_URL,
                        )

                        chunk_embeddings = await embeddings.aembed_documents(chunks)

                        ids = []
                        documents = []
                        metadatas = []
                        for i, chunk in enumerate(chunks):
                            chunk_id = f"{obj.id}_chunk_{i}"
                            ids.append(chunk_id)
                            documents.append(chunk)
                            metadatas.append(
                                {
                                    "document_id": obj.id,
                                    "knowledge_id": obj.knowledge_id,
                                    "title": obj.title,
                                    "chunk_index": i,
                                }
                            )

                        chroma_manager.add_documents(
                            ids=ids,
                            embeddings=chunk_embeddings,
                            documents=documents,
                            metadatas=metadatas,
                        )

                        update_data = KnowledgeDocumentUpdateSchema.model_construct(
                            chunk_count=len(chunks), is_indexed=True
                        )
                    except Exception as e:
                        log.warning(f"嵌入生成失败，跳过向量索引: {e!s}")
                        update_data = KnowledgeDocumentUpdateSchema.model_construct(
                            chunk_count=len(chunks), is_indexed=False
                        )
                else:
                    log.info("未配置嵌入模型，跳过向量索引")
                    update_data = KnowledgeDocumentUpdateSchema.model_construct(
                        chunk_count=len(chunks), is_indexed=False
                    )

                obj = await KnowledgeDocumentCRUD(auth).update_crud(id=obj.id, data=update_data)

        return KnowledgeDocumentOutSchema.model_validate(obj).model_dump()

    @classmethod
    async def document_delete_service(cls, auth: AuthSchema, ids: list[int]) -> None:
        """
        批量删除知识库文档

        参数:
        - auth (AuthSchema): 认证信息模型
        - ids (list[int]): 文档ID列表

        返回:
        - None
        """
        if len(ids) < 1:
            raise CustomException(msg="删除失败，删除对象不能为空")

        chunk_ids = []
        for id in ids:
            obj = await KnowledgeDocumentCRUD(auth).get_by_id_crud(id=id)
            if not obj:
                raise CustomException(msg="删除失败，该数据不存在")
            if obj.chunk_count:
                chunk_ids.extend([f"{obj.id}_chunk_{i}" for i in range(obj.chunk_count)])

        if chunk_ids:
            chroma_manager.delete_documents(ids=chunk_ids)

        await KnowledgeDocumentCRUD(auth).delete_crud(ids=ids)
