#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent(True) 
A_IconTip := "LCARS Terminal Interface Engine"

; ==============================================================================
; LCARS SYSTEM COLOR PALETTE (v2.0 Expanded)
; ==============================================================================
global COLOR_BACKGROUND        := "000000"  ; Pure Black (The foundational background)
global COLOR_NEUTRAL_GRAY      := "333333"  ; Dark Slate (System constant for empty slots)
global COLOR_OFF_WHITE         := "FEEBDE"  ; Off-White / Cream (Text inside structural blocks)
global COLOR_MAUVE             := "C86A6A"  ; LCARS Mauve / Dusty Rose (Used for tracking tracks)
global COLOR_ORANGE            := "FF8800"  ; LCARS Orange (System frames and main headers)
global COLOR_GOLD              := "FFAA00"  ; LCARS Gold (The most recognizable interface block tone)
global COLOR_PEACH             := "FF9900"  ; LCARS Peach / Muted Apricot (Secondary functions)
global COLOR_PURPLE            := "996699"  ; LCARS Medium/Dark Purple (Seen in data tracks)
global COLOR_CORNFLOWER        := "6699FF"  ; LCARS Blue / Cornflower (Interactive shortcuts)
global COLOR_LILAC             := "CC99CC"  ; Light Purple/Lilac (Standard navigation & secondary text)
global COLOR_LIGHT_BLUE        := "BBBBFF"  ; Light Blue (Data blocks and telemetry readouts)
global COLOR_STEEL_BLUE        := "555577"  ; Steel Blue (Neutral apps launched outside menu)
global COLOR_MUTED_GREEN       := "99AA66"  ; Muted Green (Auxiliary systems and scanners)
global COLOR_RED               := "EE0000"  ; Standard Red (Bright primary red for structural alerts/kill switches)
global COLOR_DARK_RED          := "882211"  ; Dark Red (Used for system anomalies)
global COLOR_BURGUNDY          := "CC6666"  ; Burgundy (Used for tactical submenus)
global COLOR_BLUE              := "0A4BEE"  ; Standard Blue (Deep Blue Alert for tactical/environmental shifts)
global COLOR_BRIGHT_RED        := "FF0000"  ; High-intensity alert status; ideal for critical warnings.
global COLOR_BRIGHT_YELLOW     := "FFCC00"  ; Classic "Operations" yellow; high visibility for active buttons.
global COLOR_BRIGHT_BLUE       := "0066FF"  ; A vivid, modern blue; useful for active telemetry or focused selection states.
global COLOR_PALE_CANARY       := "FFFF99"  ; A soft, light yellow often used for background highlighting or secondary text.
global COLOR_ATOMIC_TANGERINE  := "FF9933"  ; A vibrant, slightly softer orange than your main orange, perfect for secondary headers.
global COLOR_EGGPLANT          := "664466"  ; A rich, deep purple used in many technical LCARS layouts for panel structure or inactive status fields.
global COLOR_ANAKIWA           := "99CCFF"  ; A light, sky-blue often used to indicate "system ready" or clear data fields.
global COLOR_MARINER_BLUE      := "3366CC"  ; A mid-tone blue that bridges the gap between your CORNFLOWER and STEEL_BLUE.
global COLOR_SCIENCE_TEAL      := "008080"  ; A classic, distinctive teal frequently seen in the Science/Medical station layouts.
global COLOR_DUSKY_PINK        := "E5A9A9"  ; Shifted slightly toward a true dusty rose to differentiate from Lilac ("CC99CC")
global CHROMA_KEY              := "111111"  ; Transparent key
global COLOR_DOCK_BG := "020202"

; Shared Volume Control Palette Shortcuts
global COLOR_AMBER  := COLOR_BRIGHT_YELLOW
global COLOR_LAV    := COLOR_LILAC

; ==============================================================================
; DYNAMIC WORKSPACE DOCK BOUNDS & INTERFACE HANDLES
; ==============================================================================
global ScreenWidth     := 0
global ScreenHeight    := 0
global ScaleMultiplier := 1.0
global ActiveWinX      := 0
global ActiveWinY      := 0
global ActiveWinW      := 0
global ActiveWinH      := 0
global TopPad          := 0
global MainGuiHwnd     := 0
global AuxMenuGui      := 0
global LastActiveAppHWND := 0

; ==============================================================================
; TOPMENU SHORTCUT ENGINE GLOBALS
; ==============================================================================
global ShortcutMenuGui  := ""
global IniFilePath      := A_ScriptDir . "\LcarsConfig.ini"
global GlobalBoxWidth   := 0
global GlobalBoxHeight  := 0
global GlobalPadding    := 0
global MenuFontSize     := 16
global TopMenuCols      := 0
global TopMenuRows      := 3
global BoxControls      := Map()
global SourceBoxCtrl    := ""        
global DragStartX       := 0
global DragStartY       := 0 
global IsDraggingState  := false
global DeleteZoneGui    := ""
global DeleteZoneCtrl   := ""

; ==============================================================================
; SYSTEM STATS ENGINE GLOBALS
; ==============================================================================
global CurrentSelection := "CPU"
global SelectedDrive    := ""
global StatsGui         := ""
global StatsReadout     := ""
global ActiveColorBar   := ""

; ==============================================================================
; CLOCK MODULE GLOBALS
; ==============================================================================
global ClockGui         := ""
global DateDisplay      := ""
global TimeDisplay      := ""
global DateFormatState  := 1
global TimeFormatState  := 1

; ==============================================================================
; VOLUME CONTROL MODULE GLOBALS
; ==============================================================================
global volGui           := ""

; ==============================================================================
; TASKBAR DOCK ENGINE GLOBALS
; ==============================================================================
global LCARS_DockGui    := ""
global BlockWidth       := 126  
global MaxSlots         := 20  
global SlotHWNDs        := []
global DockControls     := []
global TopBlackBar      := ""
global BottomBlackBar   := ""

; ==============================================================================
; GLOBAL ERROR TRAP
; ==============================================================================
OnError(LcarsErrorHandler)
LcarsErrorHandler(err, mode) {
    OutputDebug("LCARS ERROR: " . err.Message . " (" . err.What . " @ line " . err.Line . ")")
    return true 
}

; ==============================================================================
; SYSTEM INITIALIZATION ROUTINE (AUTO-EXECUTE PHASE)
; ==============================================================================
InitializeLcars()
InitializeAuxMenu()
InitializeShortcutMenu()
InitializeStatsMenu()
InitializeClockWidget()
InitializeVolumeWidget()
InitializeTaskbarDock()

; Global focus message monitors
OnMessage(0x0201, WM_LBUTTONDOWN)
OnMessage(0x0202, WM_LBUTTONUP)

; Layer Enforcement Timer for all interactive panels
SetTimer(EnforceLayers, 500)

; Structural boundary mark ending the setup sequence
Return

