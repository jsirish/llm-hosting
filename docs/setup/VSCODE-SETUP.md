# VS Code Setup Guide - Qwen3-Coder-30B

## Option 1: Continue.dev (Recommend3. Enter:
   - **API Key**: `sk-vllm-222bb5bb425ee38812aa642184113ae5`
   - **Base URL**: `https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1`
   - **Model**: `Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8`
Continue.dev is a VS Code extension that supports custom OpenAI-compatible APIs.

### Installation

1. Open VS Code
2. Go to Extensions (Cmd+Shift+X)
3. Search for "Continue"
4. Install "Continue - Codestral, Claude, and more"

### Configuration

1. After installation, Continue will open
2. Click the gear icon (⚙️) in Continue sidebar
3. This opens `.continue/config.json`
4. Replace with this configuration:

```json
{
  "models": [
    {
      "title": "Qwen3-Coder-30B (RunPod)",
      "provider": "openai",
      "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
      "apiBase": "https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1",
      "apiKey": "sk-vllm-222bb5bb425ee38812aa642184113ae5",
      "contextLength": 32768
    }
  ],
  "tabAutocompleteModel": {
    "title": "Qwen3-Coder-30B (RunPod)",
    "provider": "openai",
    "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
    "apiBase": "https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1",
    "apiKey": "sk-vllm-222bb5bb425ee38812aa642184113ae5"
  },
  "embeddingsProvider": {
    "provider": "transformers.js"
  }
}
```

5. Save the file (Cmd+S)
6. Continue will reload with your model

### Usage

- **Chat**: Open Continue sidebar (Cmd+L or click Continue icon), type your question
- **Edit code**: Select code, press Cmd+I, describe changes
- **Tab autocomplete**: Just start typing, suggestions will appear
- **Add context**: Use @ to add files, folders, docs to context

### Keyboard Shortcuts

- `Cmd+L` - Open Continue chat
- `Cmd+I` - Inline edit selected code
- `Cmd+Shift+R` - Highlight code and add to context
- `Cmd+Shift+Backspace` - Cancel current request

## Option 2: Cline Extension (Alternative)

Cline is another VS Code extension for custom models.

### Installation

1. Open VS Code Extensions
2. Search for "Cline"
3. Install

### Configuration

1. Open Command Palette (Cmd+Shift+P)
2. Type "Cline: Open Settings"
3. Select "OpenAI Compatible"
4. Enter:
   - **API Key**: `sk-vllm-9937d56175885a67eeabbba783d1a3ed`
   - **Base URL**: `https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1`
   - **Model**: `Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8`

## Option 3: Cursor (Separate Editor)

Cursor is a VS Code fork with built-in AI.

1. Download from https://cursor.sh
2. Open Settings → Cursor Settings
3. Add custom model:
   - Provider: OpenAI API
   - Base URL: `https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1`
   - API Key: `sk-vllm-222bb5bb425ee38812aa642184113ae5`
   - Model: `Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8`

## Testing Your Setup

After configuration, test with:

1. **Simple prompt**: "Write a hello world function in Python"
2. **Code completion**: Start typing `def factorial(` and see suggestions
3. **Code explanation**: Select some code, ask "Explain this code"
4. **Refactoring**: Select code, ask "Refactor this to use list comprehension"

## Troubleshooting

### "Model not responding"
- Check server is running: `ssh` to pod and run `./check-server.sh`
- Verify API key: `cat /workspace/logs/api-key.txt` on pod
- Test API manually: Use curl commands from DEPLOYMENT-SUCCESS.md

### "Connection timeout"
- Check RunPod proxy is active (should be automatic)
- Try health endpoint: `curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/health`

### "Invalid API key"
- API key changes on server restart
- Get new key: `cat /workspace/logs/api-key.txt` on pod
- Update in Continue config

### Slow responses
- Normal for 30B model (2-5 seconds for first token)
- Large context increases latency
- Consider reducing max_tokens in config

## Performance Tips

1. **Context management**: Don't add unnecessary files to context
2. **Shorter prompts**: Be concise for faster responses
3. **Batch questions**: Ask multiple things at once rather than back-and-forth
4. **Use autocomplete sparingly**: Full completions are slower than chat

## Comparison: Continue vs Cline vs Cursor

| Feature | Continue | Cline | Cursor |
|---------|----------|-------|--------|
| **Free** | ✅ Yes | ✅ Yes | ⚠️ Limited |
| **Tab completion** | ✅ Yes | ❌ No | ✅ Yes |
| **Chat interface** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Inline editing** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Custom models** | ✅ Easy | ✅ Easy | ✅ Easy |
| **VS Code native** | ✅ Yes | ✅ Yes | ❌ Separate app |

**Recommendation**: Start with **Continue.dev** - it's the most feature-complete and free.

## Advanced: Tool Calling Setup

If you want to enable tool/function calling:

1. Stop server: `./stop-server.sh`
2. Edit `start-server.sh`, add these flags:
   ```bash
   --enable-auto-tool-choice \
   --tool-call-parser hermes \
   ```
3. Restart: `./start-server.sh`

Then in Continue config, add:
```json
{
  "models": [{
    ...existing config...,
    "capabilities": {
      "toolCalling": true
    }
  }]
}
```

---

**Next Step**: Install Continue.dev and test it out!
