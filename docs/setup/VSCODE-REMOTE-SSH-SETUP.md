# VS Code Remote-SSH Setup for RunPod

## Why This Fixes Your Issues

**Current Problem:**
- Copilot runs on Mac → SSH proxy → Pod
- PTY issues ("SSH client doesn't support PTY")
- Nested terminal sessions
- Can't use terminal tools directly

**After Remote-SSH:**
- VS Code runs DIRECTLY on pod
- Copilot executes commands natively
- No PTY/proxy issues
- Full terminal access
- File operations instant (no network lag)

## Step 1: Install VS Code Extension

In VS Code on your Mac:
1. Press `Cmd+Shift+X` (Extensions)
2. Search for "Remote - SSH"
3. Install the extension by Microsoft

## Step 2: Add SSH Host Configuration

### Option A: Automatic (Recommended)

1. Press `Cmd+Shift+P` → Type "Remote-SSH: Add New SSH Host"
2. Paste this exact command:
   ```bash
   ssh root@195.26.233.58 -p 40852 -i ~/.ssh/runpod_ed25519
   ```
3. Select config file: `~/.ssh/config`
4. Click "Connect"

### Option B: Manual Configuration

Add this to `~/.ssh/config`:

```ssh-config
Host runpod-petite-coffee-koi
    HostName 195.26.233.58
    User root
    Port 40852
    IdentityFile ~/.ssh/runpod_ed25519
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

**Why these settings:**
- `StrictHostKeyChecking no` - RunPod IPs change on pod restart
- `UserKnownHostsFile /dev/null` - Don't save host key (IP changes)
- `ServerAliveInterval 60` - Keep connection alive
- `ServerAliveCountMax 3` - Reconnect if connection drops

## Step 3: Connect to Pod

1. Press `Cmd+Shift+P` → "Remote-SSH: Connect to Host"
2. Select `runpod-petite-coffee-koi`
3. New VS Code window opens - this is running ON the pod!
4. In remote window: `File > Open Folder` → `/workspace`

## Step 4: Verify Remote Connection

In the remote VS Code window:

**Check 1: Status Bar**
- Bottom-left corner should show: `SSH: runpod-petite-coffee-koi`

**Check 2: Terminal**
- Open terminal (`Ctrl+\``)
- Run: `pwd` → Should show `/workspace`
- Run: `nvidia-smi` → Should show RTX 6000 Ada

**Check 3: Extensions**
- Some extensions need to be installed ON the remote pod
- VS Code will prompt you to install them remotely

## Step 5: Install Extensions Remotely

When you open the remote connection, install these on the pod:

**Required:**
- GitHub Copilot (install in SSH remote)
- Python (if doing Python work)

**Optional:**
- Continue.dev
- Any other AI coding assistants

VS Code will show "Install in SSH: runpod..." buttons for each extension.

## Step 6: Configure Copilot for Remote

Create `/workspace/.vscode/settings.json` on the pod:

```json
{
  "github.copilot.enable": {
    "*": true,
    "yaml": true,
    "plaintext": true,
    "markdown": true
  },
  "github.copilot.advanced": {
    "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8"
  },
  "terminal.integrated.cwd": "/workspace"
}
```

## Step 7: Test Copilot Agent

1. Open Copilot Chat in remote window
2. Ask: "list files in current directory"
3. Copilot should run `ls` directly on pod (no SSH proxy!)
4. Output should appear immediately without PTY errors

## Benefits You'll Get

✅ **Direct Command Execution**
- Copilot can run any command without SSH nesting
- No more "PTY not supported" errors

✅ **Fast File Operations**
- Editing files is instant (no network lag)
- Large file operations much faster

✅ **Full Terminal Access**
- Native shell experience
- Can run long processes (servers, training)
- Tab completion works properly

✅ **Better Debugging**
- Can attach debugger directly
- No proxy interference

✅ **Persistent Workspace**
- `/workspace` survives pod restarts
- All your code, models, configs preserved

## Important Notes

### IP Address Changes on Pod Restart

When you stop/start the pod, the IP and port WILL change.

**After pod restart:**

1. Get new SSH command from RunPod console
2. Update `~/.ssh/config` with new IP/port
3. Or use the proxy method temporarily:
   ```bash
   ssh v5brcrgoclcp1p-64411a48@ssh.runpod.io -i ~/.ssh/runpod_ed25519
   ```

### Extension Installation

Some extensions (like Copilot) need to be installed TWICE:
- Once on your Mac (local VS Code)
- Once on the pod (remote VS Code)

This is normal - VS Code extensions can run locally or remotely.

### File Paths

When working remotely:
- Your workspace is `/workspace` on the pod
- Mac filesystem is NOT accessible
- Use pod paths: `/workspace/llm-hosting/...`

### API Keys

Copilot settings in remote VS Code should use:
```json
{
  "continue.apiBase": "http://localhost:8000/v1",
  "openai.apiBase": "http://localhost:8000/v1"
}
```

Note `localhost` not the public URL - you're on the pod now!

## Troubleshooting

### "Permission denied (publickey)"
- Check key exists: `ls -la ~/.ssh/runpod_ed25519`
- Check permissions: `chmod 600 ~/.ssh/runpod_ed25519`

### "Connection timeout"
- Verify pod is running in RunPod console
- Check IP/port haven't changed
- Try proxy method as fallback

### "Bad owner or permissions on ~/.ssh/config"
```bash
chmod 600 ~/.ssh/config
```

### Extensions not working remotely
- Reinstall extension in remote window
- Check extension supports remote SSH (most do)

## Quick Command Reference

```bash
# Connect via Remote-SSH
# (Use VS Code UI: Cmd+Shift+P → Remote-SSH: Connect)

# Or from terminal (for testing):
ssh root@195.26.233.58 -p 40852 -i ~/.ssh/runpod_ed25519

# Check you're on the pod:
hostname  # Should show: v5brcrgoclcp1p-...
pwd       # Should show: /workspace or /root
nvidia-smi  # Should show: RTX 6000 Ada

# Start vLLM server (from remote terminal):
cd /workspace
./qwen.sh

# Test API (from remote terminal):
./test-api.sh
```

## Next Steps After Setup

1. ✅ Connect via Remote-SSH
2. ✅ Open `/workspace` folder
3. ✅ Install Copilot remotely
4. ✅ Test Copilot commands work natively
5. ✅ Start vLLM server from remote terminal
6. ✅ Configure extensions to use `localhost:8000`
7. ✅ Enjoy full Copilot functionality without PTY issues!

## Cost Consideration

Remote-SSH keeps VS Code connected to the pod, which means:
- Pod must stay running ($0.78/hour)
- Good for active coding sessions
- Remember to stop pod when done to save money
- Or switch to proxy SSH for quick checks

## Summary

Your pod **ALREADY SUPPORTS** direct SSH! Just:
1. Install Remote-SSH extension
2. Add config with IP `195.26.233.58` port `40852`
3. Connect and work directly on pod
4. No more PTY issues, full Copilot functionality

**Current SSH Info:**
- IP: 195.26.233.58
- Port: 40852
- Key: ~/.ssh/runpod_ed25519
- User: root

This will completely solve your Copilot terminal issues!
