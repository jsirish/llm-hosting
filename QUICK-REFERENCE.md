# RunPod Qwen3-Coder-30B Quick Reference

## Connection
```bash
# From your Mac - connect to RunPod
./connect-runpod.sh

# Or manually:
ssh v5brcrgoclcp1p-64411a48@ssh.runpod.io -i ~/.ssh/runpod_ed25519
```

## Server Management (on RunPod)

### Start Server (Background with Logging)
```bash
./start-server.sh
```
Starts vLLM in background with logs at `/workspace/logs/vllm-server.log`

### Check Server Status
```bash
./check-server.sh
```
Shows PID, process info, port binding, and recent logs

### Stop Server
```bash
./stop-server.sh
```
Gracefully stops the vLLM server

### Monitor Logs
```bash
# Real-time log monitoring
tail -f /workspace/logs/vllm-server.log

# Last 50 lines
tail -50 /workspace/logs/vllm-server.log

# Search for errors
grep -i error /workspace/logs/vllm-server.log
```

## Test API (on RunPod, in a second SSH session)
```bash
# Already exists: test-api.sh
./test-api.sh
```

Or test from your Mac:
```bash
# Set API key (get from /workspace/logs/api-key.txt on pod)
export VLLM_API_KEY="sk-vllm-YOUR-KEY-HERE"
./test-api-local.sh
```

## Quick Test (one-liner)
```bash
# Get API key first
API_KEY=$(cat /workspace/logs/api-key.txt)

# Test completion
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
    "prompt": "def fibonacci(n):",
    "max_tokens": 100
  }'
```

## Server Info
- **Pod ID**: v5brcrgoclcp1p
- **Pod Name**: petite_coffee_koi
- **GPU**: RTX 6000 Ada (48 GB VRAM)
- **Model**: Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8 (30B parameters)
- **Quantization**: FP8 (pre-quantized, ~15GB download, ~30GB VRAM)
- **Context Window**: 128,768 tokens (128K)
- **API Port**: 8000
- **Cost**: $0.78/hour + $10/month storage (100GB)
- **vLLM Version**: 0.12.0
- **Public Endpoint**: https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1

## Storage Configuration
- **Container Disk**: 30 GB (temporary, for OS)
- **Volume Disk**: 100 GB (persistent, mounted at `/workspace`)
- **Network Pool**: 304 TB available (shared infrastructure)
- **Cache Location**: `/workspace/hf-cache` (models stored here)
- **Storage Cost**: $0.10/GB/month = $10/month for 100GB
- **Note**: After pod restart/reset, vLLM needs reinstalling but `/workspace` data persists

## Useful Endpoints
- Health: `http://localhost:8000/health`
- Models: `http://localhost:8000/v1/models`
- Completions: `http://localhost:8000/v1/completions`
- Chat: `http://localhost:8000/v1/chat/completions`
- Docs: `http://localhost:8000/docs`

## Get API Key
```bash
# On pod
cat /workspace/logs/api-key.txt
```

## Copy Files to Pod
Since SCP doesn't work via the proxy, you need to:
1. Open the file locally
2. SSH into pod: `./connect-runpod.sh`
3. Create file: `nano filename.sh`
4. Paste content
5. Save: Ctrl+O, Enter, Ctrl+X
6. Make executable: `chmod +x filename.sh`

## After Pod Restart/Reset

When you edit pod settings (like storage) or the pod resets, you need to reinstall vLLM:

```bash
# SSH into pod
./connect-runpod.sh

# Reinstall vLLM (5-10 minutes)
./install-vllm.sh

# Start server
./qwen.sh  # or ./gptoss.sh
```

**What's Preserved:**
- ✅ All files in `/workspace` (models, scripts, logs)
- ✅ HuggingFace cache (models don't re-download)
- ✅ Your scripts and configurations

**What's Lost:**
- ❌ Python packages (vLLM, etc.) - need reinstalling
- ❌ Running processes
- ❌ Files in `/root` or `/tmp`

## Model Options

### ✅ Qwen3-Coder-30B (Current - STABLE)
```bash
./qwen.sh
```
- **Status**: Production ready, working perfectly on RTX 6000 Ada
- **Context**: 128K tokens
- **VRAM**: ~30 GB (FP8 quantization)
- **Best for**: Coding tasks, stable production use

### ⚠️ GPT-OSS-20B (EXPERIMENTAL - Ada Lovelace support in progress)
```bash
./gptoss.sh
```
- **Status**: Ada Lovelace support under active development by vLLM team
- **Requirements**: vLLM >= 0.10.2, PyTorch with +cu128 suffix, CUDA >= 12.8
- **Context**: 32K tokens (conservative)
- **Note**: May fail or be unstable until Ada Lovelace officially supported
- **See**: `docs/setup/GPT-OSS-VLLM-OFFICIAL-GUIDE.md` for details

**Recommendation**: Use Qwen3-Coder-30B for stable production. Monitor vLLM releases for GPT-OSS Ada Lovelace support.

## Current Status
✅ Storage upgraded to 100GB
✅ Server running with Qwen3-Coder-30B-FP8
✅ Native tool/function calling support
✅ OpenAI-compatible API ready
✅ 128K context window enabled
✅ FP8 quantization for efficiency
⚠️ GPT-OSS-20B experimental on RTX 6000 Ada (Ada Lovelace support in progress)
