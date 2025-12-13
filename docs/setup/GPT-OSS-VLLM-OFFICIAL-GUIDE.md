# GPT-OSS-20B Official vLLM Deployment Guide

**Date:** December 13, 2025  
**Source:** [vLLM GPT-OSS Recipe](https://docs.vllm.ai/projects/recipes/en/latest/OpenAI/GPT-OSS.html)  
**Status:** Official deployment instructions from vLLM team

---

## Overview

This guide documents the **official vLLM deployment instructions** for GPT-OSS-20B based on the vLLM team's recipe documentation. Use this as the authoritative reference for GPT-OSS deployment.

---

## GPU Support Status

### ✅ Fully Supported GPUs

These GPUs have **complete, production-ready support**:

- **H100** (80 GB VRAM)
- **H200** (141 GB VRAM)
- **B200** (future)
- **AMD MI300x** (192 GB HBM3)
- **AMD MI325x** (256 GB HBM3)
- **AMD MI355x** (future)

### 🔄 In Progress / Experimental

These GPUs are **under active development** by the vLLM team:

- **Ampere Architecture** (A100, A6000, etc.)
- **Ada Lovelace Architecture** ⚠️ **RTX 6000 Ada (our target GPU)**
- **RTX 5090** (consumer Blackwell)

**Important:** The vLLM team states they are "actively working" on Ada Lovelace support, but it is **not yet production-ready** as of vLLM 0.10.2.

### ❌ Known Issues

- **Ada Lovelace GPUs may experience deployment failures**
- Previous error encountered: `torch==2.9.0.dev20250804+cu128` unavailable
- Model may fail to load due to missing architecture support

---

## Version Requirements

### Critical Dependencies

| Component | Requirement | Notes |
|-----------|-------------|-------|
| **vLLM** | >= 0.10.2 | Required for `--tool-call-parser openai` flag |
| **PyTorch** | Must have `+cu128` suffix | Example: `2.9.0+cu128` |
| **CUDA** | >= 12.8 | Must match during installation AND serving |
| **Recommended vLLM** | >= 0.11.1 | For `--async-scheduling` performance improvements |

### Verify Your Environment

```bash
# 1. Check PyTorch version (MUST have +cu128 suffix)
python -c "import torch; print(torch.__version__)"
# Should output: 2.9.0+cu128 or similar

# 2. Check CUDA version (MUST be >= 12.8)
nvcc --version
# Should show CUDA 12.8 or higher

# 3. Check vLLM version
python -c "import vllm; print(vllm.__version__)"
# Should show: 0.10.2 or higher
```

---

## Recommended Deployment Configuration

### For A100 GPUs (Fully Supported)

Since Ada Lovelace support is still in progress, use this configuration on A100 if available:

```bash
# GPT-OSS-20B - Single GPU Configuration
vllm serve openai/gpt-oss-20b \
  --async-scheduling \
  --tool-call-parser openai \
  --enable-auto-tool-choice \
  --max-model-len 32768 \
  --gpu-memory-utilization 0.90
```

### For Ada Lovelace GPUs (Experimental)

If deploying on RTX 6000 Ada (our current hardware), start conservatively:

```bash
# GPT-OSS-20B - Ada Lovelace Experimental Configuration
vllm serve openai/gpt-oss-20b \
  --tool-call-parser openai \
  --enable-auto-tool-choice \
  --max-model-len 16384 \
  --gpu-memory-utilization 0.85 \
  --enforce-eager
```

**Note:** Removed `--async-scheduling` and reduced context until stability is confirmed.

---

## Key Flags Explained

### `--async-scheduling`

- **Purpose:** Higher performance, reduces host overheads
- **Requirement:** vLLM >= 0.11.1 recommended
- **Status:** May not work on Ada Lovelace yet
- **Trade-off:** Better throughput vs. stability

### `--tool-call-parser openai`

- **Purpose:** Native OpenAI tool calling format
- **Requirement:** vLLM >= 0.10.2
- **Benefit:** Compatible with OpenAI SDK and clients

### `--enable-auto-tool-choice`

- **Purpose:** Automatic tool selection based on context
- **Benefit:** Smarter function calling decisions
- **Use Case:** Agentic workflows, code assistants

### `--enforce-eager`

- **Purpose:** Disables CUDA graph compilation
- **When to Use:** Troubleshooting crashes, experimental GPUs
- **Trade-off:** More stable but slower performance

---

## Troubleshooting

### Issue: PyTorch CUDA Version Mismatch

**Error Message:**
```
The link interface of target 'torch::nvtoolsext' contains: CUDA::nvToolsExt but the target was not found
```

**Cause:** PyTorch version doesn't have `+cu128` suffix

**Solution:**
```bash
# Verify PyTorch version
python -c "import torch; print(torch.__version__)"

# If missing +cu128, reinstall with correct CUDA version
pip uninstall torch
pip install torch --index-url https://download.pytorch.org/whl/cu128
```

### Issue: CUDA Version Too Old

**Error Message:**
```
CUDA 12.8 or higher is required
```

**Cause:** System CUDA toolkit is older than 12.8

**Solution:**
1. Update CUDA drivers on your GPU instance
2. Verify with `nvcc --version`
3. Ensure installation and serving use the same CUDA version

### Issue: Model Won't Load on Ada Lovelace

**Error Message:**
```
Model architecture not supported on this GPU
```

**Cause:** Ada Lovelace support is still in development

**Solution Options:**
1. **Wait for official support:** Monitor vLLM releases
2. **Use A100 instead:** Switch to fully supported GPU
3. **Try alternative model:** Qwen3-Coder-30B is working and stable

### Issue: vLLM Version Too Old

**Error Message:**
```
unrecognized arguments: --tool-call-parser
```

**Cause:** vLLM version < 0.10.2

**Solution:**
```bash
pip install --upgrade vllm
# Verify version is >= 0.10.2
python -c "import vllm; print(vllm.__version__)"
```

---

## Previous Deployment Issues

### Historical Context (Dec 2024)

**What Happened:**
- Attempted to deploy GPT-OSS-20B on RTX 6000 Ada (RunPod)
- Encountered error: `torch==2.9.0.dev20250804+cu128` unavailable
- Model was unavailable due to missing dependencies

**Root Cause:**
- Ada Lovelace support was not ready
- PyTorch nightly build with specific CUDA version not available
- Model architecture support incomplete

**Current Status:**
- vLLM team is "actively working" on Ada Lovelace support
- No ETA provided for production readiness
- Recommended to wait for official announcement

---

## Alternative: Stable Production Model

### Qwen3-Coder-30B (Currently Working)

If you need a working solution now:

```bash
# Qwen3-Coder-30B - Production Ready
vllm serve Qwen/Qwen2.5-Coder-32B-Instruct \
  --max-model-len 131072 \
  --gpu-memory-utilization 0.95 \
  --enable-prefix-caching
```

**Benefits:**
- ✅ Works on Ada Lovelace (RTX 6000 Ada)
- ✅ 128K context window (vs 32K for GPT-OSS)
- ✅ Proven stable in production
- ✅ Excellent for coding tasks

**Trade-offs:**
- ❌ Larger model (30B vs 20B)
- ❌ No native OpenAI tool calling format
- ✅ But tool use still works via standard methods

---

## Monitoring for Ada Lovelace Support

### How to Track Updates

1. **Watch vLLM Releases:**
   - https://github.com/vllm-project/vllm/releases
   - Look for Ada Lovelace in release notes

2. **Check GPU Support Documentation:**
   - https://docs.vllm.ai/en/latest/getting_started/installation.html
   - GPU compatibility matrix

3. **Monitor GPT-OSS Recipe Updates:**
   - https://docs.vllm.ai/projects/recipes/en/latest/OpenAI/GPT-OSS.html
   - Official deployment guide updates

### Action Items

- [ ] Verify vLLM version on RunPod (need >= 0.10.2)
- [ ] Check PyTorch version has correct `+cu128` suffix
- [ ] Try A100 configuration with async-scheduling (if A100 available)
- [ ] Monitor vLLM releases for Ada Lovelace support announcement
- [ ] Consider using Qwen3-Coder-30B as current stable alternative

---

## Recommendation

### Short Term (Now)

**Use Qwen3-Coder-30B** - It's working, stable, and excellent for coding tasks.

```bash
# Already deployed and tested on RTX 6000 Ada
./qwen.sh
```

### Medium Term (When Ada Support Ships)

**Try GPT-OSS-20B** with the official vLLM configuration once Ada Lovelace support is announced.

### Long Term (Production)

**Evaluate both models** based on:
- Tool calling requirements
- Context window needs (128K vs 32K)
- Performance characteristics
- Cost considerations

---

## References

- **vLLM GPT-OSS Recipe:** https://docs.vllm.ai/projects/recipes/en/latest/OpenAI/GPT-OSS.html
- **vLLM 0.10.2 Release:** https://github.com/vllm-project/vllm/releases/tag/v0.10.2
- **GPT-OSS Model Card:** https://huggingface.co/openai/gpt-oss-20b
- **Previous Deployment Docs:** `archive/docs/GPT-OSS-*.md`

---

**Last Updated:** December 13, 2025  
**Status:** Ada Lovelace support in progress - recommend waiting or using alternative GPU
