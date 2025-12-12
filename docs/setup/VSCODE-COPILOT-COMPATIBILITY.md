# VS Code Copilot Compatibility Issues

## Current Issue: "Unknown role: functions"

### Problem
VS Code Copilot is using the **deprecated `function` role** in chat messages, which vLLM doesn't support.

### Technical Details

**Supported Roles (vLLM/OpenAI Current API):**
- `system` - System instructions
- `user` - User messages
- `assistant` - Model responses
- `tool` - Tool/function call results (modern API)

**Deprecated Role (Old OpenAI API):**
- `function` - Function call results (deprecated in 2023)

### Why This Happens
GitHub Copilot may be:
1. Using an older OpenAI API client internally
2. Not yet updated to support custom models with modern API specs
3. Hardcoded to use `function` role for tool calling scenarios

### Solutions

#### Option 1: Disable Tool Calling in Copilot (Recommended)
Try adding this to your VS Code settings to disable function calling:

```json
{
  "github.copilot.advanced": {
    "ArliAI/gpt-oss-20b-Derestricted": {
      "maxInputTokens": 61440,
      "maxOutputTokens": 4096,
      "url": "https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1",
      "requiresAPIKey": true,
      "enableFunctionCalling": false
    }
  }
}
```

#### Option 2: Use Different Copilot Mode
- Try using Copilot in **code completion mode** instead of chat mode
- Code completions don't require tool calling

#### Option 3: Report to GitHub
This is a bug in VS Code Copilot. They should:
1. Use the modern `tool` role instead of deprecated `function` role
2. Or provide a setting to disable function calling for custom models

**Report at:** https://github.com/microsoft/vscode/issues

#### Option 4: Use Alternative Clients
Instead of VS Code Copilot, use clients that properly support the OpenAI API:
- **Continue.dev** - VS Code extension for custom LLMs
- **Cody** - Sourcegraph's AI assistant
- **Cursor** - AI-native editor
- **Direct API calls** - Use OpenAI Python client or curl

### Testing the Server

Your vLLM server works perfectly with standard clients:

```bash
# Test with curl (this works)
curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-vllm-03db23a5d5c003a0035cdca53b4d0acd" \
  -d '{
    "model": "ArliAI/gpt-oss-20b-Derestricted",
    "messages": [
      {"role": "system", "content": "You are a helpful coding assistant."},
      {"role": "user", "content": "Write a Python function to calculate fibonacci"}
    ],
    "max_tokens": 500
  }'
```

```python
# Test with OpenAI Python client (this works)
from openai import OpenAI

client = OpenAI(
    base_url="https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1",
    api_key="sk-vllm-03db23a5d5c003a0035cdca53b4d0acd"
)

response = client.chat.completions.create(
    model="ArliAI/gpt-oss-20b-Derestricted",
    messages=[
        {"role": "system", "content": "You are a helpful coding assistant."},
        {"role": "user", "content": "Write a Python function to calculate fibonacci"}
    ],
    max_tokens=500
)

print(response.choices[0].message.content)
```

### Modern Tool Calling (If Supported)

If you want to use tool calling with properly configured clients:

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1",
    api_key="sk-vllm-03db23a5d5c003a0035cdca53b4d0acd"
)

tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get the current weather in a location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {"type": "string"},
                    "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]}
                },
                "required": ["location"]
            }
        }
    }
]

response = client.chat.completions.create(
    model="ArliAI/gpt-oss-20b-Derestricted",
    messages=[{"role": "user", "content": "What's the weather in SF?"}],
    tools=tools,
    tool_choice="auto"
)

# If the model calls a tool, the response will have tool_calls
if response.choices[0].message.tool_calls:
    tool_call = response.choices[0].message.tool_calls[0]
    print(f"Tool: {tool_call.function.name}")
    print(f"Args: {tool_call.function.arguments}")

    # Send tool result back using "tool" role (not "function")
    response2 = client.chat.completions.create(
        model="ArliAI/gpt-oss-20b-Derestricted",
        messages=[
            {"role": "user", "content": "What's the weather in SF?"},
            response.choices[0].message,  # Assistant's tool call
            {
                "role": "tool",  # Modern API uses "tool", not "function"
                "content": '{"temperature": 72, "condition": "sunny"}',
                "tool_call_id": tool_call.id
            }
        ]
    )
    print(response2.choices[0].message.content)
```

## Summary

- ✅ Your vLLM server is configured correctly
- ✅ The API works with standard OpenAI clients
- ❌ VS Code Copilot is using deprecated API features
- 🔧 Try disabling function calling in Copilot settings
- 🔧 Consider using alternative VS Code extensions that properly support custom models

## Alternative: Continue.dev Extension

**Continue.dev** is a popular VS Code extension that properly supports custom OpenAI-compatible APIs:

1. Install from VS Code marketplace
2. Configure in `.continue/config.json`:

```json
{
  "models": [
    {
      "title": "GPT-OSS-20B",
      "provider": "openai",
      "model": "ArliAI/gpt-oss-20b-Derestricted",
      "apiBase": "https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1",
      "apiKey": "sk-vllm-03db23a5d5c003a0035cdca53b4d0acd",
      "contextLength": 65536,
      "completionOptions": {
        "maxTokens": 4096
      }
    }
  ]
}
```

Continue.dev uses the modern OpenAI API and should work without the `function` role error.
