#!/bin/bash
# Quick script to check your RunPod environment
# Run this on the pod to see where you should put files

echo "🔍 RunPod Environment Check"
echo "==========================="
echo ""

echo "Current user:"
whoami
echo ""

echo "Current directory:"
pwd
echo ""

echo "Home directory:"
echo $HOME
echo ""

echo "Available directories:"
echo "  /workspace exists: $([ -d /workspace ] && echo 'YES ✅' || echo 'NO ❌')"
echo "  /home exists: $([ -d /home ] && echo 'YES ✅' || echo 'NO ❌')"
echo "  /root exists: $([ -d /root ] && echo 'YES ✅' || echo 'NO ❌')"
echo ""

if [ -d /workspace ]; then
    echo "📁 /workspace contents:"
    ls -lh /workspace 2>/dev/null | head -10
    echo ""
    echo "✅ RECOMMENDED: Use /workspace for your scripts"
    echo "   (This directory persists across pod restarts)"
else
    echo "⚠️  /workspace not found"
fi

echo ""
echo "Disk space:"
df -h / /workspace 2>/dev/null | grep -v "Filesystem"
