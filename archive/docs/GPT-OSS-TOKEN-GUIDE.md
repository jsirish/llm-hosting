# GPT-OSS-20B Token Configuration Guide

## Understanding Context Window: 131,072 tokens (128K)

### How Token Budget Works

The **total context window** is shared between input and output:

```
input_tokens + output_tokens ≤ 131,072
```

### Examples:

| Input Tokens | Max Output Tokens | Total |
|--------------|-------------------|-------|
| 1,000 | 130,072 | 131,072 |
| 50,000 | 81,072 | 131,072 |
| 100,000 | 31,072 | 131,072 |
| 120,000 | 11,072 | 131,072 |

### Recommended Settings

**For typical coding tasks:**
- **Max Input**: 120,000 tokens (leaves room for large files)
- **Max Output**: 8,192 tokens (enough for most code responses)

**For long-form generation:**
- **Max Input**: 60,000 tokens
- **Max Output**: 70,000 tokens

## Running Multiple Agents Simultaneously

### GPU Memory (VRAM) Constraints

**Current Setup:**
- GPU: RTX 6000 Ada (48 GB VRAM)
- Model: GPT-OSS-20B (~20-25 GB VRAM base)
- Context: 128K tokens

**VRAM Usage Per Agent:**
- Base model: ~20-25 GB
- 128K context cache: ~5-10 GB per agent
- **Total per agent: ~30-35 GB**

### Can You Run Multiple Agents?

**1 Agent:** ✅ **Safe** (~30-35 GB / 48 GB = 73%)
- Current setup ✅

**2 Agents:** ⚠️ **Tight** (60-70 GB needed, only 48 GB available)
- Won't fit with 128K context
- Might work with reduced context (32K-64K per agent)

**3 Agents:** ❌ **Won't Fit** (90-105 GB needed, only 48 GB available)

### Solutions for Multiple Agents:

#### Option 1: Reduce Context Per Agent
```bash
# In gptoss.sh, reduce to 32K or 64K:
export VLLM_MAX_MODEL_LEN=32768   # 32K = ~5 GB VRAM per agent
export VLLM_MAX_MODEL_LEN=65536   # 64K = ~8 GB VRAM per agent
```

**With 32K context:**
- 2 agents: 20 + (2 × 5) = ~30 GB → ✅ Should work
- 3 agents: 20 + (3 × 5) = ~35 GB → ✅ Might work

#### Option 2: Use Smaller Model
Switch to a smaller model like:
- **Qwen/Qwen3-Coder-14B** (~15 GB VRAM)
- **CodeLlama-13B** (~13 GB VRAM)

#### Option 3: Run Multiple Pods
Spin up 2-3 separate RunPod instances, each running one agent.

**Cost:** $0.78/hr × 3 pods = $2.34/hr

#### Option 4: Use Batch Processing
Instead of concurrent agents, run them sequentially (one at a time).

## Current VS Code Settings Explanation

```json
{
  "continue.contextLength": 131072,     // Total context window
  "continue.maxTokens": 8192,            // Max OUTPUT per request
  "ai.maxInputTokens": 120000,          // Leave 11K for output
  "ai.maxOutputTokens": 8192            // Standard response size
}
```

### Why 8K Output?

- Most code completions: 100-2000 tokens
- Large functions: 2000-5000 tokens
- Full file generation: 5000-10000 tokens
- **8K covers 95% of use cases**

### When to Increase Output:

If you need longer outputs (e.g., generating entire files):

```json
"continue.maxTokens": 16384,           // 16K output
"ai.maxInputTokens": 110000,          // Adjust input accordingly
```

**Rule of thumb:** `maxInputTokens + maxTokens ≤ 131072`

## API Request Examples

### Standard Request (balanced):
```json
{
  "max_tokens": 2000,
  "messages": [{"role": "user", "content": "Write a function..."}]
}
```

### Large Context Request:
```json
{
  "max_tokens": 4000,
  "messages": [
    {"role": "user", "content": "Here's a 50K token codebase..."}
  ]
}
```

### Long Output Request:
```json
{
  "max_tokens": 30000,
  "messages": [{"role": "user", "content": "Generate a complete app..."}]
}
```

## Monitoring VRAM Usage

To check current VRAM usage on RunPod:

```bash
# SSH to pod
./connect-runpod.sh

# Check GPU memory
nvidia-smi

# Watch in real-time
watch -n 1 nvidia-smi
```

Look for:
- **Used**: Should be 30-35 GB with 1 agent
- **Free**: Should be 13-18 GB remaining

If you see **>45 GB used**, you're near capacity.

## Summary

**Single Agent (Current Setup):**
- ✅ 128K context works perfectly
- ✅ ~30-35 GB VRAM usage
- ✅ 13-18 GB VRAM headroom

**Multiple Agents:**
- 2 agents: Reduce to 32-64K context per agent
- 3 agents: Use smaller model or separate pods
- Alternative: Sequential processing (one at a time)

**Recommended Settings:**
- Max Input: 120,000 tokens
- Max Output: 8,192 tokens
- Total: 128,192 tokens (within 131K limit)
