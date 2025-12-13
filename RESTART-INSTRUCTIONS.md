# vLLM Server Restart Instructions for RunPod

## Quick Restart Commands

SSH into your RunPod instance and run these commands:

```bash
# 1. Navigate to the project directory
cd /workspace/llm-hosting

# 2. Pull the latest changes (includes qwen3_xml parser fix)
git pull origin main

# 3. Stop the current vLLM server
./scripts/stop-server.sh

# 4. Start with the updated Qwen configuration
./models/qwen.sh
```

## What This Does

- **git pull**: Gets the merged PR #2 with `qwen3_xml` parser
- **stop-server.sh**: Kills any running vLLM processes
- **qwen.sh**: Starts vLLM with `VLLM_TOOL_PARSER="qwen3_xml"`

## Verification

After restart, the server should:
- ✅ Use XML-based tool parser (avoids JSON escape issues)
- ✅ Handle backslashes in tool call responses
- ✅ No more "Invalid \escape: line 1 column 2271" errors

## Alternative: Manual Restart

If the scripts don't work, restart manually:

```bash
# Find and kill vLLM processes
pkill -f vllm.entrypoints.openai.api_server

# Verify nothing is running
ps aux | grep vllm

# Set environment and start
export VLLM_TOOL_PARSER="qwen3_xml"
cd /workspace/llm-hosting
./models/qwen.sh
```

## Check Parser is Active

After restart, test with:

```bash
curl -s http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-vllm-c9be6c31b9f1ebd5bc5a316ac7d71381" \
  -d '{
    "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
    "messages": [{"role": "user", "content": "Test message"}],
    "max_tokens": 10
  }'
```

If you see any errors about JSON parsing in the server logs, the old parser is still running.
