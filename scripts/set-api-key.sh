#!/bin/bash

# Set vLLM API Key
# Usage: source scripts/set-api-key.sh

export VLLM_API_KEY="sk-vllm-c9be6c31b9f1ebd5bc5a316ac7d71381"

echo "✅ vLLM API key set: ${VLLM_API_KEY}"
echo ""
echo "To make this permanent, add to ~/.zshrc:"
echo "  export VLLM_API_KEY=\"${VLLM_API_KEY}\""
