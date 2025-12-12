# START HERE - LLM Hosting Setup Guide# 🚀 Quick Start Guide



Complete guide to get your self-hosted LLM running on RunPod with Continue.dev.## What You Need to Do Right Now



## ✅ What You'll Have### Step 1: Expose Port 8000 in RunPod

**This is the missing piece!**

After following this guide:

- ✅ vLLM server running on RunPod GPU (RTX 6000 Ada, 48GB)1. Open browser to: https://console.runpod.io/pods

- ✅ GPT-OSS-20B or Qwen model loaded (128K context)2. Find your pod: `petite_coffee_koi`

- ✅ Continue.dev integrated with VS Code3. Click the **☰ hamburger menu** (bottom-left of pod card)

- ✅ OpenAI-compatible API endpoint4. Click **"Edit Pod"**

- ✅ Tool calling and MCP servers enabled5. Find: **"Expose HTTP Ports (Max 10)"**

6. Change from: `8888`

**Total setup time**: ~20 minutes (first time), ~5 minutes (restart)7. Change to: `8888,8000` (add port 8000)

8. Click **"Save"** or **"Update"**

---

⚠️ **Note:** Pod may restart (takes ~5 min to reload model)

## 🚀 Part 1: RunPod Setup (One-Time)

---

### 1.1 Create RunPod Account

1. Go to https://runpod.io### Step 2: Upload New Scripts to Pod

2. Sign up and add credits ($10 minimum recommended)

3. Go to **Pods** → **+ GPU Pod**The scripts are ready on your Mac. Copy them to the pod:



### 1.2 Select GPU**Option A: Via Web Terminal**

- Choose **RTX 6000 Ada** (48GB VRAM, ~$0.76/hr)1. Go to: https://v5brcrgoclcp1p-19123.proxy.runpod.net/b6472jb6g7sa0bdoxdie9l6jrcen530q/

- Or **A6000** if 6000 Ada unavailable2. Create files using `nano`:

- Need minimum 40GB VRAM for 30B models   ```bash

   cd /workspace

### 1.3 Configure Pod   nano start-server.sh    # Copy from your Mac, Ctrl+X to save

```   nano stop-server.sh     # Copy from your Mac, Ctrl+X to save

Template: RunPod Pytorch 2.1   nano check-server.sh    # Copy from your Mac, Ctrl+X to save

Container Disk: 50GB (default is fine)   chmod +x *.sh

Volume: 304TB (included - for model caching)   ```

Ports: 8000 (TCP) - expose for API access

```**Option B: Copy/Paste via SSH**

1. `ssh v5brcrgoclcp1p-64411a48@ssh.runpod.io -i ~/.ssh/runpod_ed25519`

### 1.4 Deploy Pod2. Same as Option A

- Click **Deploy** 

- Wait 2-3 minutes for pod to start---

- Note your pod ID (e.g., `3clxt008hl0a3a`)

### Step 3: Start Server in Background

---

On the pod (via SSH or web terminal):

## 🔧 Part 2: Server Setup on RunPod

```bash

### 2.1 Connect to Podcd /workspace

From VS Code terminal:

```bash# If server is currently running in foreground, stop it first:

scripts/connect-runpod.sh# Press Ctrl+C in that terminal

# Or manually:

ssh root@<POD_ID>-ssh.runpod.io -p <SSH_PORT># Start with new script

```./start-server.sh

```

### 2.2 Setup Environment (First Time Only)

```bashYou should see:

# Clone this repo on RunPod```

cd /workspace🔐 API Key: sk-vllm-a1b2c3d4e5f6...

