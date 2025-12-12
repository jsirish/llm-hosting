# RunPod RTX 6000 Ada Pod - Deployed ✅

**Deployment Date**: 2025-01-20
**Pod ID**: `v5brcrgoclcp1p`
**Pod Name**: `petite_coffee_koi`

## Pod Specifications

- **GPU**: NVIDIA RTX 6000 Ada (48 GB VRAM)
- **RAM**: 62 GB
- **vCPUs**: 14 cores
- **Storage**: 80 GB
- **Template**: RunPod PyTorch 2.8.0 (runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404)
- **Cost**: $0.78/hour (On-Demand)

## Access URLs

### 1. Jupyter Lab (Ready Now)
- **URL**: https://v5brcrgoclcp1p-8888.proxy.runpod.net/?token=42z5ic3ocbugvss4iuqr
- **Port**: 8888
- **Status**: ✅ Ready
- **Use Case**: Python notebooks, file management, interactive development

### 2. Web Terminal (Enabled)
- **URL**: https://v5brcrgoclcp1p-19123.proxy.runpod.net/b6472jb6g7sa0bdoxdie9l6jrcen530q/
- **Port**: 19123
- **Status**: ✅ Running
- **Use Case**: Direct shell access via browser (no SSH key needed)

### 3. Direct SSH Access (Optional)
- **Host**: `195.26.233.58`
- **Port**: `40852`
- **Target**: Port 22 on pod
- **Status**: ⏸️ Requires SSH public key setup
- **Command**: `ssh root@195.26.233.58 -p 40852` (after adding key)

## Next Steps: Deploy GPT-OSS-20B with vLLM

### Quick Start (5 minutes)

1. **Open Web Terminal**:
   - Click: https://v5brcrgoclcp1p-19123.proxy.runpod.net/b6472jb6g7sa0bdoxdie9l6jrcen530q/

2. **Verify GPU**:
   ```bash
   nvidia-smi
   # Should show: RTX 6000 Ada, 48 GB VRAM
   ```

3. **Check PyTorch**:
   ```bash
   python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
   python -c "import torch; print(f'GPU: {torch.cuda.get_device_name(0)}')"
   ```

4. **Install vLLM**:
   ```bash
   pip install vllm
   ```

5. **Deploy GPT-OSS-20B** (4-bit quantized):
   ```bash
   vllm serve openai/gpt-oss-20b \
     --quantization mxfp4 \
     --tensor-parallel-size 1 \
     --max-model-len 8192 \
     --gpu-memory-utilization 0.90 \
     --port 8000 \
     --host 0.0.0.0
   ```

6. **Model will download** (~10-15 GB for 4-bit quantized version)
   - Original model: ~80 GB FP16
   - 4-bit MXFP4: ~16 GB after quantization
   - With 48 GB VRAM, you have plenty of headroom!

### Testing the Inference API

Once vLLM is running, test from another terminal:

```bash
# Inside the pod
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-20b",
    "prompt": "def fibonacci(n):",
    "max_tokens": 100,
    "temperature": 0.7
  }'
```

### Exposing the API Externally

To access the vLLM API from outside the pod:

#### Option 1: Use RunPod's Port Proxy (Simplest)
1. Add HTTP service exposure in pod settings for port 8000
2. RunPod will create a URL like: `https://v5brcrgoclcp1p-8000.proxy.runpod.net`

#### Option 2: Direct TCP Connection
1. RunPod will assign a public port mapping
2. Access via: `http://195.26.233.58:<assigned-port>/v1`

#### Option 3: Use Jupyter Lab Terminal
The Jupyter Lab instance can also be used for terminal access:
- Open: https://v5brcrgoclcp1p-8888.proxy.runpod.net/?token=42z5ic3ocbugvss4iuqr
- Click "New" → "Terminal"
- Run the same commands as above

## Performance Expectations

### RTX 6000 Ada Specs
- **Architecture**: Ada Lovelace (same as RTX 4090)
- **CUDA Cores**: 18,176
- **Tensor Cores**: 568 (4th gen)
- **Memory Bandwidth**: 960 GB/s
- **TDP**: 300W

### Expected Throughput
- **GPT-OSS-20B (4-bit MXFP4)**:
  - Tokens/sec: ~80-120 tokens/sec (batch size 1)
  - Latency (first token): ~50-100ms
  - Context window: 8192 tokens (configured)
  - Multiple concurrent users: 3-5 simultaneous requests

## Cost Tracking

- **Hourly**: $0.78/hr
- **Daily** (24h): $18.72
- **Weekly**: $131.04
- **Monthly**: ~$562

**Tip**: Use Spot pricing ($0.39/hr) for dev/test to save 50%!

## Comparison to Original DigitalOcean Setup

| Metric | DigitalOcean RTX 4000 ADA | RunPod RTX 6000 Ada |
|--------|---------------------------|---------------------|
| **Price** | $0.76/hr | $0.78/hr |
| **VRAM** | 20 GB | 48 GB (2.4x more!) |
| **RAM** | 40 GB | 62 GB |
| **vCPUs** | 8 | 14 |
| **Availability** | TOR1 only | Available now |
| **Spot Option** | No | Yes ($0.39/hr) |

**Winner**: RunPod RTX 6000 Ada - Better specs, better availability, same price!

## Troubleshooting

### If vLLM install fails:
```bash
pip install --upgrade pip
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
pip install vllm
```

### If model download is slow:
```bash
# Use Hugging Face mirror or cache
export HF_ENDPOINT=https://hf-mirror.com
```

### Check GPU usage:
```bash
watch -n 1 nvidia-smi  # Updates every second
```

### View vLLM logs:
```bash
# vLLM runs in foreground, so logs appear directly
# To run in background:
nohup vllm serve openai/gpt-oss-20b \
  --quantization mxfp4 \
  --tensor-parallel-size 1 \
  --max-model-len 8192 \
  --gpu-memory-utilization 0.90 \
  --port 8000 \
  --host 0.0.0.0 > vllm.log 2>&1 &

# View logs:
tail -f vllm.log
```

## Connection Summary

| Service | URL/Command | Status |
|---------|-------------|---------|
| **Jupyter Lab** | https://v5brcrgoclcp1p-8888.proxy.runpod.net/?token=42z5ic3ocbugvss4iuqr | ✅ Ready |
| **Web Terminal** | https://v5brcrgoclcp1p-19123.proxy.runpod.net/b6472jb6g7sa0bdoxdie9l6jrcen530q/ | ✅ Running |
| **Direct SSH** | `ssh root@195.26.233.58 -p 40852` | ⏸️ Need key |
| **vLLM API** | `http://<pod-internal>:8000/v1` | ⏳ To deploy |

## Management Commands

```bash
# Stop pod (from RunPod console)
# Click "Stop" button - billing stops immediately

# Start pod again
# Click "Start" - billing resumes

# Terminate pod (permanent)
# Click "Terminate" - data is lost!

# Create volume backup before terminating
# Settings → Cloud Sync → Backup to RunPod Storage
```

## Ready to Deploy! 🚀

Your pod is running and ready. Click the Web Terminal link above to start deploying GPT-OSS-20B!
