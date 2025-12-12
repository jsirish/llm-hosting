#!/bin/bash
# Quick status check for Gemma 3 27B

echo "🔍 Checking Gemma 3 27B Status..."
echo ""

# Check if process is running
if pgrep -f "gemma-3-27b-it" > /dev/null; then
    echo "✅ Server process running"
else
    echo "❌ Server process not found"
fi

echo ""
echo "📊 Recent logs (last 20 lines):"
echo "================================"
tail -20 /workspace/logs/vllm-server.log

echo ""
echo "🌐 Test endpoint:"
echo "curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1/models -H 'Authorization: Bearer sk-vllm-6725e6e07e1fe0b9f8a6194871f398a8'"
