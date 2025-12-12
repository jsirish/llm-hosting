#!/bin/bash
# Fetch and display vLLM server logs from RunPod

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}📋 Fetching vLLM server logs from RunPod...${NC}"
echo ""

# Number of lines to fetch (default: 50, or use first argument)
LINES=${1:-50}

echo -e "${YELLOW}Last ${LINES} lines of logs:${NC}"
echo "----------------------------------------"

ssh -T v5brcrgoclcp1p-64411a48@ssh.runpod.io -i ~/.ssh/runpod_ed25519 "tail -${LINES} /workspace/logs/vllm-server.log 2>/dev/null || echo 'No log file found at /workspace/logs/vllm-server.log'"

echo ""
echo "----------------------------------------"
echo -e "${GREEN}To follow logs in real-time, run:${NC}"
echo "  ssh v5brcrgoclcp1p-64411a48@ssh.runpod.io -i ~/.ssh/runpod_ed25519 'tail -f /workspace/logs/vllm-server.log'"
echo ""
echo -e "${GREEN}To search for errors, run:${NC}"
echo "  ssh v5brcrgoclcp1p-64411a48@ssh.runpod.io -i ~/.ssh/runpod_ed25519 'grep -i error /workspace/logs/vllm-server.log'"
