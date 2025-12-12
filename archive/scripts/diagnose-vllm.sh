#!/bin/bash
# Diagnose vLLM installation issues

echo "🔍 vLLM Installation Diagnostics"
echo "================================"
echo ""

echo "1. Python locations:"
which python3
which python
echo ""

echo "2. Python version:"
python3 --version
echo ""

echo "3. Check if vLLM is installed:"
pip list | grep -i vllm || echo "vLLM not found in pip list"
pip3 list | grep -i vllm || echo "vLLM not found in pip3 list"
echo ""

echo "4. Try importing vLLM:"
python3 -c "import vllm; print(f'✅ vLLM found: {vllm.__version__}')" 2>&1
echo ""

echo "5. Check Python site-packages:"
python3 -c "import site; print('\n'.join(site.getsitepackages()))"
echo ""

echo "6. Check if vllm module exists:"
python3 -c "import sys; print([p for p in sys.path if 'site-packages' in p or 'dist-packages' in p])" 2>&1
echo ""

echo "7. Search for vllm in common locations:"
find /usr/local/lib -name "*vllm*" -type d 2>/dev/null | head -5
find /opt -name "*vllm*" -type d 2>/dev/null | head -5
echo ""

echo "8. Check conda environments:"
if command -v conda &> /dev/null; then
    conda env list
else
    echo "Conda not installed"
fi
echo ""

echo "9. Check virtual environments:"
if [ -d "/workspace/venv" ]; then
    echo "Found venv at /workspace/venv"
    source /workspace/venv/bin/activate
    python3 -c "import vllm; print(f'✅ vLLM in venv: {vllm.__version__}')" 2>&1
    deactivate
fi
echo ""

echo "10. Check pip installation path:"
pip show vllm 2>&1 | head -10
