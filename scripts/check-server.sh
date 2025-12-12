#!/bin/bash
# Check vLLM server status

PID_FILE="/workspace/logs/vllm-server.pid"
LOG_FILE="/workspace/logs/vllm-server.log"

echo "📊 vLLM Server Status"
echo "===================="
echo ""

# Check if PID file exists
if [ ! -f "${PID_FILE}" ]; then
    echo "Status: ❌ NOT RUNNING (no PID file)"
    exit 1
fi

PID=$(cat "${PID_FILE}")

# Check if process is running
if ! kill -0 "${PID}" 2>/dev/null; then
    echo "Status: ❌ NOT RUNNING (PID ${PID} not found)"
    rm -f "${PID_FILE}"
    exit 1
fi

echo "Status: ✅ RUNNING"
echo "PID: ${PID}"
echo ""

# Show process info
echo "Process info:"
ps -p "${PID}" -o pid,ppid,cmd,%cpu,%mem,etime
echo ""

# Show port binding
echo "Port binding:"
netstat -tlnp 2>/dev/null | grep ":8000" || lsof -i :8000 2>/dev/null | grep LISTEN
echo ""

# Show recent logs
if [ -f "${LOG_FILE}" ]; then
    echo "Recent logs (last 20 lines):"
    echo "----------------------------"
    tail -20 "${LOG_FILE}"
    echo ""
    echo "📄 Full logs: ${LOG_FILE}"
else
    echo "⚠️  No log file found: ${LOG_FILE}"
fi
