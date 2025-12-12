# RunPod Port Exposure Guide

## How to Expose Port 8000 for vLLM API

Based on RunPod documentation, here are the methods to expose your vLLM server running on port 8000.

---

## Method 1: Edit Existing Pod (Recommended)

### Steps:
1. Go to [RunPod Pods Console](https://console.runpod.io/pods)
2. Find your pod: **petite_coffee_koi** (`v5brcrgoclcp1p`)
3. Click the **hamburger menu** (☰) on the bottom-left of the pod card
4. Select **"Edit Pod"**
5. Find the field: **"Expose HTTP Ports (Max 10)"**
6. Add port: `8000` (if there are existing ports, add as comma-separated: `8888,8000`)
7. Click **"Save"** or **"Update Pod"**

### After Saving:
- Your vLLM API will be accessible at:
  ```
  https://v5brcrgoclcp1p-8000.proxy.runpod.net
  ```
- The pod may restart briefly (should take < 1 minute)
- Your model will need to reload (this takes ~5 minutes with the startup script)

---

## Method 2: Edit Pod Template

If you created this pod from a template, you can update the template for future deployments:

1. Go to [My Templates](https://console.runpod.io/user/templates)
2. Find your template
3. Click **"Edit"**
4. Add `8000` to **"Expose HTTP Ports"**
5. Save the template

This won't affect your current pod but will apply to new pods created from this template.

---

## Method 3: SSH Tunnel (Immediate Access)

If you don't want to restart the pod or need immediate access:

### On your local machine:
```bash
./tunnel-api.sh
```

This creates a tunnel where `http://localhost:8000` on your machine connects to port 8000 on the pod.

### Test it:
```bash
# In another terminal
curl http://localhost:8000/health
```

**Note:** The tunnel only works while the script is running. Press Ctrl+C to stop it.

---

## RunPod HTTP Proxy Details

### URL Format:
```
https://[POD_ID]-[PORT].proxy.runpod.net
```

For your pod:
- Pod ID: `v5brcrgoclcp1p`
- Port: `8000`
- **Full URL**: `https://v5brcrgoclcp1p-8000.proxy.runpod.net`

### Proxy Architecture:
```
Your Request → Cloudflare → RunPod Load Balancer → Your Pod
```

### Important Limitations:
- **100-second timeout**: Requests must complete within 100 seconds
- **HTTPS only**: All connections are automatically secured with HTTPS
- **Publicly accessible**: Anyone with the URL can access (implement authentication!)
- **Stable for Secure Cloud**: Your public IP/port should remain stable
- **May change for Community Cloud**: IP/port may change on pod restart

### Best Practices:
1. **Implement authentication** in your application (API keys, tokens)
2. **Use rate limiting** to prevent abuse
3. **Monitor your usage** to avoid unexpected costs
4. For long-running operations (>100s), use async patterns:
   - Return job IDs immediately
   - Provide status check endpoints
   - Use polling for completion

---

## TCP Port Exposure (Alternative)

If you need direct TCP access or lower latency:

1. Edit pod → Add `8000` to **"Expose TCP Ports"**
2. Find your public IP mapping in the **"Connect"** menu under **"Direct TCP Ports"**
3. Access format: `http://PUBLIC_IP:EXTERNAL_PORT`

**Warning:** TCP port mappings change on pod restart!

---

## Verify Exposure

After exposing port 8000 via HTTP:

```bash
# Test from your local machine
./test-api-local.sh
```

Or manually:
```bash
curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/health
```

Expected response:
```json
{"status": "ok"}
```

---

## Current Status

Your pod currently has:
- ✅ Port 8888 exposed (Jupyter Lab)
- ✅ Port 19123 exposed (Web Terminal)
- ❌ Port 8000 NOT YET EXPOSED (vLLM API)

**Action Required:** Follow Method 1 above to expose port 8000.

---

## Troubleshooting

### Port not accessible after adding:
1. Wait 1-2 minutes for pod to fully restart
2. Check server is running: `./check-server.sh` (via SSH)
3. Verify port binding: `netstat -tlnp | grep 8000`

### 404 Error:
- Port hasn't been added to pod configuration yet
- Server isn't running on port 8000

### 524 Timeout Error:
- Your request took longer than 100 seconds
- Implement async/polling pattern for long operations

### Connection Refused:
- Server crashed or stopped
- Check logs: `tail -f /workspace/logs/vllm-server.log`
- Restart: `./start-server.sh`

---

## vLLM Logging Configuration

The updated `start-server.sh` script now includes:

### Built-in Features:
- ✅ Background execution with `nohup`
- ✅ Logs saved to `/workspace/logs/vllm-server.log`
- ✅ PID tracking for process management
- ✅ Automatic startup verification
- ✅ Max log length: 1000 characters (`--max-log-len 1000`)

### vLLM Environment Variables (Optional):
You can customize logging further:

```bash
# Disable vLLM's default logging
export VLLM_CONFIGURE_LOGGING=0

# Set custom logging level (DEBUG, INFO, WARNING, ERROR)
export VLLM_LOGGING_LEVEL=INFO

# Set log prefix
export VLLM_LOGGING_PREFIX="[vLLM]"

# Set stats logging interval (seconds)
export VLLM_LOG_STATS_INTERVAL=10.0
```

### Useful Commands:
```bash
# Start server in background
./start-server.sh

# Check server status
./check-server.sh

# Monitor logs in real-time
tail -f /workspace/logs/vllm-server.log

# Stop server
./stop-server.sh

# View last 50 log lines
tail -50 /workspace/logs/vllm-server.log

# Search logs for errors
grep -i error /workspace/logs/vllm-server.log
```

---

## Next Steps

1. **Expose port 8000** using Method 1 above
2. **Upload updated scripts** to your pod:
   - `start-server.sh` (updated with background execution & logging)
   - `stop-server.sh` (new)
   - `check-server.sh` (new)
3. **Stop current server** (if running in foreground)
4. **Start with new script**: `./start-server.sh`
5. **Test the API** via public URL
