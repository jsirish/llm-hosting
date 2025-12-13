#!/bin/bash
# Start LiteLLM Proxy
# Runs on port 4000 and normalizes vLLM responses for Continue.dev

# Configuration
LOG_DIR="/workspace/logs"
LOG_FILE="${LOG_DIR}/litellm-proxy.log"
PID_FILE="${LOG_DIR}/litellm-proxy.pid"

echo "🚀 Starting LiteLLM proxy..."
echo "Port: 4000"
echo "Config: /workspace/litellm-config.yaml"
echo "Log file: ${LOG_FILE}"
echo ""

# Create logs directory if it doesn't exist
mkdir -p "${LOG_DIR}"

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
fi

# Check if already running
if [ -f "${PID_FILE}" ] && kill -0 $(cat "${PID_FILE}") 2>/dev/null; then
    RUNNING_PID=$(cat "${PID_FILE}")
    echo "⚠️  LiteLLM proxy is already running (PID: ${RUNNING_PID})"
    echo ""
    echo "To stop it first, run:"
    echo "  kill ${RUNNING_PID}"
    echo ""
    echo "Or to view logs:"
    echo "  tail -f ${LOG_FILE}"
    exit 1
fi

# Start LiteLLM proxy in background
echo "Starting LiteLLM in background..."
nohup litellm --config /workspace/litellm-config.yaml --port 4000 --host 0.0.0.0 > "${LOG_FILE}" 2>&1 &

# Save PID
echo $! > "${PID_FILE}"

echo "✅ LiteLLM proxy started successfully!"
echo ""
echo "PID: $(cat ${PID_FILE})"
echo "Log file: ${LOG_FILE}"
echo ""
echo "📊 To monitor logs in real-time:"
echo "   tail -f ${LOG_FILE}"
echo ""
echo "🛑 To stop the proxy:"
echo "   kill $(cat ${PID_FILE})"
echo ""
echo "Waiting 5 seconds for proxy to initialize..."
sleep 5

# Check if process is still running
if kill -0 $(cat "${PID_FILE}") 2>/dev/null; then
    echo "✅ Proxy is running"
    echo ""
    echo "Test it with:"
    echo "  curl http://localhost:4000/v1/models"
else
    echo "❌ Proxy failed to start. Check logs:"
    echo "  tail ${LOG_FILE}"
    exit 1
fi
