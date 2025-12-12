# Qwen 3 Coder 30B - RunPod Deployment Status

**Date:** December 12, 2025
**Pod:** v5brcrgoclcp1p (petite_coffee_koi)
**GPU:** NVIDIA RTX 6000 Ada 48GB VRAM
**Cost:** $0.78/hour

## ✅ Current Status: WORKING (vLLM Direct)

### Active Model
- **Model:** Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8
- **Size:** ~31B parameters (FP8 quantized)
- **Context:** 131,072 tokens (128K)
- **Memory:** ~24GB VRAM (50% savings vs full precision)

### Endpoints
- **vLLM Direct:** https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1 ✅ WORKING
- **LiteLLM Proxy:** https://v5brcrgoclcp1p-4000.proxy.runpod.net/v1 ❌ DOWN (502)

### API Key
```
sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9
```

## Test Results

### ✅ Basic Functionality
```bash
curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1/chat/completions \
  -H "Authorization: Bearer sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9" \
  -d '{"model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8", "messages": [{"role": "user", "content": "Hi"}]}'
```
**Result:** Working! Returns valid responses.

### ✅ Non-Alternating Roles (KEY ADVANTAGE!)
```bash
curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1/chat/completions \
  -H "Authorization: Bearer sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9" \
  -d '{
    "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
    "messages": [
      {"role": "user", "content": "First question"},
      {"role": "user", "content": "Second question"}
    ]
  }'
```
**Result:** ✅ WORKS! No role validation errors (unlike Gemma 3)

### ⚠️ Response Fields Issue
Response contains non-standard OpenAI fields that break Copilot:
```json
{
  "annotations": null,      // ← BREAKS COPILOT
  "audio": null,            // ← BREAKS COPILOT
  "content": "...",         // ✅ Standard
  "function_call": null,
  "reasoning": null,        // ← BREAKS COPILOT
  "reasoning_content": null,// ← BREAKS COPILOT
  "refusal": null,          // ← BREAKS COPILOT
  "role": "assistant",      // ✅ Standard
  "tool_calls": null
}
```

## Solution: LiteLLM Proxy (Currently Down)

### Why We Need It
LiteLLM strips the problematic fields to give clean OpenAI-compatible responses:
```json
{
  "content": "...",
  "role": "assistant"
}
```

### To Restart LiteLLM on RunPod
```bash
# SSH to RunPod
./connect-runpod.sh

# Upload updated script (if needed)
# Then run:
./setup-litellm.sh

# In a new terminal:
./start-litellm.sh
```

### After LiteLLM is Running
Update VS Code Copilot settings to use:
- **Endpoint:** https://v5brcrgoclcp1p-4000.proxy.runpod.net/v1
- **API Key:** sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9
- **Model:** qwen-30b

## Key Advantages of Qwen 3 vs Gemma 3

| Feature | Qwen 3 Coder | Gemma 3 |
|---------|-------------|---------|
| **Role Validation** | ✅ Flexible (accepts non-alternating) | ❌ Strict (must alternate) |
| **Code Optimization** | ✅ Specifically trained for code | ⚠️ General purpose |
| **Memory Usage** | ~24GB (FP8) | ~25GB (FP8) |
| **Context Window** | 128K tokens | 128K tokens |
| **Copilot Compatibility** | ✅ Better (with LiteLLM) | ❌ Role errors |

## Next Steps

1. **Immediate:** Restart LiteLLM proxy on RunPod
2. **Test:** Verify LiteLLM strips non-standard fields
3. **Configure:** Update VS Code to use LiteLLM endpoint
4. **Validate:** Test Copilot completions end-to-end

## Files Updated
- ✅ `qwen3.sh` - Deployment script for Qwen 3
- ✅ `setup-litellm.sh` - LiteLLM configuration (new API key)
- ✅ `gemma3.sh` - Updated with new API key (backup)

## Commands Reference

### Check Model Status
```bash
curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1/models \
  -H "Authorization: Bearer sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9"
```

### Test Qwen 3 Direct
```bash
curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9" \
  -d '{
    "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
    "messages": [{"role": "user", "content": "Write a hello world in Python"}],
    "max_tokens": 100
  }'
```

### Stop vLLM (to switch models)
```bash
pkill -f vllm
```

### Stop LiteLLM
```bash
pkill -f litellm
```

## Conclusion

**Qwen 3 is the better choice for Copilot:**
- ✅ No role alternation errors
- ✅ Optimized for code generation
- ✅ Same memory footprint as Gemma 3
- ✅ Same 128K context window

**Just need to restart LiteLLM proxy to strip the problematic response fields.**
