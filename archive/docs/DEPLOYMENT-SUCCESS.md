# 🎉 Qwen3-Coder-30B Deployment Success!

**Date**: December 11, 2025
**Stat```json
{
  "models": [
    {
      "title": "Qwen3-Coder-30B (RunPod)",
      "provider": "openai",
      "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
      "apiBase": "https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1",
      "apiKey": "sk-vllm-222bb5bb425ee38812aa642184113ae5"
    }
  ]
}
```AND WORKING

## Deployment Details

- **Model**: Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8
- **Parameters**: 30 billion
- **Quantization**: FP8 (pre-quantized, ~15GB download, ~30GB VRAM)
- **Context Window**: 32,768 tokens
- **Platform**: RunPod Cloud GPU
- **GPU**: NVIDIA RTX 6000 Ada (48GB VRAM)
- **Cost**: $0.78/hour
- **vLLM Version**: 0.12.0

## API Credentials

### Public Endpoint
```
https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1
```

### API Key
```
sk-vllm-222bb5bb425ee38812aa642184113ae5
```

**⚠️ Important**: This API key changes every time you restart the server. Get the current key with:
```bash
ssh v5brcrgoclcp1p-64411a48@ssh.runpod.io -i ~/.ssh/runpod_ed25519
cat /workspace/logs/api-key.txt
```

## Environment Setup (Mac)

Add to your `~/.zshrc`:
```bash
export VLLM_API_KEY="sk-vllm-222bb5bb425ee38812aa642184113ae5"
export VLLM_API_URL="https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1"
```

Then reload: `source ~/.zshrc`

## Test Commands

### Health Check
```bash
curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/health \
  -H "Authorization: Bearer ${VLLM_API_KEY}"
```

### List Models
```bash
curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1/models \
  -H "Authorization: Bearer ${VLLM_API_KEY}"
```

### Chat Completion
```bash
curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${VLLM_API_KEY}" \
  -d '{
    "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
    "messages": [{"role": "user", "content": "Write a Python function to reverse a string"}],
    "max_tokens": 500
  }'
```

## VS Code Copilot Configuration

### Option 1: Using Continue.dev Extension

1. Install Continue.dev extension in VS Code
2. Open Continue settings (`.continue/config.json`)
3. Add model configuration:

```json
{
  "models": [
    {
      "title": "Qwen3-Coder-30B",
      "provider": "openai",
      "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
      "apiBase": "https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1",
      "apiKey": "sk-vllm-9937d56175885a67eeabbba783d1a3ed"
    }
  ]
}
```

### Option 2: Using GitHub Copilot (if supported)

GitHub Copilot doesn't natively support custom models, but you can use it with a proxy:

1. Use a tool like `nginx` or `openai-proxy` to route requests
2. Or use Continue.dev which has better custom model support

## RunPod Management

### Connect to Pod
```bash
./connect-runpod.sh

# Or manually:
ssh v5brcrgoclcp1p-64411a48@ssh.runpod.io -i ~/.ssh/runpod_ed25519
```

### Server Management (on pod)
```bash
# Start server
./start-server.sh

# Check status
./check-server.sh

# Stop server
./stop-server.sh

# Monitor logs
tail -f /workspace/logs/vllm-server.log
```

### Get Current API Key (on pod)
```bash
cat /workspace/logs/api-key.txt
```

## Key Learnings

### What Didn't Work
- ❌ **GPT-OSS-20B**: Required unavailable PyTorch nightly (August 2024)
- ❌ **Initial cache location**: `/root/.cache/huggingface` filled up 30GB root overlay
- ❌ **Tool calling flags**: Not needed for Qwen (has native support)

### What Worked
- ✅ **Qwen3-Coder-30B-FP8**: Latest model with pre-quantization
- ✅ **Cache location**: Moved to `/workspace/hf-cache` (304TB network storage)
- ✅ **Simplified config**: Removed unnecessary flags
- ✅ **vLLM 0.12.0**: Standard build, no special compilation needed

### Critical Fix
The breakthrough was discovering the 49GB cache in `/workspace/.cache/huggingface` and moving HuggingFace cache to `/workspace/hf-cache` to avoid the 30GB root overlay limit.

## Performance

### Tested Capabilities
- ✅ Code generation (Python, JavaScript, etc.)
- ✅ Code explanation
- ✅ Multiple solution approaches
- ✅ Comments and documentation
- ⏳ Tool calling (not yet tested)
- ⏳ 32k context window (not yet tested at full capacity)

### Sample Output Quality
The model generates high-quality code with multiple approaches, clear comments, and proper error handling. Example Fibonacci function included recursive and iterative solutions with complexity analysis.

## Next Steps

1. **Configure VS Code/Continue.dev** with the API credentials
2. **Test tool calling** functionality for function definitions
3. **Test large context** with 32k token files
4. **Benchmark performance** vs other models
5. **Document cost analysis** ($0.78/hr = ~$561/month if running 24/7)

## Troubleshooting

### If server crashes
1. Check logs: `tail -50 /workspace/logs/vllm-server.log`
2. Check disk space: `df -h`
3. Clear cache if needed: `rm -rf /workspace/.cache/huggingface`
4. Restart: `./stop-server.sh && ./start-server.sh`

### If out of disk space
```bash
# Check usage
du -sh /workspace/*

# Clear HuggingFace cache (if old models)
rm -rf /workspace/.cache/huggingface

# Clear temp files
rm -rf /tmp/torchinductor_root /tmp/tiktoken-rs-cache
```

### If model won't load
- Verify GPU has enough VRAM: `nvidia-smi`
- Check if process crashed: `ps aux | grep vllm`
- Try smaller model: `Qwen/Qwen2.5-Coder-14B-Instruct`

## Cost Optimization

**Current**: $0.78/hour
**Daily**: $18.72 (24 hours)
**Monthly**: $561.60 (30 days, 24/7)

### Strategies
- Only run during work hours (8 hours/day) = $187/month
- Use RunPod spot pricing (lower cost, can be interrupted)
- Switch to smaller model if quality is acceptable
- Use on-demand: Start when needed, stop when idle

## Support

- **RunPod Docs**: https://docs.runpod.io/
- **vLLM Docs**: https://docs.vllm.ai/
- **Qwen Models**: https://huggingface.co/Qwen
- **Continue.dev**: https://continue.dev/docs

---

**Created**: December 11, 2025
**Last Updated**: December 11, 2025
**Status**: Production-ready ✅
