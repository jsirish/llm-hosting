#!/bin/bash
# RunPod Connection Script
# Pod: petite_coffee_koi-migration (3clxt008hl0a3a)
# GPU: RTX 6000 Ada x1 (48 GB)
# Cost: $0.79/hr

echo "🚀 Connecting to RunPod..."
echo "Pod: petite_coffee_koi-migration"
echo "Pod ID: 3clxt008hl0a3a"
echo "GPU: RTX 6000 Ada x1 (48 GB VRAM)"
echo ""
echo "📝 Opening Jupyter Lab in browser..."
echo "Password: 42z5ic3ocbugvss4iuqr"
echo ""
echo "Once Jupyter opens, click 'Terminal' under 'Other' section"
echo "Then run: cd /workspace && ./qwen3.sh"
echo ""

# Open Jupyter in browser
open "https://3clxt008hl0a3a-8888.proxy.runpod.net/"
