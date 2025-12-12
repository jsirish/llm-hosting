# 🔐 API Key Setup Guide

## Why Use an API Key?

Your vLLM server on RunPod is **publicly accessible** once port 8000 is exposed. Without authentication:
- ❌ Anyone who finds your URL can use your GPU
- ❌ You pay for their inference costs ($0.78/hr)
- ❌ No rate limiting or abuse protection

With an API key:
- ✅ Only authorized requests are processed
- ✅ You control who can access your API
- ✅ Can revoke/rotate keys as needed

---

## How It Works

The updated `start-server.sh` script now:

1. **Generates a secure random API key** (or uses your custom one)
2. **Saves it to** `/workspace/logs/api-key.txt`
3. **Starts vLLM with** `--api-key` parameter
4. **Displays the key** when server starts

All API requests must include:
```
Authorization: Bearer YOUR_API_KEY_HERE
```

---

## Quick Start

### 1. Start Server (Generates Key Automatically)

```bash
cd /workspace
./start-server.sh
```

You'll see:
```
🔐 API Key: sk-vllm-a1b2c3d4e5f6...
   (Save this! You'll need it for API requests)
```

**The key is saved to:** `/workspace/logs/api-key.txt`

---

### 2. Get Your API Key

```bash
# On the pod
cat /workspace/logs/api-key.txt
```

**Save this somewhere secure!** You'll need it for all API requests.

---

### 3. Use the API Key

#### From Inside Pod:
```bash
# The test script automatically loads the key
./test-api.sh
```

#### From Your Mac (via RunPod Proxy):
```bash
# Set the API key as environment variable
export VLLM_API_KEY="sk-vllm-a1b2c3d4e5f6..."

# Run tests
./test-api-local.sh
```

#### Manual curl Example:
```bash
curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-vllm-a1b2c3d4e5f6..." \
  -d '{
    "model": "ArliAI/gpt-oss-20b-Derestricted",
    "prompt": "Hello, world!",
    "max_tokens": 50
  }'
```

---

## Custom API Key

### Option 1: Set Before Starting
```bash
# On the pod
export VLLM_API_KEY="my-secure-key-12345"
./start-server.sh
```

### Option 2: Generate a Strong Key
```bash
# Generate a random 32-character key
openssl rand -base64 32

# Or hex format
openssl rand -hex 32
```

Example output:
```
vT8xK2mP9Qr4sN7wL5jB3eF1hU6yG0zA
```

Then use it:
```bash
export VLLM_API_KEY="vT8xK2mP9Qr4sN7wL5jB3eF1hU6yG0zA"
./start-server.sh
```

---

## Key Management

### View Current Key
```bash
cat /workspace/logs/api-key.txt
```

### Rotate Key (Change It)
```bash
# Stop server
./stop-server.sh

# Generate new key and start
export VLLM_API_KEY="$(openssl rand -hex 32)"
./start-server.sh

# Update your applications with new key
cat /workspace/logs/api-key.txt
```

### Remove Key (Open Access - Not Recommended)
Edit `start-server.sh` and remove the `--api-key` line, then restart.

**⚠️ WARNING:** This makes your API publicly accessible without authentication!

---

## Security Best Practices

### 1. **Keep Keys Secret**
- ❌ Don't commit to git
- ❌ Don't share in chat/email
- ❌ Don't log in plaintext
- ✅ Use environment variables
- ✅ Store in secure password manager

### 2. **Rotate Regularly**
- Change keys every 30-90 days
- Change immediately if compromised
- Keep old key active briefly during rotation

### 3. **Use Strong Keys**
- Minimum 32 characters
- Use `openssl rand` or similar
- Mix of letters, numbers, symbols
- Avoid predictable patterns

### 4. **Monitor Usage**
Check your RunPod billing dashboard regularly for unexpected usage spikes.

### 5. **Implement Rate Limiting**
Consider adding a reverse proxy (nginx, Cloudflare) with rate limiting in front of vLLM.

---

## Testing Authentication

### Test Without Key (Should Fail)
```bash
curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/health
```

Expected response:
```json
{"error": "Unauthorized"}
```
or
```json
{"detail": "Missing or invalid API key"}
```

### Test With Key (Should Succeed)
```bash
curl https://v5brcrgoclcp1p-8000.proxy.runpod.net/health \
  -H "Authorization: Bearer YOUR_KEY_HERE"
```

Expected response:
```json
{"status": "ok"}
```

---

## Python Example

