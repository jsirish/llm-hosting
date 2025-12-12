# GPT-OSS-20B with Special vLLM Build

## Overview

GPT-OSS requires a **special build of vLLM** (version 0.10.1+gptoss) that includes custom patches for the model's architecture and tool calling system. The standard vLLM won't recognize the model.

## Key Differences

| Aspect | Standard vLLM | GPT-OSS vLLM Build |
|--------|---------------|-------------------|
| Version | 0.12.0 | 0.10.1+gptoss |
| Model Support | Qwen, Llama, Mistral, etc. | **openai/gpt-oss-20b** |
| PyTorch | Stable CUDA 12.8 | Nightly CUDA 12.8 |
| Tool Calling | Standard parsers | Custom GPT-OSS format |
| Installation | `pip install vllm` | Special wheels repo |

## Installation Steps

### 1. SSH into RunPod
```bash
./connect-runpod.sh
```

### 2. Stop Current Server (if running)
```bash
./stop-server.sh
```

### 3. Install GPT-OSS vLLM Build
```bash
# Copy the install script to pod (via nano/paste since SCP doesn't work)
nano install-vllm-gptoss.sh
# Paste the content, save (Ctrl+O, Enter, Ctrl+X)

# Make executable and run
chmod +x install-vllm-gptoss.sh
./install-vllm-gptoss.sh
```

The install script will:
- Install `uv` package manager (recommended by vLLM)
- Remove existing vLLM installation
- Install vLLM 0.10.1+gptoss with PyTorch nightly CUDA 12.8
- Verify the installation

### 4. Upload GPT-OSS Start Script
```bash
# Copy the GPT-OSS start script to pod
nano start-server-gptoss.sh
# Paste the content, save

chmod +x start-server-gptoss.sh
```

### 5. Start GPT-OSS Server
```bash
./start-server-gptoss.sh
```

### 6. Monitor Startup
```bash
tail -f /workspace/logs/vllm-server.log
```

## Expected Behavior

### Successful Startup
```
INFO:     Started server process [XXXXX]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### Model Download
- Model size: ~40GB
- Download time: 2-3 minutes (RunPod has fast internet)
- First run only - cached after that

## API Usage

### Get New API Key
After starting, the key is printed in the output and saved to:
```bash
cat /workspace/logs/api-key.txt
```

### Test Endpoint
```bash
# From pod (localhost)
curl http://localhost:8000/v1/models

# From Mac (public endpoint)
export VLLM_API_KEY="sk-vllm-YOUR-KEY-HERE"
./test-api-local.sh
```

## Command Reference

### Using `vllm serve` (Recommended)
```bash
vllm serve openai/gpt-oss-20b \
  --max-model-len 32768 \
  --port 8000
```

### Legacy Python Module Command
```bash
python3 -m vllm.entrypoints.openai.api_server \
  --model openai/gpt-oss-20b \
  --max-model-len 32768 \
  --port 8000
```

## VS Code Copilot Compatibility

### Known Issues (from previous testing)
1. **"Unknown role: functions"** - VS Code uses deprecated OpenAI function role
2. **Custom special tokens** - GPT-OSS uses proprietary format that may conflict

### Recommended Approach
1. Start GPT-OSS server with special vLLM build
2. Test API endpoints work correctly
3. Try VS Code Copilot integration
4. If tool calling fails, consider alternatives:
   - **Continue.dev** - Better compatibility with custom models
   - **Cursor** - Built for OpenAI-compatible APIs
   - **Cody** - Flexible model support

## Troubleshooting

### "Model not found" Error
**Symptom:** `OSError: openai/gpt-oss-20b is not a valid model identifier`

**Solution:** You're using standard vLLM, not the GPT-OSS build. Run `./install-vllm-gptoss.sh`

### Version Check
```bash
python3 -c "import vllm; print(vllm.__version__)"
```
Should show: `0.10.1+gptoss` or similar

### Dependency Conflicts
If installation fails:
```bash
# Create fresh environment
python3 -m venv /workspace/venv-gptoss
source /workspace/venv-gptoss/bin/activate
./install-vllm-gptoss.sh
```

### CUDA Errors
GPT-OSS build uses PyTorch nightly. If you see CUDA errors:
```bash
# Check CUDA version
nvidia-smi
# Should show CUDA 12.x
```

## Switching Back to Qwen3-Coder

If you want to go back to Qwen3-Coder-30B:

```bash
# 1. Stop GPT-OSS server
./stop-server.sh

# 2. Reinstall standard vLLM
pip uninstall -y vllm
pip install vllm==0.12.0

# 3. Start Qwen server
./start-server.sh  # (uses Qwen3-Coder-30B-Instruct)
```

## Resource Usage

| Model | Size | VRAM (BF16) | VRAM (FP8) | Context |
|-------|------|-------------|------------|---------|
| GPT-OSS-20B | ~40GB | ~40GB | ~20GB | 32k |
| Qwen3-Coder-30B | ~60GB | Too large | ~30GB | 32k |

**Note:** GPT-OSS-20B at BF16 uses ~40GB VRAM, fits comfortably in 48GB without quantization.

## Next Steps

1. **Install GPT-OSS vLLM:** Run `./install-vllm-gptoss.sh` on pod
2. **Start Server:** Run `./start-server-gptoss.sh` on pod
3. **Get API Key:** Check startup output or `/workspace/logs/api-key.txt`
4. **Test API:** Run `./test-api-local.sh` from Mac
5. **Try VS Code Copilot:** Update settings with new API key and model name

## References

- [OpenAI GPT-OSS Cookbook](https://cookbook.openai.com/articles/gpt-oss/run-vllm)
- [vLLM GPT-OSS Wheels](https://wheels.vllm.ai/gpt-oss/)
- [GPT-OSS Model Card](https://huggingface.co/openai/gpt-oss-20b)
