# Getting Started with Your RunPod LLM Setup

## ✅ Current Status (Dec 12, 2025 - 1:08 PM CT)

**Pod Status:** ✅ RUNNING
**Pod Name:** petite_coffee_koi-migration
**Pod ID:** 3clxt008hl0a3a
**GPU:** RTX 6000 Ada x1 (48GB VRAM)
**Cost:** $0.79/hr
**Migration:** Completed successfully at ~12:55 PM CT

## 🚀 Quick Start Guide

### 1. Connect to Your Pod

```bash
./connect-runpod.sh
```

This will open Jupyter Lab in your browser. The password is: `42z5ic3ocbugvss4iuqr`

Once in Jupyter:
1. Click **"Terminal"** under the "Other" section
2. You'll be in `/workspace` with all your scripts

### 2. Start the LLM Model

In the Jupyter terminal:

```bash
cd /workspace
./qwen3.sh
```

This starts **Qwen 3 Coder 30B FP8** with:
- 128K context window
- Optimized for code generation
- Accepts non-alternating conversation roles (better for Copilot)

**Wait ~2-3 minutes** for the model to load into VRAM.

### 3. Start the Simple Proxy

Open a **new Jupyter terminal** (File → New → Terminal):

```bash
cd /workspace
./run-proxy.sh
python3 /workspace/proxy.py
```

This starts the proxy on port 4000 that strips problematic response fields that break Copilot.

### 4. Test the Setup

From your **local machine** (not on RunPod):

```bash
# Test models endpoint
curl https://3clxt008hl0a3a-4000.proxy.runpod.net/v1/models

# Test completion
curl https://3clxt008hl0a3a-4000.proxy.runpod.net/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9" \
  -d '{
    "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### 5. Configure VS Code Copilot

Update your VS Code settings (or use Continue.dev extension):

**Endpoint:** `https://3clxt008hl0a3a-4000.proxy.runpod.net/v1`
**API Key:** `sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9`
**Model:** `Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8`

See `COPILOT_CONFIG_PROMPT.md` for detailed configuration instructions.

## 📊 What's Running

### Models Available:
1. **Qwen 3 Coder 30B FP8** (Recommended) - Already deployed
   - Best for code generation
   - 128K context window
   - Handles non-alternating roles

2. **Gemma 3 27B FP8** (Backup)
   - Available via `./gemma3.sh`
   - Has strict role alternation (may break with Copilot)

3. **GPT-OSS 20B** (Alternative)
   - Available via `./gptoss.sh`
   - Smaller, faster

### Endpoints:
- **vLLM Direct:** https://3clxt008hl0a3a-8000.proxy.runpod.net/v1
- **Simple Proxy:** https://3clxt008hl0a3a-4000.proxy.runpod.net/v1 (Recommended)
- **Jupyter:** https://3clxt008hl0a3a-8888.proxy.runpod.net/

## 🔧 Troubleshooting

### Pod Stopped?
1. Go to https://console.runpod.io/pods
2. Click menu (three dots) on your pod
3. Click "Start Pod"

### Model Not Responding?
```bash
# Check if vLLM is running
ps aux | grep vllm

# Check logs
tail -f /workspace/logs/vllm.log

# Restart if needed
./stop-server.sh
./qwen3.sh
```

### Proxy Not Working?
```bash
# Check if proxy is running
ps aux | grep proxy

# Restart if needed
pkill -f proxy.py
python3 /workspace/proxy.py
```

## 💡 Why This Setup?

1. **Qwen 3 vs Gemma 3:** Qwen 3 accepts non-alternating conversation roles, which Copilot frequently sends
2. **Simple Proxy:** vLLM returns extra fields (`reasoning`, `reasoning_content`, etc.) that break Copilot's JSON parser
3. **128K Context:** Large enough to analyze entire files at once

## 📁 Important Files

- `qwen3.sh` - Start Qwen 3 model
- `run-proxy.sh` - Setup and start the simple proxy
- `proxy.py` - The actual proxy code
- `connect-runpod.sh` - Connect to pod
- `RUNPOD_STATUS_MEMORY.md` - Detailed pod information
- `COPILOT_CONFIG_PROMPT.md` - VS Code configuration guide

## 🎯 Next Steps

1. ✅ Pod is running
2. ✅ Migration successful
3. ⏳ Start Qwen 3 model (`./qwen3.sh`)
4. ⏳ Start simple proxy (`python3 /workspace/proxy.py`)
5. ⏳ Test endpoints
6. ⏳ Configure VS Code Copilot
7. ⏳ Enjoy self-hosted AI coding assistance!

## 💰 Cost Management

**Current:** $0.79/hr when running
**Daily (24hr):** ~$19/day
**Weekly:** ~$133/week
**Monthly:** ~$570/month

**Remember to stop the pod when not in use!**

```bash
# From RunPod console:
# Click menu → Stop Pod
```

## 🆘 Need Help?

1. Check `RUNPOD_STATUS_MEMORY.md` for detailed setup info
2. Check logs in `/workspace/logs/`
3. All scripts are in `/workspace/` on the pod
4. Jupyter password: `42z5ic3ocbugvss4iuqr`
