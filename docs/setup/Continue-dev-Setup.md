# Continue.dev Setup for Self-Hosted Models

## Why Continue.dev?
- **Built for self-hosted models** - handles quirks better than Copilot
- **More flexible** - doesn't choke on extra response fields
- **Better context** - can use entire files/folders
- **Free & open source** - no subscription needed
- **Active development** - frequent updates

## Installation
1. Install from VS Code marketplace: `Continue - Codestral, Claude, and more`
2. Or visit: https://marketplace.visualstudio.com/items?itemName=Continue.continue

## Configuration for Qwen 3

Add to `~/.continue/config.json`:

```json
{
  "models": [
    {
      "title": "Qwen 3 Coder 30B",
      "provider": "openai",
      "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
      "apiBase": "https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1",
      "apiKey": "sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9",
      "contextLength": 131072,
      "completionOptions": {
        "maxTokens": 4096,
        "temperature": 0.2
      }
    }
  ],
  "tabAutocompleteModel": {
    "title": "Qwen 3 Autocomplete",
    "provider": "openai",
    "model": "Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8",
    "apiBase": "https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1",
    "apiKey": "sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9"
  },
  "allowAnonymousTelemetry": false,
  "embeddingsProvider": {
    "provider": "free-trial"
  }
}
```

## Benefits Over Copilot
✅ No weird field parsing errors
✅ Works with non-alternating conversation roles
✅ Better at understanding context
✅ Can use @file and @folder mentions
✅ More transparent about what it's doing

## Usage
- **Cmd/Ctrl + L**: Open chat
- **Cmd/Ctrl + I**: Inline edit
- **Tab**: Accept autocomplete
- **Cmd/Ctrl + Shift + R**: Refactor selection

## Testing
After setup, test with:
1. Open a code file
2. Press Cmd/Ctrl + L
3. Type: "Explain this code"
4. Should work without any field errors!
