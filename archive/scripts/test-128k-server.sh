#!/bin/bash
# Quick test for the new 128K context server

API_KEY="sk-vllm-c627cedbf339782f52774e32377d84b6"
ENDPOINT="https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1"

echo "🧪 Testing Qwen3-Coder-30B with 128K context window"
echo "===================================================="
echo ""

# Test 1: Health check
echo "1️⃣ Health Check..."
curl -s "${ENDPOINT}/health" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.'
echo ""

# Test 2: List models
echo "2️⃣ List Models..."
curl -s "${ENDPOINT}/models" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.data[0]'
echo ""

# Test 3: Simple completion
echo "3️⃣ Simple Completion Test..."
curl -s "${ENDPOINT}/chat/completions" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
    "messages": [{"role": "user", "content": "Write a hello world in Python"}],
    "max_tokens": 100
  }' | jq '.choices[0].message.content'
echo ""

# Test 4: Tool calling test
echo "4️⃣ Tool Calling Test..."
curl -s "${ENDPOINT}/chat/completions" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
    "messages": [{"role": "user", "content": "What is the weather like today?"}],
    "tools": [{
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "Get the current weather",
        "parameters": {
          "type": "object",
          "properties": {
            "location": {"type": "string"}
          }
        }
      }
    }],
    "max_tokens": 50
  }' | jq '.choices[0]'
echo ""

echo "✅ Tests complete!"
echo ""
echo "📊 Server Info:"
echo "   Model: Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8"
echo "   Context: 128K tokens (131,072)"
echo "   Parser: qwen3_coder"
echo "   API Key: ${API_KEY}"