git clone <your-repo-url> llm-hosting   (Save this! You'll need it for API requests)

cd llm-hosting

✅ Server started successfully!

# Install vLLM with GPT-OSS supportPID: 12345

pip install vllm==0.12.0Log file: /workspace/logs/vllm-server.log

API Key file: /workspace/logs/api-key.txt

# Setup HuggingFace token (for gated models)```

scripts/setup-hf-token.sh

# Enter your HF token when prompted**🔐 IMPORTANT: Save the API key!** You'll need it for all requests.

```

---

### 2.3 Start a Model

### Step 4: Get Your API Key

**Option A: GPT-OSS-20B (Recommended)**

```bashOn the pod:

cd /workspace/llm-hosting```bash

models/gptoss.shcat /workspace/logs/api-key.txt

``````



**Option B: Qwen 3 Coder 30B (Best for coding)****Copy this key** - you'll need it for API requests!

```bash

cd /workspace/llm-hosting---

models/qwen.sh

```### Step 5: Test It!



**What happens**:**From the pod (automatic - uses saved key):**

- Model downloads to `/workspace/hf-cache` (only first time)```bash

- vLLM server starts on port 8000./test-api.sh

- API key generated and saved to `/workspace/logs/api-key.txt````

- Server runs in background

**From your Mac (after port is exposed):**

**Wait time**:```bash

- First download: 10-15 minutescd /Users/jsirish/AI/llm-hosting

- From cache: 2-3 minutes to load

# Set your API key

---export VLLM_API_KEY="sk-vllm-YOUR_KEY_HERE"



## 💻 Part 3: Continue.dev Setup# Run tests

./test-api-local.sh

### 3.1 Install Continue Extension```

1. Open VS Code

2. Go to Extensions (⌘+Shift+X)**Or manually:**

3. Search "Continue"```bash

4. Install "Continue - Codestral, Claude, and more"curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/health \

  -H "Authorization: Bearer sk-vllm-YOUR_KEY_HERE"

### 3.2 Get Your API Details```



On RunPod:Expected response:

```bash```json

# Get API key{"status":"ok"}

cat /workspace/logs/api-key.txt```



# Get API endpoint (from RunPod dashboard)---

# Format: https://<POD_ID>-8000.proxy.runpod.net/v1

```## Alternative: Use SSH Tunnel (Works Immediately)



### 3.3 Configure Continue**If you don't want to wait for port exposure:**



Edit `~/.continue/config.yaml`:On your Mac:

```bash

```yaml# Terminal 1: Start tunnel

name: Continue./tunnel-api.sh

version: 0.0.1

schema: v1# Terminal 2: Test API

models:curl http://localhost:8000/health

  - name: RunPod GPT-OSS-20B```

    provider: openai

    model: openai/gpt-oss-20bThis works right now, but only while tunnel is running.

    apiBase: https://<POD_ID>-8000.proxy.runpod.net/v1

    apiKey: sk-vllm-<YOUR_KEY_HERE>---

    capabilities:

      - tool_use## Useful Commands

    defaultCompletionOptions:

      contextLength: 131072  # 128K total### On Pod:

      maxTokens: 98304       # 96K output```bash

      temperature: 0.1       # Deterministic./start-server.sh          # Start server in background

      stop:./check-server.sh          # Check if running

        - "<|end|>"./stop-server.sh           # Stop server

        - "<|start|>"tail -f /workspace/logs/vllm-server.log  # Watch logs

        - "<|assistant|>"```

        - "<|user|>"

        - "<|system|>"### On Mac:

        - "<|channel|>"```bash

        - "<|endoftext|>"./tunnel-api.sh            # Create SSH tunnel

        - "\n\n###"./test-api-local.sh        # Test via RunPod proxy

        - "</tool>"curl http://localhost:8000/health  # Test via tunnel

        - "</final>"```

        - "Some(\""

        - "need to analyze"---

        - "We should"

```## What Changed?



**Important**: Replace `<POD_ID>` and `<YOUR_KEY_HERE>` with your actual values!1. ✅ **start-server.sh** now runs in background with logging

2. ✅ **stop-server.sh** added for clean shutdown

### 3.4 Test Continue3. ✅ **check-server.sh** added for status monitoring

1. Open a file in VS Code4. ✅ Logs saved to `/workspace/logs/vllm-server.log`

2. Press `Cmd+L` (or `Ctrl+L` on Windows)5. ✅ Server survives SSH disconnects

3. Type: "Write a hello world function"6. ✅ Complete documentation in `RUNPOD-PORT-EXPOSURE.md`

4. Should see response from your model!

---

---

## Troubleshooting

## 🛠️ Part 4: Day-to-Day Usage

### Port 8000 returns 404:

### Starting Server- **Cause:** Port not exposed in RunPod yet

```bash- **Fix:** Follow Step 1 above

# SSH to RunPod

ssh root@<POD_ID>-ssh.runpod.io -p <SSH_PORT>### Server won't start:

```bash

# Start model# Check what's wrong

cd /workspace/llm-hosting./check-server.sh

models/gptoss.sh  # or qwen.sh, gemma3.sh, etc.

# View logs

# Wait for "Application startup complete" messagetail -50 /workspace/logs/vllm-server.log

```

# Try stopping first

### Checking Status./stop-server.sh

```bash

# Check if server is running# Start again

scripts/check-server.sh./start-server.sh

```

# Monitor GPU usage

scripts/monitor-runpod.sh### Can't find RunPod UI option:

- Look for the **hamburger menu icon** (three horizontal lines)

# View logs- It's in the **bottom-left** corner of your pod card

tail -f /workspace/logs/vllm-server.log- See screenshots in `RUNPOD-PORT-EXPOSURE.md`

```

---

### Stopping Server

```bash## 🎯 Success Checklist

scripts/stop-server.sh

# or- [ ] Port 8000 exposed in RunPod UI

kill $(cat /workspace/logs/vllm-server.pid)- [ ] New scripts uploaded to pod

```- [ ] Scripts made executable (`chmod +x *.sh`)

- [ ] Server started with `./start-server.sh`

### Getting New API Key- [ ] Health check returns `{"status":"ok"}`

Every time you restart the server, a new API key is generated:- [ ] Can access via public URL

```bash

cat /workspace/logs/api-key.txt---

```

Update this in your `~/.continue/config.yaml`!## 📚 More Info



---- **Port Exposure:** `RUNPOD-PORT-EXPOSURE.md`

- **Complete Update:** `UPDATE-SUMMARY.md`

## 📊 Troubleshooting- **Command Reference:** `QUICK-REFERENCE.md`

- **Deployment Info:** `RUNPOD-DEPLOYED.md`

### Server Won't Start
```bash
# Check logs
tail -50 /workspace/logs/vllm-server.log

# Check if port is in use
lsof -i :8000

# Kill any existing server
pkill -f vllm
```

### Out of Memory
```bash
# Check GPU usage
nvidia-smi

# Reduce max_model_len in model script
# Edit models/gptoss.sh:
export VLLM_MAX_MODEL_LEN=65536  # Reduce from 131072
```

### Token Leakage (Model outputs "Some('need to...")"
✅ **Fixed!** The 13 stop sequences in Continue config prevent this.

If you still see it, check:
1. Continue config has all stop sequences
2. Temperature is 0.1 (not higher)
3. Server loaded with correct chat template (check logs for "Harmony")

See [docs/troubleshooting/GPT-OSS-TOKEN-LEAKAGE-FIX.md](docs/troubleshooting/GPT-OSS-TOKEN-LEAKAGE-FIX.md)

### Can't Connect from Continue
1. Check API endpoint URL is correct (with `-8000.proxy.runpod.net`)
2. Check API key is up to date
3. Test with curl:
```bash
curl https://<POD_ID>-8000.proxy.runpod.net/v1/models \
  -H "Authorization: Bearer <YOUR_API_KEY>"
```

---

## 💡 Pro Tips

### 1. Model Selection
- **GPT-OSS-20B**: General use, excellent tool calling, OpenAI-trained
- **Qwen 3 Coder 30B**: Best for coding tasks, faster, more efficient
- **Gemma 3 27B**: Good balance, Google-trained
- **Kimi K2**: Experimental, DeepSeek-V3 based

### 2. Context Length
All models support 128K tokens! That's:
- ~96,000 words
- ~150-200 pages of text
- Entire codebases in context

### 3. Cost Management
- Server costs $0.76-0.79/hr when running
- Stop pod when not using (saves money)
- Models are cached - no re-download needed
- Consider spot instances for 50% savings (may be interrupted)

### 4. Performance
- First request is slow (model warmup)
- Subsequent requests are fast (CUDA graphs)
- Prefix caching reuses repeated context (huge speedup!)
- Typical generation: 20-50 tokens/sec

### 5. MCP Servers (Advanced)
Continue.dev supports MCP (Model Context Protocol) servers:
- **Context7**: Library documentation
- **GitHub**: Repository access
- **Playwright**: Browser automation
- **Filesystem**: Local file operations

Already configured in the Continue config!

---

## 📚 Next Steps

### Learn More
- [File Guide](docs/reference/FILE-GUIDE.md) - What each file does
- [Server Management](docs/reference/SERVER-MANAGEMENT.md) - Advanced operations
- [API Configuration](docs/reference/API-KEY-GUIDE.md) - Authentication details

### Customize
- Edit model configs in `models/` directory
- Adjust context length in `VLLM_MAX_MODEL_LEN`
- Change temperature in Continue config
- Add more models (copy existing scripts)

### Monitor
```bash
# GPU usage
watch -n 1 nvidia-smi

# Server logs (real-time)
tail -f /workspace/logs/vllm-server.log

# System resources
htop
```

---

## 🆘 Getting Help

### Common Issues
Check [docs/troubleshooting/](docs/troubleshooting/) for:
- Token leakage fixes
- Copilot integration issues
- Memory errors
- Connection problems

### Logs Location
- Server logs: `/workspace/logs/vllm-server.log`
- API key: `/workspace/logs/api-key.txt`
- PID file: `/workspace/logs/vllm-server.pid`

### Quick Diagnostics
```bash
# Full system check
scripts/check-environment.sh

# Server health
curl http://localhost:8000/health

# Model list
curl http://localhost:8000/v1/models
```

---

## ✅ Success Checklist

- [ ] RunPod pod created and running
- [ ] SSH access working
- [ ] vLLM installed (v0.12.0+)
- [ ] Model downloaded to cache
- [ ] Server started successfully
- [ ] API endpoint accessible
- [ ] Continue.dev installed in VS Code
- [ ] Config file updated with API key
- [ ] Test query works in Continue
- [ ] Tool calling works (optional)

**If all checked, you're ready to go! 🎉**

---

**Last Updated**: December 12, 2025  
**Current Status**: ✅ All systems operational  
**Questions?** Check docs/ or review logs
