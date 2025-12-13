# LiteLLM + vLLM Tool Calling Configuration

## Architecture (Updated)

```
Continue.dev (IDE)
    ↓ OpenAI-compatible API with tools
LiteLLM Proxy (Port 4000)
    ↓ Format normalization & parameter cleanup
vLLM Server (Port 8000)
    ↓ qwen_coder parser (XML → JSON)
Qwen3-Coder-30B Model
    ↓ Generates XML tool calls
```

## Why This Architecture?

### Previous Approach (Failed)
- **vLLM only** with various parsers (`qwen3_coder`, `qwen3_xml`, `hermes`, `openai`)
- **Problem**: vLLM's `_postprocess_messages` validates all tool calls as JSON, causing failures with Qwen's XML output

### Current Approach (Working)
1. **vLLM** with `qwen_coder` parser:
   - Parses Qwen's XML tool call format (`<tool_call>`, `<function>`, `<parameter>`)
   - Converts to vLLM's internal tool call structure
   - No JSON validation issues because parsing happens BEFORE validation

2. **LiteLLM** as normalization layer:
   - Takes vLLM's parsed tool calls
   - Normalizes to OpenAI format expected by Continue.dev
   - Strips non-standard parameters like `supports_function_calling`
   - Handles retries and timeouts

## Configuration Files

### models/qwen.sh
```bash
export VLLM_TOOL_PARSER="qwen_coder"  # Parse Qwen's XML format
```

### scripts/setup-litellm-proxy.sh
```yaml
model_list:
  - model_name: qwen3-coder-30b
    litellm_params:
      model: openai/Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8
      api_base: http://localhost:8000/v1  # vLLM with qwen_coder parser
      supports_function_calling: true
      supports_parallel_function_calling: true
```

### ~/.continue/config.yaml
```yaml
- name: RunPod Qwen3-Coder-30B (Tool Calling via LiteLLM)
  provider: openai
  model: qwen3-coder-30b
  apiBase: https://3clxt008hl0a3a-4000.proxy.runpod.net/v1
  apiKey: sk-litellm-c9be6c31b9f1ebd5bc5a316ac7d71381
  capabilities:
    - tool_use
```

## Update Instructions

### On RunPod Instance

1. **Upload the updated scripts**:
   ```bash
   scp -i ~/.ssh/id_ed25519 scripts/setup-litellm-proxy.sh scripts/update-runpod-config.sh models/qwen.sh 3clxt008hl0a3a-64411a07@ssh.runpod.io:/workspace/llm-hosting/
   ```

2. **Run the update script**:
   ```bash
   ssh -i ~/.ssh/id_ed25519 3clxt008hl0a3a-64411a07@ssh.runpod.io
   cd /workspace/llm-hosting
   ./scripts/update-runpod-config.sh
   ```

### On Local Machine (Continue.dev)

1. **Restart Continue.dev extension**:
   - VS Code → Command Palette (Cmd+Shift+P)
   - Type: "Developer: Reload Window"
   - Or: Quit and restart VS Code

2. **Verify configuration**:
   - Open Continue.dev
   - Select "RunPod Qwen3-Coder-30B (Tool Calling via LiteLLM)"
   - Check that it's using port 4000

## Testing

### 1. Verify vLLM Parser
```bash
# On RunPod
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-vllm-c9be6c31b9f1ebd5bc5a316ac7d71381" \
  -d '{
    "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
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
  }' | jq '.choices[0].message'
```

**Expected**: Should have `tool_calls` array (not XML in `content`)

### 2. Verify LiteLLM Normalization
```bash
# From local machine
curl https://3clxt008hl0a3a-4000.proxy.runpod.net/v1/chat/completions \
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
  }' | jq '.choices[0].message'
```

**Expected**: Clean OpenAI-formatted `tool_calls` array

### 3. Test in Continue.dev
1. Open Continue.dev chat
2. Ask: "What files are in my workspace? Use the filesystem tool."
3. Verify:
   - ✅ Tool call is made
   - ✅ No JSON parsing errors
   - ✅ Tool results are used in response

## Troubleshooting

### Issue: Still getting XML in response
**Cause**: vLLM's qwen_coder parser not active
**Fix**:
```bash
# Check vLLM startup
ps aux | grep vllm
# Should show: --tool-call-parser qwen_coder

# Restart vLLM
pkill -f vllm
./models/qwen.sh
```

### Issue: LiteLLM not normalizing format
**Cause**: LiteLLM config not updated
**Fix**:
```bash
./scripts/setup-litellm-proxy.sh
./scripts/start-litellm-proxy.sh
```

### Issue: Continue.dev still seeing errors
**Cause**: Continue.dev needs restart or config cache
**Fix**:
1. Reload VS Code window
2. Clear Continue.dev cache: `~/.continue/`
3. Verify config points to port 4000

## Monitoring

### vLLM Logs
```bash
journalctl -u vllm-server -f
# Look for: "Tool parser: qwen_coder"
```

### LiteLLM Logs
```bash
tail -f /workspace/logs/litellm-proxy.log
# Look for successful tool call transformations
```

### Continue.dev Logs
Check VS Code Developer Tools Console for API calls

## Key Differences from Previous Attempts

| Aspect | Previous | Current |
|--------|----------|---------|
| vLLM Parser | None/various | `qwen_coder` |
| LiteLLM Role | Full tool handling | Format normalization only |
| Tool Format Flow | XML → Failure | XML → vLLM parser → JSON → LiteLLM → OpenAI format |
| Validation Point | Before parsing (failed) | After parsing (works) |

## Success Criteria

✅ vLLM parses XML tool calls successfully
✅ LiteLLM normalizes to OpenAI format
✅ Continue.dev receives proper `tool_calls` array
✅ No JSON parsing errors in logs
✅ Tool execution works end-to-end
