import asyncio
from fastmcp import Client
from fastmcp import FastMCP
import asyncio

# 转换为 MCP 服务器
mcp = FastMCP.from_fastapi(app=app)

async def demo():
    async with Client(mcp) as client:
        # 列出可用工具
        tools = await client.list_tools()
        for tool in tools:
            print(f"工具: {tool.name}")
            print(f"描述: {tool.description}")
            if tool.inputSchema:
                print(f"参数: {tool.inputSchema}")
            # 访问标签和其他元数据
            if hasattr(tool, 'meta') and tool.meta:
                fastmcp_meta = tool.meta.get('_fastmcp', {})
                print(f"标签: {fastmcp_meta.get('tags', [])}")
        
        resources = await client.list_resources()
        for resource in resources:
            print(f"资源 URI: {resource.uri}")
            print(f"名称: {resource.name}")
            print(f"描述: {resource.description}")
            print(f"MIME 类型: {resource.mimeType}")
            # 访问标签和其他元数据
            if hasattr(resource, '_meta') and resource._meta:
                fastmcp_meta = resource._meta.get('_fastmcp', {})
                print(f"标签: {fastmcp_meta.get('tags', [])}")

        prompts = await client.list_prompts()
        for prompt in prompts:
            print(f"提示: {prompt.name}")
            print(f"描述: {prompt.description}")
            if prompt.arguments:
                print(f"参数: {[arg.name for arg in prompt.arguments]}")
            # 访问标签和其他元数据
            if hasattr(prompt, '_meta') and prompt._meta:
                fastmcp_meta = prompt._meta.get('_fastmcp', {})
                print(f"标签: {fastmcp_meta.get('tags', [])}")
        
        # 创建产品
        result = await client.call_tool(
            "create_product_products_post",
            {
                "name": "无线键盘",
                "price": 79.99,
                "category": "电子产品",
                "description": "蓝牙机械键盘"
            }
        )
        print(f"已创建产品: {result.data}")
        
        # 列出价格低于 $100 的电子产品
        result = await client.call_tool(
            "list_products_products_get",
            {"category": "电子产品", "max_price": 100}
        )
        print(f"经济实惠的电子产品: {result.data}")

if __name__ == "__main__":
    asyncio.run(demo())