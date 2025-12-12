#!/bin/bash
# Search for tool/function calling capable models

echo "🔍 Searching for tool-capable models (20-32B parameters)..."
echo ""

echo "=== Hermes Models (Known for tool use) ==="
huggingface-cli search-models --filter "hermes" --limit 20 | grep -iE "(20b|24b|32b|22b)"

echo ""
echo "=== Functionary Models (Built for tools) ==="
huggingface-cli search-models --filter "functionary" --limit 20 | grep -iE "(20b|24b|32b|22b|medium|small)"

echo ""
echo "=== Function Calling Models ==="
huggingface-cli search-models --filter "function-calling" --limit 20 | grep -iE "(20b|24b|32b|22b)"

echo ""
echo "=== Tool Use Models ==="
huggingface-cli search-models --filter "tool" --limit 20 | grep -iE "(20b|24b|32b|22b)"

echo ""
echo "📝 Recommended models with native tool support:"
echo "  - NousResearch/Hermes-3-Llama-3.1-8B (smaller, efficient)"
echo "  - meetkai/functionary-medium-v3.2 (24B, built for tools)"
echo "  - Qwen/Qwen2.5-32B-Instruct (32B, excellent tool use)"
echo "  - meta-llama/Llama-3.3-70B-Instruct (larger, best quality)"
