#!/bin/bash
# Emergency Cache Fix - Run this on RunPod to fix disk quota issue

echo "🔧 Emergency Cache Fix"
echo "====================="
echo ""

# Check current disk usage
echo "Current disk usage:"
df -h
echo ""

# Check root cache location (the problematic one)
ROOT_CACHE="/root/.cache/huggingface"
if [ -d "${ROOT_CACHE}" ]; then
    ROOT_SIZE=$(du -sh "${ROOT_CACHE}" 2>/dev/null | cut -f1)
    echo "❌ Found cache in root: ${ROOT_CACHE} (${ROOT_SIZE})"
    echo "   This is filling up the 30GB root overlay!"
    echo ""
    echo "Cleaning up root cache..."
    rm -rf "${ROOT_CACHE}"
    echo "✅ Root cache cleared"
    echo ""
else
    echo "✅ No cache in root location"
    echo ""
fi

# Check workspace cache location (the correct one)
WORKSPACE_CACHE="/workspace/hf-cache"
if [ -d "${WORKSPACE_CACHE}" ]; then
    WORKSPACE_SIZE=$(du -sh "${WORKSPACE_CACHE}" 2>/dev/null | cut -f1)
    echo "✅ Workspace cache exists: ${WORKSPACE_CACHE} (${WORKSPACE_SIZE})"
    echo "   This uses the 304TB network storage (good!)"
else
    echo "Creating workspace cache directory..."
    mkdir -p "${WORKSPACE_CACHE}"
    echo "✅ Workspace cache created"
fi
echo ""

# Show current disk usage after cleanup
echo "Disk usage after cleanup:"
df -h
echo ""

# Set environment variables for current session
export HF_HOME="${WORKSPACE_CACHE}"
export TRANSFORMERS_CACHE="${WORKSPACE_CACHE}"
export HF_DATASETS_CACHE="${WORKSPACE_CACHE}/datasets"

echo "Environment variables set:"
echo "  HF_HOME=${HF_HOME}"
echo "  TRANSFORMERS_CACHE=${TRANSFORMERS_CACHE}"
echo "  HF_DATASETS_CACHE=${HF_DATASETS_CACHE}"
echo ""

echo "✅ Cache fix complete!"
echo ""
echo "Now you can safely run:"
echo "  ./gptoss.sh"
echo ""
