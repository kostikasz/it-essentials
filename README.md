# kostikasz IT Support Quick Kit
**A menu-driven PowerShell utility for rapid Windows setup — built as a hands-on learning project.**

---

## The Story

I started setting up Windows Server VMs and quickly hit a familiar wall: every fresh install means hunting down browsers, fixing that awful Windows 11 right-click context menu, and going through the same repetitive steps over and over. Rather than just living with it, I decided to learn PowerShell by solving the problem.

The goal was never just a tool — it was a project I could grow with. I used it to practice real workflows: PowerShell scripting, Git, a Jira ticketing board for tracking features, and AI-assisted development with Claude Code. Along the way I built custom Claude Code skills (`commit-creator`, `pr-creator`) to make the development loop faster and more consistent. The script itself became the classroom.

---

## Features

- **App installation** via winget with friendly error messages for 8 known failure codes
- **Registry fixes** — applies or reverts changes, detects current state, restarts Explorer automatically
- **Bulk operations** — install all browsers or apply all fixes in one go with a single confirmation
- **System information** — query OS, CPU, RAM, and disk details; export to CSV
- **Safe by default** — confirmation prompts before every system change, full revert support
- **Session logging** — timestamped log file created automatically under `logs/`; verbose mode available

---

## Demo

```text
kostikasz IT support quick kit

Choose an option:
[1] Install essential apps
[2] Install fixes
[3] Bulk install apps/fixes
[4] System information
[Q] Quit
```

---

## What It Can Do

### Install Apps
Installs via winget. Failed installs surface a readable error instead of silently passing.

| App | ID |
|---|---|
| Google Chrome | `Google.Chrome` |
| Mozilla Firefox | `Mozilla.Firefox` |
| Brave | `Brave.Brave` |

### Fixes
| Fix | What it does |
|---|---|
| Classic right-click menu | Restores the full Windows 10-style context menu on Windows 11 |
| Show file extensions | Sets Explorer to always show file extensions |

Both fixes detect their current state and offer a revert if already applied.

### Bulk Operations
- **Install all browsers** — Chrome, Firefox, Brave in sequence
- **Apply all fixes** — all registry fixes in one pass, Explorer restarted once at the end

### System Info
View OS version, CPU, RAM, and disk details individually, or export everything to CSV files under `system_info/`.

---

## Usage

### Requirements
- Windows 10/11
- PowerShell 5.1+
- winget
- Administrator privileges

### Run

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\quick-kit.ps1
```

With verbose logging:
```powershell
.\quick-kit.ps1 -EnableVerbose
```

Silent mode (skips confirmation prompts — useful for automated runs):
```powershell
.\quick-kit.ps1 -EnableSilent
```

> Must be run as Administrator. The script exits immediately if it detects no elevation.

---

## Logging

All activity is logged to a timestamped file under `logs/` created on first run. The file name includes the script name and the session start time.

Logged events: script start, admin check result, installs (success/failure with exit code), fixes applied/reverted, user cancellations, quit.

Verbose entries (winget command strings, detailed registry state) are written only when `-EnableVerbose` is set.

---

## Project Structure

```
quick-kit.ps1          single-file script, ~700 lines
logs/                  session log files (auto-created)
system_info/           CSV exports from the system info module (auto-created)
```

The script is intentionally a single file with no external dependencies or config files.

---

## Tooling Used

| Tool | Purpose |
|---|---|
| PowerShell 5.1 | Script language |
| winget | App installation backend |
| Git + GitHub | Version control |
| Jira | Feature and task tracking (ITE-XX tickets) |
| Claude Code | AI-assisted development, code review, commit messages |
| Custom Claude skills | `commit-creator` for consistent commit messages, `pr-creator` for PR descriptions |

---

## Why

I'm a student teaching myself IT support and systems administration. This project is my way of learning by doing — writing real code, using real workflows, and solving problems I actually run into. Every feature started as something I needed while setting up a VM.

---

## Contributing

Suggestions, issues, and improvements are welcome. Open an issue or submit a pull request.

---

## License

MIT — free to use and modify.

---

If you find this useful, consider starring the repository.
