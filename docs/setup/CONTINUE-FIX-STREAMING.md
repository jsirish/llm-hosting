# Continue.dev Streaming Fix

## Problem
The qwen3_coder parser in vLLM has a streaming bug that causes `IndexError: list index out of range` during streaming tool calls.

## Solution
Disable streaming in Continue.dev configuration.

## Steps

1. Open `~/.continue/config.json`

2. Add `stream: false` to your model configuration:

```json
{
  "models": [
    {
      "title": "RunPod Qwen3-Coder-30B (Tool Calling via LiteLLM)",
      "provider": "openai",
      "model": "qwen3-coder-30b",
      "apiKey": "sk-litellm-c9be6c31b9f1ebd5bc5a316ac7d71381",
      "apiBase": "https://3clxt008hl0a3a-4000.proxy.runpod.net/v1",
      "stream": false,
      "requestOptions": {
        "stream": false
      }
    }
  ]
}
```

3. Reload VS Code: `Cmd+Shift+P` → "Developer: Reload Window"

4. Test tool calling in Continue.dev

## Why This Works

- vLLM's qwen3_coder parser works perfectly in non-streaming mode
- Non-streaming responses are faster and more reliable for tool calling
- Continue.dev will show the full response at once instead of token-by-token

## Verification

After applying this fix, tool calling should work without errors. You'll see responses appear all at once instead of streaming.
