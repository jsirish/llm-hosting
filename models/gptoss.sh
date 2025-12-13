#!/bin/bash
# GPT-OSS-20B Configuration and Launcher
# Sets environment variables and starts the generic vLLM server
#
# ⚠️ IMPORTANT: Ada Lovelace Support Status
# - Ada Lovelace (RTX 6000 Ada) support is IN PROGRESS
# - vLLM team is "actively working" on Ada Lovelace support
# - May experience deployment failures until officially supported
# - Requires vLLM >= 0.10.2, PyTorch with +cu128 suffix, CUDA >= 12.8
# - See: docs/setup/GPT-OSS-VLLM-OFFICIAL-GUIDE.md for full details

# Model Configuration (Conservative settings for Ada Lovelace compatibility)
export VLLM_MODEL="openai/gpt-oss-20b"
export VLLM_MODEL_DESCRIPTION="GPT-OSS-20B (OpenAI Open Source)"
export VLLM_SERVED_MODEL_NAME="openai/gpt-oss-20b"  # Serve under this name (can add aliases)
export VLLM_MAX_MODEL_LEN=32768      # 32K tokens (conservative for stability)
export VLLM_GPU_MEMORY_UTIL=0.90     # 90% GPU memory utilization (official recommendation)
export VLLM_TOOL_PARSER="openai"     # Native OpenAI tool calling format (requires vLLM >= 0.10.2)
export VLLM_QUANTIZATION=""          # Let vLLM auto-detect (or set to "fp8", "awq", etc.)

# Performance optimizations
export VLLM_TOKENIZER_MODE="auto"
export VLLM_ENABLE_PREFIX_CACHING="true"

# Note: Official vLLM docs recommend these additional flags for A100:
# - --async-scheduling (requires vLLM >= 0.11.1, may not work on Ada Lovelace yet)
# - --enable-auto-tool-choice (automatic tool selection)
# These are already set in start-vllm-server.sh

# For troubleshooting Ada Lovelace issues, try:
# - Reduce context: export VLLM_MAX_MODEL_LEN=16384
# - Lower GPU util: export VLLM_GPU_MEMORY_UTIL=0.85
# - Disable CUDA graphs: Add --enforce-eager flag to start-vllm-server.sh

# Optional: Set a persistent API key (otherwise it generates a new one each time)
# export VLLM_API_KEY="sk-your-persistent-key-here"

echo "⚠️  IMPORTANT: Ada Lovelace (RTX 6000 Ada) Support Status"
echo "============================================================"
echo "Ada Lovelace support is IN PROGRESS by vLLM team"
echo "Deployment may fail until officially supported"
echo ""
echo "Requirements:"
echo "  - vLLM >= 0.10.2"
echo "  - PyTorch with +cu128 suffix"
echo "  - CUDA >= 12.8"
echo ""
echo "See docs/setup/GPT-OSS-VLLM-OFFICIAL-GUIDE.md for details"
echo "Consider using Qwen3-Coder-30B (./qwen.sh) as stable alternative"
echo ""
echo "🔧 GPT-OSS-20B Configuration"
echo "============================"
echo "Model: ${VLLM_MODEL}"
echo "Context: ${VLLM_MAX_MODEL_LEN} tokens (32K - conservative)"
echo "GPU Memory: ${VLLM_GPU_MEMORY_UTIL} (90% - official recommendation)"
echo "Tool Parser: ${VLLM_TOOL_PARSER} (requires vLLM >= 0.10.2)"
echo ""

# Launch the generic server
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/../scripts/start-vllm-server.sh"
