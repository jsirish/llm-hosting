#!/bin/bash
# Generic vLLM Server Startup Script
# Run this on RunPod to start any vLLM-compatible model
# Use model-specific scripts (qwen.sh, gptoss.sh) to set configuration

# Ensure model configuration is provided
if [ -z "${VLLM_MODEL}" ]; then
    echo "❌ Error: VLLM_MODEL not set!"
    echo ""
    echo "Usage: Set environment variables first, then run this script"
    echo "Example:"
    echo "  export VLLM_MODEL=\"Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8\""
    echo "  export VLLM_MAX_MODEL_LEN=32768"
    echo "  export VLLM_TOOL_PARSER=\"qwen3_xml\"  # For Qwen3 models"
    echo "  ./start-vllm-server.sh"
    echo ""
    echo "Or use a model-specific script:"
    echo "  ./qwen.sh"
    echo "  ./gptoss.sh"
    exit 1
fi

# Configuration (with defaults)
MODEL="${VLLM_MODEL}"
SERVED_MODEL_NAME="${VLLM_SERVED_MODEL_NAME:-${MODEL}}"  # Name(s) to serve the model under
MAX_MODEL_LEN="${VLLM_MAX_MODEL_LEN:-32768}"
GPU_MEMORY_UTIL="${VLLM_GPU_MEMORY_UTIL:-0.95}"
TOOL_PARSER="${VLLM_TOOL_PARSER:-openai}"
MODEL_DESCRIPTION="${VLLM_MODEL_DESCRIPTION:-${MODEL}}"
QUANTIZATION="${VLLM_QUANTIZATION:-}"  # Optional: e.g., "awq", "gptq", "fp8", or empty for auto/none
TOKENIZER_MODE="${VLLM_TOKENIZER_MODE:-auto}"
ENABLE_PREFIX_CACHING="${VLLM_ENABLE_PREFIX_CACHING:-false}"

PORT=8000
LOG_DIR="/workspace/logs"
LOG_FILE="${LOG_DIR}/vllm-server.log"
PID_FILE="${LOG_DIR}/vllm-server.pid"
CACHE_DIR="/workspace/hf-cache"

# Set HuggingFace cache to workspace (has 304TB vs 30GB root overlay)
export HF_HOME="${CACHE_DIR}"
export TRANSFORMERS_CACHE="${CACHE_DIR}"
export HF_DATASETS_CACHE="${CACHE_DIR}/datasets"

# API Key (IMPORTANT: Change this to a secure random string!)
# Generate with: openssl rand -base64 32
# Or set via environment: export VLLM_API_KEY="your-key-here"
API_KEY="${VLLM_API_KEY:-sk-vllm-$(openssl rand -hex 16)}"

# Create directories if they don't exist
mkdir -p "${LOG_DIR}"
mkdir -p "${CACHE_DIR}"
mkdir -p "${CACHE_DIR}/datasets"

# Verify cache location
echo "📦 Cache Configuration:"
echo "   HF_HOME=${HF_HOME}"
echo "   TRANSFORMERS_CACHE=${TRANSFORMERS_CACHE}"
echo "   Cache dir exists: $([ -d "${CACHE_DIR}" ] && echo "✅" || echo "❌")"
echo "   Available space: $(df -h /workspace | tail -1 | awk '{print $4}')"
echo ""

echo "🚀 Starting vLLM Server..."
echo ""
echo "Model: ${MODEL}"
echo "Description: ${MODEL_DESCRIPTION}"
echo "Context Length: ${MAX_MODEL_LEN} tokens"
echo "GPU Memory Utilization: ${GPU_MEMORY_UTIL}"
echo "Tool Call Parser: ${TOOL_PARSER}"
echo "Tokenizer Mode: ${TOKENIZER_MODE}"
if [ "${ENABLE_PREFIX_CACHING}" = "true" ]; then
    echo "Prefix Caching: Enabled ✅"
fi
if [ -n "${QUANTIZATION}" ]; then
    echo "Quantization: ${QUANTIZATION}"
else
    echo "Quantization: auto (from model config)"
fi
echo "GPU: RTX 6000 Ada (48 GB VRAM)"
echo "API Port: ${PORT}"
echo "Log file: ${LOG_FILE}"
echo "Cache dir: ${CACHE_DIR} (using /workspace storage)"
echo ""
echo "🔐 API Key: ${API_KEY}"
echo "   (Save this! You'll need it for API requests)"
echo ""

# Save API key to file for reference
echo "${API_KEY}" > "${LOG_DIR}/api-key.txt"
chmod 600 "${LOG_DIR}/api-key.txt"

# Check if server is already running
if [ -f "${PID_FILE}" ] && kill -0 $(cat "${PID_FILE}") 2>/dev/null; then
    RUNNING_PID=$(cat "${PID_FILE}")
    echo "⚠️  Server is already running (PID: ${RUNNING_PID})"
    echo ""
    echo "To stop it first, run:"
    echo "  kill ${RUNNING_PID}"
    echo ""
    echo "Or to view logs:"
    echo "  tail -f ${LOG_FILE}"
    exit 1
fi

# Start vLLM server in background with nohup
# vLLM has built-in logging - we redirect stdout/stderr to log file
echo "Starting server in background..."

# Build the vLLM command
VLLM_CMD="python3 -m vllm.entrypoints.openai.api_server \
  --model ${MODEL} \
  --served-model-name ${SERVED_MODEL_NAME} \
  --tensor-parallel-size 1 \
  --max-model-len ${MAX_MODEL_LEN} \
  --gpu-memory-utilization ${GPU_MEMORY_UTIL} \
  --port ${PORT} \
  --host 0.0.0.0 \
  --api-key ${API_KEY} \
  --max-log-len 1000 \
  --enable-auto-tool-choice \
  --tool-call-parser ${TOOL_PARSER} \
  --tokenizer-mode ${TOKENIZER_MODE}"

# Add optional flags
[ -n "${QUANTIZATION}" ] && VLLM_CMD="${VLLM_CMD} --quantization ${QUANTIZATION}"
[ "${ENABLE_PREFIX_CACHING}" = "true" ] && VLLM_CMD="${VLLM_CMD} --enable-prefix-caching"

# Start the server
nohup ${VLLM_CMD} > "${LOG_FILE}" 2>&1 &

# Save PID
echo $! > "${PID_FILE}"

echo "✅ Server started successfully!"
echo ""
echo "PID: $(cat ${PID_FILE})"
echo "Log file: ${LOG_FILE}"
echo "API Key file: ${LOG_DIR}/api-key.txt"
echo ""
echo "🔐 API Authentication:"
echo "   Add header: Authorization: Bearer ${API_KEY}"
echo ""
echo "📊 To monitor logs in real-time:"
echo "   tail -f ${LOG_FILE}"
echo ""
echo "🛑 To stop the server:"
echo "   kill $(cat ${PID_FILE})"
echo ""
echo "Waiting 5 seconds for server to initialize..."
sleep 5

# Check if process is still running
if kill -0 $(cat "${PID_FILE}") 2>/dev/null; then
    echo "✅ Server is running"
    echo ""
    echo "🧪 Test the API:"
    echo "   curl http://localhost:${PORT}/health \\"
    echo "     -H \"Authorization: Bearer ${API_KEY}\""
else
    echo "❌ Server failed to start. Check logs:"
    echo "   tail -50 ${LOG_FILE}"
    rm -f "${PID_FILE}"
    exit 1
fi
