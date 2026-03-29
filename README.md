# Claude Desktop Auto-Continue

**The first known solution for automating the Claude Desktop Windows app's "Continue" button.**

## The Problem

Claude Desktop has a per-turn tool-use limit (~20 calls). When hit, a "Continue" button appears and Claude is frozen until the user manually clicks it. This interrupts long-running agentic workflows.

## The Solution

`Tara.Continue.py` - a Python script that types "continue" into the Claude Desktop text input field and presses Enter, which is equivalent to clicking the Continue button.

## How It Works

1. **Finds the window** - Uses `pygetwindow` to find any window titled "Claude" (title-based, not process ID)
2. **Activates it** - Restores from minimized if needed, brings to foreground
3. **Clicks the text field** - Calculates position relative to window bounds (center X, 55px from bottom)
4. **Clears existing text** - Ctrl+A, Delete
5. **Types "continue"** - Character-by-character via `pyautogui.typewrite()` (real OS-level keystrokes)
6. **Presses Enter** - Submits the message

## Why This Approach

This script was developed through R&D testing **24 different approaches**. Methods that failed:

- **UI Automation (MSAA/COM)** - Electron reports all element coordinates as (0,0)
- **AHK ControlFocus/ControlSend** - Electron renders in a single control, no sub-elements
- **PowerShell SendKeys/SendInput/keybd_event** - Keystrokes don't reach Electron input field from background scripts
- **ValuePattern.SetValue()** - Text appears visually but app doesn't recognize it internally (React controlled inputs bypass)

**Why pyautogui works:** `typewrite()` sends real OS-level keyboard events. The Electron app processes these as genuine user input, triggering React's onChange handlers. This means the app knows text is present when Enter is pressed.

## Requirements

```
pip install pyautogui pygetwindow
```

- Python 3.x
- Windows 10/11
- Claude Desktop running

## Usage

### Double-click (recommended)

Double-click `Claude-Continue.bat` whenever Claude is stalled at the Continue button.

### Command line

```
python Tara.Continue.py
```

### Scheduled/timed

Wrap in a loop or Windows Task Scheduler for automatic firing at intervals.

## Logging

All actions are timestamped in `auto-continue-log.txt` in the script directory.

## Author

Developed by **Tara** (Claude AI Assistant) for **Brian Todd Moore**

First working solution: March 29, 2026
