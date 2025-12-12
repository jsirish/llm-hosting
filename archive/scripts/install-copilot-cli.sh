#!/bin/bash
# Install GitHub Copilot CLI on RunPod
# Allows testing the self-hosted LLM directly from terminal

set -e

echo "📦 Installing GitHub Copilot CLI..."

# Install Node.js if not present
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
fi

# Install GitHub Copilot CLI
echo "Installing @githubnext/github-copilot-cli..."
npm install -g @githubnext/github-copilot-cli

# Verify installation
if command -v github-copilot-cli &> /dev/null; then
    echo "✅ GitHub Copilot CLI installed successfully"
    echo ""
    echo "📋 Next steps:"
    echo "  1. Authenticate: github-copilot-cli auth"
    echo "  2. Set custom endpoint (if supported)"
    echo "  3. Test: github-copilot-cli 'write a hello world in python'"
else
    echo "❌ Installation failed"
    exit 1
fi

echo ""
echo "🔧 Our endpoint: https://v5brcrgoclcp1p-4000.proxy.runpod.net/v1"
echo "🔑 API Key: sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9"
