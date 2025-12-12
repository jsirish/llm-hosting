# 🚀 Quick Start Guide

## What You Need to Do Right Now

### Step 1: Expose Port 8000 in RunPod
**This is the missing piece!**

1. Open browser to: https://console.runpod.io/pods
2. Find your pod: `petite_coffee_koi`
3. Click the **☰ hamburger menu** (bottom-left of pod card)
4. Click **"Edit Pod"**
5. Find: **"Expose HTTP Ports (Max 10)"**
6. Change from: `8888`
7. Change to: `8888,8000` (add port 8000)
8. Click **"Save"** or **"Update"**

⚠️ **Note:** Pod may restart (takes ~5 min to reload model)

---

### Step 2: Upload New Scripts to Pod

The scripts are ready on your Mac. Copy them to the pod:

**Option A: Via Web Terminal**
1. Go to: https://v5brcrgoclcp1p-19123.proxy.runpod.net/b6472jb6g7sa0bdoxdie9l6jrcen530q/
2. Create files using `nano`:
   ```bash
   cd /workspace
   nano start-server.sh    # Copy from your Mac, Ctrl+X to save
   nano stop-server.sh     # Copy from your Mac, Ctrl+X to save
   nano check-server.sh    # Copy from your Mac, Ctrl+X to save
   chmod +x *.sh
   ```

**Option B: Copy/Paste via SSH**
1. `ssh v5brcrgoclcp1p-64411a48@ssh.runpod.io -i ~/.ssh/runpod_ed25519`
2. Same as Option A

---

### Step 3: Start Server in Background

On the pod (via SSH or web terminal):

```bash
cd /workspace

# If server is currently running in foreground, stop it first:
# Press Ctrl+C in that terminal

# Start with new script
./start-server.sh
```

You should see:
```
🔐 API Key: sk-vllm-a1b2c3d4e5f6...
   (Save this! You'll need it for API requests)

✅ Server started successfully!
PID: 12345
Log file: /workspace/logs/vllm-server.log
API Key file: /workspace/logs/api-key.txt
```

**🔐 IMPORTANT: Save the API key!** You'll need it for all requests.

---

### Step 4: Get Your API Key

On the pod:
```bash
cat /workspace/logs/api-key.txt
```

**Copy this key** - you'll need it for API requests!

---

### Step 5: Test It!

**From the pod (automatic - uses saved key):**
```bash
./test-api.sh
```

**From your Mac (after port is exposed):**
```bash
cd /Users/jsirish/AI/llm-hosting

# Set your API key
export VLLM_API_KEY="sk-vllm-YOUR_KEY_HERE"

# Run tests
./test-api-local.sh
```

**Or manually:**
```bash
curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/health \
  -H "Authorization: Bearer sk-vllm-YOUR_KEY_HERE"
```

Expected response:
```json
{"status":"ok"}
```

---

## Alternative: Use SSH Tunnel (Works Immediately)

**If you don't want to wait for port exposure:**

On your Mac:
```bash
# Terminal 1: Start tunnel
./tunnel-api.sh

# Terminal 2: Test API
curl http://localhost:8000/health
```

This works right now, but only while tunnel is running.

---

## Useful Commands

### On Pod:
```bash
./start-server.sh          # Start server in background
./check-server.sh          # Check if running
./stop-server.sh           # Stop server
tail -f /workspace/logs/vllm-server.log  # Watch logs
```

### On Mac:
```bash
./tunnel-api.sh            # Create SSH tunnel
./test-api-local.sh        # Test via RunPod proxy
curl http://localhost:8000/health  # Test via tunnel
```

---

## What Changed?

1. ✅ **start-server.sh** now runs in background with logging
2. ✅ **stop-server.sh** added for clean shutdown
3. ✅ **check-server.sh** added for status monitoring
4. ✅ Logs saved to `/workspace/logs/vllm-server.log`
5. ✅ Server survives SSH disconnects
6. ✅ Complete documentation in `RUNPOD-PORT-EXPOSURE.md`

---

## Troubleshooting

### Port 8000 returns 404:
- **Cause:** Port not exposed in RunPod yet
- **Fix:** Follow Step 1 above

### Server won't start:
```bash
# Check what's wrong
./check-server.sh

# View logs
tail -50 /workspace/logs/vllm-server.log

# Try stopping first
./stop-server.sh

# Start again
./start-server.sh
```

### Can't find RunPod UI option:
- Look for the **hamburger menu icon** (three horizontal lines)
- It's in the **bottom-left** corner of your pod card
- See screenshots in `RUNPOD-PORT-EXPOSURE.md`

---

## 🎯 Success Checklist

- [ ] Port 8000 exposed in RunPod UI
- [ ] New scripts uploaded to pod
- [ ] Scripts made executable (`chmod +x *.sh`)
- [ ] Server started with `./start-server.sh`
- [ ] Health check returns `{"status":"ok"}`
- [ ] Can access via public URL

---

## 📚 More Info

- **Port Exposure:** `RUNPOD-PORT-EXPOSURE.md`
- **Complete Update:** `UPDATE-SUMMARY.md`
- **Command Reference:** `QUICK-REFERENCE.md`
- **Deployment Info:** `RUNPOD-DEPLOYED.md`
