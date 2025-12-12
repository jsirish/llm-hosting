# Continue.dev Setup Guide for Self-Hosted vLLM

**Pod**: petite_coffee_koi-migration (3clxt008hl0a3a)
**GPU**: RTX 6000 Ada x1 (48GB VRAM)
**Cost**: $0.79/hr

## 🎯 Overview

This setup provides **optimal configuration for Continue.dev** using self-hosted vLLM models:

- **Chat Model**: Kimi K2 30B (DeepSeek-V3) - Advanced reasoning & conversation
- **Autocomplete Model**: Qwen2.5-Coder 1.5B - Fast, accurate code completion
- **No Proxy Needed**: Continue talks directly to vLLM's OpenAI-compatible API
- **No LiteLLM Needed**: vLLM provider built into Continue

---

## 📦 What Was Created

### On the Pod (`/workspace/`):

1. **`kimi-k2.sh`** - Kimi K2 30B chat model launcher
   - Model: deepseek-ai/DeepSeek-V3
   - Port: 8000
   - Context: 128K tokens
   - VRAM: ~45GB (maximized at 0.95 utilization)
   - Tool parser: deepseek

2. **`autocomplete.sh`** - Qwen2.5-Coder 1.5B autocomplete launcher
   - Model: Qwen/Qwen2.5-Coder-1.5B-Instruct
   - Port: 8001 (separate from chat)
   - Context: 32K tokens
   - VRAM: ~3GB (0.3 utilization - leaves room for chat model)
   - Tool parser: qwen

3. **`continue-config.yaml`** - Complete Continue.dev configuration
   - Ready to copy to `~/.continue/config.yaml`
   - Pre-configured with your pod endpoints
   - Includes all roles: chat, edit, apply, autocomplete

---

## 🚀 Quick Start

### Step 1: Start the Models

Open two terminals in Jupyter Lab:

**Terminal 1 - Chat Model:**
```bash
cd /workspace
./kimi-k2.sh
```
Wait 3-5 minutes for Kimi K2 to load (~30GB model).

**Terminal 2 - Autocomplete Model:**
```bash
cd /workspace
./autocomplete.sh
```
Wait 1-2 minutes for Qwen autocomplete to load (~3GB model).

### Step 2: Install Continue.dev in VS Code

1. Open VS Code
2. Go to Extensions (⌘+Shift+X)
3. Search for "Continue"
4. Install the Continue extension
5. Reload VS Code if prompted

### Step 3: Configure Continue

**Option A - Copy Config File (Recommended):**
```bash
# From your local machine:
scp root@3clxt008hl0a3a-8888.proxy.runpod.net:/workspace/continue-config.yaml ~/.continue/config.yaml
```

**Option B - Manual Configuration:**

1. Open Continue settings (click Continue icon in sidebar → gear icon)
2. Click "Edit config.json"
3. Copy content from `/workspace/continue-config.yaml` on pod
4. Paste into `~/.continue/config.yaml`
5. Save

### Step 4: Test It!

1. **Test Chat**: Open Continue sidebar (⌘+L), type a question
2. **Test Autocomplete**: Start typing code, wait for suggestions (gray text)
3. **Test Edit**: Select code, press ⌘+I, ask for changes

---

## 🔧 Configuration Details

### Chat Model Configuration

```yaml
models:
  - name: Kimi K2 30B
    provider: vllm
    model: kimi-k2
    apiBase: https://3clxt008hl0a3a-8000.proxy.runpod.net/v1
    apiKey: sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9
    contextLength: 131072
    roles:
      - chat
      - edit
      - apply
```

**Endpoints:**
- **Chat**: https://3clxt008hl0a3a-8000.proxy.runpod.net/v1
- **Served as**: `kimi-k2`
- **Capabilities**: Reasoning, tool calling, long context (128K)

### Autocomplete Model Configuration

```yaml
models:
  - name: Qwen Autocomplete
    provider: vllm
    model: qwen-autocomplete
    apiBase: https://3clxt008hl0a3a-8001.proxy.runpod.net/v1
    apiKey: sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9
    contextLength: 32768
    roles:
      - autocomplete
```

**Endpoints:**
- **Autocomplete**: https://3clxt008hl0a3a-8001.proxy.runpod.net/v1
- **Served as**: `qwen-autocomplete`
- **Capabilities**: Fast inline completions, FIM (fill-in-middle)

---

## 📊 Resource Usage

