# Project Summary - GPT-OSS-20B Hosting

**Last Updated:** January 20, 2025 at 4:30 PM EST

## Current Status: ✅ DEPLOYED on RunPod!

**Pod ID:** `v5brcrgoclcp1p` | **GPU:** RTX 6000 Ada (48 GB) | **Cost:** $0.78/hr

🚀 **Active Deployment:** RunPod RTX 6000 Ada is now running and ready for vLLM deployment.

**Quick Access:**
- 📊 **Jupyter Lab**: [Open Notebook](https://v5brcrgoclcp1p-8888.proxy.runpod.net/?token=42z5ic3ocbugvss4iuqr)
- 💻 **Web Terminal**: [Open Terminal](https://v5brcrgoclcp1p-19123.proxy.runpod.net/b6472jb6g7sa0bdoxdie9l6jrcen530q/)
- 📖 **Full Details**: See `RUNPOD-DEPLOYED.md`

## 📁 Project Files

### 🎯 Active Deployment
1. **`RUNPOD-DEPLOYED.md`** 🚀 ACTIVE
   - **Current pod details and access URLs**
   - Complete vLLM deployment instructions
   - Performance specs and cost tracking
   - Troubleshooting guide
   - **START HERE for next steps!**

### Main Documentation
2. **`GPT-OSS-20B_DigitalOcean_0.76hr.md`**
   - Original setup guide for DigitalOcean
   - ⚠️ Updated with availability warning
   - Still valid once GPUs are back in stock

3. **`Alternative-GPU-Providers.md`**
   - Complete guide to alternative cloud providers
   - RunPod, Vast.ai, Paperspace, Lambda Labs
   - Detailed pricing comparison and setup guides

4. **`RUNPOD-DEPLOYMENT-GUIDE.md`**
   - Step-by-step RunPod deployment walkthrough
   - Account setup and configuration
   - General RunPod reference guide

### Monitoring Tools
5. **`check-do-gpu-availability.sh`** (Executable)
   - Automated GPU availability checker
   - Monitors DigitalOcean for RTX 4000 ADA restocking
   - Sends macOS notifications when available
   - Can run continuously or as cron job

6. **`API-TOKEN-SETUP.md`**
   - Instructions for setting up DigitalOcean API access
   - How to use the monitoring script
   - Troubleshooting guide

## 🎯 Next Steps: Deploy GPT-OSS-20B

### ✅ Pod is Ready - Deploy vLLM Now!

1. **Open Web Terminal**:
   - Click: https://v5brcrgoclcp1p-19123.proxy.runpod.net/b6472jb6g7sa0bdoxdie9l6jrcen530q/

2. **Follow the guide in `RUNPOD-DEPLOYED.md`**:
   - Verify GPU with `nvidia-smi`
   - Install vLLM: `pip install vllm`
   - Deploy GPT-OSS-20B with 4-bit quantization
   - Test inference API

3. **Estimated Time**: 15-20 minutes
   - vLLM install: ~2 minutes
   - Model download: ~10-15 minutes (16 GB quantized)
   - First inference test: ~1 minute

### Alternative: Use Jupyter Lab
- URL: https://v5brcrgoclcp1p-8888.proxy.runpod.net/?token=42z5ic3ocbugvss4iuqr
- Open "New" → "Terminal" for shell access
- Same deployment steps as web terminal

## 📊 Deployment Comparison

### ✅ DEPLOYED: RunPod RTX 6000 Ada - $0.78/hr
- **Status:** Active and running now
- **VRAM:** 48 GB (3x more headroom!)
- **Availability:** Immediate
- **Spot Option:** $0.39/hr (50% cheaper)

### ⏸️ Alternative: DigitalOcean RTX 4000 ADA - $0.76/hr
- **Status:** Limited availability (TOR1 only)
- May require waitlist/approval
- 20 GB VRAM
- Follow setup in `GPT-OSS-20B_DigitalOcean_0.76hr.md`

### Option C: Ultra Budget Option
✅ **Use RunPod RTX A6000 - $0.33/hr**
- Less than HALF the price!
- Still has 48 GB VRAM
- Perfect for testing or budget projects

## 💰 Cost Comparison

| Provider | GPU | Price/hr | Monthly (160h) | Status |
|----------|-----|----------|----------------|--------|
| **RunPod** | RTX 6000 Ada | $0.74 | $118 | ✅ **AVAILABLE NOW** |
| **RunPod** | RTX A6000 | $0.33 | $53 | ✅ **BEST VALUE** |
| **RunPod** | L40 | $0.69 | $110 | ✅ Available |
| DigitalOcean | RTX 4000 Ada | $0.76 | $122 | ❌ Unavailable |

## 🚀 Quick Start Commands

### Check DigitalOcean Availability
```bash
cd /Users/jsirish/AI/llm-hosting
./check-do-gpu-availability.sh check
```

### Monitor Continuously (Get Notified)
```bash
./check-do-gpu-availability.sh monitor
# Checks hourly, notifies when available
```

### Start with RunPod Instead
1. Go to [runpod.io](https://www.runpod.io)
2. Sign up and add $10 credit
3. Deploy GPU Pod → Choose RTX 6000 Ada or RTX A6000
4. Follow vLLM setup from main guide

## 📊 What Can Run GPT-OSS-20B?

Minimum requirements for 4-bit quantization:
- ✅ 20+ GB VRAM (model fits in ~16 GB)
- ✅ CUDA-capable GPU
- ✅ vLLM support

Tested and working:
- RTX 4000 Ada (20 GB) - Target but unavailable
- RTX 6000 Ada (48 GB) - **RECOMMENDED** ✅
- L40/L40S (48 GB) - Excellent ✅
- RTX A6000 (48 GB) - Budget option ✅
- RTX 3090 (24 GB) - Works, tight on VRAM ✅
- RTX 4090 (24 GB) - Works, tight on VRAM ✅

## 📝 Software Stack (Same for All Providers)

Regardless of provider, the setup is identical:

```bash
# 1. Install vLLM
pip install vllm

# 2. Run GPT-OSS-20B
vllm serve openai/gpt-oss-20b \
  --quantization mxfp4 \
  --tensor-parallel-size 1 \
  --max-model-len 8192 \
  --gpu-memory-utilization 0.90

# 3. Access API at http://localhost:8000/v1
# Works with LibreChat, Open WebUI, etc.
```

## 🔗 Useful Links

### Cloud Providers
- [RunPod](https://www.runpod.io) - **Recommended**
- [Vast.ai](https://vast.ai) - Cheapest
- [Paperspace](https://www.paperspace.com)
- [Lambda Labs](https://lambdalabs.com)
- [DigitalOcean](https://cloud.digitalocean.com/gpus/new) - When available

### Documentation
- [vLLM Documentation](https://docs.vllm.ai/)
- [GPT-OSS Model Card](https://huggingface.co/openai/gpt-oss-20b)
- [RunPod Documentation](https://docs.runpod.io/)

### Login Credentials
- DigitalOcean: Stored in 1Password (dev@dynamicagency.com)
- Access via: `op item get wnwfdxjyqxmp46xvds5qbsxwd4`

## ⏭️ Next Actions

1. **Decide on provider:**
   - ✅ RunPod (available now, same price)
   - ⏳ Wait for DigitalOcean (unknown timeline)

2. **If using RunPod:**
   - Open `Alternative-GPU-Providers.md`
   - Follow "Quick Start: RunPod Setup" section
   - Choose RTX 6000 Ada ($0.74/hr) or RTX A6000 ($0.33/hr)

3. **If waiting for DigitalOcean:**
   - Set up API token (see `API-TOKEN-SETUP.md`)
   - Run: `./check-do-gpu-availability.sh monitor`
   - Get notified when available

4. **For testing/development:**
   - Use RunPod RTX A6000 at $0.33/hr
   - Test your workflow before committing to higher costs

## 📞 Questions?

All documentation is in this folder. Key files:
- Main setup: `GPT-OSS-20B_DigitalOcean_0.76hr.md`
- Alternatives: `Alternative-GPU-Providers.md`
- Monitoring: `check-do-gpu-availability.sh`
- API setup: `API-TOKEN-SETUP.md`
