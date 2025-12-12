# Continue.dev Setup Checklist

## Step 1: Install vLLM on Pod ✓
```bash
# SSH into pod
ssh 3clxt008hl0a3a@ssh.runpod.io -i ~/.ssh/runpod_ed25519
# Or use: ./connect-runpod.sh

# Run install script (5-10 minutes)
cd /workspace
./install-vllm.sh
```

## Step 2: Upload Scripts to Pod
Since SCP doesn't work via proxy, manually upload these files:

**Files to upload to `/workspace/`:**
1. `kimi-k2.sh` - Chat model launcher
2. `autocomplete.sh` - Autocomplete model launcher
3. `CONTINUE-README.md` - Quick reference

**How to upload each file:**
```bash
# 1. Open file locally (in this directory)
# 2. Copy contents
# 3. SSH into pod: ./connect-runpod.sh
# 4. Create file: nano kimi-k2.sh
# 5. Paste content
# 6. Save: Ctrl+O, Enter, Ctrl+X
# 7. Make executable: chmod +x kimi-k2.sh
# 8. Repeat for other files
```

## Step 3: Start Models on Pod

### Terminal 1: Start Chat Model
```bash
cd /workspace
./kimi-k2.sh
```
Wait 3-5 minutes for model to load. Look for "Uvicorn running" message.

### Terminal 2: Start Autocomplete Model
```bash
cd /workspace
./autocomplete.sh
```
Wait 1-2 minutes for model to load.

## Step 4: Verify Models Are Running
```bash
# Test chat model
curl https://3clxt008hl0a3a-8000.proxy.runpod.net/v1/models \
  -H "Authorization: Bearer sk-vllm-41d3575b25edb67c4a428859379be0a3"

# Test autocomplete model
curl https://3clxt008hl0a3a-8001.proxy.runpod.net/v1/models \
  -H "Authorization: Bearer sk-vllm-41d3575b25edb67c4a428859379be0a3"
```

Both should return JSON with model info. If you get errors, the models are still loading.

## Step 5: Install Continue.dev Extension
1. Open VS Code
2. Press `⌘+Shift+X` (Extensions)
3. Search for "Continue"
4. Click Install
5. Reload VS Code

## Step 6: Configure Continue.dev
```bash
# Copy config to Continue directory
cp continue-config.yaml ~/.continue/config.yaml

# Or create directory if it doesn't exist
mkdir -p ~/.continue
cp continue-config.yaml ~/.continue/config.yaml
```

## Step 7: Test Continue.dev
1. **Test Chat**: Press `⌘+L` → Ask "Write a Python function to reverse a string"
2. **Test Autocomplete**: Open a Python file → Start typing `def hello` → Wait for gray suggestions
3. **Test Edit**: Select some code → Press `⌘+I` → Request changes

## Troubleshooting

### Models won't start
- Check vLLM installed: `pip show vllm`
- Check GPU: `nvidia-smi`
- Check logs: `tail -f /workspace/logs/*.log`

### Continue.dev not connecting
- Verify models running (Step 4)
- Check config file exists: `cat ~/.continue/config.yaml`
- Restart VS Code
- Check Continue output: View → Output → Select "Continue"

### Autocomplete not working
- Make sure autocomplete model is running (port 8001)
- Check Continue settings: disable "Use copy buffer"
- Try typing slowly and waiting 300ms

## Quick Reference

**Pod**: 3clxt008hl0a3a (petite_coffee_koi-migration)
**GPU**: RTX 6000 Ada (48GB VRAM)
**Jupyter**: https://3clxt008hl0a3a-8888.proxy.runpod.net/ (password: 42z5ic3ocbugvss4iuqr)

**Endpoints**:
- Chat: https://3clxt008hl0a3a-8000.proxy.runpod.net/v1
- Autocomplete: https://3clxt008hl0a3a-8001.proxy.runpod.net/v1

**API Key**: sk-vllm-41d3575b25edb67c4a428859379be0a3

**Files**:
- Config: `continue-config.yaml` → `~/.continue/config.yaml`
- Status check: `./check-continue-status.sh`
- Full guide: `CONTINUE-SETUP.md`

## Next Steps After Setup

Once everything is working:
1. ⭐ Bookmark the pod endpoints
2. 📝 Keep Jupyter Lab open for monitoring logs
3. 🚀 Start coding with AI assistance!
4. 💾 Remember: Pod needs to stay running (costs $0.79/hr)

---
Last Updated: December 12, 2025
