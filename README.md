# 🛠️ kostikasz IT Support Quick Kit
**Lightweight PowerShell toolkit for rapid Windows setup and common IT support fixes.**
Designed for helpdesk technicians, homelab enthusiasts, and junior sysadmins who want to automate repetitive post-install tasks and troubleshooting steps.

---

## 🚀 Overview
IT Support Quick Kit is a menu-driven PowerShell utility that helps automate:
* essential application installation
* common Windows fixes
* safe registry changes
* basic workstation preparation

The goal is simple: **save technician time and reduce human error** during routine support work.

---

## ✨ Features
* Admin privilege detection
* Menu-driven interactive interface
* Automated app installs via winget with exit code detection
* Retry prompt on failed installations
* Windows 11 classic context menu fix
* Safe change confirmation prompts
* Revert support for registry changes
* Modular function-based design
* Timestamped logging to file with verbose mode toggle (`-EnableVerbose`)

---

## 🖥️ Demo
```text
kostikasz IT support quick kit
Choose an option:
[1] Install essential apps
[2] Install fixes
[Q] Quit
```

---

## 📦 Current Capabilities

### 🔹 Essential Apps
**Browsers**
* Google Chrome
* Mozilla Firefox
* Brave

Installed using winget. Failed installs surface a user-friendly error and prompt a retry instead of silently failing.

---

### 🔹 Fixes
**Windows 11 classic right-click menu**
* Detects if fix is already applied
* Applies registry modification
* Allows safe revert
* Restarts Explorer automatically

---

## 📋 Logging
Quick Kit logs all activity to a timestamped file under a `logs/` folder created automatically on first run.

Logged events include successful installs, failed installs, applied fixes, and reverts.

To enable verbose output during a session:
```powershell
.\quick-kit.ps1 -EnableVerbose
```

---

## 🏗️ Project Structure
```text
quick-kit.ps1
├── Admin privilege check
├── Parameter handling
├── Menu system
├── App installation module
├── Fix management module
├── Logging module
└── Main execution loop
```

---

## ▶️ Usage

### Requirements
* Windows 10/11
* PowerShell 5.1+
* winget installed
* Administrator privileges

---

### Run the script
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\quick-kit.ps1
```

With verbose logging:
```powershell
.\quick-kit.ps1 -EnableVerbose
```

> ⚠️ Must be run as Administrator.

---

## 🔒 Safety
* Confirmation prompts before system changes
* Detects existing registry state
* Reversible fixes
* No external downloads outside winget

---

## 🗺️ Roadmap
* [ ] Silent install support
* [ ] Bulk app installation
* [ ] System information report
* [ ] Additional common fixes
* [ ] Config-driven installs (JSON)
* [ ] Remote execution support

---

## 📈 Why I Built This
I'm a middle school student teaching myself IT support with the goal of securing a position in the field. Rather than sticking to tutorials, I wanted a real project that reflects the kind of work actually done in helpdesk and sysadmin roles.

I built this tool to practice skills that matter in practice — PowerShell scripting, version control with Git, working with a ticketing workflow in Jira, and writing maintainable code. Automating repetitive Windows setup tasks felt like a natural starting point since it's a real problem with a measurable solution.

The project is actively being developed as my knowledge grows and as I find new problems worth solving.

---

## 🤝 Contributing
Suggestions, issues, and improvements are welcome.
If you find a bug or have an idea, feel free to open an issue or submit a pull request.

---

## 📄 License
MIT License — free to use and modify.

---
⭐ If you find this useful, consider starring the repository.
