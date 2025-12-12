#!/bin/bash
# Test GPT-OSS-20B vLLM API from local machine via RunPod proxy

RUNPOD_API="https://v5brcrgoclcp1p-8000.proxy.runpod.net"
MODEL="openai/gpt-oss-20b"

# API Key - you need to set this after starting the server
# Get it from: ssh to pod, then cat /workspace/logs/api-key.txt
API_KEY="${VLLM_API_KEY:-YOUR_API_KEY_HERE}"

if [ "$API_KEY" = "YOUR_API_KEY_HERE" ]; then
    echo "⚠️  WARNING: API_KEY not set!"
    echo ""
    echo "To get your API key:"
    echo "1. SSH to pod: ./connect-runpod.sh"
    echo "2. Run: cat /workspace/logs/api-key.txt"
    echo "3. Set it: export VLLM_API_KEY='your-key-here'"
    echo "4. Run this script again"
    echo ""
    echo "Continuing with placeholder (will fail if server requires auth)..."
    echo ""
fi

echo "🧪 Testing vLLM API via RunPod proxy..."
echo "API URL: $RUNPOD_API"
echo ""

# Test 1: Health check
echo "1️⃣  Health Check:"
curl -s "$RUNPOD_API/health" \
  -H "Authorization: Bearer $API_KEY" | jq '.' || echo "Failed or port not exposed yet"
echo ""
echo ""

# Test 2: List models
echo "2️⃣  List Available Models:"
curl -s "$RUNPOD_API/v1/models" \
  -H "Authorization: Bearer $API_KEY" | jq '.'
echo ""
echo ""

# Test 3: Simple completion
echo "3️⃣  Test Completion (Code generation):"
curl -s "$RUNPOD_API/v1/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "{
    \"model\": \"$MODEL\",
    \"prompt\": \"def fibonacci(n):\",
    \"max_tokens\": 100,
    \"temperature\": 0.7
  }" | jq '.'
echo ""
echo ""

# Test 4: Chat completion
echo "4️⃣  Test Chat Completion:"
curl -s "$RUNPOD_API/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "{
    \"model\": \"$MODEL\",
    \"messages\": [
      {\"role\": \"user\", \"content\": \"Write a Python function to calculate factorial.\"}
    ],
    \"max_tokens\": 150,
    \"temperature\": 0.7
  }" | jq '.'
echo ""
echo ""

echo "✅ Testing complete!"
echo ""
echo "If you see errors, you may need to expose port 8000 in RunPod's HTTP services panel."
echo "The web UI should let you add a new HTTP service for port 8000."
