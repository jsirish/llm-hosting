#!/bin/bash
# Test LiteLLM Proxy (run this ON the RunPod instance)

echo "🧪 Testing LiteLLM Proxy..."
echo ""

# Test 1: Check if LiteLLM is running
echo "1. Checking if LiteLLM is running on port 4000..."
if curl -s http://localhost:4000/health > /dev/null 2>&1; then
    echo "   ✅ LiteLLM is responding"
else
    echo "   ❌ LiteLLM is not responding on port 4000"
    echo "   Start it with: ./scripts/start-litellm-proxy.sh"
    exit 1
fi
echo ""

# Test 2: List available models
echo "2. Listing available models..."
curl -s http://localhost:4000/v1/models \
  -H "Authorization: Bearer sk-litellm-c9be6c31b9f1ebd5bc5a316ac7d71381" | jq -r '.data[].id'
echo ""

# Test 3: Simple completion
echo "3. Testing simple completion..."
RESPONSE=$(curl -s http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-litellm-c9be6c31b9f1ebd5bc5a316ac7d71381" \
  -d '{
    "model": "qwen3-coder-30b",
    "messages": [
      {"role": "user", "content": "Say hello in exactly 3 words"}
    ],
    "max_tokens": 20,
    "temperature": 0.7
  }')

if echo "$RESPONSE" | jq -e '.choices[0].message.content' > /dev/null 2>&1; then
    echo "   ✅ Completion successful:"
    echo "$RESPONSE" | jq -r '.choices[0].message.content'
else
    echo "   ❌ Completion failed:"
    echo "$RESPONSE" | jq .
fi
echo ""

# Test 4: Tool calling
echo "4. Testing tool calling..."
RESPONSE=$(curl -s http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-litellm-c9be6c31b9f1ebd5bc5a316ac7d71381" \
  -d '{
    "model": "qwen3-coder-30b",
    "messages": [
      {"role": "user", "content": "Use the get_weather function to check the weather in Paris."}
    ],
    "tools": [
      {
        "type": "function",
        "function": {
          "name": "get_weather",
          "description": "Get the current weather",
          "parameters": {
            "type": "object",
            "properties": {
              "location": {"type": "string", "description": "City name"}
            },
            "required": ["location"]
          }
        }
      }
    ],
    "max_tokens": 200
  }')

if echo "$RESPONSE" | jq -e '.choices[0].message.tool_calls' > /dev/null 2>&1; then
    echo "   ✅ Tool calling response received"
    echo "   Tool calls:"
    echo "$RESPONSE" | jq -r '.choices[0].message.tool_calls'
else
    echo "   ⚠️  Tool calls array empty or missing"
    echo "   Content:"
    echo "$RESPONSE" | jq -r '.choices[0].message.content' | head -20
fi
echo ""

echo "✅ LiteLLM proxy tests complete!"
echo ""
echo "Next step: Expose port 4000 in RunPod and update Continue.dev config"
