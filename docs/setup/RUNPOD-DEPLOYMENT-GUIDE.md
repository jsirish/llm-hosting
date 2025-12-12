# RunPod Deployment Guide - GPT-OSS-20B

**Date:** December 11, 2025
**Status:** Ready to Deploy

---

## Why RunPod?

**Advantages over DigitalOcean:**
- ✅ **Available NOW** - No waitlist or approval needed
- ✅ **Cheaper** - $0.74/hr vs $0.76/hr (RTX 6000 Ada)
- ✅ **Better Specs** - 48 GB VRAM vs 20 GB
- ✅ **More Options** - Multiple GPU tiers from $0.16-0.74/hr
- ✅ **Flexible** - Community Cloud (spot) or Secure Cloud (on-demand)

---

## Step 1: Account Setup

### Create RunPod Account
1. Visit: https://www.runpod.io
2. Click "Sign Up" (top right)
3. Create account with email/password or social login
4. Verify email address

### Store Credentials in 1Password

```bash
# Use 1Password to save your RunPod credentials
op item create --category=Login \
  --title="RunPod Account" \
  --vault="Private" \
  'username=your-email@example.com' \
  'password=your-password' \
  'website=https://console.runpod.io/login' \
  --tags="runpod,gpu,ai"
```

### Add Initial Credits
- Minimum: $10 (recommended: $25 for testing)
- Payment methods: Credit card, crypto
- Per-second billing (no minimums)

---

## Step 2: Choose Your GPU

### Recommended Options (in order of preference):

#### Option A: RTX 6000 Ada - $0.74/hr ⭐ BEST VALUE
- **VRAM:** 48 GB (3x headroom vs target)
- **System RAM:** 167 GB
- **vCPUs:** 10
- **Price:** $0.74/hr
- **Best for:** Production use, multiple concurrent users

#### Option B: L40 - $0.69/hr 💰 CHEAPEST COMPARABLE
- **VRAM:** 48 GB
- **System RAM:** 94 GB
- **vCPUs:** 8
- **Price:** $0.69/hr
- **Best for:** Cost-conscious production

#### Option C: RTX A6000 - $0.33/hr 🎯 ULTRA BUDGET
- **VRAM:** 48 GB
- **System RAM:** 50 GB
- **vCPUs:** 9
- **Price:** $0.33/hr (less than half!)
- **Best for:** Development, testing, budget operation

#### Option D: RTX 3090 - $0.22/hr 💸 MINIMUM VIABLE
- **VRAM:** 24 GB (tight but works)
- **System RAM:** 125 GB
- **vCPUs:** 16
- **Price:** $0.22/hr
- **Best for:** Testing, development only

---

## Step 3: Deploy GPU Pod

### Navigate to Console
1. Go to: https://console.runpod.io/deploy
2. Click "Deploy" → "GPU Pods"

### Choose Pod Type
- **Community Cloud** (Recommended for cost)
  - Spot pricing (cheapest)
  - Can be interrupted (rare)
  - Save ~50% vs Secure Cloud

- **Secure Cloud** (Production)
  - On-demand, guaranteed
  - No interruptions
  - +20-30% cost

### Select GPU
1. Filter by VRAM: **40+ GB**
2. Sort by: **Price (Low to High)**
3. Look for: **RTX 6000 Ada** or **L40**
4. Check availability in regions

### Choose Template/Image
**Recommended Options:**

1. **RunPod Pytorch** (Pre-configured, easiest)
   - PyTorch + CUDA pre-installed
   - Good for quick start

2. **Ubuntu 22.04 + CUDA** (Clean slate)
   - Latest CUDA drivers
   - More control

3. **Custom Docker Image** (Advanced)
   - If you have your own setup

### Configure Pod
- **Volume Size:** 50 GB minimum (model weights ~40GB)
- **Expose HTTP Ports:** 8000 (for vLLM API)
- **Expose TCP Ports:** 22 (SSH)
- **Pod Name:** `gpt-oss-20b-vllm`

