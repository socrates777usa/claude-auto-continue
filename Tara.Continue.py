"""
Tara.Continue.py - Claude Desktop Auto-Continue Script
======================================================

PURPOSE:
    Automatically types "continue" into the Claude Desktop application's
    text input field and presses Enter to submit it. This is used to resume
    Claude when it hits the per-turn tool-use limit and displays a "Continue"
    button that requires manual user interaction.

HOW IT WORKS:
    This script does NOT use process IDs, browser APIs, Chrome DevTools Protocol,
    UI Automation accessibility APIs, or any browser-based approach. It treats
    Claude Desktop purely as a desktop application and simulates exactly what
    a human would do: find the window, click the text field, type, press Enter.

    Step-by-step:

    1. FIND THE WINDOW
       Uses pygetwindow to search for any window with "Claude" in the title.
       This is title-based, not process-ID-based, so it works after reboots,
       updates, or any situation where the process ID changes.

    2. RESTORE and ACTIVATE
       If the window is minimized, it restores it. Then it activates (brings
       to foreground) the window so it can receive keyboard input.

    3. CLICK THE TEXT INPUT FIELD
       Calculates the text field position relative to the window bounds:
       - Horizontal: center of the window (w.left + w.width // 2)
       - Vertical: 55 pixels up from the bottom edge (w.top + w.height - 55)
       These are NOT hardcoded screen coordinates - they are recalculated
       from the window's actual position every time the script runs. This
       means it works regardless of which monitor the window is on, what
       size it is, or where it's positioned.

    4. CLEAR EXISTING TEXT
       Sends Ctrl+A (select all) then Delete to clear any text that might
       already be in the field.

    5. TYPE "continue"
       Uses pyautogui.typewrite() which sends individual OS-level keystroke
       events for each character. This is critical - these are REAL keyboard
       events that the application processes as genuine user input. This is
       why it works where other methods (like UI Automation's ValuePattern.SetValue)
       failed to trigger the app's internal state management.

    6. PRESS ENTER
       Sends Enter via pyautogui.press('enter') to submit the typed text.
       The app recognizes the text because it was entered through real
       keystroke events (step 5), so Enter successfully submits.

REQUIREMENTS:
    - Python 3.x
    - pyautogui (pip install pyautogui)
    - pygetwindow (pip install pygetwindow)
    - Claude Desktop application running on Windows

USAGE:
    python Tara.Continue.py

    Or create a .bat file for double-click launching:
        @echo off
        python "C:\\path\\to\\Tara.Continue.py"

BACKGROUND:
    This script was developed through extensive R and D testing 24 approaches
    to programmatically input text into the Claude Desktop Electron application
    on Windows. Methods that FAILED included: UI Automation MSAA/COM (coordinates
    reported as 0,0), AHK ControlFocus/ControlSend (Electron renders in single
    control), PowerShell SendKeys/SendInput/keybd_event (didn't reach Electron
    input), and ValuePattern.SetValue (text appeared but app didn't recognize it
    for submission). The pyautogui approach succeeded because it sends real
    OS-level keyboard events that the Electron/React app processes as genuine
    user input.

AUTHOR:
    Tara (Claude AI Assistant) for Brian Todd Moore
    First working solution: 2026-03-29
"""

import time
import pyautogui
import pygetwindow as gw

log_path = r"C:\Users\socra\OneDrive\AAA-AI\_Shared\Scripts\auto-continue-log.txt"

def log(msg):
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    with open(log_path, "a", encoding="utf-8") as f:
        f.write(f"{ts} - {msg}\n")

log("=== Tara.Continue TRIGGERED ===")

try:
    claude_windows = gw.getWindowsWithTitle("Claude")
    if claude_windows:
        w = claude_windows[0]
        if w.isMinimized:
            w.restore()
        w.activate()
        log(f"Activated Claude window")
        time.sleep(1)

        field_x = w.left + (w.width // 2)
        field_y = w.top + w.height - 55
        log(f"Clicking text field at ({field_x}, {field_y})")
        pyautogui.click(field_x, field_y)
        time.sleep(0.5)

        pyautogui.hotkey('ctrl', 'a')
        time.sleep(0.1)
        pyautogui.press('delete')
        time.sleep(0.2)

        pyautogui.typewrite('continue', interval=0.05)
        time.sleep(0.5)
        log("Typed 'continue'")

        pyautogui.press('enter')
        log("Pressed Enter")

        log("=== Tara.Continue COMPLETE ===")
    else:
        log("FAIL: Could not find Claude window")

except Exception as e:
    log(f"ERROR: {e}")
