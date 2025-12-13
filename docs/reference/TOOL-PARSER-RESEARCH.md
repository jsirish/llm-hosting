# Tool Call Parser Research - vLLM

**Date**: December 11, 2025
**Research Question**: Does vLLM have a parser for GPT-OSS?

---

## Available Tool Call Parsers in vLLM 0.12.0

```
deepseek_v3, deepseek_v31, ernie45, glm45, granite, granite-20b-fc,
hermes, hunyuan_a13b, internlm, jamba, kimi_k2, llama3_json,
llama4_json, llama4_pythonic, longcat, minimax, minimax_m2, mistral,
olmo3, openai, phi4_mini_json, pythonic, qwen3_coder, qwen3_xml,
seed_oss, step3, xlam
```

---

## Findings

### GPT-OSS Parser Status
❌ **No dedicated `gpt_oss` parser exists in vLLM**

### Possible Alternatives for GPT-OSS

If GPT-OSS were obtainable, the most likely parsers to use would be:

1. **`openai`** (MOST LIKELY) ✅
   - GPT-OSS is based on OpenAI's model format
   - Would use OpenAI's function calling format
   - Standard JSON-based tool calling

2. **`seed_oss`** (UNCERTAIN) ❓
   - Name suggests it might be for open-source models
   - No documentation found linking it to GPT-OSS
   - Could be for a different OSS project (SEED)
   - Worth trying if `openai` parser doesn't work

3. **Custom Parser** (FALLBACK)
   - Could create custom parser following vLLM's plugin system
   - Would need to understand GPT-OSS's native output format

---

## Qwen3-Coder Parser Evolution

### ✅ Current: `qwen3_xml` (Recommended)
- Uses XML format (avoids JSON escape character issues)
- Dedicated parser for Qwen3-Coder models
- Compatible with Continue.dev tool calling
- Handles code with backslashes and special characters reliably

### Previous Attempts
1. ❌ `qwen3_coder` - Initial success but had JSON escape issues
   - Worked initially with basic tool calls
   - Failed with responses containing backslashes (e.g., regex, file paths)
   - Error: `400 Invalid \escape: line 1 column 2271`
2. ❌ `openai` - Incompatible (requires token IDs)
   - Error: `OpenAIToolParser requires token IDs and does not support text-based extraction`
   - Returned 500 errors
3. ✅ `qwen3_xml` - **Current solution**
   - XML format naturally handles backslashes
   - No JSON parsing errors
   - Stable for all response types

---

## Parser Testing Journey

### Attempted Parsers (for Qwen3-Coder-30B)
1. ❌ `hermes` - Generated XML format instead of JSON (`<function=...>`)
2. ❌ `default` - Not a valid parser (KeyError)
3. ❌ `internlm` - Tried briefly
4. ⚠️ `qwen3_coder` - Worked initially, but had escape character issues
5. ❌ `openai` - Requires token IDs (incompatible)
6. ✅ `qwen3_xml` - CURRENT! XML format avoids escape issues

### Key Learning
**Always use the model-specific parser when available!**

Each model family has its own tool calling format:
- Qwen → `qwen3_coder` or `qwen3_xml`
- Llama → `llama3_json` or `llama4_json`
- DeepSeek → `deepseek_v3` or `deepseek_v31`
- Granite → `granite` or `granite-20b-fc`
- OpenAI-based models → `openai`

---

## Updated GPT-OSS Configuration

If GPT-OSS ever becomes available, use this configuration:

```bash
nohup python3 -m vllm.entrypoints.openai.api_server \
  --model "openai/gpt-oss-20b" \
  --tensor-parallel-size 1 \
  --max-model-len 32768 \
  --gpu-memory-utilization 0.90 \
  --port 8000 \
  --host 0.0.0.0 \
  --api-key "${API_KEY}" \
  --enable-auto-tool-choice \
  --tool-call-parser openai \
  > "${LOG_FILE}" 2>&1 &
```

**Alternative to try if `openai` doesn't work:**
```bash
--tool-call-parser seed_oss
```

---

## Critical Deployment Lessons

### 1. Cache Location
**Problem**: Root overlay only has 30GB, filled up quickly
**Solution**: Use `/workspace/hf-cache` (304TB network storage)

```bash
export HF_HOME="/workspace/hf-cache"
export TRANSFORMERS_CACHE="/workspace/hf-cache"
export HF_DATASETS_CACHE="/workspace/hf-cache/datasets"
```

### 2. Tool Call Parser Required
**Problem**: GitHub Copilot requires tool calling, but vLLM needs parser specified
**Solution**: Use model-specific parser with `--enable-auto-tool-choice`

```bash
--enable-auto-tool-choice \
--tool-call-parser qwen3_coder
```

### 3. Pre-quantized Models Better
**Problem**: Runtime quantization adds complexity and download size
**Solution**: Use pre-quantized models (e.g., models with `-FP8` suffix)

**Example**: `Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8`
- ~15GB download vs potentially larger unquantized + quantization overhead
- Reliable, tested by model authors
- Loads faster

### 4. No "Default" Parser
**Problem**: Tried `--tool-call-parser default`, got KeyError
**Solution**: Must specify exact parser name from the list

**Error message helped us discover the full parser list!**

---

## Documentation Sources

### vLLM Tool Calling Docs
- **URL**: https://docs.vllm.ai/en/latest/features/tool_calling.html
- **Key Info**:
  - Custom parser plugin system
  - Parser registration with `ToolParserManager`
  - Each parser handles specific model formats

### Parser Implementation Examples
- GLM4-MoE: Uses `<tool_call>` XML-style tags
- Phi4 Mini: Uses `functools[...]` format
- HunyuanA13B: Uses JSON array format
- Qwen3 Coder: Uses native Qwen JSON format

---

## Recommendations

### For GPT-OSS (if it becomes available)
1. ✅ Try `--tool-call-parser openai` first
2. 🔄 Fallback to `--tool-call-parser seed_oss`
3. 📝 Document which one works
4. ⚠️ Remember to set cache location to `/workspace/hf-cache`

### For Other Models
1. 🔍 Check vLLM docs for model-specific parser
2. 📋 Look at the full parser list (see error message trick)
3. 🧪 Test with simple requests before complex workflows
4. ⚡ Use pre-quantized versions when available

---

## Current Production Setup

**Model**: Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8
**Parser**: `qwen3_coder`
**API Key**: `sk-vllm-c627cedbf339782f52774e32377d84b6`
**Context Window**: 128K tokens (131,072)
**Status**: ✅ Working perfectly with GitHub Copilot### Configuration
```bash
--enable-auto-tool-choice \
--tool-call-parser qwen3_coder
```

### Test Results
- ✅ Basic chat completions work
- ✅ Code generation works
- ✅ Tool calling format is JSON (not XML)
- ✅ GitHub Copilot compatible
- ✅ 32k context window active

---

## References

- vLLM GitHub: https://github.com/vllm-project/vllm
- Tool Calling Docs: https://docs.vllm.ai/en/latest/features/tool_calling.html
- Qwen Models: https://huggingface.co/Qwen
- Context7 vLLM Docs: Researched via `/websites/vllm_ai_en` and `/vllm-project/vllm`

---

**Last Updated**: December 11, 2025
**Status**: Production ready with Qwen3-Coder-30B-FP8 ✅
