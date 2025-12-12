# GPT-OSS-20B Troubleshooting Guide

**Date**: December 11, 2025
**Model**: openai/gpt-oss-20b
**Status**: Model available, troubleshooting initialization issues

---

## Issue: Server Crashes During Startup

### Symptoms
- Model downloads successfully (~21GB)
- Process starts but crashes during initialization
- No processes found in `nvidia-smi`
- GPU memory shows only 2MiB used

### Root Cause Analysis

From logs, we see GPT-OSS is automatically applying **MX FP4 quantization**:
```
quantization=mxfp4
Using Marlin backend
```

This experimental quantization may be unstable with:
- Large context windows (128K)
- 20B parameter models
- CUDA graph compilation

---

## Solutions to Try (In Order)

### 1. ✅ Reduce Context Window (DONE)
**Current**: 32K tokens (down from 128K)

```bash
export VLLM_MAX_MODEL_LEN=32768
```

### 2. ✅ Lower GPU Memory Utilization (DONE)
**Current**: 0.85 (down from 0.95)

```bash
export VLLM_GPU_MEMORY_UTIL=0.85
```

### 3. 🔄 Try Different Quantization Settings

#### Option A: Disable Quantization (Use Full Precision)
```bash
# Edit gptoss.sh
export VLLM_QUANTIZATION="none"
```
**Pros**: Most stable
**Cons**: Uses ~40GB VRAM (may be tight on 48GB GPU)

#### Option B: Try FP8 Quantization (Like Qwen)
```bash
# Edit gptoss.sh
export VLLM_QUANTIZATION="fp8"
```
**Pros**: Stable, well-tested quantization
**Cons**: May not work if model doesn't support FP8

#### Option C: Try AWQ Quantization
```bash
# Edit gptoss.sh
export VLLM_QUANTIZATION="awq"
```
**Pros**: Good balance of size/performance
**Cons**: Requires AWQ-quantized weights

### 4. 🔄 Further Reduce Context
If still crashing, try even smaller context:

```bash
export VLLM_MAX_MODEL_LEN=16384  # 16K
# or
export VLLM_MAX_MODEL_LEN=8192   # 8K
```

### 5. 🔄 Disable CUDA Graphs
Add to start command in `start-vllm-server.sh`:

```bash
--enforce-eager
```

This disables CUDA graph compilation (slower but more stable).

---

## Diagnostic Commands

### Check Last Error
```bash
tail -100 /workspace/logs/vllm-server.log
```

### Look for Specific Errors
```bash
grep -E "error|Error|ERROR|failed|Failed|OOM|CUDA" /workspace/logs/vllm-server.log | tail -20
```

### Check Model Download
```bash
du -sh /workspace/hf-cache/hub/models--openai--gpt-oss-20b/
```

### Monitor GPU During Startup
```bash
watch -n 1 nvidia-smi
```

---

## Updated Scripts

### Generic Server (`start-vllm-server.sh`)
Now supports `VLLM_QUANTIZATION` environment variable:
- Empty string `""`: Auto-detect from model
- `"none"`: No quantization (full precision)
- `"fp8"`: FP8 quantization
- `"awq"`: AWQ quantization
- `"gptq"`: GPTQ quantization

### GPT-OSS Config (`gptoss.sh`)
Current conservative settings:
```bash
export VLLM_MODEL="openai/gpt-oss-20b"
export VLLM_MAX_MODEL_LEN=32768       # 32K context
export VLLM_GPU_MEMORY_UTIL=0.85      # 85% GPU memory
export VLLM_TOOL_PARSER="openai"
export VLLM_QUANTIZATION=""           # Auto-detect
```

---

## Testing Strategy

### Step 1: Try Current Settings (32K, Auto Quantization)
```bash
./stop-server.sh
./gptoss.sh
# Wait 5-10 minutes, check logs
```

### Step 2: If Failed, Try No Quantization
```bash
# Edit gptoss.sh
export VLLM_QUANTIZATION="none"
export VLLM_MAX_MODEL_LEN=16384  # Reduce to 16K for safety

./stop-server.sh
./gptoss.sh
```

### Step 3: If Failed, Try Minimal Config
```bash
# Edit gptoss.sh
export VLLM_MAX_MODEL_LEN=8192
export VLLM_GPU_MEMORY_UTIL=0.75

./stop-server.sh
./gptoss.sh
```

### Step 4: If Still Failed, Check Compatibility
The model may require:
- Specific vLLM version
- Special dependencies
- Model-specific patches

---

## Expected Behavior When Working

### Successful Startup Logs
```
INFO: Starting to load model openai/gpt-oss-20b...
INFO: Loading weights...
INFO: Model weights loaded successfully
INFO: Capturing CUDA graphs...
INFO: Capturing cudagraphs... done
INFO: Application startup complete
```

### GPU Memory Usage
- **With quantization**: 15-25GB
- **Without quantization**: 35-45GB

### Startup Time
- First time (with download): 10-20 minutes
- Subsequent starts: 3-5 minutes

---

## Comparison with Qwen

| Aspect | Qwen3-Coder-30B | GPT-OSS-20B |
|--------|-----------------|-------------|
| Parameters | 30B | 20B |
| Quantization | Pre-quantized FP8 | Runtime MX FP4 (auto) |
| Context (working) | 128K | TBD (testing 32K) |
| VRAM Usage | ~30GB | TBD (~20-40GB) |
| Stability | ✅ Excellent | 🔄 Testing |
| Startup Time | ~3 min | ~5-10 min |

---

## Alternative: Switch Back to Qwen

If GPT-OSS proves unstable, Qwen is production-ready:

```bash
./stop-server.sh
./qwen.sh  # Reliable, 128K context, proven working
```

---

## Common Error Patterns

### Error: "CUDA out of memory"
**Solution**: Reduce context length or enable quantization

### Error: "Failed to load weights"
**Solution**: Check model download completed, try lower GPU memory util

### Error: "Compilation failed"
**Solution**: Add `--enforce-eager` flag to disable CUDA graphs

### Error: "AssertionError" or "RuntimeError"
**Solution**: Check logs for specific error, may be model incompatibility

---

## Next Steps

1. ✅ Updated scripts to support quantization control
2. 🔄 Test current conservative settings (32K context)
3. 🔄 Check logs for specific error
4. 🔄 Adjust quantization based on error
5. 🔄 Report findings and working configuration

---

**Status**: Scripts updated, ready for testing
**Last Updated**: December 11, 2025
