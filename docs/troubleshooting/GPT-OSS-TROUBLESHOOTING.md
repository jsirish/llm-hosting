# GPT-OSS-20B Troubleshooting Guide

**Date**: December 13, 2025 (Updated)
**Model**: openai/gpt-oss-20b
**Status**: Ada Lovelace support in progress, version requirements documented

---

## ⚠️ Ada Lovelace Support Status (UPDATED)

### Official vLLM Documentation Findings

Based on the [official vLLM GPT-OSS recipe](https://docs.vllm.ai/projects/recipes/en/latest/OpenAI/GPT-OSS.html):

**GPU Support Status:**
- ✅ **Fully Supported**: H100, H200, B200, AMD MI300x/MI325x/MI355x
- 🔄 **In Progress**: Ampere, **Ada Lovelace (RTX 6000 Ada)**, RTX 5090
- ⚠️ **Our GPU**: RTX 6000 Ada is NOT yet production-ready

**What This Means:**
- vLLM team is "actively working" on Ada Lovelace support
- Deployment on RTX 6000 Ada may fail or be unstable
- No ETA provided for production readiness
- Recommended to wait for official support announcement OR use A100

### Version Requirements

| Component | Requirement | Why |
|-----------|-------------|-----|
| **vLLM** | >= 0.10.2 | Required for `--tool-call-parser openai` flag |
| **vLLM (recommended)** | >= 0.11.1 | For `--async-scheduling` performance |
| **PyTorch** | Must have `+cu128` suffix | Example: `2.9.0+cu128` |
| **CUDA** | >= 12.8 | Must match during installation AND serving |

**Critical:** PyTorch MUST have the `+cu128` suffix or you'll get linker errors.

---

## Quick Verification Commands

Before attempting deployment, verify your environment:

```bash
# 1. Check PyTorch version (MUST show +cu128)
python -c "import torch; print(torch.__version__)"
# Expected: 2.9.0+cu128 or similar

# 2. Check CUDA version (MUST be >= 12.8)
nvcc --version
# Expected: CUDA 12.8 or higher

# 3. Check vLLM version (MUST be >= 0.10.2)
python -c "import vllm; print(vllm.__version__)"
# Expected: 0.10.2 or higher
```

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

### 3. ✅ Use Official vLLM Configuration (RECOMMENDED)

According to the [official vLLM documentation](https://docs.vllm.ai/projects/recipes/en/latest/OpenAI/GPT-OSS.html), use this configuration for A100 (or try on Ada Lovelace):

```bash
vllm serve openai/gpt-oss-20b \
  --async-scheduling \
  --tool-call-parser openai \
  --enable-auto-tool-choice \
  --max-model-len 32768 \
  --gpu-memory-utilization 0.90
```

**For Ada Lovelace (Experimental):**
```bash
# Start conservative without --async-scheduling
vllm serve openai/gpt-oss-20b \
  --tool-call-parser openai \
  --enable-auto-tool-choice \
  --max-model-len 16384 \
  --gpu-memory-utilization 0.85 \
  --enforce-eager
```

**Key Flags:**
- `--async-scheduling`: Higher performance (requires vLLM >= 0.11.1)
- `--tool-call-parser openai`: Native OpenAI format (requires vLLM >= 0.10.2)
- `--enable-auto-tool-choice`: Automatic tool selection
- `--enforce-eager`: Disable CUDA graphs (more stable on unsupported GPUs)

### 4. 🔄 Further Reduce Context
If still crashing, try even smaller context:

```bash
export VLLM_MAX_MODEL_LEN=16384  # 16K
# or
export VLLM_MAX_MODEL_LEN=8192   # 8K
```

### 5. 🔄 Try Different Quantization Settings

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

### 6. 🔄 Disable CUDA Graphs
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

### Error: PyTorch CUDA Version Mismatch

**Full Error Message:**
```
The link interface of target 'torch::nvtoolsext' contains: CUDA::nvToolsExt but the target was not found
```

**Root Cause:** PyTorch version doesn't have the `+cu128` suffix

**Solution:**
```bash
# 1. Verify PyTorch version
python -c "import torch; print(torch.__version__)"

# 2. If missing +cu128, reinstall with correct CUDA version
pip uninstall torch
pip install torch --index-url https://download.pytorch.org/whl/cu128

# 3. Verify again
python -c "import torch; print(torch.__version__)"
# Should now show: 2.x.x+cu128
```

### Error: PyTorch Dev Version Unavailable

**Full Error Message:**
```
ERROR: Could not find a version that satisfies the requirement torch==2.9.0.dev20250804+cu128
```

**Root Cause:** Trying to install a specific nightly build that no longer exists

**Solution:**
```bash
# Install latest stable PyTorch with CUDA 12.8
pip install torch --index-url https://download.pytorch.org/whl/cu128

# Or install latest nightly (if needed)
pip install --pre torch --index-url https://download.pytorch.org/whl/nightly/cu128
```

### Error: "CUDA out of memory"
**Solution**: Reduce context length or enable quantization

### Error: "Failed to load weights"
**Solution**: Check model download completed, try lower GPU memory util

### Error: "Compilation failed"
**Solution**: Add `--enforce-eager` flag to disable CUDA graphs

### Error: "AssertionError" or "RuntimeError"
**Solution**: Check logs for specific error, may be model incompatibility

### Error: vLLM Flag Not Recognized

**Full Error Message:**
```
error: unrecognized arguments: --tool-call-parser
```

**Root Cause:** vLLM version is older than 0.10.2

**Solution:**
```bash
# Update vLLM to latest version
pip install --upgrade vllm

# Verify version
python -c "import vllm; print(vllm.__version__)"
# Should show: 0.10.2 or higher
```

### Error: CUDA Version Too Old

**Full Error Message:**
```
RuntimeError: CUDA 12.8 or higher is required
```

**Root Cause:** System CUDA toolkit is older than 12.8

**Solution:**
1. Update CUDA drivers on your GPU instance
2. Verify with `nvcc --version`
3. Ensure installation and serving use the same CUDA version
4. May need to restart pod/instance after driver update

---

## Monitoring for Ada Lovelace Support

### How to Track Updates

1. **Watch vLLM Releases:**
   - https://github.com/vllm-project/vllm/releases
   - Look for "Ada Lovelace" in release notes

2. **Check GPU Support Documentation:**
   - https://docs.vllm.ai/en/latest/getting_started/installation.html
   - GPU compatibility matrix

3. **Monitor GPT-OSS Recipe:**
   - https://docs.vllm.ai/projects/recipes/en/latest/OpenAI/GPT-OSS.html
   - Official deployment guide updates

### Action Items

- [ ] Verify vLLM version on RunPod (need >= 0.10.2)
- [ ] Check PyTorch version has correct `+cu128` suffix
- [ ] Try A100 configuration with async-scheduling (if A100 available)
- [ ] Monitor vLLM releases for Ada Lovelace support announcement
- [ ] Consider using Qwen3-Coder-30B as current stable alternative

---

## Recommended Alternative: Qwen3-Coder-30B

While waiting for Ada Lovelace support, use the proven stable alternative:

```bash
# Qwen3-Coder-30B - Working on RTX 6000 Ada
./qwen.sh
```

**Benefits:**
- ✅ Works perfectly on Ada Lovelace (RTX 6000 Ada)
- ✅ 128K context window (4x larger than GPT-OSS's 32K)
- ✅ Proven stable in production
- ✅ Excellent for coding tasks
- ✅ No experimental dependencies

**See:** `docs/setup/GPT-OSS-VLLM-OFFICIAL-GUIDE.md` for full comparison

---

## Next Steps

1. ✅ Updated scripts with Ada Lovelace warnings
2. ✅ Documented version requirements
3. ✅ Added official vLLM configuration
4. 🔄 Wait for Ada Lovelace support announcement OR
5. 🔄 Use Qwen3-Coder-30B as stable production alternative
6. 🔄 Monitor vLLM releases for updates

---

## Additional Resources

- **Official vLLM GPT-OSS Guide:** `docs/setup/GPT-OSS-VLLM-OFFICIAL-GUIDE.md`
- **vLLM Recipe:** https://docs.vllm.ai/projects/recipes/en/latest/OpenAI/GPT-OSS.html
- **vLLM Releases:** https://github.com/vllm-project/vllm/releases
- **Archive:** Previous deployment attempts in `archive/docs/GPT-OSS-*.md`

---

**Status**: Ada Lovelace support in progress - recommend waiting or using Qwen alternative
**Last Updated**: December 13, 2025
