# LLM Hosting on RunPod# Project Summary - GPT-OSS-20B Hosting



Self-hosted LLM inference server running on RunPod GPU instances with vLLM. Optimized for use with Continue.dev, GitHub Copilot, and other OpenAI-compatible clients.**Last Updated:** January 20, 2025 at 4:30 PM EST



## 🚀 Quick Start## Current Status: ✅ DEPLOYED on RunPod!



**Read [START-HERE.md](START-HERE.md) for complete setup instructions.****Pod ID:** `v5brcrgoclcp1p` | **GPU:** RTX 6000 Ada (48 GB) | **Cost:** $0.78/hr



### Current Setup🚀 **Active Deployment:** RunPod RTX 6000 Ada is now running and ready for vLLM deployment.

- **Platform**: RunPod (RTX 6000 Ada, 48GB VRAM)

- **Server**: vLLM v0.12.0 with OpenAI-compatible API**Quick Access:**

- **Primary Model**: GPT-OSS-20B (128K context, MXFP4 quantization)- 📊 **Jupyter Lab**: [Open Notebook](https://v5brcrgoclcp1p-8888.proxy.runpod.net/?token=42z5ic3ocbugvss4iuqr)

- **Client**: Continue.dev in VS Code- 💻 **Web Terminal**: [Open Terminal](https://v5brcrgoclcp1p-19123.proxy.runpod.net/b6472jb6g7sa0bdoxdie9l6jrcen530q/)

- 📖 **Full Details**: See `RUNPOD-DEPLOYED.md`

### Start a Model

## 📁 Project Files

```bash

# From your local machine, start on RunPod:### 🎯 Active Deployment

cd models/1. **`RUNPOD-DEPLOYED.md`** 🚀 ACTIVE

./gptoss.sh      # GPT-OSS-20B (OpenAI OSS model)   - **Current pod details and access URLs**

./qwen.sh        # Qwen 3 Coder 30B (best for coding)   - Complete vLLM deployment instructions

./gemma3.sh      # Gemma 3 27B (Google's model)   - Performance specs and cost tracking

./kimi-k2.sh     # Kimi K2 / DeepSeek-V3   - Troubleshooting guide

```   - **START HERE for next steps!**



All models use the generic `scripts/start-vllm-server.sh` launcher with optimized settings.### Main Documentation

2. **`GPT-OSS-20B_DigitalOcean_0.76hr.md`**

## 📁 Repository Structure   - Original setup guide for DigitalOcean

   - ⚠️ Updated with availability warning

```   - Still valid once GPUs are back in stock

llm-hosting/

├── README.md                 # This file3. **`Alternative-GPU-Providers.md`**

├── START-HERE.md             # Complete setup guide   - Complete guide to alternative cloud providers

├── models/                   # Model launcher scripts   - RunPod, Vast.ai, Paperspace, Lambda Labs

│   ├── gptoss.sh            # GPT-OSS-20B   - Detailed pricing comparison and setup guides

│   ├── qwen.sh              # Qwen 3 Coder 30B

│   ├── qwen3.sh             # Alternative Qwen launcher4. **`RUNPOD-DEPLOYMENT-GUIDE.md`**

│   ├── gemma3.sh            # Gemma 3 27B   - Step-by-step RunPod deployment walkthrough

│   └── kimi-k2.sh           # Kimi K2 (DeepSeek-V3)   - Account setup and configuration

├── scripts/                  # Utility scripts   - General RunPod reference guide

│   ├── start-vllm-server.sh # Generic vLLM launcher

│   ├── stop-server.sh       # Stop running server### Monitoring Tools

│   ├── check-server.sh      # Health check5. **`check-do-gpu-availability.sh`** (Executable)

│   ├── monitor-runpod.sh    # Monitor GPU usage   - Automated GPU availability checker

│   └── connect-runpod.sh    # SSH to RunPod   - Monitors DigitalOcean for RTX 4000 ADA restocking

├── docs/                     # Documentation   - Sends macOS notifications when available

│   ├── setup/               # Setup guides   - Can run continuously or as cron job

│   ├── troubleshooting/     # Common issues & fixes

│   └── reference/           # API docs, file guide6. **`API-TOKEN-SETUP.md`**

└── archive/                  # Old/obsolete files   - Instructions for setting up DigitalOcean API access

    ├── scripts/             # Archived test scripts   - How to use the monitoring script

    └── docs/                # Outdated status docs   - Troubleshooting guide

```

## 🎯 Next Steps: Deploy GPT-OSS-20B

## 🔧 Key Features

### ✅ Pod is Ready - Deploy vLLM Now!

### Models

- **GPT-OSS-20B**: OpenAI's open-source model with native tool calling
  - ⚠️ **Note:** Ada Lovelace (RTX 6000 Ada) support is IN PROGRESS
  - Requires vLLM >= 0.10.2, PyTorch with +cu128 suffix, CUDA >= 12.8
  - See: `docs/setup/GPT-OSS-VLLM-OFFICIAL-GUIDE.md` for details
- **Qwen 3 Coder 30B**: Specialized for code generation (✅ **STABLE on Ada Lovelace**)
- **Gemma 3 27B**: Google's efficient instruction model
- All models support 128K context with FP8/MXFP4 quantization

### ⚠️ GPT-OSS Ada Lovelace Status

**Current Status:** Ada Lovelace (RTX 6000 Ada) support is **under active development** by vLLM team.

**What This Means:**
- Deployment on RTX 6000 Ada may fail or be unstable
- vLLM team is "actively working" on Ada Lovelace support
- No ETA provided for production readiness
- **Recommended:** Use Qwen3-Coder-30B as stable alternative (working now)

**Version Requirements:**
- vLLM >= 0.10.2 (for `--tool-call-parser openai` flag)
- PyTorch with `+cu128` suffix
- CUDA >= 12.8

**See:** `docs/setup/GPT-OSS-VLLM-OFFICIAL-GUIDE.md` for full details and deployment instructions.

### Start a Model

1. **Open Web Terminal**:
   - Click: https://v5brcrgoclcp1p-19123.proxy.runpod.net/b6472jb6g7sa0bdoxdie9l6jrcen530q/

2. **Follow the guide in `RUNPOD-DEPLOYED.md`**:

   - Verify GPU with `nvidia-smi`

### Performance Optimizations   - Install vLLM: `pip install vllm`

- ✅ Prefix caching enabled (reuse context across requests)   - Deploy GPT-OSS-20B with 4-bit quantization

- ✅ Auto tokenizer mode (proper chat template detection)   - Test inference API

- ✅ CUDA graph optimization

- ✅ 95% GPU memory utilization3. **Estimated Time**: 15-20 minutes

- ✅ Chunked prefill for long contexts   - vLLM install: ~2 minutes

   - Model download: ~10-15 minutes (16 GB quantized)

### Continue.dev Integration   - First inference test: ~1 minute

- 13 stop sequences to prevent token leakage

- Temperature 0.1 for deterministic behavior### Alternative: Use Jupyter Lab

- 96K output tokens (131K total context)- URL: https://v5brcrgoclcp1p-8888.proxy.runpod.net/?token=42z5ic3ocbugvss4iuqr

- Tool use enabled with MCP servers- Open "New" → "Terminal" for shell access

- Same deployment steps as web terminal

## 📖 Documentation

## 📊 Deployment Comparison

### Setup Guides

- [GPT-OSS Official vLLM Guide](docs/setup/GPT-OSS-VLLM-OFFICIAL-GUIDE.md) - ⚠️ **Ada Lovelace status & version requirements**
- [Continue.dev Setup](docs/setup/CONTINUE-SETUP.md) - VS Code extension configuration
- [RunPod Deployment](docs/setup/RUNPOD-DEPLOYMENT-GUIDE.md) - Cloud GPU setup
- [API Configuration](docs/reference/API-KEY-GUIDE.md) - Authentication setup

### ✅ DEPLOYED: RunPod RTX 6000 Ada - $0.78/hr

- **Status:** Active and running now
- **VRAM:** 48 GB (3x more headroom!)

- **Availability:** Immediate

### Troubleshooting- **Spot Option:** $0.39/hr (50% cheaper)

- [Token Leakage Fix](docs/troubleshooting/GPT-OSS-TOKEN-LEAKAGE-FIX.md) - **Recent fix!**

- [Common Issues](docs/troubleshooting/GPT-OSS-TROUBLESHOOTING.md)### ⏸️ Alternative: DigitalOcean RTX 4000 ADA - $0.76/hr

- [Copilot Integration](docs/troubleshooting/COPILOT-MODEL-ERROR-FIX.md)- **Status:** Limited availability (TOR1 only)

- May require waitlist/approval

### Reference- 20 GB VRAM

- [File Guide](docs/reference/FILE-GUIDE.md) - What each file does- Follow setup in `GPT-OSS-20B_DigitalOcean_0.76hr.md`

- [Server Management](docs/reference/SERVER-MANAGEMENT.md) - Start, stop, monitor

- [Tool Parser Research](docs/reference/TOOL-PARSER-RESEARCH.md) - Model capabilities### Option C: Ultra Budget Option

✅ **Use RunPod RTX A6000 - $0.33/hr**

## 🛠️ Common Tasks- Less than HALF the price!

- Still has 48 GB VRAM

### Check Server Status- Perfect for testing or budget projects

```bash

scripts/check-server.sh## 💰 Cost Comparison

```

| Provider | GPU | Price/hr | Monthly (160h) | Status |

### Monitor GPU Usage|----------|-----|----------|----------------|--------|

```bash| **RunPod** | RTX 6000 Ada | $0.74 | $118 | ✅ **AVAILABLE NOW** |

scripts/monitor-runpod.sh| **RunPod** | RTX A6000 | $0.33 | $53 | ✅ **BEST VALUE** |

```| **RunPod** | L40 | $0.69 | $110 | ✅ Available |

| DigitalOcean | RTX 4000 Ada | $0.76 | $122 | ❌ Unavailable |

### View Logs

```bash## 🚀 Quick Start Commands

scripts/fetch-logs.sh

# or on RunPod:### Check DigitalOcean Availability

tail -f /workspace/logs/vllm-server.log```bash

```cd /Users/jsirish/AI/llm-hosting

./check-do-gpu-availability.sh check

### Stop Server```

```bash

scripts/stop-server.sh### Monitor Continuously (Get Notified)

# or on RunPod:```bash

kill $(cat /workspace/logs/vllm-server.pid)./check-do-gpu-availability.sh monitor

```# Checks hourly, notifies when available

```

## 🔐 Security

### Start with RunPod Instead

- API keys are randomly generated per server start1. Go to [runpod.io](https://www.runpod.io)

- Keys saved to `/workspace/logs/api-key.txt` on RunPod2. Sign up and add $10 credit

- Update your Continue.dev config with new key after restart3. Deploy GPU Pod → Choose RTX 6000 Ada or RTX A6000

- Config location: `~/.continue/config.yaml`4. Follow vLLM setup from main guide



## 💡 Tips## 📊 What Can Run GPT-OSS-20B?



1. **First Time Setup**: Read START-HERE.md completelyMinimum requirements for 4-bit quantization:

2. **Model Choice**: Use Qwen for coding, GPT-OSS for general + tools- ✅ 20+ GB VRAM (model fits in ~16 GB)

3. **Context Length**: All models support 128K tokens (huge!)- ✅ CUDA-capable GPU

4. **Monitoring**: Check GPU memory with `monitor-runpod.sh`- ✅ vLLM support

5. **Logs**: Always check logs if something isn't working

Tested and working:

## 📊 Current Status- RTX 4000 Ada (20 GB) - Target but unavailable

- RTX 6000 Ada (48 GB) - **RECOMMENDED** ✅

✅ **Working**:- L40/L40S (48 GB) - Excellent ✅

- GPT-OSS-20B running on RunPod- RTX A6000 (48 GB) - Budget option ✅

- Continue.dev integration- RTX 3090 (24 GB) - Works, tight on VRAM ✅

- Token leakage fixed (Dec 12, 2025)- RTX 4090 (24 GB) - Works, tight on VRAM ✅

- All model launchers updated with performance optimizations

## 📝 Software Stack (Same for All Providers)

⏳ **In Progress**:

- Documentation consolidationRegardless of provider, the setup is identical:

- Testing other models (Gemma, Kimi)

```bash

## 🤝 Contributing# 1. Install vLLM

pip install vllm

This is a personal project for self-hosted LLM inference. Feel free to use as reference or fork for your own setup.

# 2. Run GPT-OSS-20B

## 📝 Notesvllm serve openai/gpt-oss-20b \

  --quantization mxfp4 \

- **Cost**: ~$0.76-0.79/hr on RunPod (RTX 6000 Ada)  --tensor-parallel-size 1 \

- **Storage**: 304TB workspace (plenty for model caching)  --max-model-len 8192 \

- **VRAM**: 48GB (can run 30B+ models with quantization)  --gpu-memory-utilization 0.90

- **Network**: Models cached, no re-download needed

# 3. Access API at http://localhost:8000/v1

---# Works with LibreChat, Open WebUI, etc.

```

**Last Updated**: December 12, 2025

**Current Pod**: petite_coffee_koi-migration (3clxt008hl0a3a)  ## 🔗 Useful Links

**Status**: ✅ Operational

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
