import os
from typing import Any

from langchain_chroma import Chroma
from langchain_core.documents import Document
from langchain_core.embeddings import Embeddings

from app.config.setting import settings


class DummyEmbeddings(Embeddings):
    """虚拟嵌入类，用于在没有嵌入模型时使用"""

    def embed_documents(self, texts: list[str]) -> list[list[float]]:
        return [[0.0] * 1536 for _ in texts]

    def embed_query(self, text: str) -> list[float]:
        return [0.0] * 1536


class ChromaDBManager:
    """ChromaDB 管理类 - 使用 langchain-chroma"""

    _instance = None
    _vectorstore = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        if self._vectorstore is None:
            self._initialize_vectorstore()

    def _initialize_vectorstore(self):
        """初始化 ChromaDB 向量存储"""
        os.makedirs(settings.CHROMA_PERSIST_DIR, exist_ok=True)
        self._vectorstore = Chroma(
            collection_name=settings.CHROMA_COLLECTION_NAME,
            persist_directory=settings.CHROMA_PERSIST_DIR,
            embedding_function=DummyEmbeddings(),
        )

    def get_vectorstore(self) -> Chroma:
        """获取向量存储实例"""
        if self._vectorstore is None:
            self._initialize_vectorstore()
        assert self._vectorstore is not None
        return self._vectorstore

    def add_documents(
        self,
        ids: list[str],
        embeddings: list[list[float]],
        documents: list[str],
        metadatas: list[dict[str, Any]] | None = None,
    ):
        """添加文档到 ChromaDB"""
        vectorstore = self.get_vectorstore()

        docs = [
            Document(page_content=doc, metadata=meta if meta else {})
            for doc, meta in zip(documents, metadatas or [{}] * len(documents), strict=False)
        ]

        vectorstore.add_documents(
            documents=docs,
            ids=ids,
            embeddings=embeddings,
        )

    def query_documents(
        self,
        query_embeddings: list[list[float]],
        n_results: int = 5,
        where: dict[str, Any] | None = None,
        where_document: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        """查询文档"""
        vectorstore = self.get_vectorstore()

        results = vectorstore.similarity_search_by_vector(
            embedding=query_embeddings[0],
            k=n_results,
            filter=where,
        )

        return {
            "documents": [[doc.page_content for doc in results]],
            "metadatas": [[doc.metadata for doc in results]],
        }

    def delete_documents(
        self,
        ids: list[str],
    ):
        """删除文档"""
        vectorstore = self.get_vectorstore()
        vectorstore.delete(ids=ids)

    def get_documents(
        self,
        ids: list[str] | None = None,
        where: dict[str, Any] | None = None,
        limit: int | None = None,
        offset: int | None = None,
    ) -> dict[str, Any]:
        """获取文档"""
        vectorstore = self.get_vectorstore()

        if ids:
            results = vectorstore.get_by_ids(ids)
        else:
            results = []

        return {
            "documents": [[doc.page_content for doc in results]] if results else [[]],
            "metadatas": [[doc.metadata for doc in results]] if results else [[]],
        }

    def update_documents(
        self,
        ids: list[str],
        embeddings: list[list[float]] | None = None,
        documents: list[str] | None = None,
        metadatas: list[dict[str, Any]] | None = None,
    ):
        """更新文档 - 通过删除旧文档再添加新文档的方式实现"""
        vectorstore = self.get_vectorstore()

        if documents or metadatas:
            vectorstore.delete(ids=ids)

            if documents:
                docs = [
                    Document(page_content=doc, metadata=meta if meta else {})
                    for doc, meta in zip(documents, metadatas or [{}] * len(documents), strict=False)
                ]
                vectorstore.add_documents(
                    documents=docs,
                    ids=ids,
                    embeddings=embeddings,
                )

    def reset(self):
        """重置 ChromaDB"""
        if self._vectorstore is not None:
            self._vectorstore.delete_collection()
            self._vectorstore = None


chroma_manager = ChromaDBManager()