; ==============================================================================
; MAIN INTERFACE ENGINE
; ==============================================================================
InitializeLcars() {
    ; Environment Detection - Absolute screen size for auto-hide taskbars
    MonitorGet(1, &Left, &Top, &Right, &Bottom)
    global ScreenWidth     := Right - Left
    global ScreenHeight    := Bottom - Top
    global ScaleMultiplier := ScreenHeight / 1080

    StaticX := 147
    StaticY := 130

    ; Identify desktop window handle
    DesktopHwnd := WinExist("ahk_class WorkerW") ? WinExist("ahk_class WorkerW") : WinExist("ahk_class Progman")

    ; --- LAYER 1: BACKGROUND CANVAS (CLICK-THROUGH) ---
    TopMenuGui := Gui("-Caption +ToolWindow +E0x20 +E0x08000000")
    TopMenuGui.BackColor := CHROMA_KEY
    global MainGuiHwnd := TopMenuGui.Hwnd

    ; --- Layout Elements ---
    TopMenuX := 0, TopMenuY := 0
    StatsReservation := Round(510 * ScaleMultiplier)
    TopMenuW := (StaticX + (ScreenWidth - StaticX) - StatsReservation) + 40, TopMenuH := 101
    TopMenuGui.AddText("x" . TopMenuX . " y" . TopMenuY . " w" . TopMenuW . " h" . TopMenuH . " Background" . COLOR_LILAC)

    TopMenuX1 := 0, TopMenuY1 := 75
    TopMenuW1 := Round(340 * ScaleMultiplier), TopMenuH1 := 48
    TopMenuGui.AddText("x" . TopMenuX1 . " y" . TopMenuY1 . " w" . TopMenuW1 . " h" . TopMenuH1 . " Background" . COLOR_LIGHT_BLUE)

    TopMenuXbar := 0, TopMenuYbar := 73
    TopMenuWbar := 140, TopMenuHbar := 6
    TopMenuGui.AddText("x" . TopMenuXbar . " y" . TopMenuYbar . " w" . TopMenuWbar . " h" . TopMenuHbar . " Background" . COLOR_BACKGROUND)

    TopMenuX4 := Round(346 * ScaleMultiplier), TopMenuY4 := 107
    TopMenuW4 := Round(65 * ScaleMultiplier), TopMenuH4 := 16
    TopMenuGui.AddText("x" . TopMenuX4 . " y" . TopMenuY4 . " w" . TopMenuW4 . " h" . TopMenuH4 . " Background" . COLOR_ORANGE)

    TopMenuX5 := Round(417 * ScaleMultiplier), TopMenuY5 := 107
    TopMenuW5 := Round(385 * ScaleMultiplier), TopMenuH5 := 16
    TopMenuGui.AddText("x" . TopMenuX5 . " y" . TopMenuY5 . " w" . TopMenuW5 . " h" . TopMenuH5 . " Background" . COLOR_PURPLE)

    TopMenuX6 := Round(808 * ScaleMultiplier), TopMenuY6 := 107
    TopMenuW6 := Round(200 * ScaleMultiplier), TopMenuH6 := 16
    TopMenuGui.AddText("x" . TopMenuX6 . " y" . TopMenuY6 . " w" . TopMenuW6 . " h" . TopMenuH6 . " Background" . COLOR_LILAC)

    TopMenuX7 := Round(1014 * ScaleMultiplier), TopMenuY7 := 107
    TopMenuW7 := Round(65 * ScaleMultiplier), TopMenuH7 := 16
    TopMenuGui.AddText("x" . TopMenuX7 . " y" . TopMenuY7 . " w" . TopMenuW7 . " h" . TopMenuH7 . " Background" . COLOR_ORANGE)

    TopMenuX8 := Round(1085 * ScaleMultiplier), TopMenuY8 := 107
    TopMenuW8 := Round(700 * ScaleMultiplier), TopMenuH8 := 16
    TopMenuGui.AddText("x" . TopMenuX8 . " y" . TopMenuY8 . " w" . TopMenuW8 . " h" . TopMenuH8 . " Background" . COLOR_MAUVE)

    TopMenuX9 := Round(1791 * ScaleMultiplier), TopMenuY9 := 107
    TopMenuW9 := Round(129 * ScaleMultiplier), TopMenuH9 := 16
    TopMenuGui.AddText("x" . TopMenuX9 . " y" . TopMenuY9 . " w" . TopMenuW9 . " h" . TopMenuH9 . " Background" . COLOR_LILAC)

    TopMenuXb := 140, TopMenuYb := 0
    TopMenuWb := (TopMenuW - 40 + 6) - TopMenuXb, TopMenuHb := 107
    TopMenuGui.AddText("x" . TopMenuXb . " y" . TopMenuYb . " w" . TopMenuWb . " h" . TopMenuHb . " Background" . COLOR_BACKGROUND)

    SideBarX := 0, SideBarY := 123
    SideBarW := 126, SideBarH := 100
    TopMenuGui.AddText("x" . SideBarX . " y" . SideBarY . " w" . SideBarW . " h" . SideBarH . " Background" . COLOR_LIGHT_BLUE)

    SideBarX2 := 0, SideBarY2 := SideBarY + SideBarH
    SideBarW2 := 126
    SideBarH2 := ScreenHeight - SideBarY2
    TopMenuGui.AddText("x" . SideBarX2 . " y" . SideBarY2 . " w" . SideBarW2 . " h" . SideBarH2 . " Background" . COLOR_MAUVE)

    ; Segmented Data Blocks Row
    BotRowY := ScreenHeight - 32
    TopMenuGui.AddText("x126 y" . BotRowY . " w" . Round(700 * ScaleMultiplier) . " h32 Background" . COLOR_MAUVE)
    TopMenuGui.AddText("x" . Round(832 * ScaleMultiplier) . " y" . BotRowY . " w" . Round(65 * ScaleMultiplier) . " h32 Background" . COLOR_ORANGE)
    TopMenuGui.AddText("x" . Round(903 * ScaleMultiplier) . " y" . BotRowY . " w" . Round(200 * ScaleMultiplier) . " h32 Background" . COLOR_LILAC)
    TopMenuGui.AddText("x" . Round(1109 * ScaleMultiplier) . " y" . BotRowY . " w" . Round(385 * ScaleMultiplier) . " h32 Background" . COLOR_PURPLE)
    TopMenuGui.AddText("x" . Round(1500 * ScaleMultiplier) . " y" . BotRowY . " w" . Round(65 * ScaleMultiplier) . " h32 Background" . COLOR_ORANGE)
    
    BotRowX9 := Round(1571 * ScaleMultiplier)
    BotRowW9 := ScreenWidth - BotRowX9
    TopMenuGui.AddText("x" . BotRowX9 . " y" . BotRowY . " w" . BotRowW9 . " h32 Background" . COLOR_LILAC)

    ; --- CALCULATE WORKSPACE DOCK BOUNDS ---
    global ActiveWinX := StaticX
    global ActiveWinY := StaticY
    global ActiveWinW := ScreenWidth - StaticX + 10

    ; Dynamically check for the taskbar, or fallback to your 40px guess
    try {
        WinGetPos(,,, &TaskbarH, "ahk_class Shell_TrayWnd")
    } catch {
        TaskbarH := 40
    }
    
    ; Exact boundary assignment using the precise structural formula
    global ActiveWinH := ScreenHeight - ((TaskbarH > 1) ? TaskbarH : 0) - StaticY + 10
    global TopPad     := ActiveWinY

    ; --- LAYER 2: INTERACTIVE FOREGROUND LAYER ---
    InteractGui := Gui("-Caption +ToolWindow +E0x08000000 +Parent" . TopMenuGui.Hwnd)
    InteractGui.BackColor := CHROMA_KEY

    ; --- RENDER EXECUTION ---
    TopMenuGui.Show("x0 y0 w" . ScreenWidth . " h" . ScreenHeight . " NoActivate")
    WinSetTransColor(CHROMA_KEY, TopMenuGui.Hwnd)

    InteractGui.Show("x" . StaticX . " y" . StaticY . " w400 h100 NoActivate")
    WinSetTransColor(CHROMA_KEY, InteractGui.Hwnd)

    ; Primary layer placement below panels
    SendInterfaceToBottom()

    ; --- INITIALIZE VIEWPORT MANAGERS & SYSTEM HOOKS ---
    DllCall("RegisterShellHookWindow", "Ptr", A_ScriptHwnd)
    OnMessage(DllCall("RegisterWindowMessage", "Str", "SHELLHOOK"), ShellEvent)
    SetTimer(WatchdogCheck, 500)

    EnforceBoundaries()

    ; Clean up rendering artifacts
    DllCall("user32\RedrawWindow", "ptr", DesktopHwnd, "ptr", 0, "ptr", 0, "uint", 1)
}

