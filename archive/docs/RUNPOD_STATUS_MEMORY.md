# RunPod Pod Status Memory

## Current Situation (Dec 12, 2025) - ✅ MIGRATION SUCCESSFUL!
- **New Pod Name:** petite_coffee_koi-migration
- **New Pod ID:** 3clxt008hl0a3a
- **Status:** ✅ RUNNING
- **GPU:** RTX 6000 Ada x1 (48GB VRAM)
- **Cost:** $0.79/hr
- **User Timezone:** America/Chicago (Central Time)
- **Migration Time:** ~12:55 PM CT, took ~10 minutes
- **Old Pod:** petite_coffee_koi (v5brcrgoclcp1p) - can be terminated

## What Happened
- Pod was stopped to save costs
- RTX 6000 Ada GPU was released back to pool
- GPU now rented by someone else or under maintenance
- No RTX 6000 Ada instances currently available

## Data Status
✅ **ALL DATA IS SAFE**
- Network volume (100GB): `/workspace/` - **PRESERVED**
- Container storage (30GB): **PRESERVED**
- All scripts intact:
  - `gemma3.sh`
  - `qwen3.sh`
  - `setup-litellm.sh`
  - `proxy.py`
  - All configuration files

## Next Steps

### When to Check Availability
**Best times (Central Time):**
- **7-9 AM CT** (5-7 AM PT) - Best availability
- **12-2 PM CT** (10 AM-12 PM PT) - Good availability
- **5-7 PM CT** (3-5 PM PT) - Moderate availability
- **Late night/early morning** - Often good

### How to Restart
1. Go to RunPod console: https://console.runpod.io/pods
2. Click menu (three dots) on petite_coffee_koi
3. Click "Start Pod"
4. Choose "Automatically migrate your Pod data"
5. If RTX 6000 Ada still unavailable, try again later OR manually edit pod to use different GPU

### Alternative GPUs (48GB VRAM needed)
If RTX 6000 Ada unavailable:
- **A6000** (48GB) - Same capability, ~$0.80/hr
- **A40** (48GB) - Slightly slower, ~$0.60/hr
- **L40** (48GB) - Good option, ~$0.80/hr
- **A100 40GB** - Barely enough, not recommended
- **A100 80GB** - Overkill but works, ~$1.50/hr

## Quick Start Commands (Pod Now Running!)
```bash
# SSH into new pod
ssh root@3clxt008hl0a3a.proxy.runpod.net -p 22

# 1. Start Qwen 3 model
cd /workspace
./qwen3.sh

# 2. In new terminal, start simple proxy
./run-proxy.sh
python3 /workspace/proxy.py

# 3. Test it (from your local machine)
curl https://3clxt008hl0a3a-4000.proxy.runpod.net/v1/models

# 4. Test actual completion
curl https://3clxt008hl0a3a-4000.proxy.runpod.net/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9" \
  -d '{
    "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## Copilot Configuration (Updated for New Pod!)
**Endpoint:** https://3clxt008hl0a3a-4000.proxy.runpod.net/v1
**API Key:** sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9
**Model:** Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8

## Why This Matters
- Qwen 3 accepts non-alternating conversation roles (Gemma 3 doesn't)
- Simple proxy strips problematic fields that break Copilot
- 128K context window for large file analysis
- Optimized for code generation

## Monitoring
Run: `./monitor-runpod.sh &` for hourly checks with macOS notifications
