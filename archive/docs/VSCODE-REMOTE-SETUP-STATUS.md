# VS Code Remote-SSH Setup - COMPLETED

## ✅ What Was Done

### 1. SSH Config Created
Added to `~/.ssh/config`:
```ssh
Host runpod-petite-coffee-koi
    HostName 195.26.233.58
    User root
    Port 47721
    IdentityFile ~/.ssh/runpod_ed25519
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 60
    ServerAliveCountMax 3
    LogLevel QUIET

Host runpod
    (same settings, short alias)
```

### 2. SSH Keys Linked
Created symlinks so RunPod's expected `id_ed25519` points to `runpod_ed25519`:
```bash
~/.ssh/id_ed25519 -> ~/.ssh/runpod_ed25519
~/.ssh/id_ed25519.pub -> ~/.ssh/runpod_ed25519.pub
```

### 3. Current Status
- ✅ SSH config file created
- ✅ Key files linked properly
- ⚠️ TCP port 47721 not accessible (connection refused)
- ✅ Proxy SSH works (but has PTY limitations)

## ⚠️ TCP SSH Port Issue

The direct TCP connection (`195.26.233.58:47721`) is refusing connections. This could be:

1. **Firewall blocking** - RunPod's firewall might block external TCP SSH
2. **Pod template limitation** - Template might not enable TCP SSH by default
3. **Port not properly exposed** - TCP SSH feature might not be active

## 🔧 Solutions

### Option A: Use VS Code with Proxy SSH (WORKAROUND)

Even though the proxy SSH has PTY limitations for terminal commands, **VS Code Remote-SSH can still work**:

1. **Modify SSH config** to use proxy method:
   ```ssh
   Host runpod-proxy
       HostName ssh.runpod.io
       User v5brcrgoclcp1p-64411a48
       IdentityFile ~/.ssh/runpod_ed25519
       StrictHostKeyChecking no
       UserKnownHostsFile /dev/null
       ServerAliveInterval 60
       ServerAliveCountMax 3
   ```

2. **Connect in VS Code**:
   - `Cmd+Shift+P` → "Remote-SSH: Connect to Host"
   - Select `runpod-proxy`
   - Open folder `/workspace`

3. **Limitations**:
   - Interactive terminal commands might still have PTY issues
   - But file editing, code execution, and most Copilot features will work
   - Can run commands via "Run" buttons in VS Code

### Option B: Enable Web Terminal (ALTERNATIVE)

RunPod has a "Web terminal" feature:

1. Go to RunPod console → Connect tab
2. Enable "Web terminal"
3. Use browser-based terminal (no PTY issues)
4. Still use VS Code locally, terminal in browser

### Option C: Fix TCP SSH (BEST, but requires investigation)

**To properly enable TCP SSH:**

1. **Check if template supports it**:
   - Some RunPod templates don't enable SSH server on TCP port
   - You might need a different template

2. **Verify port is exposed**:
   - RunPod console → Connect → "SSH over exposed TCP"
   - If it shows a port, it should work
   - If connection refused, contact RunPod support

3. **Alternative: Try different port**:
   The console shows both:
   - SSH: port 22 (internal)
   - Exposed: port 47721 (external)

   Maybe the mapping isn't working?

## 📝 Next Steps

### Immediate Solution (Try This First)

Add proxy SSH to config and use it with VS Code Remote-SSH:

```bash
cat >> ~/.ssh/config << 'EOF'

# RunPod Proxy (workaround for TCP SSH issues)
Host runpod-proxy
    HostName ssh.runpod.io
    User v5brcrgoclcp1p-64411a48
    IdentityFile ~/.ssh/runpod_ed25519
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 60
    ServerAliveCountMax 3
    LogLevel QUIET
    RequestTTY no
EOF
```

Then in VS Code:
1. Install "Remote - SSH" extension
2. `Cmd+Shift+P` → "Remote-SSH: Connect to Host"
3. Select `runpod-proxy`
4. Open folder: `/workspace`
5. Install Copilot in remote session

**This should work** even with PTY limitations because:
- VS Code doesn't rely on PTY for file operations
- Code execution uses different mechanisms
- Only interactive terminal has issues

### Test Connection First

```bash
# Test proxy connection (should work)
ssh runpod-proxy "pwd; ls -la /workspace" 2>&1 | grep -v "PTY"

# If that works, VS Code Remote-SSH should work too
```

## 🎯 Expected Outcome

Once connected via Remote-SSH (even with proxy):

✅ **What Will Work:**
- File editing (instant, no lag)
- Running scripts
- Code execution
- GitHub Copilot (most features)
- Python debugger
- Git operations
- File search

⚠️ **What Might Have Issues:**
- Interactive terminal (PTY limitations)
- Commands requiring terminal input
- Terminal-based editors (nano, vim)

But you can use the Web Terminal in RunPod console for those cases!

## 📊 Status Summary

| Feature | Status | Notes |
|---------|--------|-------|
| SSH Config | ✅ Created | `~/.ssh/config` updated |
| Key Linking | ✅ Done | `id_ed25519` → `runpod_ed25519` |
| Direct TCP SSH | ❌ Not working | Port 47721 connection refused |
| Proxy SSH | ✅ Works | PTY limitations |
| VS Code Remote-SSH | 🟡 Can work | Use proxy method |
| Copilot on Remote | 🟡 Should work | File operations OK |

## 🚀 Ready to Connect

**Run this now to test:**

```bash
# Add proxy config
cat >> ~/.ssh/config << 'EOF'

Host runpod-proxy
    HostName ssh.runpod.io
    User v5brcrgoclcp1p-64411a48
    IdentityFile ~/.ssh/runpod_ed25519
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 60
    ServerAliveCountMax 3
    RequestTTY no
EOF

# Test it
echo "Testing connection..."
ssh runpod-proxy "echo '✅ SSH works!'; pwd" 2>&1 | grep -v "PTY" | grep -v "doesn't support"
```

If that prints `/root` or `/workspace`, you're ready to use Remote-SSH!

**Then in VS Code:**
1. Press `Cmd+Shift+P`
2. Type "Remote-SSH: Connect to Host"
3. Select `runpod-proxy`
4. New window opens → Open folder `/workspace`
5. Install extensions remotely
6. Start coding with Copilot!

## 🔍 Troubleshooting Direct TCP

If you want to fix the direct TCP SSH (for better performance):

1. **Check pod status:**
   ```bash
   # Via proxy
   ssh runpod-proxy "systemctl status sshd" 2>&1 | grep -v PTY
   ```

2. **Check what's listening on port 22:**
   ```bash
   ssh runpod-proxy "netstat -tlnp | grep :22" 2>&1 | grep -v PTY
   ```

3. **Try telnet to test port:**
   ```bash
   telnet 195.26.233.58 47721
   ```
   If it connects, SSH should work. If refused, port mapping is broken.

4. **Contact RunPod Support** if port mapping is broken

Current SSH details:
- Pod ID: v5brcrgoclcp1p
- IP: 195.26.233.58
- TCP Port: 47721
- Status: Connection refused (needs investigation)
