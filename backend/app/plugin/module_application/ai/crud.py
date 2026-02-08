from collections.abc import Sequence
from typing import Any

from app.api.v1.module_system.auth.schema import AuthSchema
from app.core.base_crud import CRUDBase

from .model import AgentConfigModel, KnowledgeDocumentModel, KnowledgeModel
from .schema import (
    AgentConfigCreateSchema,
    AgentConfigUpdateSchema,
    KnowledgeCreateSchema,
    KnowledgeDocumentCreateSchema,
    KnowledgeDocumentUpdateSchema,
    KnowledgeUpdateSchema,
)


class AgentConfigCRUD(CRUDBase[AgentConfigModel, AgentConfigCreateSchema, AgentConfigUpdateSchema]):
    """智能体配置数据层"""

    def __init__(self, auth: AuthSchema) -> None:
        """
        初始化CRUD

        参数:
        - auth (AuthSchema): 认证信息模型
        """
        self.auth = auth
        super().__init__(model=AgentConfigModel, auth=auth)

    async def get_by_id_crud(
        self, id: int, preload: list[str | Any] | None = None
    ) -> AgentConfigModel | None:
        """
        获取智能体配置详情

        参数:
        - id (int): 智能体配置ID
        - preload (list[str | Any] | None): 预加载关系，未提供时使用模型默认项

        返回:
        - AgentConfigModel | None: 智能体配置模型实例（如果存在）
        """
        return await self.get(id=id, preload=preload)

    async def get_default_crud(
        self, preload: list[str | Any] | None = None
    ) -> AgentConfigModel | None:
        """
        获取默认智能体配置

        参数:
        - preload (list[str | Any] | None): 预加载关系，未提供时使用模型默认项

        返回:
        - AgentConfigModel | None: 智能体配置模型实例（如果存在）
        """
        return await self.get(is_default=1, preload=preload)

    async def get_list_crud(
        self,
        search: dict | None = None,
        order_by: list[dict[str, str]] | None = None,
        preload: list[str | Any] | None = None,
    ) -> Sequence[AgentConfigModel]:
        """
        列表查询智能体配置

        参数:
        - search (dict | None): 查询参数字典
        - order_by (list[dict[str, str]] | None): 排序参数列表
        - preload (list[str | Any] | None): 预加载关系，未提供时使用模型默认项

        返回:
        - Sequence[AgentConfigModel]: 智能体配置模型实例序列
        """
        return await self.list(
            search=search or {},
            order_by=order_by or [{"id": "asc"}],
            preload=preload,
        )

    async def create_crud(
        self, data: AgentConfigCreateSchema
    ) -> AgentConfigModel | None:
        """
        创建智能体配置

        参数:
        - data (AgentConfigCreateSchema): 创建智能体配置模型

        返回:
        - Optional[AgentConfigModel]: 创建的智能体配置模型实例（如果成功）
        """
        return await self.create(data=data)

    async def update_crud(
        self, id: int, data: AgentConfigUpdateSchema
    ) -> AgentConfigModel | None:
        """
        更新智能体配置

        参数:
        - id (int): 智能体配置ID
        - data (AgentConfigUpdateSchema): 更新智能体配置模型

        返回:
        - AgentConfigModel | None: 更新的智能体配置模型实例（如果成功）
        """
        return await self.update(id=id, data=data)

    async def delete_crud(self, ids: list[int]) -> None:
        """
        批量删除智能体配置

        参数:
        - ids (list[int]): 智能体配置ID列表

        返回:
        - None
        """
        return await self.delete(ids=ids)


