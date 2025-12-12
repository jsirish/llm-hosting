#!/bin/bash
# Test Gemma 3 27B API
# Run this after deploying gemma3.sh

set -e

echo "🧪 Testing Gemma 3 27B API..."

# Get API key
if [ -f /workspace/logs/api-key.txt ]; then
    API_KEY=$(cat /workspace/logs/api-key.txt)
else
    echo "❌ API key not found. Run ./gemma3.sh first"
    exit 1
fi

ENDPOINT="https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1"

echo ""
echo "1️⃣ Testing /v1/models endpoint..."
curl -s "$ENDPOINT/models" \
  -H "Authorization: Bearer $API_KEY" | jq '.data[0]'

echo ""
echo "2️⃣ Testing chat completion..."
curl -s "$ENDPOINT/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{
    "model": "google/gemma-3-27b-it",
    "messages": [
      {"role": "user", "content": "Write a one-line Python function to calculate factorial"}
    ],
    "max_tokens": 100,
    "temperature": 0.7
  }' | jq -r '.choices[0].message.content'

echo ""
echo "✅ Tests complete!"
