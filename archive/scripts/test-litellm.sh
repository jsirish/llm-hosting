#!/bin/bash
# Test LiteLLM proxy to verify response normalization

set -e

API_KEY="sk-vllm-6725e6e07e1fe0b9f8a6194871f398a8"
LITELLM_ENDPOINT="https://v5brcrgoclcp1p-4000.proxy.runpod.net/v1"

echo "🧪 Testing LiteLLM Proxy Response Normalization"
echo "================================================"
echo ""

echo "1️⃣ Testing /v1/models endpoint..."
curl -s "${LITELLM_ENDPOINT}/models" \
  -H "Authorization: Bearer ${API_KEY}" | jq '.data[].id'

echo ""
echo "2️⃣ Testing chat completion (checking for clean response)..."
response=$(curl -s "${LITELLM_ENDPOINT}/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "model": "gemma-3-27b",
    "messages": [
      {"role": "user", "content": "Say hello in one sentence"}
    ],
    "max_tokens": 50
  }')

echo "Full response:"
echo "$response" | jq

echo ""
echo "3️⃣ Checking for problematic fields..."
echo "Has 'reasoning' field: $(echo "$response" | jq -r '.choices[0].message | has("reasoning")')"
echo "Has 'reasoning_content' field: $(echo "$response" | jq -r '.choices[0].message | has("reasoning_content")')"
echo "Has 'annotations' field: $(echo "$response" | jq -r '.choices[0].message | has("annotations")')"
echo "Has 'audio' field: $(echo "$response" | jq -r '.choices[0].message | has("audio")')"

echo ""
echo "4️⃣ Clean content only:"
echo "$response" | jq -r '.choices[0].message.content'

echo ""
echo "✅ Test complete!"
