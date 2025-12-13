#!/usr/bin/env python3
"""
LiteLLM Wrapper to force non-streaming mode for qwen3_coder parser bug workaround
"""
from fastapi import FastAPI, Request, Response
from fastapi.responses import StreamingResponse, JSONResponse
import httpx
import json
import asyncio

app = FastAPI()

LITELLM_URL = "http://localhost:4000"

@app.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"])
async def proxy(path: str, request: Request):
    """Proxy all requests to LiteLLM, forcing stream=false for /v1/chat/completions"""

    # Read request body
    body = await request.body()

    # For chat completions, force stream=false
    if path == "v1/chat/completions" and body:
        try:
            data = json.loads(body)
            # Force non-streaming mode
            data["stream"] = False
            body = json.dumps(data).encode()
        except:
            pass

    # Forward request to LiteLLM
    async with httpx.AsyncClient() as client:
        response = await client.request(
            method=request.method,
            url=f"{LITELLM_URL}/{path}",
            headers={k: v for k, v in request.headers.items() if k.lower() != "host"},
            content=body,
            params=request.query_params,
        )

        return Response(
            content=response.content,
            status_code=response.status_code,
            headers=dict(response.headers),
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=4001)
