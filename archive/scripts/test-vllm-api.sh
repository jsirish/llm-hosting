#!/bin/bash
# Test vLLM API on RunPod

echo "🧪 Testing vLLM API..."
echo ""

curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "prompt": "def fibonacci(n):",
    "max_tokens": 100,
    "temperature": 0.7
  }' | python3 -m json.tool

echo ""
echo "✅ Test complete!"