class KnowledgeCRUD(CRUDBase[KnowledgeModel, KnowledgeCreateSchema, KnowledgeUpdateSchema]):
    """知识库数据层"""

    def __init__(self, auth: AuthSchema) -> None:
        """
        初始化CRUD

        参数:
        - auth (AuthSchema): 认证信息模型
        """
        self.auth = auth
        super().__init__(model=KnowledgeModel, auth=auth)

    async def get_by_id_crud(
        self, id: int, preload: list[str | Any] | None = None
    ) -> KnowledgeModel | None:
        """
        获取知识库详情

        参数:
        - id (int): 知识库ID
        - preload (list[str | Any] | None): 预加载关系，未提供时使用模型默认项

        返回:
        - KnowledgeModel | None: 知识库模型实例（如果存在）
        """
        return await self.get(id=id, preload=preload)

    async def get_by_name_crud(
        self, name: str, preload: list[str | Any] | None = None
    ) -> KnowledgeModel | None:
        """
        通过名称获取知识库

        参数:
        - name (str): 知识库名称
        - preload (list[str | Any] | None): 预加载关系，未提供时使用模型默认项

        返回:
        - Optional[KnowledgeModel]: 知识库模型实例（如果存在）
        """
        return await self.get(name=name, preload=preload)

    async def get_list_crud(
        self,
        search: dict | None = None,
        order_by: list[dict[str, str]] | None = None,
        preload: list[str | Any] | None = None,
    ) -> Sequence[KnowledgeModel]:
        """
        列表查询知识库

        参数:
        - search (dict | None): 查询参数字典
        - order_by (list[dict[str, str]] | None): 排序参数列表
        - preload (list[str | Any] | None): 预加载关系，未提供时使用模型默认项

        返回:
        - Sequence[KnowledgeModel]: 知识库模型实例序列
        """
        return await self.list(
            search=search or {},
            order_by=order_by or [{"id": "asc"}],
            preload=preload,
        )

    async def create_crud(self, data: KnowledgeCreateSchema) -> KnowledgeModel | None:
        """
        创建知识库

        参数:
        - data (KnowledgeCreateSchema): 创建知识库模型

        返回:
        - Optional[KnowledgeModel]: 创建的知识库模型实例（如果成功）
        """
        return await self.create(data=data)

    async def update_crud(
        self, id: int, data: KnowledgeUpdateSchema
    ) -> KnowledgeModel | None:
        """
        更新知识库

        参数:
        - id (int): 知识库ID
        - data (KnowledgeUpdateSchema): 更新知识库模型

        返回:
        - KnowledgeModel | None: 更新的知识库模型实例（如果成功）
        """
        return await self.update(id=id, data=data)

    async def delete_crud(self, ids: list[int]) -> None:
        """
        批量删除知识库

        参数:
        - ids (list[int]): 知识库ID列表

        返回:
        - None
        """
        return await self.delete(ids=ids)


class KnowledgeDocumentCRUD(CRUDBase[KnowledgeDocumentModel, KnowledgeDocumentCreateSchema, KnowledgeDocumentUpdateSchema]):
    """知识库文档数据层"""

    def __init__(self, auth: AuthSchema) -> None:
        """
        初始化CRUD

        参数:
        - auth (AuthSchema): 认证信息模型
        """
        self.auth = auth
        super().__init__(model=KnowledgeDocumentModel, auth=auth)

    async def get_by_id_crud(
        self, id: int, preload: list[str | Any] | None = None
    ) -> KnowledgeDocumentModel | None:
        """
        获取知识库文档详情

        参数:
        - id (int): 文档ID
        - preload (list[str | Any] | None): 预加载关系，未提供时使用模型默认项

        返回:
        - KnowledgeDocumentModel | None: 知识库文档模型实例（如果存在）
        """
        return await self.get(id=id, preload=preload)

    async def get_by_knowledge_id_crud(
        self, knowledge_id: int, preload: list[str | Any] | None = None
    ) -> Sequence[KnowledgeDocumentModel]:
        """
        通过知识库ID获取文档列表

        参数:
        - knowledge_id (int): 知识库ID
        - preload (list[str | Any] | None): 预加载关系，未提供时使用模型默认项

        返回:
        - Sequence[KnowledgeDocumentModel]: 知识库文档模型实例序列
        """
        return await self.list(search={"knowledge_id": (0, knowledge_id)}, preload=preload)

    async def get_list_crud(
        self,
        search: dict | None = None,
        order_by: list[dict[str, str]] | None = None,
        preload: list[str | Any] | None = None,
    ) -> Sequence[KnowledgeDocumentModel]:
        """
        列表查询知识库文档

        参数:
        - search (dict | None): 查询参数字典
        - order_by (list[dict[str, str]] | None): 排序参数列表
        - preload (list[str | Any] | None): 预加载关系，未提供时使用模型默认项

        返回:
        - Sequence[KnowledgeDocumentModel]: 知识库文档模型实例序列
        """
        return await self.list(
            search=search or {},
            order_by=order_by or [{"id": "asc"}],
            preload=preload,
        )

    async def create_crud(
        self, data: KnowledgeDocumentCreateSchema
    ) -> KnowledgeDocumentModel | None:
        """
        创建知识库文档

        参数:
        - data (KnowledgeDocumentCreateSchema): 创建知识库文档模型

        返回:
        - Optional[KnowledgeDocumentModel]: 创建的知识库文档模型实例（如果成功）
        """
        return await self.create(data=data)

    async def update_crud(
        self, id: int, data: KnowledgeDocumentUpdateSchema
    ) -> KnowledgeDocumentModel | None:
        """
        更新知识库文档

        参数:
        - id (int): 文档ID
        - data (KnowledgeDocumentUpdateSchema): 更新知识库文档模型

        返回:
        - KnowledgeDocumentModel | None: 更新的知识库文档模型实例（如果成功）
        """
        return await self.update(id=id, data=data)

    async def delete_crud(self, ids: list[int]) -> None:
        """
        批量删除知识库文档

        参数:
        - ids (list[int]): 文档ID列表

        返回:
        - None
        """
        return await self.delete(ids=ids)
