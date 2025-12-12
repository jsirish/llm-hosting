# Repository Cleanup Plan

## Current State
- 41 shell scripts (many test/setup scripts)
- 41 markdown docs (overlapping guides and status files)
- No organization structure

## Proposed Structure

```
llm-hosting/
├── README.md                      # Main entry point
├── START-HERE.md                  # Quick start guide
├── models/                        # Model launcher scripts
│   ├── gptoss.sh
│   ├── qwen.sh
│   ├── qwen3.sh
│   ├── gemma3.sh
│   └── kimi-k2.sh
├── scripts/                       # Utility scripts
│   ├── start-vllm-server.sh      # Generic server launcher
│   ├── stop-server.sh
│   ├── check-server.sh
│   ├── fetch-logs.sh
│   ├── monitor-runpod.sh
│   ├── connect-runpod.sh
│   └── setup-hf-token.sh
├── docs/                          # Documentation (consolidated)
│   ├── setup/
│   │   ├── continue-setup.md
│   │   ├── runpod-deployment.md
│   │   └── api-configuration.md
│   ├── troubleshooting/
│   │   ├── token-leakage-fix.md
│   │   └── common-issues.md
│   └── reference/
│       ├── file-guide.md
│       └── server-management.md
└── archive/                       # Old/obsolete files
    ├── scripts/                   # Old test/install scripts
    └── docs/                      # Outdated status docs
```

## Files to Archive

### Scripts (move to archive/scripts/)
- `install-vllm*.sh` (3 files) - installation done
- `test-*.sh` (9 files) - one-time tests
- `start-server.sh`, `start-server-gptoss.sh` - obsolete (replaced by start-vllm-server.sh)
- `setup-vllm.sh`, `setup-litellm.sh` - one-time setup
- `diagnose-vllm.sh` - troubleshooting done
- `tunnel-api.sh`, `run-proxy.sh`, `simple-proxy.py` - not needed with RunPod
- `check-do-gpu-availability.sh` - DO not being used

### Docs to Archive (move to archive/docs/)
- Status files: `*-STATUS*.md`, `RUNPOD-DEPLOYED.md`, `DEPLOYMENT-SUCCESS.md`
- Duplicate setup guides (consolidate into docs/setup/)
- Old troubleshooting docs (consolidate into docs/troubleshooting/)

### Docs to Consolidate

**Setup Documentation (merge into docs/setup/):**
- Continue-dev-Setup.md
- CONTINUE-SETUP.md
- CONTINUE-SIMPLE-SETUP.md
- VSCODE-SETUP.md
- RUNPOD-DEPLOYMENT-GUIDE.md
→ Merge into: `docs/setup/continue-setup.md`, `docs/setup/runpod-deployment.md`

**Troubleshooting (merge into docs/troubleshooting/):**
- GPT-OSS-TOKEN-LEAKAGE-FIX.md (KEEP - recent fix!)
- GPT-OSS-TROUBLESHOOTING.md
- COPILOT-MODEL-ERROR-FIX.md
→ Merge into: `docs/troubleshooting/common-issues.md`

**Reference (merge into docs/reference/):**
- FILE-GUIDE.md
- SERVER-MANAGEMENT.md
- API-KEY-GUIDE.md

## Files to Keep in Root
- README.md - main overview
- START-HERE.md - quick start
- .vscode/, .continue/, .playwright-mcp/ - config directories

## Implementation Steps
1. Create new directory structure
2. Move model launchers to models/
3. Move utility scripts to scripts/
4. Create archive/ and move obsolete files
5. Consolidate documentation into docs/
6. Update README.md with new structure
7. Create comprehensive START-HERE.md guide

## Notes
- All currently working scripts (gptoss.sh, qwen.sh, start-vllm-server.sh, etc.) will be preserved
- No functionality will be lost - just organized
- Archive can be deleted later after verification
