# VS Code Remote-SSH - Ready to Connect! 🚀

## ✅ Setup Complete

Your SSH config is ready for VS Code Remote-SSH:

```ssh
Host runpod
    HostName ssh.runpod.io
    User v5brcrgoclcp1p-64411a48
    IdentityFile ~/.ssh/id_ed25519
```

## 🎯 Next Steps

### 1. Install Remote-SSH Extension

In VS Code:
1. Press `Cmd+Shift+X` (Extensions)
2. Search for "Remote - SSH"
3. Install the one by Microsoft

### 2. Connect to RunPod

1. Press `Cmd+Shift+P`
2. Type: "Remote-SSH: Connect to Host"
3. Select: **runpod**
4. New VS Code window opens (connected to pod!)

### 3. Open Workspace

In the new remote window:
1. `File > Open Folder`
2. Enter: `/workspace`
3. Click OK

### 4. Install Extensions Remotely

VS Code will show "Install in SSH: runpod" buttons for:
- GitHub Copilot
- Python
- Any other extensions you use

Click to install them on the remote pod.

### 5. Test Copilot

1. Open Copilot Chat
2. Ask: "list files in /workspace"
3. Copilot should execute commands directly on the pod!

## 📝 Important Notes

### PTY Limitations (Minor Issue)
The proxy SSH has PTY limitations, but:
- ✅ VS Code file editing works perfectly
- ✅ Code execution works
- ✅ Most commands work
- ⚠️ Some interactive terminal commands may have issues
- ✅ You can use RunPod's Web Terminal for those cases

### What Will Work Great
- ✅ File editing (instant, no lag)
- ✅ GitHub Copilot (most features)
- ✅ Running scripts
- ✅ Python debugger
- ✅ Git operations
- ✅ Search/replace across files
- ✅ Terminal for most commands

### Connection Stability
- ✅ No port changes (proxy handles routing)
- ✅ Automatic reconnection
- ✅ ServerAliveInterval keeps connection active

## 🔧 Troubleshooting

### "Could not establish connection"
- Check pod is running in RunPod console
- Verify pod ID hasn't changed (if you recreated pod)

### Extensions not showing
- Make sure you're in the remote window (bottom-left shows "SSH: runpod")
- Reinstall extension by clicking "Install in SSH: runpod"

### Terminal commands fail
- Some commands need PTY (rare)
- Use RunPod Web Terminal for those
- Or run via VS Code's "Run" buttons

## 🎮 Ready to Use!

You're all set! Just:
1. Install Remote-SSH extension
2. `Cmd+Shift+P` → "Remote-SSH: Connect to Host" → runpod
3. Open `/workspace` folder
4. Start coding!

## 💡 Pro Tips

- The remote connection stays open as long as VS Code is running
- Files edit instantly (no network lag)
- Terminal opens directly on the pod
- Can run vLLM server from integrated terminal
- Copilot will execute commands natively

## 🚀 After Connecting

Test your setup:
```bash
# In remote VS Code terminal:
cd /workspace
./check-server.sh  # Check vLLM status
./qwen.sh          # Start Qwen model
./test-api.sh      # Test API
```

All commands run directly on the pod - no SSH proxy needed!
