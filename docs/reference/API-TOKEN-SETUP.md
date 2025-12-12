# DigitalOcean API Token Setup

To use the GPU availability checker, you need a DigitalOcean API token.

## Quick Setup

### Option 1: Get Token from DigitalOcean (Recommended)

1. **Go to API Tokens page:**
   https://cloud.digitalocean.com/account/api/tokens

2. **Generate New Token:**
   - Click "Generate New Token"
   - Name: `GPU Availability Checker`
   - Scopes: Read-only (only need to read sizes)
   - Click "Generate Token"

3. **Copy the token** (you'll only see it once!)

4. **Store in 1Password:**
   ```bash
   # Create new item in 1Password
   op item create \
     --category="API Credential" \
     --title="DigitalOcean API Token" \
     --vault="Development Tools" \
     credential="your-token-here"
   ```

### Option 2: Use Existing Login (Browser Method)

The monitoring script is already set up to work with your browser session through Playwright MCP.

## Using the Checker

### One-time Check
```bash
# If token is in 1Password
./check-do-gpu-availability.sh check

# Or set token manually
export DO_API_TOKEN="your-token-here"
./check-do-gpu-availability.sh check
```

### Continuous Monitoring (Recommended)
```bash
# Monitor and get notified when GPU becomes available
./check-do-gpu-availability.sh monitor
```

This will:
- Check every hour
- Send macOS notification when available
- Log all checks to `~/.do-gpu-check.log`
- Stop automatically when GPU is found

### Background Monitoring (Advanced)
```bash
# Run in background
nohup ./check-do-gpu-availability.sh monitor > /dev/null 2>&1 &

# Check status
tail -f ~/.do-gpu-check.log

# Stop monitoring
pkill -f check-do-gpu-availability
```

## Alternative: Manual Browser Checking

You can also check manually using the Playwright MCP script we used earlier. Just ask me to check and I'll navigate to the GPU creation page and report status.

## Cron Setup (Optional)

To check automatically every hour:

```bash
# Edit crontab
crontab -e

# Add this line (checks at the start of every hour)
0 * * * * /Users/jsirish/AI/llm-hosting/check-do-gpu-availability.sh check >> ~/.do-gpu-check-cron.log 2>&1
```

## What Gets Checked

The script checks these regions:
- **NYC2** (New York Datacenter 2)
- **ATL1** (Atlanta Datacenter 1)
- **TOR1** (Toronto Datacenter 1)
- **NYC3** (New York Datacenter 3)

For this GPU:
- **RTX 4000 ADA** (gpu-4000adax1-20gb)
- 20 GB VRAM
- $0.76/hour

## Troubleshooting

### "API token not set" error
Make sure you either:
1. Have the token in 1Password as "DigitalOcean API Token"
2. Set `DO_API_TOKEN` environment variable

### "API request failed" error
- Check your API token is valid
- Verify you have internet connection
- Token may have expired (generate new one)

### No notifications appearing
- Notifications only work on macOS
- Check System Settings → Notifications → Script Editor
- First notification after installation may require approval