; ==============================================================================
; DYNAMIC TASKBAR SIDEBAR DOCK ENGINE
; ==============================================================================
InitializeTaskbarDock() {
    global LCARS_DockGui, TopBlackBar, BottomBlackBar, DockControls
    
    VerticalOffset := 206
    
    LCARS_DockGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000")
    
    ; CHANGE THIS LINE: Use COLOR_DOCK_BG instead of COLOR_BACKGROUND
    LCARS_DockGui.BackColor := COLOR_DOCK_BG
    WinSetTransColor(COLOR_DOCK_BG, LCARS_DockGui)

    ; Keep CreateSolidBitmap using COLOR_BACKGROUND ("000000") so the bars stay solid black
    TopBlackBar := LCARS_DockGui.Add("Pic", "x0 y0 w" . BlockWidth . " h6 Hidden", "HBITMAP:" . CreateSolidBitmap(COLOR_BACKGROUND))
    BottomBlackBar := LCARS_DockGui.Add("Pic", "x0 y0 w" . BlockWidth . " h6 Hidden", "HBITMAP:" . CreateSolidBitmap(COLOR_BACKGROUND))
	
    Loop MaxSlots
    {
        Row := {}
        
        ; Main Pill Background
        Row.Block := LCARS_DockGui.Add("Pic", "x0 y0 w" . BlockWidth . " h33 Hidden", "HBITMAP:" . CreateSolidBitmap(COLOR_CORNFLOWER))
        
        ; App Name (Top Line)
        LCARS_DockGui.SetFont("s8 Bold q5", "Arial")
        Row.AppTxt := LCARS_DockGui.Add("Text", "x0 y0 w" . BlockWidth . " h14 c" . COLOR_BACKGROUND . " +BackgroundTrans +Hidden +0x4000")
        
        ; File Title (Bottom Line)
        LCARS_DockGui.SetFont("s7 Norm", "Arial")
        Row.Txt := LCARS_DockGui.Add("Text", "x0 y0 w" . BlockWidth . " h14 c" . COLOR_BACKGROUND . " +BackgroundTrans +Hidden +0x4000")
        
        ; Unicode Tactical Close Button
        LCARS_DockGui.SetFont("s38 q5", "Arial")
        Row.Btn := LCARS_DockGui.Add("Text", "x0 y0 w40 h48 c" . COLOR_RED . " +BackgroundTrans +Hidden", Chr(0x25D7))
        
        ; 1px Solid Interstitial Divider Line
        Row.Divider := LCARS_DockGui.Add("Pic", "x0 y0 w" . BlockWidth . " h1 Hidden", "HBITMAP:" . CreateSolidBitmap(COLOR_BACKGROUND))
        
        ; Bind native click events
        Row.Block.OnEvent("Click", DockControlClicked.Bind(A_Index, "Activate"))
        Row.AppTxt.OnEvent("Click", DockControlClicked.Bind(A_Index, "Activate"))
        Row.Txt.OnEvent("Click", DockControlClicked.Bind(A_Index, "Activate"))
        Row.Btn.OnEvent("Click", DockControlClicked.Bind(A_Index, "Close"))
        
        DockControls.Push(Row)
    }

    LCARS_DockGui.Show("x0 y" . VerticalOffset . " w200 h" . (ScreenHeight - VerticalOffset) . " NoActivate")
    
    RefreshTaskbarDock()
}

RefreshTaskbarDock() {
    global SlotHWNDs, DockControls, TopBlackBar, BottomBlackBar
    
    ActiveHWND := WinActive("A")
    idList := WinGetList(,, "Program Manager")
    
    ; 1. Gather all currently valid open windows
    CurrentWindows := Map()
    for this_id in idList
    {
        Title := WinGetTitle(this_id)
        
        if (Title = "" || Title = "Start" || Title = "Program Manager" || Title = "Settings" || Title = "LCARS_Sidebar")
            continue
            
        Style := WinGetStyle(this_id)
        ExStyle := WinGetExStyle(this_id)
        if !(Style & 0x10000000) || (ExStyle & 0x00000080)
            continue
            
        CurrentWindows[this_id] := Title
    }
    
    ; 2. RE-INDEX / SHIFT UP
    NewSlotHWNDs := []
    for OldHWND in SlotHWNDs
    {
        if (OldHWND != 0 && CurrentWindows.Has(OldHWND)) {
            NewSlotHWNDs.Push(OldHWND)
        }
    }
    
    ; 3. APPEND NEW WINDOWS
    for win_id, win_title in CurrentWindows
    {
        AlreadyTracked := false
        for tracked_id in NewSlotHWNDs
        {
            if (tracked_id = win_id) {
                AlreadyTracked := true
                break
            }
        }
        
        if (!AlreadyTracked && NewSlotHWNDs.Length < MaxSlots) {
            NewSlotHWNDs.Push(win_id)
        }
    }
    
    SlotHWNDs := NewSlotHWNDs
    ActiveCount := SlotHWNDs.Length

    TotalRenderedBlocks := (ActiveCount = 0) ? 1 : ActiveCount

    ; 4. RENDER ENGINE
    Loop MaxSlots
    {
        RowY := 6 + ((A_Index - 1) * 34)
        Row := DockControls[A_Index]
        
        if (ActiveCount = 0 && A_Index = 1) {
            ; Fallback: One grey placeholder box
            Row.Block.Value := "HBITMAP:" . CreateSolidBitmap(COLOR_NEUTRAL_GRAY)
            Row.Block.Move(0, RowY, BlockWidth, 33)
            Row.Block.Visible := true
            
            Row.AppTxt.Value := ""
            Row.AppTxt.Move(6, RowY + 10, BlockWidth, 14)
            Row.AppTxt.Visible := true
            
            Row.Txt.Visible := false
            Row.Btn.Visible := false
            Row.Divider.Visible := false
        }
        else if (A_Index <= ActiveCount) {
            ; Render dynamic active slot
            this_id := SlotHWNDs[A_Index]
            win_title := CurrentWindows[this_id]
            
            PName := WinGetProcessName(this_id)
            PName := StrUpper(RegExReplace(PName, "\.exe$", ""))
            
            TargetColor := (this_id = ActiveHWND) ? COLOR_BRIGHT_YELLOW : COLOR_LIGHT_BLUE
            
            DisplayApp := (StrLen(PName) > 15) ? SubStr(PName, 1, 12) . "..." : PName
            DisplayTitle := (StrLen(win_title) > 28) ? SubStr(win_title, 1, 25) . "..." : win_title
            
            Row.Block.Value := "HBITMAP:" . CreateSolidBitmap(TargetColor)
            Row.Block.Move(0, RowY, BlockWidth, 33)
            Row.Block.Visible := true
            
            Row.AppTxt.Value := DisplayApp
            Row.AppTxt.Move(6, RowY + 2, BlockWidth, 14)
            Row.AppTxt.Visible := true
            
            Row.Txt.Value := DisplayTitle
            Row.Txt.Move(6, RowY + 15, BlockWidth, 14)
            Row.Txt.Visible := true
            
            Row.Btn.Move(109, RowY - 15, 40, 48)
            Row.Btn.Visible := true

            if (A_Index < ActiveCount) {
                Row.Divider.Move(0, RowY + 33, BlockWidth, 1)
                Row.Divider.Visible := true
            } else {
                Row.Divider.Visible := false
            }
        }
        else {
            Row.Block.Visible := false
            Row.AppTxt.Visible := false
            Row.Txt.Visible := false
            Row.Btn.Visible := false
            Row.Divider.Visible := false
        }
    }

    ; 5. DYNAMIC BOUNDARY FRAME RENDERING
    TopBlackBar.Move(0, 0, BlockWidth, 6)
    TopBlackBar.Visible := true

    BottomY := 6 + (TotalRenderedBlocks * 34) - 1
    BottomBlackBar.Move(0, BottomY, BlockWidth, 6)
    BottomBlackBar.Visible := true
}

DockControlClicked(SlotNum, Action, CtrlObj, Info) {
    global SlotHWNDs
    if (SlotHWNDs.Length = 0 || SlotNum > SlotHWNDs.Length)
        return
        
    TargetHWND := SlotHWNDs[SlotNum]
    if (!TargetHWND)
        return
        
    if (Action = "Close") {
        if WinExist(TargetHWND) {
            WinClose(TargetHWND)
        }
        SetTimer(RefreshTaskbarDock, -1)
    } else {
        if WinExist(TargetHWND) {
            WinActivate(TargetHWND)
        }
    }
}

; ==============================================================================
; INTERACTIVE CLOCK WIDGET MODULE
; ==============================================================================
InitializeClockWidget() {
    global ClockGui, DateDisplay, TimeDisplay
    
    ClockGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08000000")
    ClockGui.BackColor := "000000" 
    WinSetTransColor("000000", ClockGui) 

    ; 1. Date Element (Top)
    ClockGui.SetFont("s22", "Impact")
    DateDisplay := ClockGui.AddText("y0 w250 h30 c" . COLOR_ORANGE . " Right +0x0100", "YYYY.MM.DD")
    DateDisplay.OnEvent("Click", ToggleDate)

    ; 2. Time Element (Bottom)
    ClockGui.SetFont("s33", "Impact")
    TimeDisplay := ClockGui.AddText("y+0 w250 h50 c" . COLOR_OFF_WHITE . " Right +0x0100", "HH:MM:SS")
    TimeDisplay.OnEvent("Click", ToggleTime)

    ; Scale positioning relative to screen dimensions if scaled, or absolute x1630 y10
    ClockX := Round(1610 * ScaleMultiplier)
    ClockY := Round(10 * ScaleMultiplier)
    ClockGui.Show("x" . ClockX . " y" . ClockY . " NoActivate")

    ; Initial state update and refresh loop
    UpdateClock()
    SetTimer(UpdateClock, 1000)
}

