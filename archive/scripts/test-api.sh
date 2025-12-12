#!/bin/bash
# Test vLLM API from inside the pod

# Load API key
API_KEY_FILE="/workspace/logs/api-key.txt"
if [ -f "${API_KEY_FILE}" ]; then
    API_KEY=$(cat "${API_KEY_FILE}")
else
    echo "❌ API key file not found: ${API_KEY_FILE}"
    echo "Make sure you started the server with ./start-server.sh"
    exit 1
fi

echo "🧪 Testing vLLM API with authentication..."
echo ""

# Health check
echo "=== Test 1: Health Check ==="
curl http://localhost:8000/health \
  -H "Authorization: Bearer ${API_KEY}"
echo ""
echo ""

# List models
echo "=== Test 2: List Models ==="
curl http://localhost:8000/v1/models \
  -H "Authorization: Bearer ${API_KEY}"
echo ""
echo ""

# Code completion test
echo "=== Test 3: Code Completion ==="
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "prompt": "def fibonacci(n):",
    "max_tokens": 100,
    "temperature": 0.7
  }'
echo ""
echo ""

# Chat completion test
echo "=== Test 4: Chat Completion ==="
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "messages": [
      {"role": "user", "content": "Write a Python function to reverse a string"}
    ],
    "max_tokens": 150,
    "temperature": 0.7
  }'
echo ""
echo ""

echo "✅ Tests complete!"
