#!/bin/bash
# Qwen3-Coder-30B FP8 vLLM Server Startup Script
# Run this on RunPod to start the inference server with logging

# Configuration
MODEL="Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8"
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

echo "🚀 Starting Qwen3-Coder-30B FP8 vLLM Server..."
echo ""
echo "Model: ${MODEL}"
echo "Quantization: FP8 (Pre-quantized by Qwen, ~15GB download)"
echo "GPU: RTX 6000 Ada (48 GB VRAM)"
echo "Version: Qwen3-Coder (Latest, December 2024)"
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
    echo "⚠️  Server is already running (PID: $(cat ${PID_FILE}))"
    echo "To stop it, run: kill $(cat ${PID_FILE})"
    exit 1
fi

# Start vLLM server in background with nohup
# vLLM has built-in logging - we redirect stdout/stderr to log file
echo "Starting server in background..."
nohup python3 -m vllm.entrypoints.openai.api_server \
  --model "${MODEL}" \
  --tensor-parallel-size 1 \
  --max-model-len 32768 \
  --gpu-memory-utilization 0.95 \
  --port ${PORT} \
  --host 0.0.0.0 \
  --api-key "${API_KEY}" \
  --max-log-len 1000 \
  --enable-auto-tool-choice \
  --tool-call-parser qwen3_coder \
  > "${LOG_FILE}" 2>&1 &

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

# Alternative models you can try:
# --model openai/gpt-oss-20b \
# --model NousResearch/Hermes-3-Llama-3.1-8B \
# --model Qwen/Qwen3-8B \