ToggleDate(*) {
    global DateFormatState := !DateFormatState
    UpdateClock()
}

ToggleTime(*) {
    global TimeFormatState := !TimeFormatState
    UpdateClock()
}

UpdateClock(*) {
    df := DateFormatState ? "yyyy.MM.dd" : "MM.dd.yyyy"
    tf := TimeFormatState ? "HH:mm:ss" : "h:mm tt"
    
    DateDisplay.Text := FormatTime(, df)
    TimeDisplay.Text := FormatTime(, tf)
}

; ==============================================================================
; INTEGRATED LCARS VOLUME CONTROL WIDGET MODULE
; ==============================================================================
InitializeVolumeWidget() {
    global volGui
    
    ; Create GUI Window using LCARS-compatible non-activating styles
    volGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000", "LCARS VOLUME")
    volGui.BackColor := COLOR_BACKGROUND

    volGui.MarginX := 6
    volGui.MarginY := 6

    currentVol := Round(SoundGetVolume())
    isMuted    := SoundGetMute() ? true : false

    ; Volume Status & Slider
    volGui.SetFont("s10 bold c" . (isMuted ? COLOR_RED : COLOR_AMBER), "Arial")
    volTextCtrl := volGui.AddText("vVolText w104 Center", isMuted ? "VOL: MUTED" : "VOL: " . currentVol . "%")

    volSlider := volGui.AddSlider("vVolSlider w104 Range0-100 ToolTip", currentVol)
    volSlider.OnEvent("Change", OnSliderChange)

    ; Buttons
    volGui.SetFont("s10 bold cBlack", "Arial")

    btnMuteText  := isMuted ? "UNMUTE" : "MUTE"
    btnMuteColor := isMuted ? COLOR_RED : COLOR_LAV

    btnMute := volGui.AddText("vBtnMute w104 h20 Center +0x200 Background" . btnMuteColor, btnMuteText)
    btnMute.OnEvent("Click", ToggleMute)

    volGui.SetFont("s15 bold cBlack", "Arial")

    btnDown := volGui.AddText("w48 h18 x6 y+6 Center +0x200 Background" . COLOR_AMBER, "-")
    btnDown.OnEvent("Click", (*) => AdjustVol(-5))

    btnUp := volGui.AddText("w48 h18 x+8 yp Center +0x200 Background" . COLOR_AMBER, "+")
    btnUp.OnEvent("Click", (*) => AdjustVol(+5))

    ; Position strictly on left screen edge (X:0, Y:78, Window Width: 116px)
    volGui.Show("x0 y78 w116 NoActivate")
}

OnSliderChange(ctrl, *) {
    newVol := ctrl.Value
    SoundSetVolume(newVol)
    
    if (SoundGetMute()) {
        SoundSetMute(0)
        UpdateMuteUI(false)
    } else {
        volGui["VolText"].Value := "VOL: " . newVol . "%"
    }
}

AdjustVol(delta) {
    current := SoundGetVolume()
    target := Clamp(Round(current + delta), 0, 100)
    SoundSetVolume(target)
    volGui["VolSlider"].Value := target
    
    if (SoundGetMute()) {
        SoundSetMute(0)
        UpdateMuteUI(false)
    } else {
        volGui["VolText"].Value := "VOL: " . target . "%"
    }
}

ToggleMute(*) {
    SoundSetMute(-1)
    realState := SoundGetMute() ? true : false
    UpdateMuteUI(realState)
}

UpdateMuteUI(muted) {
    volTxt := volGui["VolText"]
    btnMuteCtrl := volGui["BtnMute"]
    
    if (muted) {
        btnMuteCtrl.Opt("+Background" . COLOR_RED)
        btnMuteCtrl.Value := "UNMUTE"
        
        volTxt.SetFont("c" . COLOR_RED)
        volTxt.Value := "VOL: MUTED"
    } else {
        btnMuteCtrl.Opt("+Background" . COLOR_LAV)
        btnMuteCtrl.Value := "MUTE"
        
        volTxt.SetFont("c" . COLOR_AMBER)
        volTxt.Value := "VOL: " . Round(SoundGetVolume()) . "%"
    }
    
    WinRedraw(volGui.Hwnd)
}

Clamp(val, low, high) {
    return Max(low, Min(val, high))
}

; ==============================================================================
; DYNAMIC SHORTCUT TOP MENU ENGINE
; ==============================================================================
InitializeShortcutMenu() {
    global ShortcutMenuGui, GlobalBoxWidth, GlobalBoxHeight, GlobalPadding, TopMenuCols, DeleteZoneGui, DeleteZoneCtrl
    
    BaseWidth   := 125
    BaseHeight  := 33
    BasePadding := 1

    GlobalBoxWidth  := Round(BaseWidth * ScaleMultiplier)
    GlobalBoxHeight := Round(BaseHeight * ScaleMultiplier)
    GlobalPadding   := Round(BasePadding * ScaleMultiplier)

    ShortcutMenuGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08000000")
    ShortcutMenuGui.BackColor := COLOR_BACKGROUND
    ShortcutMenuGui.SetFont("s" . MenuFontSize . " norm", "Impact")

    TopMenu_X := ActiveWinX
    TopMenu_Y := 0                               
    TopMenu_H := (GlobalBoxHeight * 3) + (GlobalPadding * 2) 

    StatsReservation := Round(510 * ScaleMultiplier) 
    TopMenu_W := (ScreenWidth - ActiveWinX) - StatsReservation  

    TopMenuCols := Floor((TopMenu_W + GlobalPadding) / (GlobalBoxWidth + GlobalPadding))

    Loop TopMenuRows {
        currentRow := A_Index
        Loop TopMenuCols {
            currentCol := A_Index
            slotKey := "Slot_" . currentRow . "_" . currentCol
            
            boxX := (currentCol - 1) * (GlobalBoxWidth + GlobalPadding)
            boxY := (currentRow - 1) * (GlobalBoxHeight + GlobalPadding)
            
            btnName  := IniRead(IniFilePath, "Shortcuts", slotKey . "_Name", "")
            btnPath  := IniRead(IniFilePath, "Shortcuts", slotKey . "_Path", "")
            btnColor := IniRead(IniFilePath, "Shortcuts", slotKey . "_Color", COLOR_STEEL_BLUE)
            
            boxColor := (btnPath != "") ? btnColor : COLOR_STEEL_BLUE
            boxCtrl := ShortcutMenuGui.AddText("x" . boxX . " y" . boxY . " w" . GlobalBoxWidth . " h" . GlobalBoxHeight . " Background" . boxColor . " Center +0x200 +0x0100 c" . COLOR_OFF_WHITE, "")
            
            boxCtrl.Row := currentRow
            boxCtrl.Col := currentCol
            boxCtrl.Key := slotKey
            
            SetButtonTextAndFont(boxCtrl, btnName)
            BoxControls[slotKey] := boxCtrl
        }
    }

    ShortcutMenuGui.Show("x" . TopMenu_X . " y" . TopMenu_Y . " w" . TopMenu_W . " h" . TopMenu_H . " NoActivate")
    WinSetAlwaysOnTop(1, "ahk_id " . ShortcutMenuGui.Hwnd)

    ; Initialize the Drag-Delete Zone UI
    DeleteZoneGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x20")
    DeleteZoneGui.BackColor := COLOR_BACKGROUND
    DeleteZoneCtrl := DeleteZoneGui.AddText("x0 y0 w" . GlobalBoxWidth . " h" . GlobalBoxHeight . " Background" . COLOR_RED . " Center +0x200 c" . COLOR_OFF_WHITE, "REMOVE")
    DeleteZoneCtrl.Key := "DELETE_ZONE"
}

