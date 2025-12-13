#!/bin/bash
# Update RunPod configuration for Gemma3-27B with native tool calling
# Run this script ON the RunPod instance

set -e

echo "🔄 Deploying Gemma3-27B with native tool calling support"
echo "=========================================================="
echo ""

# Step 1: Restart vLLM with Gemma3-27B (openai parser for tool calling)
echo "1️⃣ Stopping current vLLM server..."

# Try to use the stop script if it exists, otherwise use pkill
if [ -f "./scripts/stop-server.sh" ]; then
    ./scripts/stop-server.sh 2>/dev/null || true
else
    pkill -f "vllm.entrypoints.openai.api_server" || true
    pkill -f "vllm serve" || true
fi
sleep 3

echo ""
echo "2️⃣ Starting Gemma3-27B with native OpenAI tool calling..."
./models/gemma3.sh
echo "   ✅ vLLM restart initiated"

# Wait for vLLM to be ready
echo ""
echo "3️⃣ Waiting for vLLM to initialize..."
for i in {1..60}; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "   ✅ vLLM is ready!"
        break
    fi
    echo -n "."
    sleep 2
done
echo ""

# Step 2: Verify configuration
echo ""
echo "4️⃣ Verifying Gemma3-27B configuration..."
echo ""

echo "   Testing vLLM endpoint..."
curl -s http://localhost:8000/v1/models | jq -r '.data[].id' || echo "   ⚠️  vLLM test failed"

echo ""
echo "   Testing tool calling..."
RESPONSE=$(curl -s http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-vllm-c9be6c31b9f1ebd5bc5a316ac7d71381" \
  -d '{
    "model": "google/gemma-3-27b-it",
    "messages": [{"role": "user", "content": "What is the weather in Paris? Use the get_weather tool."}],
    "tools": [{
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "Get weather",
        "parameters": {
          "type": "object",
          "properties": {
            "location": {"type": "string"}
          },
          "required": ["location"]
        }
      }
    }],
    "max_tokens": 100
  }')

if echo "$RESPONSE" | jq -e '.choices[0].message.tool_calls' > /dev/null 2>&1; then
    echo "   ✅ Tool calling working! Response has tool_calls array"
    echo "$RESPONSE" | jq '.choices[0].message.tool_calls'
else
    echo "   ⚠️  Tool calling format issue - no tool_calls array found"
    echo "   Response content:"
    echo "$RESPONSE" | jq '.choices[0].message.content' | head -5
fi

echo ""
echo "=========================================================="
echo "✅ Gemma3-27B deployment complete!"
echo ""
echo "Architecture:"
echo "  Continue.dev → vLLM (port 8000) → Gemma3-27B"
echo "                          ↑"
echo "                   OpenAI tool parser (native)"
echo ""
echo "Model: google/gemma-3-27b-it"
echo "Context: 128K tokens"
echo "Tool Calling: Native OpenAI format"
echo ""
echo "Next: Select 'RunPod Gemma3-27B' in Continue.dev"
