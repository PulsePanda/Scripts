# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Mandatory: Git Sync Protocol

**Every session must start and end with git operations. No exceptions.**

### On Session Start (before any work)

```bash
git fetch origin
git status
# If behind origin/master:
git pull origin master
```

If there are merge conflicts, stop and alert the user. Do not auto-resolve.

### On Session End (after all work)

1. **Sanitation check** — before committing, verify:
   - No API keys, tokens, passwords, or credentials are hardcoded in any modified file
   - No `.DS_Store` or other ignored files are staged
   - All new scripts follow the naming and formatting rules below
   - All modified PowerShell scripts still have `#!ps` on line 1
   - All modified bash scripts still have `#!/bin/bash` on line 1
2. **Commit** — stage changed files individually (not `git add .`), write a clear commit message
3. **Push** — `git push origin master`

If the push fails due to remote changes, pull first, resolve, then push.

---

## What This Repo Is

Standalone IT administration scripts used by Umbrella Systems to manage two school client environments. No build system, no test suite, no package manager. Scripts are run individually on target machines.

## School Environments

| School | OS | Deployment Method | Script Type |
|--------|----|-------------------|-------------|
| **GIS** (Twin Cities German Immersion School) | 100% macOS | MDM | Bash (`.sh`) |
| **SJA** (Sejong Academy) | 100% Windows | ConnectWise ScreenConnect | PowerShell (`.ps1`) |

SJA laptops are **not domain-joined** — no Active Directory, no Group Policy. Everything is local.

## Repository Structure

| Directory | Purpose | Status |
|-----------|---------|--------|
| `Mac/` | macOS scripts for GIS | Active |
| `Windows/` | PowerShell/batch scripts for SJA | Active |
| `GAM/` | Google Workspace admin (GAMADV-XTD3) | Active |
| `Admin Utility/` | Python utilities | Active |
| `DumpFromSyncro/` | Legacy Syncro RMM exports | Reference only — do not modify |
| `Archive/` | Old/unused scripts | Do not modify |

Root-level files: `backup-docker-s3.sh` and `restore-docker-s3.sh` are Docker backup/restore scripts for server use.

---

## Script Standards

### Naming

- **All filenames: lowercase, hyphen-separated, descriptive.** Example: `enforce-password-policy.ps1`
- **Mac scripts:** `.sh` extension
- **Windows scripts:** `.ps1` extension (prefer PowerShell over `.bat` for new scripts)
- **No spaces in filenames.** Ever.

### Required Headers

Every script must start with the correct shebang and a one-line description comment.

**PowerShell (Windows/SJA):**
```powershell
#!ps

# This script [does what].
```

If the script needs more than 10 seconds in ScreenConnect, add timeout on line 1:
```powershell
#!ps #timeout=60000 #maxlength=100000

# This script [does what].
```

Note: `#timeout` is in **milliseconds**. Default is 10000 (10 seconds).

**Bash (Mac/GIS):**
```bash
#!/bin/bash

# This script [does what].
```

### Configuration Variables

Any value that changes per-machine or per-run goes at the top of the script with a `!!!SET` marker:

```powershell
# !!!SET ASSET TAG ID!!!
$assetTag = "SJAXXXX"
```

```bash
# !!!SET ASSET TAG!!!
assetTag=""
```

Rules:
- One `#` for the marker comment (not `##`)
- Placeholder values should be obviously fake: empty strings `""`, `CHANGEME`, `SJAXXXX`, `newuser`
- Never hardcode real passwords, API keys, or credentials

### Error Handling

- Use `try/catch` with `-ErrorAction Stop` for operations that can fail
- Use `Write-Host` for status output (visible in ScreenConnect console)
- End every script with a summary line: `Write-Host "Script execution completed."` or equivalent

### What NOT to Put in Scripts

- API keys, tokens, or real passwords — use environment variables or placeholder values
- School-specific data that shouldn't be in a public/shared repo
- Complex multi-purpose logic — keep scripts single-purpose

---

## GAM Scripts

GAM scripts manage Google Workspace across both schools. Before running any GAM command:

```bash
# Check which tenant is active
gam print config | grep customer_id

# Switch tenant
gam select gis save   # for GIS
gam select sja save   # for SJA
```

Assumes GAMADV-XTD3 is installed and configured with customer instances `gis` and `sja`.

---

## ScreenConnect Deployment Notes (SJA)

- Scripts are pushed one-at-a-time via the ScreenConnect Commands tab
- Default execution timeout is **10 seconds** (10000ms) — set `#timeout=` for longer scripts
- `#maxlength=100000` prevents output truncation
- ScreenConnect's offline command queue is **unreliable** — queued commands for offline machines may never execute
- Scripts run as SYSTEM (elevated)

---

## When Creating a New Script

1. Determine the target: Mac (`Mac/`) or Windows (`Windows/`)
2. Use the correct naming convention: `lowercase-hyphen-description.ps1` or `.sh`
3. Add the required header (shebang + description)
4. Put all configurable values at the top with `!!!SET` markers
5. Add error handling for operations that can fail
6. End with a summary/completion message
7. Test on a single machine before broad deployment