; ==============================================================================
; AUXILIARY THREE-DOT MENU ENGINE
; ==============================================================================
InitializeAuxMenu() {
    global AuxMenuGui
    AuxMenuGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08000000")
    MaskColor := COLOR_BACKGROUND 
    AuxMenuGui.BackColor := MaskColor

    DotSize := Round(24 * ScaleMultiplier)
    AuxPad  := Round(12 * ScaleMultiplier)
    TotalW  := (DotSize * 3) + (AuxPad * 2)

    ; 1. Red Dot (Kill Switch / Exit App)
    KillSwitchBtn := AuxMenuGui.AddText("x0 y0 w" . DotSize . " h" . DotSize . " +BackgroundTrans +0x0100")
    KillSwitchBtn.Key := "SYS_KILL"

    ; 2. Blue Dot (Window Viewport Snapper)
    ResetLayoutBtn := AuxMenuGui.AddText("x" . (DotSize + AuxPad) . " y0 w" . DotSize . " h" . DotSize . " +BackgroundTrans +0x0100")
    ResetLayoutBtn.Key := "SYS_SNAP"

    ; 3. Gold Dot (Desktop Icon Matrix Realignment)
    IconSnapBtn := AuxMenuGui.AddText("x" . ((DotSize * 2) + (AuxPad * 2)) . " y0 w" . DotSize . " h" . DotSize . " +BackgroundTrans +0x0100")
    IconSnapBtn.Key := "SYS_ICONS"

    ; Position it at your exact blueprint coordinates
    AuxMenuGui.Show("x15 y40 w" . (TotalW + 20) . " h" . (DotSize + 20) . " NoActivate")
    WinSetTransColor(MaskColor, AuxMenuGui)

    ; ==============================================================================
    ; GDI+ VECTOR PAINTING ROUTINE
    ; ==============================================================================
    hGdiplus := DllCall("kernel32.dll\LoadLibrary", "Str", "gdiplus.dll", "Ptr")
    si := Buffer(24, 0)
    NumPut("UInt", 1, si, 0) 
    DllCall("gdiplus.dll\GdiplusStartup", "Ptr*", &pToken:=0, "Ptr", si.Ptr, "Ptr", 0)

    hdc := DllCall("user32.dll\GetDC", "Ptr", AuxMenuGui.Hwnd, "Ptr")
    DllCall("gdiplus.dll\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &pGraphics:=0)
    DllCall("gdiplus.dll\GdipSetSmoothingMode", "Ptr", pGraphics, "Int", 4)

    ; Paint RED
    ColorRedARGB := 0xFFFF0000 
    DllCall("gdiplus.dll\GdipCreateSolidFill", "UInt", ColorRedARGB, "Ptr*", &pBrushRed:=0)
    DllCall("gdiplus.dll\GdipFillEllipse", "Ptr", pGraphics, "Ptr", pBrushRed, "Float", 0, "Float", 0, "Float", DotSize, "Float", DotSize)

    ; Paint BLUE
    ColorBlueARGB := 0xFF0000FF 
    DllCall("gdiplus.dll\GdipCreateSolidFill", "UInt", ColorBlueARGB, "Ptr*", &pBrushBlue:=0)
    DllCall("gdiplus.dll\GdipFillEllipse", "Ptr", pGraphics, "Ptr", pBrushBlue, "Float", DotSize + AuxPad, "Float", 0, "Float", DotSize, "Float", DotSize)

    ; Paint GOLD
    ColorGoldARGB := 0xFFFFAA00 
    DllCall("gdiplus.dll\GdipCreateSolidFill", "UInt", ColorGoldARGB, "Ptr*", &pBrushGold:=0)
    DllCall("gdiplus.dll\GdipFillEllipse", "Ptr", pGraphics, "Ptr", pBrushGold, "Float", (DotSize * 2) + (AuxPad * 2), "Float", 0, "Float", DotSize, "Float", DotSize)

    ; GDI+ Cleanup
    DllCall("gdiplus.dll\GdipDeleteBrush", "Ptr", pBrushRed)
    DllCall("gdiplus.dll\GdipDeleteBrush", "Ptr", pBrushBlue)
    DllCall("gdiplus.dll\GdipDeleteBrush", "Ptr", pBrushGold)
    DllCall("gdiplus.dll\GdipDeleteGraphics", "Ptr", pGraphics)
    DllCall("user32.dll\ReleaseDC", "Ptr", AuxMenuGui.Hwnd, "Ptr", hdc)
}

; ==============================================================================
; SYSTEM TELEMETRY / MONITORING ENGINE
; ==============================================================================
InitializeStatsMenu() {
    global StatsGui, StatsReadout, ActiveColorBar, CurrentSelection, SelectedDrive
    
    StatsReservation := Round(510 * ScaleMultiplier)
    StatsX := ScreenWidth - StatsReservation + Round(40 * ScaleMultiplier)
    StatsY := 0
    
    StatsGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08000000")
    StatsGui.BackColor := COLOR_BACKGROUND
    
    StatsGui.SetFont("s24 norm", "Impact")
    StatsReadout := StatsGui.AddText("w200 h35 c" . COLOR_OFF_WHITE, "")
    
    ActiveColorBar := StatsGui.AddText("y+2 w200 h6 Background" . COLOR_RED, "")
    
    StatsGui.SetFont("s10", "Arial")
    
    CpuBtn := StatsGui.AddText("y+10 w15 h15 Background" . COLOR_RED . " +0x0100", "")
    CpuBtn.Key := "STAT_CPU"
    
    RamBtn := StatsGui.AddText("x+5 w15 h15 Background" . COLOR_BLUE . " +0x0100", "")
    RamBtn.Key := "STAT_RAM"
    
    NetBtn := StatsGui.AddText("x+5 w15 h15 Background" . COLOR_GOLD . " +0x0100", "")
    NetBtn.Key := "STAT_NET"
    
    Loop Parse, DriveGetList() {
        blk := StatsGui.AddText("x+5 w15 h15 Background" . COLOR_MUTED_GREEN . " +0x0100", "")
        blk.Key := "STAT_DRIVE_" . A_LoopField
    }
    
    UpdateStats()
    StatsGui.Show("x" . StatsX . " y" . StatsY . " NoActivate")
    SetTimer(UpdateStats, 3000)
}

; ==============================================================================
; UTILITY: FORCE LAYER TO BOTTOM OF STACK
; ==============================================================================
SendInterfaceToBottom() {
    if (MainGuiHwnd) {
        DllCall("SetWindowPos", "ptr", MainGuiHwnd, "ptr", 1, "int", 0, "int", 0, "int", 0, "int", 0, "uint", 0x0013)
    }
}

; ==============================================================================
; INTERACTION HANDLERS & OPERATIONS
; ==============================================================================
~LButton::TrackActiveApp()

TrackActiveApp() {
    global LastActiveAppHWND
    currentActive := WinExist("A")
    
    if (currentActive && currentActive != MainGuiHwnd && currentActive != AuxMenuGui && currentActive != ShortcutMenuGui.Hwnd && (!StatsGui || currentActive != StatsGui.Hwnd) && (!ClockGui || currentActive != ClockGui.Hwnd) && (!volGui || currentActive != volGui.Hwnd) && (!LCARS_DockGui || currentActive != LCARS_DockGui.Hwnd)) {
        try {
            winClass := WinGetClass("ahk_id " . currentActive)
            if (winClass != "Shell_TrayWnd" && winClass != "Progman" && winClass != "WorkerW") {
                LastActiveAppHWND := currentActive
            }
        }
    }
}

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    global SourceBoxCtrl, DragStartX, DragStartY, IsDraggingState, CurrentSelection, SelectedDrive
    clickedCtrl := GuiCtrlFromHwnd(hwnd)
    
    if (clickedCtrl && clickedCtrl.HasProp("Key")) {
        ; Handle telemetry engine routing safely
        if (SubStr(clickedCtrl.Key, 1, 5) == "STAT_") {
            targetStat := SubStr(clickedCtrl.Key, 6)
            barColor := COLOR_RED
            
            if (SubStr(targetStat, 1, 6) == "DRIVE_") {
                CurrentSelection := "DRIVE"
                SelectedDrive := SubStr(targetStat, 7)
                barColor := COLOR_MUTED_GREEN
            } else {
                CurrentSelection := targetStat
                SelectedDrive := ""
                if (CurrentSelection == "CPU")
                    barColor := COLOR_RED
                else if (CurrentSelection == "RAM")
                    barColor := COLOR_BLUE
                else if (CurrentSelection == "NET")
                    barColor := COLOR_GOLD
            }
            ActiveColorBar.Opt("Background" . barColor)
            ActiveColorBar.Redraw()
            UpdateStats()
            return 0
        }

        ; Handle system three-dot execution matrix
        if (clickedCtrl.Key == "SYS_KILL") {
            ExitApp() 
            return 0  
        }
        if (clickedCtrl.Key == "SYS_SNAP") {
            ForceViewportRecalibration() 
            return 0  
        }
        if (clickedCtrl.Key == "SYS_ICONS") {
            AlignDesktopIcons() 
            return 0
        }
        
        ; Handle Top Menu Grid interception setup
        SourceBoxCtrl := clickedCtrl
        IsDraggingState := false
        CoordMode("Mouse", "Screen")
        MouseGetPos(&DragStartX, &DragStartY)
        SetTimer(CheckDragDelay, -180)
    }
}

