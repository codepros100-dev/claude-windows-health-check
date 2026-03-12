---
name: windows-health-check
description: Comprehensive Windows system health check, diagnostics, and remediation
argument-hint: [--report-only] [--auto-fix] [--quick]
disable-model-invocation: true
---

# Windows System Health Check & Remediation

You are a Windows system administrator performing a comprehensive health check. Follow the phases below strictly. Do NOT delete files, uninstall software, or modify the registry unless fixing a clearly broken key. Always ask for confirmation before making system changes.

## Arguments

Parse `$ARGUMENTS` for flags:
- `--report-only`: Run diagnostics and generate report only, skip remediation
- `--auto-fix`: Automatically apply safe fixes (updates, temp cleanup, outdated software) without asking. Still ask before reboots.
- `--quick`: Run only critical checks (system health, security, disk space) -- skip full software inventory, network connections, and event viewer deep dive

If no arguments provided, run full diagnostics and ask before each remediation action.

## Phase 1: DIAGNOSTICS

Run the PowerShell diagnostic scripts in parallel using Bash. Use script files to avoid `$` escaping issues in bash-to-powershell. The diagnostic scripts are located in `${CLAUDE_SKILL_DIR}/scripts/`.

### Step 1a: Run all diagnostic scripts in parallel

Execute these script files simultaneously (each via `powershell -NoProfile -ExecutionPolicy Bypass -File "path/to/script.ps1"`):

1. **system-info.ps1** -- OS version, CPU, RAM, disk, uptime, battery, activation
2. **security-check.ps1** -- Defender status, firewall, pending updates, recent installs
3. **software-inventory.ps1** -- Installed software, startup programs, outdated apps (skip if --quick)
4. **performance-check.ps1** -- Temp folder sizes, large folders, top processes
5. **network-check.ps1** -- Adapters, DNS, connectivity, open connections (skip if --quick)
6. **services-check.ps1** -- Critical services, event viewer errors
7. **hardware-check.ps1** -- Device manager issues, drivers, disk health

### Step 1b: Collect and analyze results

Parse all script outputs. For each of the 7 categories, assign:
- **PASS** (8-10/10): No issues or only cosmetic ones
- **WARN** (5-7/10): Issues that should be addressed but aren't urgent
- **FAIL** (0-4/10): Critical issues requiring immediate attention

## Phase 2: REPORT

Generate a markdown report at `~/Desktop/System-Health-Check-YYYY-MM-DD.md` containing:

1. System summary table (OS, CPU, RAM, disk, battery)
2. Each of the 7 category sections with findings tables
3. Summary scorecard (PASS/WARN/FAIL per category)
4. Prioritized issues list (Critical / Warning / Info)
5. Recommended fixes with exact commands
6. Overall health score out of 100

Show the user a summary of findings in the conversation.

## Phase 3: REMEDIATION (skip if --report-only)

For each issue found, offer fixes in priority order:

### Auto-fixable (safe):
- Install pending Windows updates (requires elevation via script + Start-Process -Verb RunAs)
- Update outdated software via winget (requires elevation)
- Clean user temp files (requires elevation)
- Start full Defender scan if overdue

### Requires confirmation:
- Reboot for pending updates
- Any driver updates
- Anything affecting system state

**IMPORTANT: Elevation pattern** -- PowerShell commands with `$` variables get corrupted by bash. Always write a .ps1 script file first, then execute it:
```
powershell -Command 'Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File C:\Users\chaim\Desktop\fix-script.ps1" -Wait'
```

## Phase 4: VERIFY

After remediation:
1. Re-check pending updates
2. Verify services are running
3. Update the MD report with remediation results
4. Report revised health score

## Output Style

- Use tables for structured data
- Keep conversation output concise -- details go in the MD report
- Always show the health score prominently
- Clean up any temporary .ps1 scripts created during remediation
