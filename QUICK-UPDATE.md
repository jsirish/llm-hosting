# Quick Update - Enable vLLM qwen_coder Parser

## TL;DR

**Problem**: LiteLLM alone can't parse Qwen's XML tool calls
**Solution**: Enable vLLM's `qwen_coder` parser + LiteLLM for normalization

## Run This on RunPod

```bash
# 1. Stop services
pkill -f vllm
kill $(cat /workspace/logs/litellm-proxy.pid)

# 2. Update vLLM to use qwen_coder parser
# Edit models/qwen.sh:
export VLLM_TOOL_PARSER="qwen_coder"

# 3. Recreate LiteLLM config
./scripts/setup-litellm-proxy.sh

# 4. Restart services
./models/qwen.sh &
sleep 10
./scripts/start-litellm-proxy.sh

# 5. Test
curl http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-litellm-c9be6c31b9f1ebd5bc5a316ac7d71381" \
  -d '{
    "model": "qwen3-coder-30b",
    "messages": [{"role": "user", "content": "Use get_weather for Paris"}],
    "tools": [{
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "Get weather",
        "parameters": {
          "type": "object",
          "properties": {"location": {"type": "string"}},
          "required": ["location"]
        }
      }
    }]
  }' | jq '.choices[0].message.tool_calls'
```

**Expected**: Should show a `tool_calls` array (not XML)

## Then Restart Continue.dev

1. VS Code → Cmd+Shift+P
2. "Developer: Reload Window"

## Architecture Now

```
Continue.dev
  ↓ (OpenAI format)
LiteLLM (4000)
  ↓ (normalizes params)
vLLM (8000) + qwen_coder parser
  ↓ (parses XML → JSON)
Model generates XML
```

## What Changed

| Component | Before | After |
|-----------|--------|-------|
| vLLM | No parser (`""`) | `qwen_coder` parser |
| LiteLLM | Try to handle everything | Just normalize format |
| Tool Format | XML → Fail | XML → vLLM parse → JSON → LiteLLM normalize |

See `docs/setup/LITELLM-VLLM-TOOLCALLING.md` for detailed explanation.