CheckDragDelay() {
    global SourceBoxCtrl, DeleteZoneGui, DeleteZoneCtrl, IsDraggingState
    if (SourceBoxCtrl && GetKeyState("LButton", "P")) {
        IsDraggingState := true
        srcPath := IniRead(IniFilePath, "Shortcuts", SourceBoxCtrl.Key . "_Path", "")
        if (srcPath != "") {
            DeleteZoneCtrl.SetFont("s20 norm", "Impact") 
            DeleteZoneGui.Show("x0 y0 w" . GlobalBoxWidth . " h" . GlobalBoxHeight . " NoActivate")
        }
    }
}

WM_LBUTTONUP(wParam, lParam, msg, hwnd) {
    global SourceBoxCtrl, DragStartX, DragStartY, DeleteZoneGui, IsDraggingState
    
    SetTimer(CheckDragDelay, 0)
    if (DeleteZoneGui)
        DeleteZoneGui.Hide()
    
    if (!SourceBoxCtrl)
        return
        
    CoordMode("Mouse", "Screen")
    MouseGetPos(&currentX, &currentY)
    moveThreshold := 8 
    
    srcCtrl := SourceBoxCtrl
    SourceBoxCtrl := "" 
    
    isClickGesture := (Abs(currentX - DragStartX) < moveThreshold && Abs(currentY - DragStartY) < moveThreshold && !IsDraggingState)
    
    if (isClickGesture) {
        ExecuteShortcutLaunch(srcCtrl)
        return
    }
    
    if (currentX >= 0 && currentX <= GlobalBoxWidth && currentY >= 0 && currentY <= GlobalBoxHeight) {
        DeleteShortcutData(srcCtrl)
        return
    }
    
    releasedHwnd := DllCall("user32.dll\WindowFromPoint", "Int64", GetMousePosInt64(), "Ptr")
    targetCtrl := GuiCtrlFromHwnd(releasedHwnd)
    
    if (!targetCtrl || !targetCtrl.HasProp("Key"))
        return
        
    if (srcCtrl.Key == targetCtrl.Key) {
        CycleBoxColor(srcCtrl)
        return
    }
    
    if (srcCtrl.Key != targetCtrl.Key) {
        MoveShortcutData(srcCtrl, targetCtrl)
        return
    }
}

GetMousePosInt64() {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    return (my << 32) | (mx & 0xFFFFFFFF)
}

CalculateFontSize(text, maxWidth, baseSize := 16, fontName := "Impact") {
    fontSize := baseSize
    loop {
        dummy := Gui()
        dummy.SetFont("s" . fontSize . " norm", fontName)
        txtCtrl := dummy.AddText("", text)
        txtCtrl.GetPos(,, &measuredWidth)
        dummy.Destroy()
        if (measuredWidth <= maxWidth || fontSize <= 8) {
            return fontSize
        }
        fontSize--
    }
}

SetButtonTextAndFont(ctrlObj, text) {
    global MenuFontSize
    if (text == "") {
        ctrlObj.SetFont("s" . MenuFontSize)
        ctrlObj.Text := ""
        return
    }
    safetyMargin := Round(8 * ScaleMultiplier)
    maxTextWidth := GlobalBoxWidth - safetyMargin
    optimalSize := CalculateFontSize(text, maxTextWidth, MenuFontSize, "Impact")
    ctrlObj.SetFont("s" . optimalSize)
    ctrlObj.Text := text
}

ExecuteShortcutLaunch(ctrlObj) {
    currentPath := IniRead(IniFilePath, "Shortcuts", ctrlObj.Key . "_Path", "")
    
    if (currentPath == "") {
        nameBox := InputBox("Enter LCARS button display label:", "LCARS Terminal - New Shortcut")
        if (nameBox.Result != "OK" || nameBox.Value == "")
            return
        pathBox := InputBox("Enter target application path, folder directory, or URL address:", "LCARS Terminal - Target Link")
        if (pathBox.Result != "OK" || pathBox.Value == "")
            return
            
        IniWrite(nameBox.Value, IniFilePath, "Shortcuts", ctrlObj.Key . "_Name")
        IniWrite(pathBox.Value, IniFilePath, "Shortcuts", ctrlObj.Key . "_Path")
        IniWrite(COLOR_GOLD,     IniFilePath, "Shortcuts", ctrlObj.Key . "_Color")
        
        SetButtonTextAndFont(ctrlObj, nameBox.Value)
        ctrlObj.Opt("Background" . COLOR_GOLD)
        ctrlObj.Redraw()
    } 
    else {
        try {
            ; Passing "Max" in parameter 3 tells Windows to launch the window maximized
            Run(currentPath, , "Max")
        } catch {
            MsgBox("System Error: Unable to launch target execution path.", "LCARS Command Failure", "Iconx")
        }
    }
}

MoveShortcutData(srcCtrl, targetCtrl) {
    srcName  := IniRead(IniFilePath, "Shortcuts", srcCtrl.Key . "_Name", "")
    srcPath  := IniRead(IniFilePath, "Shortcuts", srcCtrl.Key . "_Path", "")
    srcColor := IniRead(IniFilePath, "Shortcuts", srcCtrl.Key . "_Color", COLOR_GOLD)
    
    targetPath := IniRead(IniFilePath, "Shortcuts", targetCtrl.Key . "_Path", "")
    if (targetPath != "") {
        MsgBox("Target cell is already occupied. Rearrangement aborted.", "LCARS Buffer Conflict", "Iconi")
        return
    }
    
    if (srcPath == "")
        return
        
    IniWrite(srcName, IniFilePath, "Shortcuts", targetCtrl.Key . "_Name")
    IniWrite(srcPath, IniFilePath, "Shortcuts", targetCtrl.Key . "_Path")
    IniWrite(srcColor, IniFilePath, "Shortcuts", targetCtrl.Key . "_Color")
    
    IniDelete(IniFilePath, "Shortcuts", srcCtrl.Key . "_Name")
    IniDelete(IniFilePath, "Shortcuts", srcCtrl.Key . "_Path")
    IniDelete(IniFilePath, "Shortcuts", srcCtrl.Key . "_Color")
    
    SetButtonTextAndFont(targetCtrl, srcName)
    targetCtrl.Opt("Background" . srcColor)
    targetCtrl.Redraw()
    
    SetButtonTextAndFont(srcCtrl, "")
    srcCtrl.Opt("Background" . COLOR_STEEL_BLUE)
    srcCtrl.Redraw()
}

DeleteShortcutData(srcCtrl) {
    srcName := IniRead(IniFilePath, "Shortcuts", srcCtrl.Key . "_Name", "Unknown Shortcut")
    
    confirm := MsgBox("Are you sure you want to permanently delete the shortcut '" . srcName . "'?", "LCARS Terminal - Confirm Deletion", "YesNo Icon! Default2")
    if (confirm == "No") {
        return 
    }
    
    IniDelete(IniFilePath, "Shortcuts", srcCtrl.Key . "_Name")
    IniDelete(IniFilePath, "Shortcuts", srcCtrl.Key . "_Path")
    IniDelete(IniFilePath, "Shortcuts", srcCtrl.Key . "_Color")
    
    SetButtonTextAndFont(srcCtrl, "")
    srcCtrl.Opt("Background" . COLOR_STEEL_BLUE)
    srcCtrl.Redraw()
}

