#!/bin/bash
# Simple installation of vLLM with GPT-OSS support using pip
# Run this on RunPod before starting the GPT-OSS server

echo "🔧 Installing vLLM with GPT-OSS support..."
echo ""
echo "This will install vLLM 0.10.1+gptoss with PyTorch nightly CUDA 12.8"
echo ""

# Uninstall existing vLLM to avoid conflicts
echo "🗑️  Removing existing vLLM installation..."
pip uninstall -y vllm || true

# Install vLLM with GPT-OSS support using regular pip
echo "📥 Installing vLLM 0.10.1+gptoss..."
pip install --pre vllm==0.10.1+gptoss \
    --extra-index-url https://wheels.vllm.ai/gpt-oss/ \
    --extra-index-url https://download.pytorch.org/whl/nightly/cu128

echo ""
if [ $? -eq 0 ]; then
    echo "✅ Installation successful! Verifying..."
    VLLM_VERSION=$(python3 -c "import vllm; print(vllm.__version__)" 2>&1)
    if [ $? -eq 0 ]; then
        echo "vLLM version: ${VLLM_VERSION}"
        echo ""
        echo "🎉 Installation complete!"
    else
        echo "⚠️  Installation completed but verification failed:"
        echo "${VLLM_VERSION}"
        echo ""
        echo "Try running: python3 -c 'import vllm; print(vllm.__version__)'"
    fi
else
    echo "❌ Installation failed! Check error messages above."
    exit 1
fi

echo ""
echo "Next steps:"
echo "1. Run ./start-server-gptoss.sh to start the GPT-OSS server"
echo ""
