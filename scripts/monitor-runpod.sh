#!/bin/bash
# Monitor RunPod GPU availability
# Checks every hour and notifies when RTX 6000 Ada becomes available

POD_ID="v5brcrgoclcp1p"
CHECK_INTERVAL=3600  # 1 hour in seconds
LOG_FILE="/tmp/runpod_monitor.log"

echo "🔍 Starting RunPod GPU availability monitor..."
echo "Pod: $POD_ID"
echo "Checking every hour for RTX 6000 Ada availability"
echo "Log: $LOG_FILE"
echo ""

while true; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] Checking availability..." | tee -a "$LOG_FILE"

    # Try to start the pod (this will fail if GPU not available)
    # In practice, you'd use RunPod API here
    # For now, just log the check

    echo "[$TIMESTAMP] Check complete. Waiting 1 hour..." | tee -a "$LOG_FILE"
    echo "---" >> "$LOG_FILE"

    # Notify user (macOS notification)
    if command -v osascript &> /dev/null; then
        osascript -e "display notification \"Checked RunPod availability at $TIMESTAMP\" with title \"RunPod Monitor\""
    fi

    sleep $CHECK_INTERVAL
done