CycleBoxColor(ctrlObj) {
    currentPath := IniRead(IniFilePath, "Shortcuts", ctrlObj.Key . "_Path", "")
    if (currentPath == "")
        return
        
    currentColor := IniRead(IniFilePath, "Shortcuts", ctrlObj.Key . "_Color", COLOR_GOLD)
    colorPalette := [COLOR_GOLD, COLOR_ORANGE, COLOR_PEACH, COLOR_LILAC, COLOR_CORNFLOWER, COLOR_LIGHT_BLUE, COLOR_MUTED_GREEN]
	
    nextColor := colorPalette[1]
    
    Loop colorPalette.Length {
        if (colorPalette[A_Index] == currentColor) {
            nextIndex := (A_Index == colorPalette.Length) ? 1 : A_Index + 1
            nextColor := colorPalette[nextIndex]
            break
        }
    }
    
    IniWrite(nextColor, IniFilePath, "Shortcuts", ctrlObj.Key . "_Color")
    ctrlObj.Opt("Background" . nextColor)
    ctrlObj.Redraw()
}

ForceViewportRecalibration() {
    global LastActiveAppHWND
    
    if (!LastActiveAppHWND || !WinExist("ahk_id " . LastActiveAppHWND)) {
        winList := WinGetList()
        for currentHWND in winList {
            try {
                winTitle := WinGetTitle("ahk_id " . currentHWND)
                winClass := WinGetClass("ahk_id " . currentHWND)
            } catch {
                continue
            }
            if (winClass = "Shell_TrayWnd" || winClass = "Progman" || winClass = "WorkerW" 
                || winClass = "AutoHotkeyGUI" || InStr(winTitle, "LCARS") || winTitle == "") {
                continue
            }
            LastActiveAppHWND := currentHWND
            break
        }
    }
    
    if (!LastActiveAppHWND)
        return
	
    WinRestore("ahk_id " . LastActiveAppHWND)
    DllCall("user32.dll\MoveWindow", "Int", LastActiveAppHWND, "Int", ActiveWinX - Round(20 * ScaleMultiplier), "Int", ActiveWinY - Round(3 * ScaleMultiplier), "Int", ActiveWinW + Round(20 * ScaleMultiplier), "Int", ActiveWinH + Round(10 * ScaleMultiplier), "Int", 1)
}

AlignDesktopIcons() {
    LV := 0
    try LV := ControlGetHwnd("SysListView321", "ahk_class Progman")
    if (!LV) {
        try LV := ControlGetHwnd("SysListView321", "ahk_class WorkerW")
    }
    
    if (!LV) {
        MsgBox("System Error: Unable to interface with desktop matrix.", "LCARS Sensor Failure", "Iconx")
        return
    }
    
    iconCount := SendMessage(0x1004, 0, 0, LV)
    
    startX := ActiveWinX + 20
    startY := ActiveWinY + 20
    spacingX := 80
    spacingY := 100
    
    curX := startX
    curY := startY
    
    Loop iconCount {
        idx := A_Index - 1
        lParam := (curY << 16) | (curX & 0xFFFF)
        SendMessage(0x100F, idx, lParam, LV)
        
        curY += spacingY
        if (curY > (ScreenHeight - spacingY - 40)) {
            curY := startY
            curX += spacingX
        }
    }
}

; ==============================================================================
; TELEMETRY SAMPLING ENGINE (WMI REFRESH)
; ==============================================================================
UpdateStats(*) {
    global CurrentSelection, SelectedDrive, StatsReadout
    if (!StatsReadout)
        return

    val := ""
    if (CurrentSelection == "CPU")
        val := LoadPercentage("CPU") . "% CPU"
    else if (CurrentSelection == "RAM")
        val := LoadPercentage("RAM") . "% RAM"
    else if (CurrentSelection == "NET")
        val := LoadPercentage("NET") . "% NET"
    else if (CurrentSelection == "DRIVE")
        val := SelectedDrive . ": " . Round(100 - (DriveGetSpaceFree(SelectedDrive . ":") / DriveGetCapacity(SelectedDrive . ":") * 100)) . "% USED"
    
    StatsReadout.Text := val
}

LoadPercentage(type) {
    static objWMI := ComObject("WbemScripting.SWbemLocator").ConnectServer(".", "root\cimv2")
    
    if (type == "CPU") {
        try {
            items := objWMI.ExecQuery("Select LoadPercentage from Win32_Processor")._NewEnum
            while items(&item, &i)
                return item.LoadPercentage
        }
    }
    if (type == "RAM") {
        mem := Buffer(64, 0), NumPut("UInt", 64, mem, 0)
        DllCall("GlobalMemoryStatusEx", "Ptr", mem)
        return NumGet(mem, 4, "UInt") 
    }
    if (type == "NET") {
        try {
            items := objWMI.ExecQuery("Select BytesTotalPerSec from Win32_PerfFormattedData_Tcpip_NetworkInterface")._NewEnum
            totalNet := 0
            while items(&item, &i) {
                totalNet += item.BytesTotalPerSec
            }
            
            maxCapacity := 12500000 
            percent := Round((totalNet / maxCapacity) * 100)
            return Min(100, percent) 
        }
    }
    return 0
}

; ==============================================================================
; WINDOW MANAGER & VIEWPORT SNAP ENGINE FUNCTIONS
; ==============================================================================
ShellEvent(wParam, lParam, *) {
    if (wParam = 1 || wParam = 2 || wParam = 4 || wParam = 32772) {
        SetTimer(RefreshTaskbarDock, -1)
        Sleep(100) 
        EnforceBoundaries()
        SendInterfaceToBottom()
    }
}

WatchdogCheck() {
    EnforceBoundaries()
    if (AuxMenuGui) {
        try {
            WinSetAlwaysOnTop(1, "ahk_id " . AuxMenuGui.Hwnd)
        }
    }
}

EnforceBoundaries() {
    activeHWND := WinActive("A")
    if (!activeHWND)
        return
        
    try {
        winClass := WinGetClass("ahk_id " . activeHWND)
        winTitle := WinGetTitle("ahk_id " . activeHWND)
    } catch {
        return 
    }
    
    if (winClass = "Shell_TrayWnd" || winClass = "Progman" || winClass = "WorkerW" 
        || winClass = "AutoHotkeyGUI" || winClass = "Windows.UI.Core.CoreWindow" 
        || winClass = "XamlExplorerHostIslandWindow" || InStr(winTitle, "Snipping Tool")
        || winTitle = "LCARS_Sidebar" || winTitle = "LCARS_TopMenu" || winTitle = "LCARS_SystemStats") {
        return
    }
    
    try {
        minMaxState := WinGetMinMax("ahk_id " . activeHWND)
    } catch {
        return
    }
	
    if (minMaxState = 1) {
        WinRestore("ahk_id " . activeHWND)
        DllCall("user32.dll\MoveWindow", "Ptr", activeHWND, "Int", ActiveWinX - Round(20 * ScaleMultiplier), "Int", ActiveWinY - Round(3 * ScaleMultiplier), "Int", ActiveWinW + Round(20 * ScaleMultiplier), "Int", ActiveWinH + Round(10 * ScaleMultiplier), "Int", 1)
    }
}

EnforceLayers() {
    try {
        if (ShortcutMenuGui) {
            WinSetAlwaysOnTop(1, "ahk_id " . ShortcutMenuGui.Hwnd)
        }
        if (StatsGui) {
            WinSetAlwaysOnTop(1, "ahk_id " . StatsGui.Hwnd)
        }
        if (ClockGui) {
            WinSetAlwaysOnTop(1, "ahk_id " . ClockGui.Hwnd)
        }
        if (volGui) {
            WinSetAlwaysOnTop(1, "ahk_id " . volGui.Hwnd)
        }
        if (LCARS_DockGui) {
            WinSetAlwaysOnTop(1, "ahk_id " . LCARS_DockGui.Hwnd)
        }
    }
}

; ==============================================================================
; DYNAMIC BITMAP GENERATOR
; ==============================================================================
StrUpper(String) {
    return Format("{:U}", String)
}

