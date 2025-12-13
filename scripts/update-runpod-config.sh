#!/bin/bash
# Update RunPod configuration for LiteLLM + vLLM tool calling
# Run this script ON the RunPod instance

set -e

echo "🔄 Updating RunPod configuration for LiteLLM + vLLM tool calling"
echo "=================================================================="
echo ""

# Step 1: Recreate LiteLLM config
echo "1️⃣ Updating LiteLLM configuration..."
./scripts/setup-litellm-proxy.sh

# Step 2: Restart vLLM with qwen3_coder parser
echo ""
echo "2️⃣ Restarting vLLM server with qwen3_coder parser..."
echo "   Stopping current vLLM server..."

# Try to use the stop script if it exists, otherwise use pkill
if [ -f "./scripts/stop-server.sh" ]; then
    ./scripts/stop-server.sh 2>/dev/null || true
else
    pkill -f "vllm.entrypoints.openai.api_server" || true
    pkill -f "vllm serve" || true
fi
sleep 3

echo "   Starting vLLM with qwen3_coder parser..."
./models/qwen.sh
echo "   ✅ vLLM restart initiated"

# Wait for vLLM to be ready
echo "   Waiting for vLLM to initialize..."
for i in {1..60}; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "   ✅ vLLM is ready!"
        break
    fi
    echo -n "."
    sleep 2
done
echo ""

# Step 3: Restart LiteLLM proxy
echo ""
echo "3️⃣ Restarting LiteLLM proxy..."
if [ -f /workspace/logs/litellm-proxy.pid ]; then
    OLD_PID=$(cat /workspace/logs/litellm-proxy.pid)
    echo "   Stopping old LiteLLM (PID: $OLD_PID)..."
    kill $OLD_PID 2>/dev/null || echo "   Process not found"
    sleep 2
fi

echo "   Starting LiteLLM proxy..."
./scripts/start-litellm-proxy.sh

# Wait for LiteLLM to be ready
echo "   Waiting for LiteLLM to initialize..."
for i in {1..30}; do
    if curl -s http://localhost:4000/ > /dev/null 2>&1; then
        echo "   ✅ LiteLLM is ready!"
        break
    fi
    echo -n "."
    sleep 1
done
echo ""

# Step 4: Verify configuration
echo ""
echo "4️⃣ Verifying configuration..."
echo ""

echo "   Testing vLLM (port 8000)..."
curl -s http://localhost:8000/v1/models | jq -r '.data[].id' || echo "   ⚠️  vLLM test failed"

echo ""
echo "   Testing LiteLLM (port 4000)..."
curl -s http://localhost:4000/v1/models \
  -H "Authorization: Bearer sk-litellm-c9be6c31b9f1ebd5bc5a316ac7d71381" | jq -r '.data[].id' || echo "   ⚠️  LiteLLM test failed"

echo ""
echo "   Testing tool calling through LiteLLM..."
RESPONSE=$(curl -s http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-litellm-c9be6c31b9f1ebd5bc5a316ac7d71381" \
  -d '{
    "model": "qwen3-coder-30b",
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
echo "=================================================================="
echo "✅ Configuration update complete!"
echo ""
echo "Architecture:"
echo "  Continue.dev → LiteLLM (port 4000) → vLLM (port 8000) → Qwen3-Coder-30B"
echo "                 ↑                      ↑"
echo "                 Format normalization   qwen3_coder parser"
echo ""
echo "Next: Update Continue.dev config and restart the extension"
