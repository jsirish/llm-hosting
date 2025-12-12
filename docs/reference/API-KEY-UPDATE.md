# 🔐 API Key Update - Quick Summary

## What Changed

All scripts now include **API key authentication** for security!

---

## Why This Matters

**Before:** Anyone who finds your RunPod URL can use your GPU (costs you $0.78/hr!)

**After:** Only requests with valid API key are processed ✅

---

## What to Upload to Pod

| File | Status | Purpose |
|------|--------|---------|
| **start-server.sh** | ⚠️ UPDATED | Now generates & uses API key |
| **test-api.sh** | ⚠️ UPDATED | Automatically loads key |
| **stop-server.sh** | ✅ Same | No changes |
| **check-server.sh** | ✅ Same | No changes |

---

## Quick Start

### 1. Upload Scripts to Pod
Copy all 4 scripts to `/workspace/` on your pod

### 2. Make Executable
```bash
chmod +x *.sh
```

### 3. Start Server
```bash
./start-server.sh
```

**SAVE THE API KEY IT SHOWS!**

### 4. Test (On Pod)
```bash
./test-api.sh
```

### 5. Test (From Mac)
```bash
# Get your key first
ssh to pod: cat /workspace/logs/api-key.txt

# Set it
export VLLM_API_KEY="YOUR_KEY_HERE"

# Test
./test-api-local.sh
```

---

## How API Key Works

### Server Side:
- Server generates random key: `sk-vllm-a1b2c3d4e5f6...`
- Saves to: `/workspace/logs/api-key.txt`
- Starts with: `--api-key "YOUR_KEY"`

### Client Side:
All requests must include:
```
Authorization: Bearer YOUR_KEY_HERE
```

---

## Files & Locations

**On Pod:**
- `/workspace/logs/api-key.txt` - Your API key
- `/workspace/logs/vllm-server.log` - Server logs
- `/workspace/logs/vllm-server.pid` - Process ID

**On Mac:**
- Set `VLLM_API_KEY` environment variable
- Or modify scripts with your key

---

## Updated Scripts Summary

### start-server.sh
**NEW:**
- Generates secure API key (or uses `$VLLM_API_KEY` env var)
- Saves key to `/workspace/logs/api-key.txt`
- Adds `--api-key` parameter to vLLM
- Shows key on startup

### test-api.sh
**NEW:**
- Loads key from `/workspace/logs/api-key.txt`
- Adds `Authorization: Bearer` header to all requests
- Shows error if key file not found

### test-api-local.sh
**NEW:**
- Uses `$VLLM_API_KEY` environment variable
- Warns if key not set
- Adds `Authorization` header to all requests

---

## Custom API Key (Optional)

Want to use your own key?

```bash
# Generate a strong key
openssl rand -hex 32

# Set before starting
export VLLM_API_KEY="your-custom-key-here"
./start-server.sh
```

---

## Troubleshooting

### "Not ready" in RunPod UI
**Cause:** Server not running or crashed

**Fix:**
```bash
./check-server.sh              # Check status
tail -50 /workspace/logs/vllm-server.log  # Check logs
./stop-server.sh               # Stop if stuck
./start-server.sh              # Restart
```

### "Unauthorized" or "Invalid API key"
**Cause:** Missing or wrong API key

**Fix:**
```bash
# On pod, get your key
cat /workspace/logs/api-key.txt

# Use it in requests
curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/health \
  -H "Authorization: Bearer YOUR_KEY_FROM_FILE"
```

### Can't find API key file
**Cause:** Server wasn't started with new script

**Fix:**
```bash
./stop-server.sh
./start-server.sh
# Key will be generated
```

---

## Complete Documentation

| Document | What It Covers |
|----------|----------------|
| **API-KEY-GUIDE.md** | Complete API key documentation |
| **START-HERE.md** | Updated quick start (with API key) |
| **FILE-GUIDE.md** | All files and their purposes |
| **RUNPOD-PORT-EXPOSURE.md** | How to expose port 8000 |

---

## Testing Checklist

### On Pod:
- [ ] Scripts uploaded
- [ ] Made executable: `chmod +x *.sh`
- [ ] Server started: `./start-server.sh`
- [ ] API key saved from startup output
- [ ] Key file exists: `cat /workspace/logs/api-key.txt`
- [ ] Test passed: `./test-api.sh`

### From Mac:
- [ ] Port 8000 exposed in RunPod UI
- [ ] API key copied from pod
- [ ] Environment variable set: `export VLLM_API_KEY="..."`
- [ ] Test passed: `./test-api-local.sh`

---

## Security Best Practices

✅ **DO:**
- Keep API key secret
- Store in environment variables
- Rotate keys every 30-90 days
- Monitor RunPod usage dashboard

❌ **DON'T:**
- Commit keys to git
- Share keys in chat/email
- Use weak/predictable keys
- Leave server running when not in use

---

## Next Steps

1. **Upload the 4 scripts** to your pod
2. **Stop any running server**
3. **Start with new script**: `./start-server.sh`
4. **Save the API key** it displays
5. **Test locally** on pod: `./test-api.sh`
6. **Test remotely** from Mac (after setting `VLLM_API_KEY`)

---

## Need Help?

- **API Key basics:** Read `API-KEY-GUIDE.md`
- **Port not exposed:** Read `RUNPOD-PORT-EXPOSURE.md`
- **Server issues:** Check `UPDATE-SUMMARY.md`
- **Commands:** See `QUICK-REFERENCE.md`

🔐 **Your API is now secure!**
