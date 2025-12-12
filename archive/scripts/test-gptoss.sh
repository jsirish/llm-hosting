#!/bin/bash
# Test GPT-OSS-20B API

API_KEY="sk-vllm-0a42026a4e93dc7f59578705be5d2e42"
ENDPOINT="https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1"

echo "🧪 Testing GPT-OSS-20B API"
echo "=========================="
echo ""

# Test 1: List models
echo "Test 1: List Models"
echo "-------------------"
curl -s "${ENDPOINT}/models" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.data[] | {id, max_model_len}'
echo ""

# Test 2: Simple code generation
echo "Test 2: Code Generation"
echo "----------------------"
curl -s "${ENDPOINT}/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "messages": [{"role": "user", "content": "Write a hello world function in Python"}],
    "max_tokens": 200,
    "temperature": 0.7
  }' | jq '.choices[0].message'
echo ""

# Test 3: Tool calling
echo "Test 3: Tool/Function Calling"
echo "-----------------------------"
curl -s "${ENDPOINT}/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "messages": [{"role": "user", "content": "What is the weather in San Francisco?"}],
    "tools": [{
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "Get the current weather for a location",
        "parameters": {
          "type": "object",
          "properties": {
            "location": {"type": "string", "description": "The city and state"}
          },
          "required": ["location"]
        }
      }
    }],
    "tool_choice": "auto"
  }' | jq '.choices[0].message'
echo ""

echo "✅ Tests complete!"
