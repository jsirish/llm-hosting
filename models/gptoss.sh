#!/bin/bash
# GPT-OSS-20B Configuration and Launcher
# Sets environment variables and starts the generic vLLM server
#
# ⚠️ NOTE: Model not currently available on HuggingFace
# This script is ready if/when the model becomes available

# Model Configuration
export VLLM_MODEL="openai/gpt-oss-20b"
export VLLM_MODEL_DESCRIPTION="GPT-OSS-20B (OpenAI Open Source)"
export VLLM_SERVED_MODEL_NAME="openai/gpt-oss-20b"  # Serve under this name (can add aliases)
export VLLM_MAX_MODEL_LEN=131072     # 128K tokens (maximized)
export VLLM_GPU_MEMORY_UTIL=0.95     # Maximum GPU memory utilization
export VLLM_TOOL_PARSER="openai"
export VLLM_QUANTIZATION=""          # Let vLLM auto-detect (or set to "fp8", "awq", etc.)

# Performance optimizations (Harmony chat template auto-detected from model)
export VLLM_TOKENIZER_MODE="auto"
export VLLM_ENABLE_PREFIX_CACHING="true"

# Note: GPT-OSS may auto-apply MX FP4 quantization
# To force full precision (no quantization), set: export VLLM_QUANTIZATION="none"
# To try FP8 quantization, set: export VLLM_QUANTIZATION="fp8"

# Optional: Set a persistent API key (otherwise it generates a new one each time)
# export VLLM_API_KEY="sk-your-persistent-key-here"

echo "⚠️  Note: GPT-OSS-20B model not currently available on HuggingFace"
echo ""
echo "🔧 GPT-OSS-20B Configuration"
echo "============================"
echo "Model: ${VLLM_MODEL}"
echo "Context: ${VLLM_MAX_MODEL_LEN} tokens (128K - maximized)"
echo "GPU Memory: ${VLLM_GPU_MEMORY_UTIL} (maximized)"
echo "Tool Parser: ${VLLM_TOOL_PARSER} (standard OpenAI format)"
echo ""

# Launch the generic server
exec ../scripts/start-vllm-server.sh
