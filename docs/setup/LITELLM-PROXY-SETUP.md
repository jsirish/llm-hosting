# LiteLLM Proxy for Tool Calling

## Overview

LiteLLM proxy solves tool calling compatibility issues by sitting between Continue.dev and vLLM, handling format translations.

**Architecture:**
```
Continue.dev → LiteLLM Proxy (port 4000) → vLLM (port 8000)
```

## Setup Steps

### 1. Install LiteLLM on RunPod
```bash
cd /workspace/llm-hosting
./scripts/setup-litellm-proxy.sh
```

### 2. Update Qwen Configuration (Already Done)
The `models/qwen.sh` now has `VLLM_TOOL_PARSER=""` to let LiteLLM handle parsing.

### 3. Start vLLM (if not running)
```bash
./scripts/stop-server.sh
./models/qwen.sh
```

### 4. Start LiteLLM Proxy
```bash
./scripts/start-litellm-proxy.sh
```

This runs LiteLLM on port 4000.

### 5. Expose Port 4000 on RunPod
In RunPod web interface:
1. Go to your pod settings
2. Add port mapping: `4000` → TCP
3. Get the public URL (will be like `https://...proxy.runpod.net:4000`)

### 6. Update Continue.dev Config
Change the `apiBase` to use LiteLLM instead of vLLM directly:

```yaml
- name: RunPod Qwen3-Coder-30B (Tool Calling via LiteLLM)
  provider: openai
  model: qwen3-coder-30b  # Model name from litellm-config.yaml
  apiBase: https://YOUR-POD.proxy.runpod.net:4000/v1  # LiteLLM port
  apiKey: sk-litellm-c9be6c31b9f1ebd5bc5a316ac7d71381
  capabilities:
    - tool_use
  defaultCompletionOptions:
    contextLength: 131072
    maxTokens: 8192
    temperature: 0.1
```

## How It Works

1. **Continue.dev** sends OpenAI-format tool calling requests
2. **LiteLLM** receives the request and forwards to vLLM
3. **vLLM** generates response (no tool parser, raw output)
4. **LiteLLM** parses the response and converts to OpenAI format
5. **Continue.dev** receives properly formatted tool calls

## Benefits

- ✅ Handles format translation automatically
- ✅ No vLLM parser configuration needed
- ✅ Compatible with Continue.dev's OpenAI expectations
- ✅ Can add retries, fallbacks, and load balancing
- ✅ Works around vLLM's JSON validation issues

## Troubleshooting

### LiteLLM Won't Start
```bash
# Check if port 4000 is already in use
lsof -i :4000

# View detailed logs
litellm --config /workspace/litellm-config.yaml --port 4000 --detailed_debug
```

### vLLM Not Responding
```bash
# Check vLLM is running
curl http://localhost:8000/v1/models

# Restart if needed
./scripts/stop-server.sh && ./models/qwen.sh
```

### Continue.dev Can't Connect
- Verify port 4000 is exposed in RunPod
- Check the public URL format
- Test with curl first:
  ```bash
  curl https://YOUR-POD.proxy.runpod.net:4000/v1/models
  ```

## References

- LiteLLM Docs: https://docs.litellm.ai/docs/proxy/quick_start
- Config: `/workspace/litellm-config.yaml`
- Logs: Check terminal where LiteLLM is running
