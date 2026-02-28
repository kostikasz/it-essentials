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

* ✅ Admin privilege detection
* ✅ Menu-driven interactive interface
* ✅ Automated app installs via winget
* ✅ Windows 11 classic context menu fix
* ✅ Safe change confirmation prompts
* ✅ Revert support for registry changes
* ✅ Modular function-based design

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

Installed using winget for reliability and repeatability.

---

### 🔹 Fixes

**Windows 11 classic right-click menu**

* Detects if fix is already applied
* Applies registry modification
* Allows safe revert
* Restarts Explorer automatically

---

## 🏗️ Project Structure

```text
quick-kit.ps1
├── Admin privilege check
├── Menu system
├── App installation module
├── Fix management module
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

> ⚠️ Must be run as Administrator.

---

## 🔒 Safety

* Confirmation prompts before system changes
* Detects existing registry state
* Reversible fixes
* No external downloads outside winget

---

## 🗺️ Roadmap

Planned improvements for upcoming versions:

* [ ] Silent install support
* [ ] Logging to file
* [ ] Bulk app installation
* [ ] System information report
* [ ] Additional common fixes
* [ ] Config-driven installs (JSON)
* [ ] Remote execution support

---

## 📈 Why I Built This

As an aspiring IT professional, I wanted to:

* practice real-world PowerShell automation
* reduce repetitive manual setup work
* build a practical portfolio project
* learn safer Windows system modifications

This project is actively being improved as my skills grow.

---

## 🤝 Contributing

Suggestions, issues, and improvements are welcome.

If you find a bug or have an idea, feel free to open an issue or submit a pull request.

---

## 📄 License

MIT License — free to use and modify.

---

⭐ If you find this useful, consider starring the repository.
