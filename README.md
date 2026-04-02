# Claude Desktop Auto-Continue

**The first known solution for automating the Claude Desktop Windows app's "Continue" button.**

When Claude Desktop hits its per-turn tool-use limit (~20 calls), a "Continue" button appears and Claude freezes until the user manually clicks it. This interrupts long-running agentic workflows that should run unattended.

This project solves that problem.

---

## v11 — AutoHotkey (Recommended)

`claude-auto-continue.ahk` is the current production solution. It runs silently in the system tray, fires every 30 minutes, and auto-sends "continue" to Claude Desktop.

### Features

- **System tray icon** with right-click menu (Send Now, Pause/Resume, View Log, Exit)
- **Forced window focus** via Win32 `SetForegroundWindow` with the Alt-key trick (bypasses Windows focus-stealing prevention)
- **Click-target text field** using window-relative coordinates (center-X, bottom minus 55px)
- **Ctrl+A → Delete → Paste → Enter** sequence for reliable text input
- **Auto-restores previous window** after sending so your workflow isn't interrupted
- **Full timestamped logging** to `auto-continue-log.txt`
- **Hotkeys:** F9 = instant trigger, F10 = pause/resume
- **Configurable timer** (default: 30 minutes / 1800000ms)

### Requirements

- [AutoHotkey v2](https://www.autohotkey.com/) (free)
- Windows 10/11
- Claude Desktop running

### Usage

1. Install AutoHotkey v2
2. Double-click `claude-auto-continue.ahk`
3. Look for the tray icon — it's running
4. Press **F9** anytime to manually trigger
5. Press **F10** to pause/resume the timer

### Customizing the Timer

Edit the `INTERVAL` variable at the top of the script:

```ahk
INTERVAL := 1800000  ; 30 minutes (in milliseconds)
```

Common values: 300000 (5 min), 600000 (10 min), 1800000 (30 min), 3600000 (1 hour)

### Customizing the Log Path

Edit the `logPath` variable to point to your preferred location.

---

## Legacy: Python + Scheduled Task

The original approach using `pyautogui` and Windows Task Scheduler. Still works but the AHK version is superior for daily use.

### Files

- `Claude.Continue.py` — Python script that types "continue" + Enter
- `Tara.Continue.py` — Streamlined variant used by scheduled task
- `Claude-Continue.bat` — One-click launcher

### Why AHK Won

The Python approach works but has limitations:
- No persistent tray icon or hotkey support
- Requires Python + pip packages installed
- Task Scheduler adds complexity
- No pause/resume capability

AutoHotkey gives us a single self-contained file with native Windows tray integration.

---

## Why This Approach (R&D History)

This script was developed through R&D testing **24 different approaches**. Methods that failed:

- **UI Automation (MSAA/COM)** — Electron reports all element coordinates as (0,0)
- **AHK ControlFocus/ControlSend** — Electron renders in a single control, no sub-elements
- **PowerShell SendKeys/SendInput/keybd_event** — Keystrokes don't reach Electron input from background
- **ValuePattern.SetValue()** — Text appears but React controlled inputs don't register it
- **Simple WinActivate** — Windows blocks focus-stealing from background processes

**What works:** Real OS-level keystrokes via clipboard paste (`Ctrl+V`) after forcing window focus with the Win32 Alt-key trick (`keybd_event` Alt down/up → `SetForegroundWindow`). The Electron app processes these as genuine user input, triggering React's onChange handlers.

---

## Author

Developed by **Brian Todd Moore** and **Tara** (Claude AI Assistant)

- First working solution: March 29, 2026
- AHK v11 (current): April 2, 2026
