# GPT-OSS-20B Environment Verification Checklist

**Purpose:** Verify your environment meets the requirements before attempting GPT-OSS-20B deployment.

**Date:** December 13, 2025

---

## Pre-Deployment Verification

### 1. Check vLLM Version

**Requirement:** vLLM >= 0.10.2 (>= 0.11.1 recommended for `--async-scheduling`)

```bash
python -c "import vllm; print(vllm.__version__)"
```

**Expected Output:**
```
0.10.2
# or higher (e.g., 0.11.1, 0.12.0)
```

**If version is too old:**
```bash
pip install --upgrade vllm
```

---

### 2. Check PyTorch Version (CRITICAL)

**Requirement:** PyTorch with `+cu128` suffix

```bash
python -c "import torch; print(torch.__version__)"
```

**Expected Output:**
```
2.9.0+cu128
# or similar version with +cu128 suffix
```

**❌ WRONG (missing +cu128):**
```
2.9.0
2.8.0+cu121
```

**If missing +cu128 suffix:**
```bash
pip uninstall torch
pip install torch --index-url https://download.pytorch.org/whl/cu128
```

---

### 3. Check CUDA Version

**Requirement:** CUDA >= 12.8

```bash
nvcc --version
```

**Expected Output:**
```
cuda_12.8.r12.8
# or higher (e.g., 12.9, 13.0)
```

**If CUDA is too old:**
- Update GPU drivers on your instance
- May require pod/instance restart
- Contact your cloud provider if CUDA update fails

---

### 4. Check GPU Type

**Requirement:** Check if your GPU is in the supported list

```bash
nvidia-smi --query-gpu=name --format=csv,noheader
```

**Fully Supported:**
- NVIDIA H100
- NVIDIA H200
- NVIDIA B200
- AMD MI300x
- AMD MI325x

**In Progress (Experimental):**
- ⚠️ NVIDIA RTX 6000 Ada (our target GPU)
- NVIDIA A100
- NVIDIA A6000
- NVIDIA RTX 5090

**If using Ada Lovelace (RTX 6000 Ada):**
- Deployment may be unstable
- Be prepared to use Qwen3-Coder-30B as fallback
- Monitor logs closely for errors
- See troubleshooting guide if issues occur

---

### 5. Check Available VRAM

**Requirement:** Minimum 20 GB VRAM (48 GB recommended)

```bash
nvidia-smi --query-gpu=memory.total --format=csv,noheader
```

**Expected Output:**
```
49140 MiB
# or higher (48+ GB)
```

**Minimum for GPT-OSS-20B:**
- With quantization: ~16-20 GB VRAM
- Without quantization: ~40 GB VRAM
- Recommended: 48 GB (RTX 6000 Ada)

---

### 6. Check Available Disk Space

**Requirement:** Minimum 50 GB free space (model weights ~40 GB)

```bash
df -h /workspace
```

**Expected Output:**
```
Available: 100G or more
```

**If insufficient space:**
- Clear HuggingFace cache: `rm -rf /workspace/hf-cache/*`
- Remove old model downloads
- Check pod configuration for larger storage

---

## Pre-Deployment Checklist Summary

Before running `./gptoss.sh`, verify:

- [ ] vLLM version >= 0.10.2 ✅
- [ ] PyTorch has `+cu128` suffix ✅ (CRITICAL)
- [ ] CUDA version >= 12.8 ✅
- [ ] GPU is supported (or experimental) ✅
- [ ] Available VRAM >= 20 GB ✅
- [ ] Available disk space >= 50 GB ✅

**All checks passed?** → Proceed with deployment

**Any checks failed?** → Fix the issue before deploying (see troubleshooting section below)

---

## Troubleshooting Failed Checks

### vLLM Too Old

```bash
pip install --upgrade vllm
# Verify
python -c "import vllm; print(vllm.__version__)"
```

### PyTorch Missing +cu128

```bash
pip uninstall torch
pip install torch --index-url https://download.pytorch.org/whl/cu128
# Verify
python -c "import torch; print(torch.__version__)"
```

### CUDA Too Old

Contact your cloud provider or:
1. Update GPU drivers
2. Restart instance
3. Verify with `nvcc --version`

### Insufficient VRAM

Options:
1. Use a larger GPU (48 GB recommended)
2. Enable quantization (reduces VRAM usage)
3. Reduce context length in `gptoss.sh`

### Insufficient Disk Space

```bash
# Clear HuggingFace cache
rm -rf /workspace/hf-cache/*

# Or move cache to larger volume
export HF_HOME=/path/to/larger/volume
```

---

## After Verification

### Ready to Deploy?

```bash
# Run the GPT-OSS deployment script
cd /home/runner/work/llm-hosting/llm-hosting
./models/gptoss.sh
```

### Monitor Deployment

```bash
# Watch logs in real-time
tail -f /workspace/logs/vllm-server.log
```

**Expected startup time:**
- First run: 10-15 minutes (model download)
- Subsequent runs: 2-5 minutes (from cache)

---

## Stable Alternative (Recommended)

If any checks fail or deployment is unstable, use the proven alternative:

```bash
# Qwen3-Coder-30B - Working on RTX 6000 Ada
./models/qwen.sh
```

**Benefits:**
- ✅ Works perfectly on Ada Lovelace
- ✅ 128K context (vs 32K for GPT-OSS)
- ✅ No experimental dependencies
- ✅ Proven stable in production

---

## References

- **Official Guide:** `docs/setup/GPT-OSS-VLLM-OFFICIAL-GUIDE.md`
- **Troubleshooting:** `docs/troubleshooting/GPT-OSS-TROUBLESHOOTING.md`
- **vLLM Docs:** https://docs.vllm.ai/
- **vLLM GPT-OSS Recipe:** https://docs.vllm.ai/projects/recipes/en/latest/OpenAI/GPT-OSS.html

---

**Last Updated:** December 13, 2025
