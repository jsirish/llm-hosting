#!/bin/bash
# vLLM Setup Script for RunPod RTX 6000 Ada
# GPT-OSS-20B with 4-bit MXFP4 Quantization

set -e  # Exit on error

echo "======================================"
echo "🚀 vLLM Setup for GPT-OSS-20B"
echo "======================================"
echo ""

# Step 1: Verify GPU
echo "📊 Step 1: Checking GPU..."
nvidia-smi
echo ""
echo "GPU Check Complete!"
echo ""

# Step 2: Check PyTorch
echo "🔥 Step 2: Verifying PyTorch and CUDA..."
python3 -c "import torch; print(f'PyTorch Version: {torch.__version__}')"
python3 -c "import torch; print(f'CUDA Available: {torch.cuda.is_available()}')"
python3 -c "import torch; print(f'CUDA Version: {torch.version.cuda}')"
python3 -c "import torch; print(f'GPU Device: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"No GPU\"}')"
echo ""

# Step 3: Install vLLM
echo "📦 Step 3: Installing vLLM..."
pip install vllm --no-cache-dir
echo ""
echo "vLLM Installation Complete!"
echo ""

# Step 4: Test vLLM import
echo "✅ Step 4: Testing vLLM installation..."
python3 -c "import vllm; print(f'vLLM Version: {vllm.__version__}')"
echo ""

echo "======================================"
echo "✅ Setup Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Deploy GPT-OSS-20B with the following command:"
echo ""
echo "   vllm serve openai/gpt-oss-20b \\"
echo "     --quantization mxfp4 \\"
echo "     --tensor-parallel-size 1 \\"
echo "     --max-model-len 8192 \\"
echo "     --gpu-memory-utilization 0.90 \\"
echo "     --port 8000 \\"
echo "     --host 0.0.0.0"
echo ""
echo "2. Model will download (~10-15 GB for 4-bit quantized)"
echo "3. Once running, API will be available at http://localhost:8000/v1"
echo ""
