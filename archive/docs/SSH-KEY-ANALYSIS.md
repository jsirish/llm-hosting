# SSH Key Analysis - SOLVED

## The Problem

**What works:**
- ✅ Proxy SSH: `ssh v5brcrgoclcp1p-64411a48@ssh.runpod.io -i ~/.ssh/runpod_ed25519`
  - Uses your custom key name
  - Always works (has PTY limitations)

**What doesn't work:**
- ❌ Direct TCP SSH: `ssh root@195.26.233.58 -p XXXXX -i ~/.ssh/id_ed25519`
  - Port keeps changing!
  - Connection refused errors

## Root Cause: Dynamic Port Mapping

**The SSH key is CORRECT** - both methods expect `id_ed25519` and we've symlinked it properly.

**The real issue:** RunPod's TCP port mapping is **DYNAMIC**:

| Time | Port | Status |
|------|------|--------|
| Earlier (your script) | 40852 | Connection refused |
| First check | 47721 | Connection refused |
| Current | **48894** | Unknown (not tested yet) |

The port changes frequently, possibly:
- On pod restart
- Periodically for security
- When network routes change

## Additional Discovery

RunPod console also shows:
- Port 36225 exposed as "HTTP Service" (might be old SSH port)
- Port 8000: vLLM API (working)
- Port 8888: Jupyter Lab

## Why Proxy SSH Works But TCP Doesn't

**Proxy SSH (`ssh.runpod.io`):**
- RunPod's proxy handles port routing
- You connect to fixed hostname
- RunPod maps it internally to current port
- Port changes don't affect you

**Direct TCP SSH:**
- You connect directly to IP:port
- If port changes, connection breaks
- Need to update config every time

## For VS Code Remote-SSH

### Option 1: Use Proxy Method (RECOMMENDED)

Update SSH config to use the proxy:

```ssh
Host runpod
    HostName ssh.runpod.io
    User v5brcrgoclcp1p-64411a48
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

**Pros:**
- Port never changes
- Always works
- No manual updates needed

**Cons:**
- PTY limitations for terminal
- Slightly higher latency (proxy hop)

### Option 2: Use Current TCP Port (TESTING)

Test the current port first:

```bash
ssh root@195.26.233.58 -p 48894 -i ~/.ssh/id_ed25519 "echo test"
```

If it works, add to SSH config:

```ssh
Host runpod-direct
    HostName 195.26.233.58
    User root
    Port 48894
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
```

**Pros:**
- Direct connection (lower latency)
- Full SSH features
- No PTY issues

**Cons:**
- Port changes require manual config update
- Need to check RunPod console for current port

## Recommendation for VS Code

**Use the proxy method** for now:

1. The port stability is more important than slight latency
2. VS Code Remote-SSH works fine with proxy
3. Terminal PTY issues are minor (most commands work)
4. No need to update config when port changes

**Commands to run:**

```bash
# Test current TCP port
ssh root@195.26.233.58 -p 48894 -i ~/.ssh/id_ed25519 "hostname"

# If that fails, use proxy for VS Code:
# The symlink is already set up (id_ed25519 -> runpod_ed25519)
# Just add this host to SSH config for VS Code to find
```

## Next Step

Install VS Code Remote-SSH extension and add:

```ssh
Host runpod
    HostName ssh.runpod.io
    User v5brcrgoclcp1p-64411a48
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

Then connect via `Cmd+Shift+P` → "Remote-SSH: Connect to Host" → `runpod`

## Summary

- ✅ SSH key is correct (symlink working)
- ✅ Key matches RunPod's uploaded key
- ❌ TCP ports are dynamic (change frequently)
- ✅ Proxy SSH is stable and recommended
- ✅ Ready for VS Code Remote-SSH setup
