#!/bin/bash

# Quick start script for the migrated pod
# Pod: petite_coffee_koi-migration (3clxt008hl0a3a)

echo "🚀 Starting everything on the new pod..."
echo "Pod ID: 3clxt008hl0a3a"
echo "Pod Name: petite_coffee_koi-migration"
echo ""

# SSH connection info
POD_SSH="root@3clxt008hl0a3a.proxy.runpod.net"
POD_PORT="22"

echo "📋 To connect to the pod:"
echo "  ssh ${POD_SSH} -p ${POD_PORT}"
echo ""

echo "📋 Once connected, run these commands:"
echo ""
echo "# 1. Start Qwen 3 model (in first terminal)"
echo "cd /workspace && ./qwen3.sh"
echo ""
echo "# 2. Start simple proxy (in second terminal)"
echo "cd /workspace && ./run-proxy.sh && python3 /workspace/proxy.py"
echo ""
echo "# 3. Test from your local machine"
echo "curl https://3clxt008hl0a3a-4000.proxy.runpod.net/v1/models"
echo ""

echo "🔧 VS Code Copilot Configuration:"
echo "  Endpoint: https://3clxt008hl0a3a-4000.proxy.runpod.net/v1"
echo "  API Key: sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9"
echo "  Model: Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8"
echo ""

echo "✅ All files ready on /workspace/ volume (migrated successfully)"
echo "✅ Cost: $0.79/hr"
echo ""

# Optionally SSH in automatically
read -p "Connect to pod now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ssh ${POD_SSH} -p ${POD_PORT}
fi
