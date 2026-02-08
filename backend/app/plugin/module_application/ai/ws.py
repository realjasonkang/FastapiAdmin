from fastapi import APIRouter, WebSocket

from app.core.logger import log
from app.core.router_class import OperationLogRoute

from .schema import ChatQuerySchema
from .service import AgentService

WS_AI = APIRouter(
    route_class=OperationLogRoute,
    prefix="/application/ai",
    tags=["智能助手WebSocket"],
)


@WS_AI.websocket("/ws", name="WebSocket聊天")
async def websocket_chat_controller(
    websocket: WebSocket,
) -> None:
    """
    WebSocket聊天接口

    支持两种消息格式：
    1. 纯文本：直接发送消息内容
    2. JSON格式：{"message": "消息内容", "knowledge_ids": [1, 2], "agent_config_id": 1}

    ws://127.0.0.1:8001/api/v1/application/ai/ws
    """
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_text()
            try:
                async for chunk in AgentService.chat_query(query=ChatQuerySchema(message=data, knowledge_ids=[], agent_config_id=None)):
                    if chunk:
                        await websocket.send_text(chunk)
            except Exception as e:
                log.error(f"处理聊天查询出错: {e!s}")
                await websocket.send_text(f"抱歉，处理您的请求时出现了错误: {e!s}")
    except Exception as e:
        log.error(f"WebSocket聊天出错: {e!s}")
    finally:
        try:
            if websocket.client_state != websocket.client_state.DISCONNECTED:
                await websocket.close()
        except Exception as e:
            log.debug(f"WebSocket关闭时发生异常(预期行为，服务可能正在关闭): {e!s}")