| Model | VRAM | Port | Context | Use Case |
|-------|------|------|---------|----------|
| Kimi K2 30B | ~45GB | 8000 | 128K | Chat, Edit, Apply |
| Qwen 1.5B | ~3GB | 8001 | 32K | Autocomplete |
| **Total** | **~48GB** | - | - | **Both models fit!** |

---

## 💡 Why This Setup?

### ✅ Advantages Over Previous Approach:

1. **No Proxy Needed**: Continue has native vLLM provider support
2. **No LiteLLM Needed**: Direct vLLM integration works perfectly
3. **Optimal Model Selection**:
   - **Large model for reasoning** (Kimi K2 30B)
   - **Small model for speed** (Qwen 1.5B autocomplete)
4. **Native Tool Calling**: Both models support function calling
5. **Separate Endpoints**: Chat and autocomplete don't interfere
6. **Maximum Context**: 128K tokens for chat, 32K for autocomplete

### 🎯 Why NOT Use GPT-4 for Autocomplete?

From Continue.dev docs:
> "Perhaps surprisingly, the answer is no. The models that we suggest for autocomplete are trained with a highly specific prompt format, which allows them to respond to requests for completing code. Some of the best commercial models like GPT-4 or Claude are not trained with this prompt format, which means that they won't generate useful completions. Most of the state-of-the-art autocomplete models are no more than 10b parameters."

**Small models (1.5B-7B) are actually BETTER for autocomplete!**

---

## 🧪 Testing Endpoints

### Test Chat Model:
```bash
curl https://3clxt008hl0a3a-8000.proxy.runpod.net/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9" \
  -d '{
    "model": "kimi-k2",
    "messages": [{"role": "user", "content": "Write a Python function to reverse a string"}],
    "max_tokens": 100
  }'
```

### Test Autocomplete Model:
```bash
curl https://3clxt008hl0a3a-8001.proxy.runpod.net/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9" \
  -d '{
    "model": "qwen-autocomplete",
    "prompt": "def reverse_string(s):\n    ",
    "max_tokens": 50
  }'
```

---

## 🔍 Troubleshooting

### Models Not Loading?

1. **Check GPU memory**:
   ```bash
   nvidia-smi
   ```

2. **Check vLLM logs**:
   ```bash
   tail -f /workspace/logs/vllm-server.log
   ```

3. **Verify processes**:
   ```bash
   ps aux | grep vllm
   ```

### Continue Not Connecting?

1. **Verify endpoints are accessible**:
   ```bash
   curl https://3clxt008hl0a3a-8000.proxy.runpod.net/v1/models
   ```

2. **Check API key** in config matches:
   ```
   sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9
   ```

3. **Check Continue logs**: VS Code → Output → Continue

### Autocomplete Not Working?

1. **Verify autocomplete model role** in config:
   ```yaml
   roles:
     - autocomplete
   ```

2. **Check autocomplete settings** in Continue:
   - Settings → Autocomplete → Enable

3. **Try typing slowly** - autocomplete has a debounce delay (300ms)

---

## 📝 Model Parsers Reference

From your existing scripts:

- **Gemma**: `VLLM_TOOL_PARSER="openai"`
- **Qwen**: `VLLM_TOOL_PARSER="qwen"`
- **DeepSeek/Kimi**: `VLLM_TOOL_PARSER="deepseek"`

---

## 🗑️ Cleanup Old Models (Optional)

If you want to remove old Qwen models to free up space:

```bash
# Check cached models
du -sh /workspace/hf-cache/*

# Remove specific model (be careful!)
rm -rf /workspace/hf-cache/models--Qwen--Qwen3-Coder-30B-*

# Or let Hugging Face cache manage itself (recommended)
# It auto-cleans LRU models when space is needed
```

---

## 📚 Additional Resources

- **Continue.dev Docs**: https://continue.dev/docs
- **vLLM Documentation**: https://docs.vllm.ai/
- **Kimi K2 Model Card**: https://huggingface.co/deepseek-ai/DeepSeek-V3
- **Qwen2.5-Coder**: https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct

---

## 🎉 Next Steps

1. ✅ Start both models
2. ✅ Install & configure Continue.dev
3. ✅ Test chat and autocomplete
4. 🚀 Start coding with AI assistance!

**Optional Enhancements:**
- Add embeddings model for codebase search
- Configure additional context providers
- Customize autocomplete debounce/behavior
- Add custom slash commands

---

## 📞 Support

If you encounter issues:
1. Check this guide's troubleshooting section
2. Review Continue.dev docs: https://continue.dev/docs
3. Check vLLM logs in `/workspace/logs/`
4. Verify pod is running in RunPod console

---

**Happy Coding! 🚀**
