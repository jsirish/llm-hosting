# Prompt for AI Agent: Configure VS Code for Self-Hosted LLM

## Task
Update my VS Code settings to use a self-hosted LLM endpoint for code completion and chat.

## Current Setup
- **Endpoint:** https://v5brcrgoclcp1p-4000.proxy.runpod.net/v1
- **API Key:** sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9
- **Model:** Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8
- **Context Length:** 131,072 tokens (128K)

## Requirements
1. Configure GitHub Copilot to use this endpoint (if possible)
2. If Copilot doesn't support custom endpoints, install and configure Continue.dev extension instead
3. Ensure autocomplete (tab completion) works
4. Ensure chat interface works
5. Set reasonable temperature (0.2-0.3 for code)
6. Set max tokens for responses (2048-4096)

## Expected Configuration Location
- **Continue.dev:** `~/.continue/config.json`
- **Copilot:** VS Code settings.json (if custom endpoints supported)

## Success Criteria
- Code completions work when I press Tab
- Chat opens with Cmd/Ctrl+L and responds
- No "Sorry, no response was returned" errors
- Model uses the self-hosted endpoint, not OpenAI

## Notes
- The proxy strips problematic response fields (reasoning, annotations, etc.)
- Qwen 3 Coder is optimized for code generation
- 128K context allows large file analysis
- Endpoint is OpenAI-compatible API format
