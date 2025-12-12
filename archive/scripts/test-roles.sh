#!/bin/bash
# Test what chat roles are supported by the vLLM server

API_KEY="${VLLM_API_KEY:-$(cat /workspace/logs/api-key.txt 2>/dev/null)}"
BASE_URL="https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1"

echo "Testing supported chat roles..."
echo ""

# Test standard roles: system, user, assistant
echo "1️⃣  Testing standard roles (system, user, assistant)..."
curl -s "${BASE_URL}/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Say hello"},
      {"role": "assistant", "content": "Hello!"},
      {"role": "user", "content": "Say goodbye"}
    ],
    "max_tokens": 50
  }' | jq -r 'if .error then "❌ Error: " + .error.message else "✅ Success: " + .choices[0].message.content end'

echo ""

# Test function role
echo "2️⃣  Testing 'function' role..."
curl -s "${BASE_URL}/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "messages": [
      {"role": "user", "content": "What is the weather?"},
      {"role": "function", "name": "get_weather", "content": "Sunny, 72F"}
    ],
    "max_tokens": 50
  }' | jq -r 'if .error then "❌ Error: " + .error.message else "✅ Success" end'

echo ""

# Test tool role
echo "3️⃣  Testing 'tool' role..."
curl -s "${BASE_URL}/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "messages": [
      {"role": "user", "content": "What is the weather?"},
      {"role": "tool", "content": "Sunny, 72F", "tool_call_id": "call_123"}
    ],
    "max_tokens": 50
  }' | jq -r 'if .error then "❌ Error: " + .error.message else "✅ Success" end'

echo ""
echo "Note: OpenAI deprecated 'function' role in favor of 'tool' role."
echo "VS Code Copilot may need to be configured to use 'tool' instead of 'function'."