### Deploy!
- Click "Deploy On-Demand" or "Deploy Spot"
- Wait ~30-60 seconds for provisioning

---

## Step 4: Access Your Pod

### Get Connection Details
```bash
# From RunPod console, copy:
# - Pod ID
# - SSH connection string
# - Public IP
# - HTTP port mapping
```

### SSH Connection
```bash
# Use the SSH command provided by RunPod
ssh root@<pod-ip> -p <port>

# Or use the web terminal in RunPod console
```

---

## Step 5: Install vLLM

### Update System (if needed)
```bash
apt-get update && apt-get upgrade -y
```

### Install vLLM
```bash
# Install vLLM with CUDA support
pip install vllm

# Verify installation
python -c "import vllm; print(vllm.__version__)"
```

---

## Step 6: Deploy GPT-OSS-20B

### Download and Run Model

```bash
# Create a startup script
cat > run-gpt-oss-20b.sh << 'EOF'
#!/bin/bash

# Run GPT-OSS-20B with 4-bit MXFP4 quantization
vllm serve openai/gpt-oss-20b \
  --quantization mxfp4 \
  --tensor-parallel-size 1 \
  --max-model-len 8192 \
  --gpu-memory-utilization 0.90 \
  --host 0.0.0.0 \
  --port 8000
EOF

chmod +x run-gpt-oss-20b.sh
```

### Start the Server
```bash
# Run in background with logs
nohup ./run-gpt-oss-20b.sh > vllm.log 2>&1 &

# Monitor logs
tail -f vllm.log

# Or run in foreground (easier for first time)
./run-gpt-oss-20b.sh
```

### Wait for Model Loading
- First run: ~5-10 minutes (downloads ~40GB model)
- Subsequent runs: ~1-2 minutes (cached)
- Watch for: "Uvicorn running on http://0.0.0.0:8000"

---

## Step 7: Test API Endpoint

### Get Your API URL
```bash
# From RunPod console, find your pod's public IP
# Your API will be at: http://<pod-ip>:<mapped-port>/v1
```

### Test with curl
```bash
# List models
curl http://<your-pod-ip>:8000/v1/models

# Test completion
curl http://<your-pod-ip>:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "prompt": "def fibonacci(n):",
    "max_tokens": 100,
    "temperature": 0.7
  }'

# Test chat completion
curl http://<your-pod-ip>:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "messages": [
      {"role": "user", "content": "Write a Python function to calculate fibonacci numbers"}
    ],
    "max_tokens": 200
  }'
```

---

## Step 8: Connect to Your Tools

### LibreChat Configuration
```yaml
# Add to librechat.yaml
endpoints:
  custom:
    - name: "GPT-OSS-20B"
      apiKey: "not-needed"
      baseURL: "http://<your-pod-ip>:8000/v1"
      models:
        default: ["openai/gpt-oss-20b"]
```

### Open WebUI Configuration
1. Settings → Connections
2. Add OpenAI API Compatible
3. Base URL: `http://<your-pod-ip>:8000/v1`
4. API Key: Leave blank or use dummy value
5. Test connection

### VSCode Continue Extension
```json
// settings.json
{
  "continue.apiUrl": "http://<your-pod-ip>:8000/v1",
  "continue.modelName": "openai/gpt-oss-20b"
}
```

---

## Cost Optimization

### Hourly Usage Tracking
```bash
# Check current pod uptime
# RunPod console shows real-time costs

# Your pod costs per hour:
RTX 6000 Ada: $0.74/hr
L40: $0.69/hr
RTX A6000: $0.33/hr
```

### Cost-Saving Tips
1. **Stop pod when not in use** - Only billed when running
2. **Use Community Cloud** - 50% cheaper than Secure Cloud
3. **Lower-tier GPUs** - RTX A6000 ($0.33/hr) works great
4. **Volume persistence** - Keep model cached between stops
5. **Set auto-stop** - Stop after X hours of inactivity

### Monthly Cost Estimates

