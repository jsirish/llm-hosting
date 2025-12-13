#!/bin/bash
# LiteLLM Proxy Setup for Tool Calling
# Normalizes vLLM responses for Continue.dev compatibility

set -e

echo "🔧 Installing LiteLLM..."
pip install 'litellm[proxy]' --quiet

echo "📝 Creating LiteLLM config..."
cat > /workspace/litellm-config.yaml << 'EOF'
model_list:
  # Qwen 3 Coder 30B - Primary model for tool calling
  # vLLM uses qwen_coder parser, LiteLLM normalizes to OpenAI format
  - model_name: qwen3-coder-30b
    litellm_params:
      model: openai/Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8
      api_base: http://localhost:8000/v1
      api_key: sk-vllm-c9be6c31b9f1ebd5bc5a316ac7d71381
      supports_function_calling: true
      supports_parallel_function_calling: true
    model_info:
      mode: chat
      supports_function_calling: true
      supports_parallel_function_calling: true
      max_tokens: 8192  # Max completion tokens
      max_input_tokens: 131072  # 128K context

litellm_settings:
  drop_params: true  # Strip non-standard parameters
  json_logs: false  # Easier to read logs
  num_retries: 2
  request_timeout: 600
  modify_params: true
  success_callback: []

general_settings:
  master_key: sk-litellm-c9be6c31b9f1ebd5bc5a316ac7d71381  # Same key for simplicity

# Router settings for load balancing (future)
router_settings:
  routing_strategy: simple-shuffle
  model_group_alias:
    qwen: qwen3-coder-30b
EOF

echo "✅ LiteLLM config created at /workspace/litellm-config.yaml"
echo ""
echo "Next steps:"
echo "1. Start vLLM with qwen_coder parser: ./models/qwen.sh (VLLM_TOOL_PARSER=\"qwen_coder\")"
echo "2. Start LiteLLM proxy: ./scripts/start-litellm-proxy.sh"
echo "3. Update Continue.dev to use: http://localhost:4000 or https://...proxy.runpod.net:4000"
echo ""
echo "Architecture: Continue.dev → LiteLLM (format normalization) → vLLM (qwen_coder parser) → Model"
