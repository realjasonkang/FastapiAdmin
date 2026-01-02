from fastmcp import FastMCP
from fastmcp.prompts.prompt import Message
from mcp.types import PromptMessage, TextContent

app = FastMCP("Math")
mcp = FastMCP.from_fastapi(app=app)

@mcp.tool()
def add(a: int, b: int) -> int:
    """Add two numbers"""
    return a + b

@mcp.tool()
def multiply(a: int, b: int) -> int:
    """Multiply two numbers"""
    return a * b

# 返回字符串的基本动态资源
@mcp.resource("resource://greeting")
def get_greeting() -> str:
    """提供简单的问候消息。"""
    return "Hello from FastMCP Resources!"

# 返回 JSON 数据的资源（字典会自动序列化）
@mcp.resource("data://config")
def get_config() -> dict:
    """以 JSON 形式提供应用程序配置。"""
    return {
        "theme": "dark",
        "version": "1.2.0",
        "features": ["tools", "resources"],
    }

# 返回字符串的基本提示（自动转换为用户消息）
@mcp.prompt
def ask_about_topic(topic: str) -> str:
    """生成询问主题解释的用户消息。"""
    return f"Can you please explain the concept of '{topic}'?"

# 返回特定消息类型的提示
@mcp.prompt
def generate_code_request(language: str, task_description: str) -> PromptMessage:
    """生成请求代码生成的用户消息。"""
    content = f"Write a {language} function that performs the following task: {task_description}"
    return PromptMessage(role="user", content=TextContent(type="text", text=content))

if __name__ == "__main__":
    mcp.run(transport="stdio")
    # fastmcp run my_server.py:mcp --transport http --port 8000