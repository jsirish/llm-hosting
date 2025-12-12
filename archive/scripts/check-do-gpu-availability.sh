#!/bin/bash

# DigitalOcean GPU Availability Checker
# Monitors when RTX 4000 ADA GPUs become available
# Last Updated: December 11, 2025
#
# KNOWN LIMITATIONS (TODO for future enhancement):
# - Currently only checks API-level size availability
# - Does NOT validate actual droplet creation permissions
# - Does NOT check account quota or waitlist status
# - May report false positives if account lacks GPU Droplet access
#
# Future improvements needed:
# 1. Add droplet creation dry-run validation
# 2. Check account GPU quota/limits
# 3. Validate regional access permissions
# 4. Test actual droplet creation capability (if API supports)
# 5. Add web scraping fallback to verify UI availability

# Configuration
DO_API_TOKEN="${DO_API_TOKEN:-$(op read 'op://Development Tools/DigitalOcean API Token/credential' 2>/dev/null)}"
REGIONS=("nyc2" "atl1" "tor1" "nyc3")
TARGET_GPU="gpu-4000adax1-20gb"
CHECK_INTERVAL=3600  # Check every hour (in seconds)
LOG_FILE="$HOME/.do-gpu-check.log"
NOTIFICATION_FILE="$HOME/.do-gpu-notification-sent"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to send notification (macOS)
send_notification() {
    local title="$1"
    local message="$2"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "display notification \"$message\" with title \"$title\" sound name \"Glass\""
    fi

    log "NOTIFICATION: $title - $message"
}

# Function to check if API token is set
check_api_token() {
    if [ -z "$DO_API_TOKEN" ]; then
        echo -e "${RED}Error: DigitalOcean API token not set${NC}"
        echo ""
        echo "Please set it in one of these ways:"
        echo "1. Export: export DO_API_TOKEN='your-token'"
        echo "2. 1Password: Store in 'DigitalOcean API Token' item"
        echo "3. Create API token at: https://cloud.digitalocean.com/account/api/tokens"
        echo ""
        exit 1
    fi
}

# Function to check GPU availability in a region
check_region() {
    local region=$1

    log "Checking region: $region"

    response=$(curl -s -X GET \
        "https://api.digitalocean.com/v2/sizes?per_page=200" \
        -H "Authorization: Bearer $DO_API_TOKEN" \
        -H "Content-Type: application/json")

    # Check if the request was successful
    if echo "$response" | grep -q '"id":"error"'; then
        log "ERROR: API request failed for region $region"
        return 1
    fi

    # Look for the target GPU size
    gpu_available=$(echo "$response" | grep -o "\"slug\":\"$TARGET_GPU\"" | wc -l)

    if [ "$gpu_available" -gt 0 ]; then
        # Check if it's actually available (not just listed)
        gpu_regions=$(echo "$response" | grep -A 50 "\"slug\":\"$TARGET_GPU\"" | grep -A 5 "\"regions\"" | grep "$region")

        if [ -n "$gpu_regions" ]; then
            return 0  # Available
        fi
    fi

    return 1  # Not available
}

# Function to get size details
get_gpu_details() {
    response=$(curl -s -X GET \
        "https://api.digitalocean.com/v2/sizes?per_page=200" \
        -H "Authorization: Bearer $DO_API_TOKEN" \
        -H "Content-Type: application/json")

    echo "$response" | grep -A 30 "\"slug\":\"$TARGET_GPU\"" | head -30
}

# Function to check all regions
check_all_regions() {
    local available_regions=()

    echo -e "\n${YELLOW}Checking GPU availability across regions...${NC}\n"

    for region in "${REGIONS[@]}"; do
        if check_region "$region"; then
            available_regions+=("$region")
            echo -e "${GREEN}✓ $region - RTX 4000 ADA AVAILABLE!${NC}"
        else
            echo -e "${RED}✗ $region - Not available${NC}"
        fi
    done

    if [ ${#available_regions[@]} -gt 0 ]; then
        log "SUCCESS: RTX 4000 ADA GPU available in: ${available_regions[*]}"

        # Send notification only once
        if [ ! -f "$NOTIFICATION_FILE" ]; then
            send_notification "DigitalOcean GPU Available!" \
                "RTX 4000 ADA is now available in: ${available_regions[*]}"
            touch "$NOTIFICATION_FILE"
        fi

        echo -e "\n${GREEN}🎉 GPU AVAILABLE IN: ${available_regions[*]}${NC}"
        echo -e "\nCreate your droplet at:"
        echo "https://cloud.digitalocean.com/gpus/new?size=$TARGET_GPU"

        return 0
    else
        log "No availability yet"

        # Remove notification file so we can notify again when available
        [ -f "$NOTIFICATION_FILE" ] && rm "$NOTIFICATION_FILE"

        return 1
    fi
}

# Function to run continuous monitoring
monitor() {
    echo -e "${YELLOW}Starting continuous monitoring...${NC}"
    echo "Checking every $(($CHECK_INTERVAL / 60)) minutes"
    echo "Log file: $LOG_FILE"
    echo "Press Ctrl+C to stop"
    echo ""

    while true; do
        check_all_regions

        if [ $? -eq 0 ]; then
            echo -e "\n${GREEN}GPU is available! Stopping monitor.${NC}"
            break
        fi

        echo -e "\nNext check in $(($CHECK_INTERVAL / 60)) minutes..."
        sleep $CHECK_INTERVAL
    done
}

# Function to show usage
usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  check     - Check availability once (default)"
    echo "  monitor   - Continuously monitor and notify when available"
    echo "  details   - Show detailed GPU information"
    echo "  help      - Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  DO_API_TOKEN - Your DigitalOcean API token"
    echo ""
    echo "Examples:"
    echo "  $0 check"
    echo "  $0 monitor"
    echo "  DO_API_TOKEN='your-token' $0 check"
}

# Main script
main() {
    local command="${1:-check}"

    case "$command" in
        check)
            check_api_token
            check_all_regions
            ;;
        monitor)
            check_api_token
            monitor
            ;;
        details)
            check_api_token
            echo "Fetching GPU details..."
            get_gpu_details
            ;;
        help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown command: $command${NC}\n"
            usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