**RTX 6000 Ada @ $0.74/hr:**
- 40 hrs/month (development): $29.60
- 160 hrs/month (part-time): $118.40
- 720 hrs/month (24/7): $532.80

**RTX A6000 @ $0.33/hr:**
- 40 hrs/month: $13.20
- 160 hrs/month: $52.80
- 720 hrs/month: $237.60

---

## Troubleshooting

### Model Download Fails
```bash
# Check disk space
df -h

# Manually download model
python -c "from transformers import AutoModelForCausalLM; AutoModelForCausalLM.from_pretrained('openai/gpt-oss-20b')"
```

### Out of Memory
```bash
# Reduce max model length
vllm serve openai/gpt-oss-20b \
  --quantization mxfp4 \
  --max-model-len 4096 \  # Lower from 8192
  --gpu-memory-utilization 0.85  # Lower from 0.90
```

### Port Not Accessible
```bash
# Check if vLLM is running
ps aux | grep vllm

# Check port binding
netstat -tlnp | grep 8000

# Verify RunPod port mapping in console
```

### Slow Inference
```bash
# Check GPU utilization
nvidia-smi

# Ensure quantization is working
# Look for "Using quantization: mxfp4" in logs
```

---

## Monitoring & Maintenance

### Check GPU Usage
```bash
# Install nvidia monitoring
watch -n 1 nvidia-smi
```

### View Logs
```bash
# Real-time logs
tail -f vllm.log

# Search logs
grep -i error vllm.log
```

### Update vLLM
```bash
pip install --upgrade vllm
```

---

## Production Checklist

Before going to production:

- [ ] Test API thoroughly with your use case
- [ ] Verify quantization is working (check logs)
- [ ] Test concurrent requests (simulate load)
- [ ] Set up monitoring/alerting
- [ ] Configure auto-restart on crash
- [ ] Document API endpoint for team
- [ ] Test with LibreChat/OpenWebUI
- [ ] Set budget alerts in RunPod
- [ ] Create volume snapshot (backup)
- [ ] Document startup procedure

---

## Comparison: RunPod vs DigitalOcean

| Feature | RunPod | DigitalOcean |
|---------|--------|--------------|
| **Availability** | ✅ Available now | ⚠️ Limited (TOR1 only) |
| **Price (Target GPU)** | $0.74/hr (RTX 6000 Ada) | $0.76/hr (RTX 4000 ADA) |
| **VRAM** | 48 GB | 20 GB |
| **Budget Options** | $0.16-0.74/hr | $0.76/hr (fixed) |
| **Billing** | Per-second | Per-hour |
| **Setup Time** | ~2 minutes | ~5 minutes |
| **Approval Required** | No | Maybe (waitlist) |
| **Community Cloud** | Yes (cheaper) | No |
| **Spot Pricing** | Yes | No |

**Winner:** RunPod for this use case

---

## Next Steps After Deployment

1. **Test thoroughly** - Ensure inference works correctly
2. **Configure clients** - Connect LibreChat, OpenWebUI, etc.
3. **Monitor costs** - Track hourly spending
4. **Optimize settings** - Tune for your use case
5. **Create snapshots** - Backup your configuration
6. **Document access** - Share API details with team

---

## Support Resources

- **RunPod Docs:** https://docs.runpod.io/
- **vLLM Docs:** https://docs.vllm.ai/
- **RunPod Discord:** https://discord.com/invite/cUpRmau42V
- **Support:** https://contact.runpod.io/hc/en-us

---

## Quick Reference Commands

```bash
# Start GPT-OSS-20B
./run-gpt-oss-20b.sh

# Stop server
pkill -f vllm

# Check if running
ps aux | grep vllm

# View logs
tail -f vllm.log

# Test API
curl http://localhost:8000/v1/models

# GPU stats
nvidia-smi

# Disk space
df -h

# Update vLLM
pip install --upgrade vllm
```

---

**Status:** Ready to deploy! 🚀

**Estimated Time to First Inference:** 15-20 minutes
**Total Setup Time:** ~30 minutes including model download

Good luck with your deployment!
