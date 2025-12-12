# GPT-OSS Token Leakage Fix

## Problem
GPT-OSS-20B was outputting internal reasoning tokens and commentary like:
```
Some("need to analyze the current state... We should... Let's do")
```

This happens when trying to manually specify the **Harmony chat template** instead of letting vLLM auto-detect it.

## The Real Issue

Initial attempt used:
```bash
export VLLM_CHAT_TEMPLATE="harmony"
```

But this **fails** with error:
```
The supplied chat template string (harmony) appears path-like, but doesn't exist!
```

**Why?**
- The `--chat-template` flag expects a **file path** to a Jinja template
- "harmony" is not a file - it's a special encoding format **built into** GPT-OSS
- The model has Harmony template in its `tokenizer_config.json`
- vLLM should **auto-detect** it automatically

## Solution

**REMOVED** the incorrect environment variable. Let vLLM auto-detect everything:

### Updated `gptoss.sh`:
```bash
# Performance optimizations (Harmony chat template auto-detected from model)
export VLLM_TOKENIZER_MODE="auto"          # Let vLLM detect chat template
export VLLM_ENABLE_PREFIX_CACHING="true"   # Performance optimization
```

### What These Do:
- **`--tokenizer-mode auto`**: vLLM auto-detects the Harmony template from model config
- **`--enable-prefix-caching`**: Improves performance by caching common prefixes
- **No `--chat-template` flag**: Let the model's built-in template handle it

## How to Apply

1. **Stop the current server** on RunPod:
   ```bash
   kill $(cat /workspace/logs/vllm-server.pid)
   ```

2. **Start with new config**:
   ```bash
   ./gptoss.sh
   ```

3. **Verify** the server log shows:
   ```
   Chat Template: harmony ⚠️ CRITICAL for proper token handling
   Prefix Caching: Enabled ✅
   ```

## References
- [OpenAI GPT-OSS vLLM Guide](https://cookbook.openai.com/articles/gpt-oss/run-vllm)
- [Harmony Response Format](https://cookbook.openai.com/article/harmony)

## Alternative: Client-Side Stop Sequences

Already added to Continue config as backup:
```yaml
stop:
  - "<|end|>"
  - "<|start|>"
  - "<|assistant|>"
  - "Some(\""
  - "need to analyze"
  - "We should"
```

But **server-side chat template is the proper fix**.
