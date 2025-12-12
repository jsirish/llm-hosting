# GPT-OSS-20B on DigitalOcean – Cost-Optimized $0.76/hr Option

✅ **UPDATED: December 11, 2025 10:15 AM** - RTX 4000 ADA GPUs are **NOW AVAILABLE** on DigitalOcean! See [Availability Status](#availability-status) section below for current status.

This document details the **lowest-cost practical configuration** for hosting **GPT-OSS-20B** on DigitalOcean, designed specifically for:
- 1–3 concurrent users
- Coding assistance (Copilot-style usage)
- Open WebUI / LibreChat
- "Fallback" usage when GitHub Copilot credits are exhausted

----20B on DigitalOcean – Cost-Optimized $0.76/hr Option

This document details the **lowest-cost practical configuration** for hosting **GPT-OSS-20B** on DigitalOcean, designed specifically for:
- 1–3 concurrent users
- Coding assistance (Copilot-style usage)
- Open WebUI / LibreChat
- “Fallback” usage when GitHub Copilot credits are exhausted

---

## 1. Recommended Droplet

### DigitalOcean GPU Droplet: NVIDIA RTX 4000 Ada

| Component | Specification |
|--------|----------------|
| GPU | NVIDIA RTX 4000 Ada |
| GPU VRAM | **20 GB GDDR6** |
| vCPUs | 8 |
| System RAM | 32 GiB |
| Storage | 500 GB NVMe SSD |
| Network | 10 Gbps |
| Region | GPU-supported regions (e.g. NYC, TOR) |
| Cost | **$0.76 / hour** |

**Monthly Cost Estimates:**
- 24/7 operation (720 hrs): **~$547/month**
- Business hours only (160 hrs): **~$122/month**

✅ Lowest possible GPU cost on DigitalOcean
✅ Enough VRAM to run GPT-OSS-20B using 4-bit quantization
⚠️ Minimal headroom—must be configured carefully

---

## 2. Model Viability on This Hardware

**Model:** `openai/gpt-oss-20b`

### Why 20B Works Here
- GPT-OSS-20B supports **MXFP4 (4-bit) quantization**
- Effective model size fits in **~16 GB VRAM**
- Leaves ~4 GB VRAM available for:
  - KV cache
  - Small batch concurrency
  - Context windows up to ~8k tokens

### What This Means in Practice
- ✅ Works for **interactive coding help**
- ✅ Handles **1–2 concurrent requests smoothly**
- ⚠️ 3 concurrent users will increase latency
- ⚠️ Large prompts or long agent chains must be limited

This configuration **will not support GPT-OSS-120B**.

---

## 3. Software Stack (Recommended)

### Base OS
- Ubuntu 22.04 LTS

### Inference Server (Recommended)
**vLLM**
- Best memory efficiency
- Optimized for multi-user batching
- OpenAI API–compatible

Alternative:
- Hugging Face `transformers serve` (simpler, slightly slower)

---

## 4. Suggested vLLM Configuration

```bash
vllm serve openai/gpt-oss-20b \
  --quantization mxfp4 \
  --tensor-parallel-size 1 \
  --max-model-len 8192 \
  --gpu-memory-utilization 0.90
```

### Notes
- **Max context** kept at 8k for safety
- GPU memory utilization capped below 95%
- No tensor parallelism (single GPU)

---

## 5. API & UI Integration

### OpenAI-Compatible Endpoint
- Default: `http://localhost:8000/v1`
- Compatible with:
  - LibreChat
  - Open WebUI
  - VS Code AI extensions
  - Custom Copilot-like plugins

---

## 6. Expected Performance

### Latency
- First token: ~1–2 seconds
- Steady generation: ~20–30 tokens/sec (single user)

### Concurrency

| Users | Experience |
|------|-----------|
| 1 | Very responsive |
| 2 | Slightly slower, still usable |
| 3 | Noticeable latency |
| 4+ | Not recommended |

---

## 7. Cost-Control Strategy (Strongly Recommended)

### DO NOT simply power off the droplet
DigitalOcean bills for powered-off droplets.

### Best Practice
- **Create droplet when needed**
- **Destroy when done**
- Store model weights on a volume snapshot or prebuilt custom image

---

## Summary

The **$0.76/hr RTX 4000 Ada droplet** is the **minimum viable production setup** for running GPT-OSS-20B on DigitalOcean.

---

## Availability Status

**Last Checked:** December 11, 2025 at 10:15 AM EST

### Current GPU Availability on DigitalOcean:

| GPU Model | Hourly Cost | VRAM | Status | Notes |
|-----------|-------------|------|--------|-------|
| **RTX 4000 ADA** | **$0.76/hr** | 20 GB | ⚠️ **LIMITED** | Only available in TOR1, may not be accessible to all accounts |
| L40S | $1.57/hr | 48 GB | ⚠️ **LIMITED** | Limited availability |
| RTX 6000 ADA | $1.57/hr | 48 GB | ⚠️ **LIMITED** | Limited availability |
| H100 | $3.39/hr | 80 GB | ⚠️ **LIMITED** | Limited availability |
| H200 | $3.44/hr | 141 GB | ⚠️ **LIMITED** | Limited availability |

**Regions with RTX 4000 ADA Available:**
- ❌ NYC2 (New York Datacenter 2) - Not accessible
- ❌ ATL1 (Atlanta Datacenter 1) - Not accessible
- ⚠️ TOR1 (Toronto Datacenter 1) - **API shows available, but may have account restrictions**
- ❌ NYC3 (New York Datacenter 3) - Not accessible

**Note:** The monitoring script shows API-level availability, but actual droplet creation may be restricted by account permissions, quota limits, or regional access. DigitalOcean GPU Droplets often have waitlists or require approval.

**Quick Deploy Link:** [Create RTX 4000 ADA GPU Droplet](https://cloud.digitalocean.com/gpus/new?size=gpu-4000adax1-20gb)

### Alternative Cloud Providers (Similar Price Range):

| Provider | GPU Model | Hourly Cost | VRAM | Notes |
|----------|-----------|-------------|------|-------|
| **RunPod** | RTX A4000 | ~$0.34/hr | 16 GB | Community Cloud pricing |
| **RunPod** | RTX A5000 | ~$0.44/hr | 24 GB | Better for 20B models |
| **Vast.ai** | Various GPUs | $0.20-0.80/hr | Varies | Spot pricing, variable availability |
| **Paperspace** | RTX A4000 | ~$0.76/hr | 16 GB | Similar to DO target pricing |
| **Lambda Labs** | RTX A6000 | ~$0.80/hr | 48 GB | When available |

### ⚠️ Limited Availability - Consider Alternatives

The RTX 4000 ADA shows as available in the API (TOR1 region only), but actual droplet creation may be restricted:

**Issues Discovered:**
- API reports availability, but web interface may not allow creation
- Possible account restrictions or waitlist requirements
- Regional access limitations

**Recommended Action:** Proceed with **RunPod** as the primary option (see `Alternative-GPU-Providers.md`)

### Monitoring Script Note

📝 **TODO:** The current monitoring script (`check-do-gpu-availability.sh`) needs enhancement:
- Currently checks API-level size availability (which may not reflect actual access)
- Should be updated to attempt actual droplet creation validation
- Need to add account quota/permission checking
- Consider using DigitalOcean's droplet creation dry-run if available

### Next Steps:

**Option A (Recommended):** Deploy on RunPod RTX 6000 Ada @ $0.74/hr (see `Alternative-GPU-Providers.md`)
**Option B:** Try DigitalOcean deployment if you have GPU Droplet access approved

---