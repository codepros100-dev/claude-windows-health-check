# Claude Windows Health Check

A comprehensive Windows system health check, diagnostics, and remediation skill for [Claude Code](https://claude.ai/code).

Run `/windows-health-check` in Claude Code to get a full system audit with a health score, prioritized issues, and one-click fixes -- all from your terminal.

**This is the first Windows system administration skill for Claude Code.**

---

## What It Does

| Phase | Description |
|-------|-------------|
| **Diagnose** | Runs 7 parallel PowerShell scripts covering system health, security, software, performance, network, services, and hardware |
| **Report** | Generates a scored markdown report with PASS/WARN/FAIL per category and an overall health score out of 100 |
| **Remediate** | Installs pending updates, cleans temp files, updates outdated software, runs antivirus scans -- with your approval |
| **Verify** | Re-checks the system after fixes and updates the report with results |

### Categories Checked

| # | Category | What's Checked |
|---|----------|---------------|
| 1 | **System Health** | OS version/build, CPU, RAM, disk space, SMART status, uptime, battery, activation |
| 2 | **Software Inventory** | Installed software with versions, startup programs, outdated apps, duplicate entries |
| 3 | **Security** | Windows Defender status, firewall, pending security updates, recent installs, suspicious startup entries |
| 4 | **Performance** | Temp folder sizes, large folders, top processes by CPU/RAM, Windows Update cache |
| 5 | **Network** | Adapter status, DNS settings, connectivity tests, active connections, listening ports |
| 6 | **Services** | Critical Windows services status, failed auto-start services, Event Viewer errors (7 days) |
| 7 | **Hardware** | Device Manager errors, GPU/audio/network drivers, battery health, disk SMART, ghost devices |

---

## Installation

### Option 1: Personal skill (recommended)

Copy the skill to your Claude Code skills directory so it's available in all projects:

```bash
# Clone the repo
git clone https://github.com/codepros100-dev/claude-windows-health-check.git

# Copy to your Claude Code skills directory
mkdir -p ~/.claude/skills
cp -r claude-windows-health-check/windows-health-check ~/.claude/skills/
```

### Option 2: Project-level skill

Add it to a specific project's `.claude/skills/` directory:

```bash
cd your-project
mkdir -p .claude/skills
cp -r /path/to/claude-windows-health-check/windows-health-check .claude/skills/
```

---

## Usage

Open Claude Code and run:

```
/windows-health-check
```

### Options

| Command | Description |
|---------|-------------|
| `/windows-health-check` | Full diagnostics + ask before each fix |
| `/windows-health-check --report-only` | Diagnostics and report only, no fixes applied |
| `/windows-health-check --auto-fix` | Automatically apply safe fixes (updates, temp cleanup, software updates). Still asks before reboots. |
| `/windows-health-check --quick` | Critical checks only (system health, security, disk) -- faster, skips full software inventory and network deep dive |

---

## Example Output

### Health Score

```
Overall Health Score: 85/100

| Category              | Status   | Score |
|-----------------------|----------|-------|
| 1. System Health      | PASS     | 9/10  |
| 2. Software Inventory | PASS     | 8/10  |
| 3. Security           | WARN     | 7/10  |
| 4. Performance        | WARN     | 6/10  |
| 5. Network            | PASS     | 10/10 |
| 6. Windows Services   | PASS     | 8/10  |
| 7. Hardware Status    | PASS     | 9/10  |
```

### Prioritized Issues

```
WARNING: 5 pending security updates -- install via Settings > Windows Update
WARNING: Disk 85% full -- only 68 GB free on 456 GB drive
WARNING: Full antivirus scan not run in 3 months
INFO: User temp folder is 4.2 GB -- can be safely cleaned
INFO: VLC 3.0.16 is outdated -- update to 3.0.23
```

### Auto-Remediation

When using `--auto-fix` or when you approve fixes, the skill can:
- Install all pending Windows security updates
- Update outdated software via `winget`
- Clean temp files (reports space freed)
- Start a full Windows Defender scan
- Install pending driver updates

All fixes run via elevated PowerShell scripts with proper error handling.

---

## File Structure

```
windows-health-check/
├── SKILL.md                          # Skill definition and orchestration
└── scripts/
    ├── system-info.ps1               # OS, CPU, RAM, disk, battery, activation
    ├── security-check.ps1            # Defender, firewall, updates, recent installs
    ├── software-inventory.ps1        # Installed apps, startup, outdated, duplicates
    ├── performance-check.ps1         # Temp sizes, large folders, top processes
    ├── network-check.ps1             # Adapters, DNS, connectivity, connections
    ├── services-check.ps1            # Critical services, event viewer errors
    └── hardware-check.ps1            # Device manager, drivers, battery, SMART
```

---

## Requirements

- **Windows 10/11** (tested on Windows 11 24H2)
- **Claude Code** CLI installed
- **PowerShell 5.1+** (built into Windows)
- **Administrator access** required for: installing updates, cleaning system temp files, running Defender scans, installing drivers

No additional software or modules required -- all scripts use built-in Windows PowerShell cmdlets.

---

## Safety

This skill follows strict safety rules:

- **Does NOT delete** any files, folders, or data without explicit approval
- **Does NOT uninstall** any software
- **Does NOT modify** registry entries
- **Does NOT change** user settings or preferences
- **Asks for confirmation** before every system change (unless `--auto-fix` is used)
- All temp file cleanup is limited to `%TEMP%` directory contents
- All scripts are **read-only diagnostics** -- remediation is separate and opt-in

---

## How It Works

1. **Diagnostics phase**: Runs 7 PowerShell scripts in parallel via Claude Code's Bash tool. Scripts are `.ps1` files (not inline commands) to avoid bash/PowerShell `$` variable escaping issues.

2. **Analysis phase**: Claude reads all script outputs, scores each category (PASS/WARN/FAIL), and identifies issues by priority (Critical/Warning/Info).

3. **Report phase**: Generates a timestamped markdown file on your Desktop with full findings, scorecard, and recommended fixes.

4. **Remediation phase**: For each issue, offers specific fixes. Safe fixes (updates, cleanup) can run automatically. System changes (reboot, driver installs) always ask first. Uses `Start-Process -Verb RunAs` for elevation.

---

## Contributing

Contributions welcome! Some ideas:

- [ ] Add checks for Windows Server editions
- [ ] Add Hyper-V / WSL health checks
- [ ] Add scheduled task auditing
- [ ] Add browser extension scanning
- [ ] Add Office 365 / Microsoft 365 health checks
- [ ] Add printer/peripheral diagnostics
- [ ] Support for multiple languages
- [ ] Add a `--schedule` flag to create a recurring Windows Task

### How to contribute

1. Fork this repo
2. Create a feature branch (`git checkout -b feature/add-wsl-check`)
3. Add your changes
4. Test with Claude Code (`/windows-health-check --report-only`)
5. Submit a pull request

---

## License

MIT License -- see [LICENSE](LICENSE) for details.

---

## Credits

Built with [Claude Code](https://claude.ai/code) by Anthropic.

Part of the [awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills) community.
