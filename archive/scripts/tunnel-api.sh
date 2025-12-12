#!/bin/bash
# SSH tunnel to access vLLM API locally
# This creates a local port 8000 that forwards to the pod's port 8000

echo "🔌 Creating SSH tunnel to vLLM API..."
echo "Access API at: http://localhost:8000"
echo "Press Ctrl+C to stop the tunnel"
echo ""

ssh -L 8000:localhost:8000 \
    v5brcrgoclcp1p-64411a48@ssh.runpod.io \
    -i ~/.ssh/runpod_ed25519 \
    -N
