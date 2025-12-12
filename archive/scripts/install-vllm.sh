#!/bin/bash
# Install vLLM and dependencies on RunPod

set -e  # Exit on error

echo "📦 Installing vLLM and dependencies..."
echo ""

# Check Python version
echo "Python version:"
python3 --version
echo ""

# Check CUDA availability
echo "CUDA info:"
nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader
echo ""
echo "CUDA Version:"
nvcc --version 2>/dev/null | grep release || nvidia-smi | grep "CUDA Version" || echo "CUDA tools not in PATH"
echo ""

# Upgrade pip first
echo "Upgrading pip..."
pip install --upgrade pip
echo ""

# Install vLLM (this takes 5-10 minutes)
echo "Installing vLLM (this may take 5-10 minutes)..."
echo "⏳ Please wait..."
pip install vllm
echo ""

# Install hf_transfer for faster model downloads
echo "Installing hf_transfer..."
pip install hf_transfer
echo ""

# Install other useful tools
echo "Installing additional tools..."
pip install huggingface_hub
echo ""

# Verify installation
echo "Verifying vLLM installation..."
python3 -c "import vllm; print(f'✅ vLLM version: {vllm.__version__}')"
echo ""

# Test CUDA
echo "Testing CUDA availability..."
python3 -c "import torch; print(f'PyTorch version: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda}'); print(f'GPU count: {torch.cuda.device_count()}')"
echo ""

echo "✅ Installation complete!"
echo ""
echo "Installed packages:"
pip list | grep -E "(vllm|torch|transformers|hf)"
echo ""
echo "Next steps:"
echo "1. Start the server: ./start-server.sh"
echo "2. Monitor logs: tail -f /workspace/logs/vllm-server.log"
