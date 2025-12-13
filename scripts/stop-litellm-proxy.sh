#!/bin/bash
# Stop the LiteLLM proxy

PID_FILE="/workspace/logs/litellm-proxy.pid"

if [ ! -f "${PID_FILE}" ]; then
    echo "❌ LiteLLM proxy is not running (no PID file found)"
    exit 1
fi

PID=$(cat "${PID_FILE}")

if ! kill -0 "${PID}" 2>/dev/null; then
    echo "❌ LiteLLM proxy is not running (PID ${PID} not found)"
    rm -f "${PID_FILE}"
    exit 1
fi

echo "🛑 Stopping LiteLLM proxy (PID: ${PID})..."
kill "${PID}"

# Wait for graceful shutdown
for i in {1..10}; do
    if ! kill -0 "${PID}" 2>/dev/null; then
        echo "✅ LiteLLM proxy stopped successfully"
        rm -f "${PID_FILE}"
        exit 0
    fi
    sleep 1
done

# Force kill if still running
echo "⚠️  Forcing shutdown..."
kill -9 "${PID}"
sleep 1

if ! kill -0 "${PID}" 2>/dev/null; then
    echo "✅ LiteLLM proxy stopped (forced)"
    rm -f "${PID_FILE}"
    exit 0
else
    echo "❌ Failed to stop LiteLLM proxy"
    exit 1
fi
