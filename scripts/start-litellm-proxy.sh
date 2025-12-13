#!/bin/bash
# Start LiteLLM Proxy
# Runs on port 4000 and normalizes vLLM responses for Continue.dev

echo "🚀 Starting LiteLLM proxy..."
echo "Port: 4000"
echo "Config: /workspace/litellm-config.yaml"
echo ""

# Check if config exists
if [ ! -f "/workspace/litellm-config.yaml" ]; then
    echo "❌ Error: /workspace/litellm-config.yaml not found"
    echo "Run: ./scripts/setup-litellm-proxy.sh first"
    exit 1
fi

# Check if vLLM is running
if ! curl -s http://localhost:8000/v1/models > /dev/null 2>&1; then
    echo "⚠️  Warning: vLLM doesn't appear to be running on port 8000"
    echo "Start vLLM first: ./models/qwen.sh"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Start LiteLLM proxy
echo "Starting LiteLLM..."
litellm --config /workspace/litellm-config.yaml --port 4000 --host 0.0.0.0

# If the above command fails, try with --detailed_debug
# litellm --config /workspace/litellm-config.yaml --port 4000 --host 0.0.0.0 --detailed_debug
