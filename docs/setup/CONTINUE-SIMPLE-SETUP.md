# Continue.dev with GPT-OSS 20B - Simple Setup

## Current Running Model

**GPT-OSS 20B** is running on port 8000:
- **Endpoint**: https://3clxt008hl0a3a-8000.proxy.runpod.net/v1
- **Model ID**: `openai/gpt-oss-20b`
- **API Key**: `sk-vllm-41d3575b25edb67c4a428859379be0a3`
- **Context**: 128K tokens
- **Purpose**: Chat, code editing, code generation

## Setup Continue.dev

### 1. Install Extension
```bash
# In VS Code
⌘+Shift+X → Search "Continue" → Install
```

### 2. Configure
```bash
# Copy config file
mkdir -p ~/.continue
cp continue-config.yaml ~/.continue/config.yaml
```

### 3. Use It!
- **Chat**: Press `⌘+L` → Ask questions
- **Edit code**: Select code → `⌘+I` → Request changes
- **Autocomplete**: Uses Continue.dev's default service (free)

## Test the Model

```bash
# Test endpoint
curl https://3clxt008hl0a3a-8000.proxy.runpod.net/v1/models \
  -H "Authorization: Bearer sk-vllm-41d3575b25edb67c4a428859379be0a3"

# Test chat
curl https://3clxt008hl0a3a-8000.proxy.runpod.net/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-vllm-41d3575b25edb67c4a428859379be0a3" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 100
  }'
```

## Why One Model?

Running two vLLM instances on one GPU is problematic:
- GPT-OSS uses ~95% GPU memory (~45GB of 48GB)
- Second model would need its own GPU or cause OOM errors
- Continue.dev's default autocomplete works great and is free

## Alternative: Local Autocomplete

If you want local autocomplete, you'd need to:
1. Get a second GPU pod, or
2. Use a CPU-based autocomplete (slower), or
3. Reduce GPT-OSS memory usage (worse quality)

For most use cases, the default Continue.dev autocomplete + GPT-OSS for chat/edit is optimal.

## Pod Info

- **Pod**: 3clxt008hl0a3a (petite_coffee_koi-migration)
- **GPU**: RTX 6000 Ada (48GB VRAM)
- **Cost**: $0.79/hr
- **Jupyter**: https://3clxt008hl0a3a-8888.proxy.runpod.net/ (password: 42z5ic3ocbugvss4iuqr)

## Troubleshooting

**Continue.dev not responding:**
1. Check model is running: `curl https://3clxt008hl0a3a-8000.proxy.runpod.net/v1/models`
2. Verify config: `cat ~/.continue/config.yaml`
3. Restart VS Code
4. Check Continue output: View → Output → "Continue"

**Model crashed:**
```bash
# SSH or Jupyter terminal
cd /workspace
./gptoss.sh  # Restart GPT-OSS
```

---
Updated: December 12, 2025