```python
import os
import requests

API_URL = "https://v5brcrgoclcp1p-8000.proxy.runpod.net"
API_KEY = os.environ.get("VLLM_API_KEY")

headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {API_KEY}"
}

# Health check
response = requests.get(f"{API_URL}/health", headers=headers)
print(response.json())

# Completion
data = {
    "model": "ArliAI/gpt-oss-20b-Derestricted",
    "prompt": "def factorial(n):",
    "max_tokens": 100
}
response = requests.post(f"{API_URL}/v1/completions", json=data, headers=headers)
print(response.json())
```

---

## JavaScript Example

```javascript
const API_URL = "https://v5brcrgoclcp1p-8000.proxy.runpod.net";
const API_KEY = process.env.VLLM_API_KEY;

const headers = {
    "Content-Type": "application/json",
    "Authorization": `Bearer ${API_KEY}`
};

// Health check
fetch(`${API_URL}/health`, { headers })
    .then(res => res.json())
    .then(data => console.log(data));

// Completion
fetch(`${API_URL}/v1/completions`, {
    method: "POST",
    headers,
    body: JSON.stringify({
        model: "ArliAI/gpt-oss-20b-Derestricted",
        prompt: "def factorial(n):",
        max_tokens: 100
    })
})
    .then(res => res.json())
    .then(data => console.log(data));
```

---

## Troubleshooting

### "Missing or invalid API key" Error
**Cause:** Request doesn't include Authorization header or key is wrong

**Fix:**
1. Verify key: `cat /workspace/logs/api-key.txt`
2. Check header format: `Authorization: Bearer YOUR_KEY`
3. Ensure no extra spaces or quotes

### "Unauthorized" Error
**Cause:** Server requires auth but you didn't provide it

**Fix:** Add the Authorization header to your request

### Key File Not Found
**Cause:** Server wasn't started with the new script

**Fix:**
```bash
./stop-server.sh
./start-server.sh
# Key will be generated and saved
```

### Server Won't Start with API Key
**Cause:** vLLM version might not support `--api-key`

**Fix:**
```bash
# Check vLLM version
pip show vllm | grep Version

# Update if needed (version 0.6.0+)
pip install --upgrade vllm
```

---

## Key Storage Locations

| File | Purpose | Permissions |
|------|---------|-------------|
| `/workspace/logs/api-key.txt` | Current API key | `600` (owner only) |
| Environment var `VLLM_API_KEY` | Custom key (optional) | - |

**Note:** Keys are stored in plaintext. For production, consider:
- AWS Secrets Manager
- HashiCorp Vault
- Kubernetes Secrets
- Environment variable injection

---

## FAQ

**Q: Can I have multiple API keys?**
A: vLLM's built-in auth supports one key. For multiple keys, use a reverse proxy (nginx, Cloudflare).

**Q: Can I disable authentication?**
A: Yes, but not recommended. Remove `--api-key` from start-server.sh.

**Q: What if I forget my key?**
A: Check `/workspace/logs/api-key.txt` on the pod.

**Q: Does this work with OpenAI client libraries?**
A: Yes! Use your API key as the OpenAI API key:

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://v5brcrgoclcp1p-8000.proxy.runpod.net/v1",
    api_key="YOUR_VLLM_API_KEY"
)

response = client.chat.completions.create(
    model="ArliAI/gpt-oss-20b-Derestricted",
    messages=[{"role": "user", "content": "Hello!"}]
)
```

**Q: Is this as secure as production systems?**
A: No. For production:
- Use HTTPS (already provided by RunPod)
- Add rate limiting
- Implement request logging
- Use OAuth/JWT tokens
- Add IP allowlisting
- Monitor for abuse

---

## Next Steps

1. ✅ Start server with `./start-server.sh`
2. ✅ Save the API key shown during startup
3. ✅ Test locally: `./test-api.sh` (on pod)
4. ✅ Test remotely: Set `VLLM_API_KEY` env var, run `./test-api-local.sh`
5. ✅ Update your applications to include the Authorization header
6. ✅ Monitor your RunPod usage dashboard
7. ✅ Rotate keys periodically (every 30-90 days)

---

## Summary

| What | How |
|------|-----|
| **Start server** | `./start-server.sh` |
| **View key** | `cat /workspace/logs/api-key.txt` |
| **Set custom key** | `export VLLM_API_KEY="your-key"` before starting |
| **Rotate key** | Stop server, set new key, start server |
| **Use in requests** | `Authorization: Bearer YOUR_KEY` header |
| **Test auth** | `./test-api.sh` (pod) or `./test-api-local.sh` (Mac) |

🔐 **Your API is now secured!**
