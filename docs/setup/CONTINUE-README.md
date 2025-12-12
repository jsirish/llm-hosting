# Continue.dev Quick Reference for RunPod

## 🚀 Starting the Models

### Start Chat Model (Kimi K2 - DeepSeek-V3)
```bash
cd /workspace
./kimi-k2.sh
```
- **Model**: DeepSeek-V3 (30B parameters)
- **Purpose**: Chat, code editing, explanations
- **Port**: 8000
- **Load Time**: 3-5 minutes
- **VRAM**: ~45GB

### Start Autocomplete Model (Qwen 1.5B)
```bash
# In a second terminal
cd /workspace
./autocomplete.sh
```
- **Model**: Qwen2.5-Coder-1.5B-Instruct
- **Purpose**: Fast code completions
- **Port**: 8001
- **Load Time**: 1-2 minutes
- **VRAM**: ~3GB

## 📡 Endpoints

| Service | URL | Purpose |
|---------|-----|---------|
| Chat API | https://3clxt008hl0a3a-8000.proxy.runpod.net/v1 | Chat, edit, apply |
| Autocomplete API | https://3clxt008hl0a3a-8001.proxy.runpod.net/v1 | Tab autocomplete |
| Chat Models | https://3clxt008hl0a3a-8000.proxy.runpod.net/v1/models | List available |
| Autocomplete Models | https://3clxt008hl0a3a-8001.proxy.runpod.net/v1/models | List available |

**API Key**: `sk-vllm-41d3575b25edb67c4a428859379be0a3`

## 🧪 Testing

### Test Chat Model
```bash
curl https://3clxt008hl0a3a-8000.proxy.runpod.net/v1/models \
  -H "Authorization: Bearer sk-vllm-41d3575b25edb67c4a428859379be0a3"
```

### Test Autocomplete Model
```bash
curl https://3clxt008hl0a3a-8001.proxy.runpod.net/v1/models \
  -H "Authorization: Bearer sk-vllm-41d3575b25edb67c4a428859379be0a3"
```

### Test Chat Completion
```bash
curl https://3clxt008hl0a3a-8000.proxy.runpod.net/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-vllm-41d3575b25edb67c4a428859379be0a3" \
  -d '{
    "model": "kimi-k2",
    "messages": [{"role": "user", "content": "Write a Python function to reverse a string"}],
    "max_tokens": 200
  }'
```

## 📊 Model Information

| Feature | Kimi K2 (Chat) | Qwen (Autocomplete) |
|---------|----------------|---------------------|
| **Model** | DeepSeek-V3 30B | Qwen2.5-Coder-1.5B |
| **Port** | 8000 | 8001 |
| **Context** | 128K tokens | 32K tokens |
| **VRAM** | ~45GB | ~3GB |
| **Parser** | deepseek | qwen |
| **Load Time** | 3-5 min | 1-2 min |
| **Purpose** | Chat/Edit | Autocomplete |

## 🔧 Monitoring

### Check Logs
```bash
# Chat model
tail -f /workspace/logs/kimi-k2.log

# Autocomplete model
tail -f /workspace/logs/autocomplete.log
```

### Check if Running
```bash
# Check ports
netstat -tlnp | grep -E '8000|8001'

# Check processes
ps aux | grep vllm
```

## 💡 Continue.dev Configuration

Config file location on your Mac: `~/.continue/config.yaml`

Key settings:
- Chat model uses vLLM provider on port 8000
- Autocomplete model uses vLLM provider on port 8001
- No LiteLLM or proxy needed (Continue has native vLLM support)

See `continue-config.yaml` for full configuration.

## 🐛 Troubleshooting

### Models won't start
1. Check if vLLM is installed: `pip show vllm`
2. Reinstall if needed: `./install-vllm.sh`
3. Check CUDA: `nvidia-smi`

### Out of memory
- Both models together use ~48GB VRAM
- RTX 6000 Ada has 48GB total
- If issues, start only one model

### Connection refused
- Wait for model to fully load (3-5 min for Kimi K2)
- Check logs: `tail -f /workspace/logs/*.log`
- Verify port: `netstat -tlnp | grep 8000`

## 📚 More Info

See `CONTINUE-SETUP.md` for comprehensive documentation including:
- Detailed configuration explanations
- Why this setup was chosen
- Performance optimization tips
- Tool parser reference
