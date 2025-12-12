#!/bin/bash
# Qwen3-Coder-30B Configuration and Launcher
# Sets environment variables and starts the generic vLLM server

# Model Configuration
export VLLM_MODEL="Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8"
export VLLM_MODEL_DESCRIPTION="Qwen3-Coder-30B FP8 (Pre-quantized, December 2024)"
export VLLM_MAX_MODEL_LEN=131072  # 128K tokens - maximize context!
export VLLM_GPU_MEMORY_UTIL=0.95
export VLLM_TOOL_PARSER="qwen3_coder"
export VLLM_QUANTIZATION=""       # No extra quantization needed (pre-quantized FP8)

# Performance optimizations (chat template auto-detected from model)
export VLLM_TOKENIZER_MODE="auto"
export VLLM_ENABLE_PREFIX_CACHING="true"

# Optional: Set a persistent API key (otherwise it generates a new one each time)
# export VLLM_API_KEY="sk-your-persistent-key-here"

echo "🔧 Qwen3-Coder-30B Configuration"
echo "================================"
echo "Model: ${VLLM_MODEL}"
echo "Context: ${VLLM_MAX_MODEL_LEN} tokens (128K)"
echo "Tool Parser: ${VLLM_TOOL_PARSER}"
echo ""

# Launch the generic server
exec ../scripts/start-vllm-server.sh
