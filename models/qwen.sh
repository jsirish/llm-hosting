#!/bin/bash
# Qwen 3 Coder 30B FP8 Configuration and Launcher
# Sets environment variables and starts the generic vLLM server

# HuggingFace Token (for gated models)
# Set via: export HF_TOKEN="your_token_here" or run scripts/setup-hf-token.sh
export HF_TOKEN="${HF_TOKEN:-}"

# Model Configuration
export VLLM_MODEL="Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8"
export VLLM_MODEL_DESCRIPTION="Qwen 3 Coder 30B Instruct (FP8 Quantized)"
export VLLM_SERVED_MODEL_NAME="Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8"
export VLLM_MAX_MODEL_LEN=131072     # 128K tokens
export VLLM_GPU_MEMORY_UTIL=0.95     # Maximum GPU memory utilization
export VLLM_TOOL_PARSER="qwen3_coder"
export VLLM_QUANTIZATION=""          # Auto-detected from model

# Performance optimizations
export VLLM_TOKENIZER_MODE="auto"
export VLLM_ENABLE_PREFIX_CACHING="true"

# Optional: Set a persistent API key (otherwise it generates a new one each time)
# export VLLM_API_KEY="your-api-key-here"

echo "🔧 Qwen 3 Coder 30B FP8 Configuration"
echo "====================================="
echo "Model: ${VLLM_MODEL}"
echo "Description: ${VLLM_MODEL_DESCRIPTION}"
echo "Context: ${VLLM_MAX_MODEL_LEN} tokens (128K)"
echo "GPU Memory: ${VLLM_GPU_MEMORY_UTIL} (maximized)"
echo "Tool Parser: ${VLLM_TOOL_PARSER}"
echo ""

# Launch the generic server (use absolute path on RunPod)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/../scripts/start-vllm-server.sh"
