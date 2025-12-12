#!/bin/bash
# Quick status check for vLLM models (optimized for Continue.dev)

echo "🔍 vLLM Model Status Check"
echo "====================================="
echo ""

# Check Kimi K2 (Chat Model - Port 8000)
echo "📱 Kimi K2 Chat Model (Port 8000):"
KIMI_STATUS=$(curl -s --max-time 3 https://3clxt008hl0a3a-8000.proxy.runpod.net/v1/models 2>&1)
if echo "$KIMI_STATUS" | jq -e '.data[0].id' > /dev/null 2>&1; then
    MODEL_NAME=$(echo "$KIMI_STATUS" | jq -r '.data[0].id')
    echo "   ✅ READY - Model: $MODEL_NAME"
else
    echo "   ⏳ LOADING... (this can take 3-5 minutes)"
fi
echo ""

# Check Qwen Autocomplete (Autocomplete Model - Port 8001)
echo "⚡ Qwen Autocomplete Model (Port 8001):"
QWEN_STATUS=$(curl -s --max-time 3 https://3clxt008hl0a3a-8001.proxy.runpod.net/v1/models 2>&1)
if echo "$QWEN_STATUS" | jq -e '.data[0].id' > /dev/null 2>&1; then
    MODEL_NAME=$(echo "$QWEN_STATUS" | jq -r '.data[0].id')
    echo "   ✅ READY - Model: $MODEL_NAME"
else
    echo "   ⏳ LOADING... (this can take 1-2 minutes)"
fi
echo ""

echo "====================================="
echo ""
echo "💡 Next Steps:"
echo "   1. Install Continue.dev extension in VS Code"
echo "   2. Copy continue-config.yaml to ~/.continue/config.yaml"
echo "   3. Start coding! Press ⌘+L to open Continue chat"
echo ""
echo "📚 Full guide: CONTINUE-SETUP.md"
