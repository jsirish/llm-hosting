#!/bin/bash
# Wait for server to be ready and then test

echo "⏳ Waiting for server to initialize..."
echo ""

API_KEY="sk-vllm-50f6f6a940b299f5cd2d852fc39c826e"
URL="https://v5brcrgoclcp1p-8000.proxy.runpod.net"

# Wait up to 2 minutes for server to be ready
for i in {1..24}; do
    echo -n "Attempt $i/24: "

    response=$(curl -s -o /dev/null -w "%{http_code}" "${URL}/health" -H "Authorization: Bearer ${API_KEY}")

    if [ "$response" = "200" ]; then
        echo "✅ Server is ready!"
        echo ""
        echo "Testing API..."
        export VLLM_API_KEY="${API_KEY}"
        ./test-api-local.sh
        exit 0
    else
        echo "Status: $response (waiting...)"
        sleep 5
    fi
done

echo ""
echo "❌ Server did not become ready after 2 minutes"
echo "Check the logs on the pod: tail -f /workspace/logs/vllm-server.log"
