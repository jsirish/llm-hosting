#!/bin/bash
# Quick script to retrieve the current API key from the RunPod server

echo "🔐 Retrieving current API key from RunPod..."
echo ""

ssh -T v5brcrgoclcp1p-64411a48@ssh.runpod.io -i ~/.ssh/runpod_ed25519 "cat /workspace/logs/api-key.txt 2>/dev/null || echo 'No API key file found'"
