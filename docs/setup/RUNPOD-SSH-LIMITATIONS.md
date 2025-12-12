# RunPod SSH Limitations

## Issue
RunPod's SSH proxy requires PTY (pseudo-terminal) allocation and doesn't support non-interactive SSH commands.

## What Works
✅ Interactive SSH sessions with `-t` flag:
```bash
./connect-runpod.sh
# Then run commands inside the session
```

## What Doesn't Work
❌ Non-interactive SSH commands:
```bash
ssh user@host "command"  # Fails with "doesn't support PTY"
```

## Solution: Use Interactive Sessions

### To Check Logs:
```bash
# 1. Connect interactively
./connect-runpod.sh

# 2. Then run commands:
tail -50 /workspace/logs/vllm-server.log
tail -f /workspace/logs/vllm-server.log  # Real-time
grep -i error /workspace/logs/vllm-server.log
```

### To Check API Key:
```bash
# 1. Connect interactively
./connect-runpod.sh

# 2. Then run:
cat /workspace/logs/api-key.txt
```

### To Check Server Status:
```bash
# 1. Connect interactively
./connect-runpod.sh

# 2. Then run:
./check-server.sh
```

## Alternative: RunPod Web Terminal
You can also use RunPod's web-based terminal:
1. Go to https://www.runpod.io/console/pods
2. Click on your pod (petite_coffee_koi)
3. Click "Connect" → "Start Web Terminal"
4. Run commands directly in the browser

## File Transfer Workaround
Since SCP also doesn't work, use one of these methods:

### Method 1: Copy-Paste (Recommended)
1. Open file locally
2. SSH into pod: `./connect-runpod.sh`
3. Create/edit file: `nano filename.sh`
4. Paste content
5. Save: Ctrl+O, Enter, Ctrl+X

### Method 2: Echo to File
```bash
./connect-runpod.sh
# Then:
cat > filename.sh << 'EOF'
# Paste your content here
EOF
chmod +x filename.sh
```

### Method 3: Use RunPod Volume
- Upload files to a cloud storage (Google Drive, Dropbox, etc.)
- Download from inside the pod using `wget` or `curl`

## Summary
For RunPod, always use **interactive SSH sessions** (`./connect-runpod.sh`) rather than trying to run commands remotely.