CreateSolidBitmap(HexColor) {
    R := "0x" SubStr(HexColor, 1, 2)
    G := "0x" SubStr(HexColor, 3, 2)
    B := "0x" SubStr(HexColor, 5, 2)
    
    Bmi := Buffer(44, 0)
    NumPut("UInt", 40, Bmi, 0) 
    NumPut("Int", 1, Bmi, 4)    
    NumPut("Int", 1, Bmi, 8)    
    NumPut("UShort", 1, Bmi, 12) 
    NumPut("UShort", 32, Bmi, 14) 
    
    pBits := 0
    hBmd := DllCall("CreateDIBSection", "Ptr", 0, "Ptr", Bmi, "UInt", 0, "PtrP", &pBits, "Ptr", 0, "UInt", 0, "Ptr")
    NumPut("UInt", (R << 16) | (G << 8) | B, pBits, 0)
    return hBmd
}

; Keep, used for testing.
; Esc::ExitApp



; ==========================================================================================
; LCARS V2.1 SYSTEM ARCHITECTURE MANUAL & MODIFICATION GUIDELINES
; ==========================================================================================
;
; 1. WINDOW ARCHITECTURE & THE TWO-TIER GUI ENGINE
;    * The system operates via a split-layer design to balance aesthetics and interactivity.
;    * Background Canvas (MainGuiHwnd): Relies on '+E0x20' to remain entirely click-through, 
;      serving as the static visual frame.
;    * Interactive Overlays (InteractGui, AuxMenuGui, ShortcutMenuGui, StatsGui): Separate GUI layers 
;      handling user inputs. The interactive layers use CHROMA_KEY ("111111") or 
;      pure black backgrounds with explicit controls, relying on WinSetTransColor or strict 
;      bounds to keep empty grid space fully click-through to the desktop.
;
; 2. TASKBAR COMPATIBILITY & DYNAMIC Z-ORDER MANAGEMENT
;    * Taskbar Protection: Do NOT use MonitorGetWorkArea() or SetParent to the desktop handle. 
;      It breaks full-screen rendering and prevents auto-hide taskbars from triggering.
;    * Window Focus Mitigation: Windows styles must retain '+E0x08000000' (WS_EX_NOACTIVATE). 
;      This blocks the GUI from capturing OS focus, allowing the taskbar to pop up seamlessly.
;    * Z-Order Split Strategy: 
;      - The background canvas uses an immediate SetWindowPos DllCall (HWND_BOTTOM) to stay 
;        under system panels. SendInterfaceToBottom() is bound to ShellEvent focus shifts 
;        to prevent the canvas from trapping auto-hide taskbars when minimizing windows.
;      - The Shortcut Menu and Telemetry Engine utilize the EnforceLayers() timer loop to deliberately 
;        maintain an HWND_TOPMOST status so app launch tiles and readouts remain constantly accessible.
;
; 3. INTEGRATED TRIPLE-ENGINE INTERACTION POOL (GRID, VECTOR & TELEMETRY)
;    * Input Message Sharing: The GDI+ vector buttons (Three-Dot Menu), the drag-and-drop shortcut grid, 
;      and the system monitor selectors all intercept clicks through a single shared pool 
;      (WM_LBUTTONDOWN / WM_LBUTTONUP).
;    * Control Namespace Guardrails: Any new structural or telemetry buttons added to the terminal MUST 
;      be assigned a unique, explicit '.Key' property namespace (e.g., 'SYS_KILL' or 'STAT_CPU'). 
;      If left blank, the shortcut engine's drag-and-drop matrix will falsely capture the click, 
;      corrupting data layouts or causing execution crashes.
;    * Telemetry Routing: Interactive stats items prefix their identification namespaces with 'STAT_'. 
;      The mouse handler captures this substring to bypass drag-and-drop validation loops and hot-swap 
;      WMI performance counters in real-time.
;
; 4. VIEWPORT SNAP MECHANICS & FOCUS CACHING
;    * Target Acquisition (~LButton): Clicking interactive elements causes the script to briefly 
;      intercept window messages. To prevent losing the user's targeted window, a low-level 
;      pass-through mouse hook (~LButton::TrackActiveApp()) caches the HWND of the true active application 
;      a split second *before* focus shifts. This enables the Blue Dot snapper to target 
;      modern Windows frames accurately.
;    * Taskbar Clearance: The viewport engine queries the physical taskbar height dynamically 
;      via WinGetPos to establish exact layout metrics, ensuring snapped windows never bleed 
;      beneath the panel.
;    * Custom Offsets: Grid boundaries can be customized manually by adjusting the pixel modifiers 
;      appended to the 'ActiveWinW' (Width) and 'ActiveWinH' (Height) expressions inside the 
;      InitializeLcars() function.
;
; 5. TELEMETRY COOLDOWN & ALIGNMENT RESEVALUTION
;    * Coordinate Mapping: The Telemetry Engine calculates its layout using the 'StatsReservation' 
;      expression derived from the main engine canvas framework. This guarantees that 
;      the monitoring panels scale automatically across disparate screen resolutions without bleeding 
;      off-screen or overlapping the shortcut grid.
;    * Performance Throttle: To minimize baseline processor overhead, WMI queries for CPU load percentages 
;      and network adapter bandwidth metrics are hard-capped to a asynchronous 3000ms polling cycle.

; 6. CLOCK MODULE INTEGRATION & DISPLAY LAYER
;    * Top Layer Enforcement: ClockGui is tracked by EnforceLayers() every 500ms 
;      alongside ShortcutMenuGui and StatsGui to keep time/date readouts above the canvas.
;    * Window Focus Exclusion: TrackActiveApp() explicitly ignores ClockGui.Hwnd 
;      so clicking the date or time to toggle formats does NOT overwrite the cached 
;      active application handle (LastActiveAppHWND) used by the Blue Dot viewport snapper.
;    * Scaled Positioning & Format Toggles: Default coordinates use (1620 * ScaleMultiplier) 
;      for screen scaling. The clock elements use OnEvent("Click") handlers (ToggleDate/ToggleTime) 
;      to flip date/time format flags instantly without restarting the 1-second timer loop.

; 7. VOLUME CONTROL MODULE INTEGRATION
;    * Top Layer Enforcement: volGui is included in EnforceLayers() (500ms cycle) 
;      to keep the overlay above the main canvas alongside ClockGui, ShortcutMenuGui, and StatsGui.
;    * Window Focus Exclusion: TrackActiveApp() explicitly ignores volGui.Hwnd 
;      so adjusting volume or toggling mute does NOT overwrite LastActiveAppHWND 
;      (preserving the Blue Dot viewport snapper target).
;    * Window Style Guardrails: Retains '+E0x08000000' (WS_EX_NOACTIVATE) to prevent 
;      capturing OS focus during slider drags or button clicks, maintaining auto-hide taskbar compatibility.
;    * Native Hardware Hooks: Direct AHK v2 SoundGetVolume, SoundSetVolume, and SoundSetMute 
;      calls bypass external dependencies, updating the UI dynamically via UpdateMuteUI and WinRedraw.

; 8. TASKBAR DOCK / SIDEBAR ENGINE INTEGRATION
;    * Separate Transparency Key (COLOR_DOCK_BG): To render solid 1px black dividers and 6px framing
;      bars without empty background space bleeding through, LCARS_DockGui uses a dedicated background 
;      color key ("020202") instead of pure black ("000000"). Never set DockGui BackColor to "000000" 
;      or WinSetTransColor will wipe out the solid black framing.
;    * Vertical Offset & Scaling: Dock Y-positioning is governed by 'VerticalOffset' inside 
;      InitializeTaskbarDock(). The total GUI height automatically calculates via 
;      (ScreenHeight - VerticalOffset) to prevent screen overflow.
;    * Dynamic Re-Indexing: Process tracking relies on ShellEvent messages (wParam 1, 2, 4, 32772) 
;      triggering RefreshTaskbarDock via a negative SetTimer (-1) to prevent hook thread blocking.
;    * Focus Tracking Exclusion: TrackActiveApp() explicitly ignores LCARS_DockGui.Hwnd so selecting 
;      or closing docked applications does not corrupt LastActiveAppHWND for the viewport snapper.

; 9. VOLUME MODULE SYMBOL STYLING
;    * Isolated Font Scaling: To change the font size of the +/- controls without affecting button 
;      geometry, call volGui.SetFont("s14 bold") immediately before instantiating btnDown and btnUp. 
;    * Alignment Preserves: Retain the +0x200 (vertical centering) and Center options in the AddText string 
;      so enlarged font glyphs self-center within the existing 48x18 bounding boxes.
; ==========================================================================================