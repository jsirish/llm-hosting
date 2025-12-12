#!/bin/bash
# Stop the vLLM server

PID_FILE="/workspace/logs/vllm-server.pid"

if [ ! -f "${PID_FILE}" ]; then
    echo "❌ Server is not running (no PID file found)"
    exit 1
fi

PID=$(cat "${PID_FILE}")

if ! kill -0 "${PID}" 2>/dev/null; then
    echo "❌ Server is not running (PID ${PID} not found)"
    rm -f "${PID_FILE}"
    exit 1
fi

echo "🛑 Stopping vLLM server (PID: ${PID})..."
kill "${PID}"

# Wait for graceful shutdown
for i in {1..10}; do
    if ! kill -0 "${PID}" 2>/dev/null; then
        echo "✅ Server stopped successfully"
        rm -f "${PID_FILE}"
        exit 0
    fi
    sleep 1
done

# Force kill if still running
if kill -0 "${PID}" 2>/dev/null; then
    echo "⚠️  Server didn't stop gracefully, forcing..."
    kill -9 "${PID}"
    sleep 1
fi

if ! kill -0 "${PID}" 2>/dev/null; then
    echo "✅ Server stopped (forced)"
    rm -f "${PID_FILE}"
else
    echo "❌ Failed to stop server"
    exit 1
fi
