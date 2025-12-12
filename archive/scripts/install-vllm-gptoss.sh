#!/bin/bash
# Install standard vLLM for GPT-OSS-20B
# Run this on RunPod (though standard vLLM should already be installed)

echo "🔧 GPT-OSS-20B Installation Notes"
echo ""
echo "✅ GOOD NEWS: No special vLLM build required!"
echo "   GPT-OSS-20B works with standard vLLM 0.12.0+"
echo "   Uses --tool-call-parser openai for function calling"
echo ""
echo "📦 Standard vLLM should already be installed on RunPod"
echo ""

# Check if vLLM is installed
if python3 -c "import vllm" 2>/dev/null; then
    VLLM_VERSION=$(python3 -c "import vllm; print(vllm.__version__)")
    echo "✅ vLLM ${VLLM_VERSION} is already installed"
    echo ""
    echo "🎉 No installation needed! You can run the GPT-OSS server directly."
    echo "   Use: ./start-server-gptoss.sh"
else
    echo "⚠️  vLLM not found. Installing standard vLLM..."
    pip install --break-system-packages vllm

    if [ $? -eq 0 ]; then
        VLLM_VERSION=$(python3 -c "import vllm; print(vllm.__version__)")
        echo "✅ vLLM ${VLLM_VERSION} installed successfully"
        echo ""
        echo "🎉 Installation complete!"
    else
        echo ""
        echo "❌ Installation failed!"
        echo "Check the error messages above."
        exit 1
    fi
fi

echo ""
echo "📝 Next steps:"
echo "1. Ensure GPT-OSS-20B model is available on HuggingFace"
echo "2. Run ./start-server-gptoss.sh to start the server"
echo ""
echo "💡 Note: Uses standard vLLM with 'openai' tool call parser"
echo "   No special build or PyTorch nightly required!"
echo ""
