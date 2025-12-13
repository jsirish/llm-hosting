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
  # vLLM uses qwen3_coder parser, LiteLLM normalizes to OpenAI format
  - model_name: qwen3-coder-30b
    litellm_params:
      model: Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8
      api_base: http://localhost:8000/v1
      api_key: sk-vllm-c9be6c31b9f1ebd5bc5a316ac7d71381
      supports_function_calling: true
      supports_parallel_function_calling: true
      custom_llm_provider: openai
      stream: false  # Force non-streaming to avoid qwen3_coder bug
    model_info:
      mode: chat
      supports_function_calling: true
      supports_parallel_function_calling: true
      max_tokens: 8192  # Max completion tokens
      max_input_tokens: 131072  # 128K context

litellm_settings:
  drop_params: true  # Strip non-standard parameters
  json_logs: false  # Easier to read logs
  num_retries: 0  # Disable retries that might cause issues
  request_timeout: 600
  success_callback: []  # Disable success callbacks
  failure_callback: []  # Disable failure callbacks
  force_stream_off: true  # Force non-streaming to avoid vLLM bug

general_settings:
  master_key: sk-litellm-c9be6c31b9f1ebd5bc5a316ac7d71381  # Same key for simplicity
EOF

echo "✅ LiteLLM config created at /workspace/litellm-config.yaml"
echo ""
echo "Next steps:"
echo "1. Start vLLM with qwen_coder parser: ./models/qwen.sh (VLLM_TOOL_PARSER=\"qwen_coder\")"
echo "2. Start LiteLLM proxy: ./scripts/start-litellm-proxy.sh"
echo "3. Update Continue.dev to use: http://localhost:4000 or https://...proxy.runpod.net:4000"
echo ""
echo "Architecture: Continue.dev → LiteLLM (format normalization) → vLLM (qwen_coder parser) → Model"
