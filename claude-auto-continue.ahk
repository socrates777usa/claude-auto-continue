; ============================================
; Claude Desktop Auto-Continue v11
; Pastes "continue" + Enter every 30 MINUTES
; Forces window focus via Win32 API
; F9 = manual instant trigger
; F10 = toggle on/off
; ============================================
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

logPath := "C:\Users\socra\OneDrive\AAA-AI\_Shared\Scripts\auto-continue-log.txt"
global clickCount := 0
global isActive := true

INTERVAL := 1800000  ; 30 minutes in milliseconds

A_IconTip := "Claude Auto-Continue v11 (30min)"

tray := A_TrayMenu
tray.Delete()
tray.Add("Claude Auto-Continue v11 (30min)", (*) => "")
tray.Disable("Claude Auto-Continue v11 (30min)")
tray.Add()
tray.Add("Send Now (F9)", (*) => SendContinue())
tray.Add("Pause/Resume (F10)", ToggleScript)
tray.Add("View Log", (*) => Run("notepad.exe " logPath))
tray.Add("Exit", (*) => ExitApp())

LogAction(msg) {
    global logPath
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    FileAppend(timestamp " - " msg "`n", logPath)
}

LogAction("=== Auto-Continue v11 (30min) STARTED ===")

F9::SendContinue()
F10::ToggleScript()

SetTimer(SendContinue, INTERVAL)

SendContinue() {
    global clickCount

    if !WinExist("Claude") {
        LogAction("SKIP: Claude window not found")
        return
    }

    hwnd := WinExist("Claude")
    prevClip := A_Clipboard
    prevHwnd := WinExist("A")
    LogAction("Found Claude (hwnd: " hwnd ") - forcing focus + sending continue")

    ; --- FORCE WINDOW FOCUS via Win32 API ---
    ; WinActivate alone fails when another app has focus.
    ; The Alt-key trick bypasses Windows' focus-steal prevention.
    if WinGetMinMax(hwnd) = -1  ; if minimized
        DllCall("ShowWindow", "Ptr", hwnd, "Int", 9)  ; SW_RESTORE

    ; Press and release Alt to allow SetForegroundWindow to succeed
    DllCall("keybd_event", "UChar", 0x12, "UChar", 0, "UInt", 0, "Ptr", 0)          ; Alt down
    DllCall("keybd_event", "UChar", 0x12, "UChar", 0, "UInt", 0x0002, "Ptr", 0)     ; Alt up
    DllCall("SetForegroundWindow", "Ptr", hwnd)
    Sleep(600)

    ; Verify focus was achieved
    activeHwnd := WinGetID("A")
    if (activeHwnd != hwnd) {
        ; Fallback: try WinActivate
        WinActivate(hwnd)
        Sleep(400)
        activeHwnd := WinGetID("A")
    }

    if (activeHwnd != hwnd) {
        LogAction("WARNING: Could not force focus to Claude window")
    } else {
        LogAction("Focus confirmed on Claude window")
    }

    ; --- CLICK THE TEXT INPUT FIELD ---
    ; Match the working Tara.Continue.py: center-X, bottom - 55px
    WinGetPos(&winX, &winY, &winW, &winH, hwnd)
    fieldX := winX + (winW // 2)
    fieldY := winY + winH - 55
    LogAction("Clicking text field at (" fieldX ", " fieldY ")")

    CoordMode("Mouse", "Screen")
    MouseMove(fieldX, fieldY, 0)
    Sleep(100)
    Click(fieldX, fieldY)
    Sleep(500)

    ; --- SELECT ALL + DELETE existing text ---
    SendInput("^a")
    Sleep(100)
    SendInput("{Delete}")
    Sleep(200)

    ; --- TYPE "continue" + ENTER ---
    A_Clipboard := "continue"
    Sleep(100)
    SendInput("^v")
    Sleep(300)
    SendInput("{Enter}")
    Sleep(200)

    A_Clipboard := prevClip

    ; --- RESTORE PREVIOUS WINDOW ---
    Sleep(300)
    if prevHwnd && (prevHwnd != hwnd) {
        try {
            DllCall("SetForegroundWindow", "Ptr", prevHwnd)
        }
    }

    clickCount++
    LogAction("SUCCESS - pasted 'continue' + Enter (#" clickCount ")")
}

ToggleScript(*) {
    global isActive, INTERVAL
    isActive := !isActive
    if isActive {
        SetTimer(SendContinue, INTERVAL)
        A_IconTip := "Claude Auto-Continue v11 (30min)"
        LogAction("RESUMED by user (F10)")
        ToolTip("Auto-Continue: RUNNING (30min)", 50, 50)
    } else {
        SetTimer(SendContinue, 0)
        A_IconTip := "Claude Auto-Continue v11 (PAUSED)"
        LogAction("PAUSED by user (F10)")
        ToolTip("Auto-Continue: PAUSED", 50, 50)
    }
    SetTimer(() => ToolTip(), -2000)
}
