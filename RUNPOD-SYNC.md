# Syncing to RunPod

## Initial Setup on RunPod

SSH to your RunPod instance and run:

```bash
# Navigate to workspace
cd /workspace

# Clone the repository
git clone https://github.com/jsirish/llm-hosting.git

# Enter directory
cd llm-hosting

# Setup HuggingFace token (for gated models)
scripts/setup-hf-token.sh
# Enter your HF token when prompted

# Make scripts executable (should already be, but just in case)
chmod +x models/*.sh scripts/*.sh
```

## Updating Code on RunPod

When you make changes locally and push to GitHub:

```bash
# On RunPod, navigate to repo
cd /workspace/llm-hosting

# Pull latest changes
git pull origin main

# Restart server with updated scripts
# Stop current server
kill $(cat /workspace/logs/vllm-server.pid) 2>/dev/null || true

# Start with updated script
models/gptoss.sh  # or whichever model you're using
```

## Environment Variables

**Important**: The scripts no longer have hardcoded tokens!

Set these before running:

```bash
# HuggingFace token (for downloading gated models)
export HF_TOKEN="your_hf_token_here"

# Or use the setup script
scripts/setup-hf-token.sh
```

The script will save your token to `~/.huggingface/token` so you only need to do this once.

## Quick Sync Workflow

**Local (your machine)**:
```bash
# Make changes
git add -A
git commit -m "Your changes"
git push origin main
```

**RunPod**:
```bash
cd /workspace/llm-hosting
git pull origin main
# Restart server if needed
```

## Repository Details

- **GitHub URL**: https://github.com/jsirish/llm-hosting
- **Branch**: main
- **Public Repository**: Yes (accessible without authentication)
- **No Secrets**: All tokens/keys must be set via environment variables

## First Time Checklist on RunPod

- [ ] Clone repository to `/workspace/llm-hosting`
- [ ] Run `scripts/setup-hf-token.sh` with your HF token
- [ ] Verify scripts are executable: `ls -la models/*.sh scripts/*.sh`
- [ ] Start a model: `models/gptoss.sh` or `models/qwen.sh`
- [ ] Get API key: `cat /workspace/logs/api-key.txt`
- [ ] Update Continue config with new API key

## Notes

- Models will be cached in `/workspace/hf-cache` (persistent)
- Logs are in `/workspace/logs/`
- API key changes with each server restart
- All old test scripts are in `archive/` directory
