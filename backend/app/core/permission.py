# -*- coding: utf-8 -*-

from typing import Optional, Set, List, Dict, Any, Union, Tuple
from sqlalchemy.sql.elements import ColumnElement
from sqlalchemy import select, and_
from sqlalchemy.ext.asyncio import AsyncSession
from app.api.v1.module_system.user.model import UserModel
from app.api.v1.module_system.dept.model import DeptModel
from app.api.v1.module_system.role.model import RoleModel
from app.api.v1.module_system.auth.schema import AuthSchema
from app.utils.common_util import get_child_id_map, get_child_recursion


class Permission:
    """
    为业务模型提供数据权限过滤功能
    """
    
    # 数据权限常量定义，提高代码可读性
    DATA_SCOPE_SELF = 1  # 仅本人数据
    DATA_SCOPE_DEPT = 2  # 本部门数据
    DATA_SCOPE_DEPT_AND_CHILD = 3  # 本部门及以下数据
    DATA_SCOPE_ALL = 4  # 全部数据
    DATA_SCOPE_CUSTOM = 5  # 自定义数据
    
    def __init__(self, db: AsyncSession, model: Any, current_user: UserModel, auth: AuthSchema):
        """
        初始化权限过滤器实例
        
        Args:
            db: 数据库会话
            model: 数据模型类
            current_user: 当前用户对象
            auth: 认证信息对象
        """
        self.db = db
        self.model = model
        self.current_user = current_user
        self.auth = auth
        self.conditions: List[ColumnElement] = []  # 权限条件列表
    
    async def get_permission_condition(self) -> Optional[ColumnElement]:
        """
        异步构建权限过滤表达式，返回None表示不限制
        
        Returns:
            权限过滤表达式或None
        """
        # 初始化条件列表
        self.conditions = []
        
        # 无用户时返回空条件
        if not self.current_user:
            return None
            
        # 超级管理员跳过所有过滤
        if self.current_user.is_superuser:
            return None
            
        # 租户级数据隔离
        await self._apply_tenant_isolation()
        # 客户级数据隔离
        await self._apply_customer_isolation()
        # 数据范围权限隔离
        await self._apply_data_scope_isolation()
        
        # 组合所有条件
        return and_(*self.conditions) if self.conditions else None
    
    async def _apply_tenant_isolation(self) -> None:
        """
        应用租户级数据隔离
        非系统用户只能查看本租户数据
        """
        if (hasattr(self.model, "tenant_id") and 
            hasattr(self.current_user, "user_type") and 
            self.current_user.user_type != "0"):  # 非系统用户
            
            user_tenant_id = getattr(self.current_user, "tenant_id", None)
            if user_tenant_id is not None:
                self.conditions.append(getattr(self.model, "tenant_id") == user_tenant_id)
    
    async def _apply_customer_isolation(self) -> None:
        """
        应用客户级数据隔离
        客户用户只能查看自己客户的数据
        """
        if hasattr(self.model, "customer_id"):
            user_customer_id = getattr(self.current_user, "customer_id", None)
            # 客户用户类型为2
            if (hasattr(self.current_user, "user_type") and 
                self.current_user.user_type == "2" and 
                user_customer_id is not None):
                
                self.conditions.append(getattr(self.model, "customer_id") == user_customer_id)
    
    async def _apply_data_scope_isolation(self) -> None:
        """
        应用数据范围权限隔离
        基于角色的五种数据权限范围过滤
        支持五种权限类型：
        1. 仅本人数据权限 - 只能查看自己创建的数据
        2. 本部门数据权限 - 只能查看同部门的数据
        3. 本部门及以下数据权限 - 可以查看本部门及所有子部门的数据
        4. 全部数据权限 - 可以查看所有数据
        5. 自定义数据权限 - 通过role_dept_relation表定义可访问的部门列表
        """
        # 只有在需要检查数据权限且模型有created_id字段时才应用数据范围过滤
        if (self.auth.check_data_scope and 
            hasattr(self.model, "created_id") and 
            hasattr(self.current_user, "roles")):
            
            # 获取用户的权限范围和部门ID集合
            data_scopes, dept_ids = await self._get_user_data_scopes()
            
            # 如果没有设置任何数据权限，默认只能查看自己的数据
            if not data_scopes:
                self._add_self_scope_condition()
                return
            
            # 如果拥有全部数据权限，不需要额外过滤
            if self.DATA_SCOPE_ALL in data_scopes:
                # 但仍需处理没有部门或角色的情况
                if not getattr(self.current_user, "dept_id", None) or not self.current_user.roles:
                    self._add_self_scope_condition()
                return
            
            # 应用相应的数据范围过滤
            if self.DATA_SCOPE_CUSTOM in data_scopes and dept_ids:
                await self._add_custom_scope_condition(dept_ids)
            elif self.DATA_SCOPE_SELF in data_scopes:
                self._add_self_scope_condition()
            elif (self.DATA_SCOPE_DEPT in data_scopes or self.DATA_SCOPE_DEPT_AND_CHILD in data_scopes):
                await self._add_dept_scope_condition(data_scopes)
            else:
                # 默认情况下，用户只能查看自己的数据
                self._add_self_scope_condition()
    
    async def _get_user_data_scopes(self) -> Tuple[Set[int], Set[int]]:
        """
        获取用户所有角色的权限范围和部门ID集合
        
        Returns:
            Tuple[Set[int], Set[int]]: (数据范围集合, 部门ID集合)
        """
        data_scopes: Set[int] = set()
        dept_ids: Set[int] = set()
        roles = getattr(self.current_user, "roles", []) or []
        
        for role in roles:
            # 获取角色关联的部门
            if hasattr(role, 'depts') and role.depts:
                for dept in role.depts:
                    if hasattr(dept, 'id'):
                        dept_ids.add(dept.id)
            
            # 获取角色的数据范围
            if hasattr(role, 'data_scope') and role.data_scope:
                try:
                    data_scopes.add(int(role.data_scope))
                except (ValueError, TypeError):
                    # 数据范围格式错误，忽略此角色的数据范围
                    continue
        
        return data_scopes, dept_ids
    
    def _add_self_scope_condition(self) -> None:
        """
        添加仅本人数据权限条件
        """
        if hasattr(self.model, "created_id"):
            self.conditions.append(getattr(self.model, "created_id") == self.current_user.id)
    
    async def _add_custom_scope_condition(self, dept_ids: Set[int]) -> None:
        """
        添加自定义数据权限条件
        
        Args:
            dept_ids: 允许访问的部门ID集合
        """
        creator_rel = getattr(self.model, "created_id", None)
        
        if (creator_rel is not None and 
            hasattr(UserModel, 'dept_id')):
            # 通过creator关系过滤部门
            self.conditions.append(
                creator_rel.has(getattr(UserModel, 'dept_id').in_(list(dept_ids)))
            )
        else:
            # 无法通过部门过滤时回退到仅本人数据
            self._add_self_scope_condition()
    
    async def _add_dept_scope_condition(self, data_scopes: Set[int]) -> None:
        """
        添加部门相关的数据权限条件
        
        Args:
            data_scopes: 用户的数据权限范围集合
        """
        dept_id_val = getattr(self.current_user, "dept_id", None)
        
        # 无部门时回退到仅本人数据
        if dept_id_val is None:
            self._add_self_scope_condition()
            return
        
        # 获取部门ID集合
        dept_ids = {dept_id_val}  # 包含本部门
        
        # 如果需要包含子部门数据
        if self.DATA_SCOPE_DEPT_AND_CHILD in data_scopes:
            child_dept_ids = await self._get_child_dept_ids(dept_id_val)
            dept_ids.update(child_dept_ids)
        
        # 应用部门过滤条件
        creator_rel = getattr(self.model, "creator", None)
        
        if (creator_rel is not None and 
            hasattr(UserModel, 'dept_id') and 
            dept_ids):
            self.conditions.append(
                creator_rel.has(getattr(UserModel, 'dept_id').in_(list(dept_ids)))
            )
        else:
            # 无法通过部门过滤时回退到仅本人数据
            self._add_self_scope_condition()
    
    async def _get_child_dept_ids(self, dept_id: int) -> List[int]:
        """
        获取指定部门的所有子部门ID（应用租户隔离）
        
        Args:
            dept_id: 部门ID
            
        Returns:
            List[int]: 子部门ID列表
        """
        try:
            # 查询所有部门以构建部门树
            dept_sql = select(DeptModel)
            
            # 应用租户隔离，确保用户只能看到自己租户的部门
            if (hasattr(self.current_user, "user_type") and 
                self.current_user.user_type != "0"):  # 非系统用户
                user_tenant_id = getattr(self.current_user, "tenant_id", None)
                if user_tenant_id is not None:
                    dept_sql = dept_sql.where(DeptModel.tenant_id == user_tenant_id)
            
            dept_result = await self.db.execute(dept_sql)
            dept_objs = dept_result.scalars().all()
            
            # 构建部门ID映射并递归获取子部门ID
            id_map = get_child_id_map(dept_objs)
            return get_child_recursion(id=dept_id, id_map=id_map)
        except Exception:
            # 异常情况下返回空列表，避免权限系统出错
            return []
    
    async def filter_query(self, query: Any) -> Any:
        """
        异步过滤查询对象
        
        Args:
            query: SQLAlchemy查询对象
            
        Returns:
            过滤后的查询对象
        """
        condition = await self.get_permission_condition()
        return query.where(condition) if condition is not None else query