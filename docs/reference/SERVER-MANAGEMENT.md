# vLLM Server Management - Simplified Architecture

This setup uses a **generic server launcher** with **model-specific configuration scripts** for easy switching between models.

## Architecture

```
┌─────────────────────────────────────────┐
│  Model Config Scripts (set env vars)   │
│  • qwen.sh                              │
│  • gptoss.sh                            │
└───────────┬─────────────────────────────┘
            │ calls
            ▼
┌─────────────────────────────────────────┐
│  Generic Server Launcher                │
│  • start-vllm-server.sh                 │
│  • Enforces single instance             │
│  • Reads env vars for configuration     │
└─────────────────────────────────────────┘
```

## Quick Start

### Start Qwen3-Coder-30B (128K context)
```bash
./qwen.sh
```

### Start GPT-OSS-20B (128K context, when available)
```bash
./gptoss.sh
```

### Stop any running server
```bash
./stop-server.sh
```

## Features

### ✅ Single Instance Enforcement
- Only one vLLM server can run at a time
- Prevents port conflicts and resource issues
- Uses shared PID file: `/workspace/logs/vllm-server.pid`

### 🔧 Easy Configuration
Each model script sets:
- `VLLM_MODEL` - Model identifier
- `VLLM_MODEL_DESCRIPTION` - Human-readable description
- `VLLM_MAX_MODEL_LEN` - Context window size
- `VLLM_GPU_MEMORY_UTIL` - GPU memory utilization
- `VLLM_TOOL_PARSER` - Tool calling parser

### 📊 Maximized Context Windows
Both models configured for **128K tokens** (131,072):
- **Qwen3-Coder-30B**: 128K context with `qwen3_xml` parser (XML format avoids JSON escape issues)
- **GPT-OSS-20B**: 128K context with `openai` parser

### 🔐 API Key Management
- Generates new random key on each start (saved to `/workspace/logs/api-key.txt`)
- Or set `VLLM_API_KEY` env var for persistent key

## Environment Variables

### Required (set by model scripts)
- `VLLM_MODEL` - Model path/identifier
- `VLLM_MAX_MODEL_LEN` - Context length (tokens)
- `VLLM_TOOL_PARSER` - Parser name

### Optional (with defaults)
- `VLLM_MODEL_DESCRIPTION` - Defaults to model name
- `VLLM_GPU_MEMORY_UTIL` - Defaults to `0.95`
- `VLLM_API_KEY` - Auto-generated if not set

## File Locations

```
/workspace/logs/
├── vllm-server.log       # Server output logs
├── vllm-server.pid       # Process ID (single instance)
└── api-key.txt           # Current API key

/workspace/hf-cache/      # Model cache (304TB storage)
```

## Examples

### Check if server is running
```bash
if [ -f /workspace/logs/vllm-server.pid ] && kill -0 $(cat /workspace/logs/vllm-server.pid) 2>/dev/null; then
    echo "Server is running (PID: $(cat /workspace/logs/vllm-server.pid))"
else
    echo "Server is not running"
fi
```

### View current API key
```bash
cat /workspace/logs/api-key.txt
```

### Monitor server logs
```bash
tail -f /workspace/logs/vllm-server.log
```

### Switch models
```bash
# Stop current server
./stop-server.sh

# Start different model
./gptoss.sh  # or ./qwen.sh
```

## Creating New Model Configs

To add a new model, create a script like:

```bash
#!/bin/bash
# mymodel.sh

export VLLM_MODEL="organization/model-name"
export VLLM_MODEL_DESCRIPTION="My Model Description"
export VLLM_MAX_MODEL_LEN=131072
export VLLM_GPU_MEMORY_UTIL=0.95
export VLLM_TOOL_PARSER="openai"  # or model-specific parser

exec ./start-vllm-server.sh
```

Make it executable:
```bash
chmod +x mymodel.sh
```

## Testing

### Test API endpoint
```bash
API_KEY=$(cat /workspace/logs/api-key.txt)
curl http://localhost:8000/health \
  -H "Authorization: Bearer ${API_KEY}"
```

### Test chat completion
```bash
API_KEY=$(cat /workspace/logs/api-key.txt)
curl http://localhost:8000/v1/chat/completions \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "'"$(grep VLLM_MODEL qwen.sh | cut -d'"' -f2)"'",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 50
  }'
```

## Troubleshooting

### "Server is already running"
Stop the existing server first:
```bash
./stop-server.sh
```

### Check server status
```bash
ps aux | grep vllm.entrypoints.openai.api_server
```

### View recent logs
```bash
tail -50 /workspace/logs/vllm-server.log
```

### Server won't start
1. Check disk space: `df -h`
2. Check GPU memory: `nvidia-smi`
3. Review logs: `tail -100 /workspace/logs/vllm-server.log`

## Performance Notes

### Context Window Impact
Larger context windows require more VRAM:
- 32K tokens: ~30GB VRAM
- 128K tokens: ~45GB VRAM (near limit on RTX 6000 Ada)

If you get OOM errors with 128K, reduce to:
- 64K: `export VLLM_MAX_MODEL_LEN=65536`
- 32K: `export VLLM_MAX_MODEL_LEN=32768`

### GPU Memory Utilization
Set to 0.95 by default. Lower if experiencing crashes:
```bash
export VLLM_GPU_MEMORY_UTIL=0.90
```

## Legacy Scripts

Old model-specific scripts are kept for reference:
- `start-server.sh` - Original Qwen script
- `start-server-gptoss.sh` - Original GPT-OSS script

These are superseded by the new architecture but preserved for historical context.
