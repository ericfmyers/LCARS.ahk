; Enforces AutoHotkey v2.0+ execution syntax and blocks legacy v1 runtime
#Requires AutoHotkey v2.0
; Automatically replaces any previously running instance of this script without prompting
#SingleInstance Force
; Keeps the script running continuously in the background even without active hotkeys
Persistent(True) 
; Sets the hover tooltip text displayed when mousing over the system tray icon
A_IconTip := "LCARS Terminal Interface Engine"

; ==============================================================================
; LCARS SYSTEM COLOR PALETTE
; ==============================================================================
global COLOR_BACKGROUND        := "000000"  ; Defines global hex code for foundational canvas background (Pure Black)
global COLOR_NEUTRAL_GRAY      := "333333"  ; Defines global hex code for empty grid slots and placeholders (Dark Slate)
global COLOR_OFF_WHITE         := "FEEBDE"  ; Defines global hex code for primary text inside structural blocks (Cream)
global COLOR_MAUVE             := "C86A6A"  ; Defines global hex code for sidebar tracks and bottom row blocks (Dusty Rose)
global COLOR_ORANGE            := "FF8800"  ; Defines global hex code for structural frames and primary headers
global COLOR_GOLD              := "FFAA00"  ; Defines global hex code for standard shortcut buttons and default accents
global COLOR_PEACH             := "FF9900"  ; Defines global hex code for secondary menu functions (Muted Apricot)
global COLOR_PURPLE            := "996699"  ; Defines global hex code for segmented data tracks and telemetry blocks
global COLOR_CORNFLOWER        := "6699FF"  ; Defines global hex code for default taskbar dock pill buttons
global COLOR_LILAC             := "CC99CC"  ; Defines global hex code for main top menu bars and secondary navigation
global COLOR_LIGHT_BLUE        := "BBBBFF"  ; Defines global hex code for telemetry readouts and upper sidebar blocks
global COLOR_STEEL_BLUE        := "555577"  ; Defines global hex code for unconfigured shortcut tiles
global COLOR_MUTED_GREEN       := "99AA66"  ; Defines global hex code for drive monitoring indicators and scanners
global COLOR_RED               := "EE0000"  ; Defines global hex code for system termination controls and critical alerts
global COLOR_DARK_RED          := "882211"  ; Defines global hex code for system anomaly readouts
global COLOR_BURGUNDY          := "CC6666"  ; Defines global hex code for tactical submenus and auxiliary panels
global COLOR_BLUE              := "0A4BEE"  ; Defines global hex code for RAM telemetry indicators and tactical shifts
global COLOR_BRIGHT_RED        := "FF0000"  ; Defines global hex code for active mute toggles and deletion drop zones
global COLOR_BRIGHT_YELLOW     := "FFCC00"  ; Defines global hex code for active taskbar window indicators (Operations Yellow)
global COLOR_BRIGHT_BLUE       := "0066FF"  ; Defines global hex code for vivid selection states and telemetry highlights
global COLOR_PALE_CANARY       := "FFFF99"  ; Defines global hex code for secondary background highlights and text
global COLOR_ATOMIC_TANGERINE  := "FF9933"  ; Defines global hex code for secondary headers and soft orange accents
global COLOR_EGGPLANT          := "664466"  ; Defines global hex code for inactive status fields and structural panels
global COLOR_ANAKIWA           := "99CCFF"  ; Defines global hex code for system-ready indicators and clear data fields
global COLOR_MARINER_BLUE      := "3366CC"  ; Defines global hex code for mid-tone interface elements
global COLOR_SCIENCE_TEAL      := "008080"  ; Defines global hex code for science and medical station panel layouts
global COLOR_DUSKY_PINK        := "E5A9A9"  ; Defines global hex code for dusty rose interface accents
global CHROMA_KEY              := "111111"  ; Defines global transparency mask color for click-through GUI layers
global COLOR_DOCK_BG           := "020202"  ; Defines global transparency key for taskbar dock framing and dividers
global COLOR_AMBER             := COLOR_BRIGHT_YELLOW  ; Maps global volume widget accent alias to bright yellow
global COLOR_LAV               := COLOR_LILAC          ; Maps global volume widget accent alias to lilac

; ==============================================================================
; DYNAMIC WORKSPACE DOCK BOUNDS & INTERFACE HANDLES
; ==============================================================================
global ScreenWidth     := 0    ; Stores primary display pixel width initialized during setup
global ScreenHeight    := 0    ; Stores primary display pixel height initialized during setup
global ScaleMultiplier := 1.0  ; Calculates UI scaling ratio based on target 1080p baseline height
global ActiveWinX      := 0    ; Defines target X-coordinate origin for snapped window viewports
global ActiveWinY      := 0    ; Defines target Y-coordinate origin for snapped window viewports
global ActiveWinW      := 0    ; Defines target pixel width for snapped window viewports
global ActiveWinH      := 0    ; Defines target pixel height for snapped window viewports
global MainGuiHwnd     := 0    ; Holds native window handle for static canvas background GUI
global AuxMenuGui      := 0    ; Holds GUI object handle for three-dot system command overlay
global LastActiveAppHWND := 0  ; Caches window handle of last active app for viewport snapper

; ==============================================================================
; TOPMENU SHORTCUT ENGINE GLOBALS
; ==============================================================================
global ShortcutMenuGui  := ""   ; Holds GUI object handle for top shortcut grid overlay
global IniFilePath      := A_ScriptDir . "\LcarsConfig.ini" ; Defines absolute path to shortcut configuration file
global GlobalBoxWidth   := 0    ; Stores calculated pixel width for shortcut pill controls
global GlobalBoxHeight  := 0    ; Stores calculated pixel height for shortcut pill controls
global GlobalPadding    := 0    ; Stores calculated pixel spacing between grid shortcut controls
global MenuFontSize     := 16   ; Defines baseline font size for grid launcher interface
global TopMenuCols      := 0    ; Stores dynamically calculated column count for top grid
global TopMenuRows      := 3    ; Defines fixed row count for top shortcut button matrix
global BoxControls      := Map() ; Maps slot keys to GUI control objects for grid management
global SourceBoxCtrl    := ""   ; Caches source control object during drag-and-drop actions
global DragStartX       := 0    ; Stores screen X-coordinate where click-drag gesture originated
global DragStartY       := 0    ; Stores screen Y-coordinate where click-drag gesture originated

; ==============================================================================
; SYSTEM STATS ENGINE GLOBALS
; ==============================================================================
global CurrentSelection := "CPU" ; Defines active telemetry display mode (CPU, RAM, NET, or DRIVE)
global SelectedDrive    := ""    ; Stores target drive letter when drive telemetry mode is active
global StatsGui         := ""    ; Holds GUI object handle for telemetry monitoring panel overlay
global StatsReadout     := ""    ; Holds text control object handle for telemetry value readouts
global ActiveColorBar   := ""    ; Holds text control object handle for telemetry indicator color bar

; ==============================================================================
; CLOCK MODULE GLOBALS
; ==============================================================================
global ClockGui         := "" ; Holds GUI object handle for time and date widget overlay
global DateDisplay      := "" ; Holds text control object handle for date readout
global TimeDisplay      := "" ; Holds text control object handle for time readout
global DateFormatState  := 1  ; Tracks active date display format toggle state
global TimeFormatState  := 1  ; Tracks active time display format toggle state

; ==============================================================================
; VOLUME CONTROL MODULE GLOBALS
; ==============================================================================
global volGui           := "" ; Holds GUI object handle for integrated volume control widget overlay

; ==============================================================================
; TASKBAR DOCK ENGINE GLOBALS
; ==============================================================================
global LCARS_DockGui    := "" ; Holds GUI object handle for dynamic taskbar dock sidebar overlay
global BlockWidth       := 126  ; Defines pixel width for taskbar dock app slot controls
global MaxSlots         := 20  ; Defines maximum capacity limit for open application dock slots
global SlotHWNDs        := [] ; Array storing tracked window handles corresponding to dock slots
global DockControls     := [] ; Array storing GUI control object maps for each dock row slot
global TopBlackBar      := "" ; Holds picture control object handle for upper black framing bar
global BottomBlackBar   := "" ; Holds picture control object handle for lower black framing bar

; ==============================================================================
; GLOBAL ERROR TRAP
; ==============================================================================
OnError(LcarsErrorHandler) ; Registers global exception handler callback for runtime errors
LcarsErrorHandler(err, mode) { ; Defines exception handler function accepting error object and mode
    OutputDebug("LCARS ERROR: " . err.Message . " (" . err.What . " @ line " . err.Line . ")") ; Writes error details, origin function, and line number to debug log
    return true  ; Suppresses default system error dialogs to keep interface running uninterrupted
}

; ==============================================================================
; SYSTEM INITIALIZATION ROUTINE (AUTO-EXECUTE PHASE)
; ==============================================================================
InitializeLcars()        ; Instantiates main background canvas, viewport metrics, and shell hooks
InitializeAuxMenu()      ; Renders three-dot vector GDI+ system command overlay
InitializeShortcutMenu() ; Builds interactive launcher grid and loads saved INI shortcuts
InitializeStatsMenu()    ; Initializes WMI performance monitoring panel and controls
InitializeClockWidget()  ; Renders interactive date and time display widget
InitializeVolumeWidget() ; Instantiates audio volume control overlay and hardware hooks
InitializeTaskbarDock()  ; Builds dynamic taskbar sidebar and registers window tracking

; Global focus message monitors
OnMessage(0x0201, WM_LBUTTONDOWN) ; Registers left mouse button down event monitor to handle grid clicks and drag actions
OnMessage(0x0202, WM_LBUTTONUP)   ; Registers left mouse button up event monitor to handle button releases and shortcut launches
OnMessage(0x0205, WM_RBUTTONUP)   ; Registers right mouse button up event monitor to handle color cycling

; Layer Enforcement Timer for all interactive panels
SetTimer(EnforceLayers, 500)

; Structural boundary mark ending the setup sequence
Return

; ==============================================================================
; MAIN INTERFACE ENGINE (HIGH-DPI CANVAS FRAMEWORK)
; ==============================================================================
InitializeLcars() {
    ; Query primary display monitor boundaries to establish physical resolution metrics
    MonitorGet(1, &Left, &Top, &Right, &Bottom)
    global ScreenWidth     := Right - Left      ; Calculates total display pixel width
    global ScreenHeight    := Bottom - Top     ; Calculates total display pixel height
    global ScaleMultiplier := ScreenHeight / 1080 ; Derives dynamic UI scaling ratio normalized against a baseline 1080p display height

    StaticX := Round(147 * ScaleMultiplier)    ; Scales baseline horizontal pixel offset for workspace boundary alignment
    StaticY := Round(130 * ScaleMultiplier)    ; Scales baseline vertical pixel offset for upper menu interface clearance

    ; Captures native Windows desktop canvas handle for background redraw refreshing
    DesktopHwnd := WinExist("ahk_class WorkerW") ? WinExist("ahk_class WorkerW") : WinExist("ahk_class Progman")

    ; --- LAYER 1: BACKGROUND CANVAS (CLICK-THROUGH) ---
    TopMenuGui := Gui("-Caption +ToolWindow +E0x20 +E0x08000000") ; Creates frameless, non-activating, click-through GUI overlay for canvas artwork
    TopMenuGui.BackColor := CHROMA_KEY                             ; Applies global transparency mask color to establish click-through background canvas
    global MainGuiHwnd := TopMenuGui.Hwnd                          ; Caches native window handle of background canvas GUI for layer Z-order management

    ; --- Top Header Frame ---
    TopMenuX := 0, TopMenuY := 0 ; Defines horizontal and vertical origins for primary top menu header block
    StatsReservation := Round(510 * ScaleMultiplier) ; Calculates horizontal pixel buffer reserved for top-right telemetry panel
    TopMenuW := (StaticX + (ScreenWidth - StaticX) - StatsReservation) + Round(40 * ScaleMultiplier) ; Computes scaled total pixel width for primary top menu block
    TopMenuH := Round(101 * ScaleMultiplier) ; Scales pixel height for primary top menu block
    TopMenuGui.AddText("x" . TopMenuX . " y" . TopMenuY . " w" . TopMenuW . " h" . TopMenuH . " Background" . COLOR_LILAC) ; Renders primary top header background block in lilac

    TopMenuX1 := 0, TopMenuY1 := Round(75 * ScaleMultiplier) ; Scales origin coordinates for upper-left secondary header block extension
    TopMenuW1 := Round(340 * ScaleMultiplier), TopMenuH1 := Round(48 * ScaleMultiplier) ; Scales width and height for upper-left secondary header block
    TopMenuGui.AddText("x" . TopMenuX1 . " y" . TopMenuY1 . " w" . TopMenuW1 . " h" . TopMenuH1 . " Background" . COLOR_LIGHT_BLUE) ; Renders upper-left secondary header block in light blue

    TopMenuXbar := 0, TopMenuYbar := Round(73 * ScaleMultiplier) ; Scales coordinates for horizontal separating line above secondary header
    TopMenuWbar := Round(140 * ScaleMultiplier), TopMenuHbar := Round(6 * ScaleMultiplier) ; Scales pixel dimensions for upper horizontal separator bar
    TopMenuGui.AddText("x" . TopMenuXbar . " y" . TopMenuYbar . " w" . TopMenuWbar . " h" . TopMenuHbar . " Background" . COLOR_BACKGROUND) ; Renders upper separator bar in solid background color

    ; --- Segmented Data Blocks Row ---
    TopMenuX4 := Round(346 * ScaleMultiplier), TopMenuY4 := Round(107 * ScaleMultiplier) ; Scales position for first segmented header accent block
    TopMenuW4 := Round(65 * ScaleMultiplier),  TopMenuH4 := Round(16 * ScaleMultiplier)  ; Scales dimensions for first segmented header accent block
    TopMenuGui.AddText("x" . TopMenuX4 . " y" . TopMenuY4 . " w" . TopMenuW4 . " h" . TopMenuH4 . " Background" . COLOR_ORANGE) ; Renders first segmented header accent block in orange

    TopMenuX5 := Round(417 * ScaleMultiplier), TopMenuY5 := Round(107 * ScaleMultiplier) ; Scales position for second segmented header data track
    TopMenuW5 := Round(385 * ScaleMultiplier), TopMenuH5 := Round(16 * ScaleMultiplier)  ; Scales dimensions for second segmented header data track
    TopMenuGui.AddText("x" . TopMenuX5 . " y" . TopMenuY5 . " w" . TopMenuW5 . " h" . TopMenuH5 . " Background" . COLOR_PURPLE) ; Renders second segmented header data track in purple

    TopMenuX6 := Round(808 * ScaleMultiplier), TopMenuY6 := Round(107 * ScaleMultiplier) ; Scales position for third segmented header accent block
    TopMenuW6 := Round(200 * ScaleMultiplier), TopMenuH6 := Round(16 * ScaleMultiplier)  ; Scales dimensions for third segmented header accent block
    TopMenuGui.AddText("x" . TopMenuX6 . " y" . TopMenuY6 . " w" . TopMenuW6 . " h" . TopMenuH6 . " Background" . COLOR_LILAC) ; Renders third segmented header accent block in lilac

    TopMenuX7 := Round(1014 * ScaleMultiplier), TopMenuY7 := Round(107 * ScaleMultiplier) ; Scales position for fourth segmented header accent block
    TopMenuW7 := Round(65 * ScaleMultiplier),   TopMenuH7 := Round(16 * ScaleMultiplier)  ; Scales dimensions for fourth segmented header accent block
    TopMenuGui.AddText("x" . TopMenuX7 . " y" . TopMenuY7 . " w" . TopMenuW7 . " h" . TopMenuH7 . " Background" . COLOR_ORANGE) ; Renders fourth segmented header accent block in orange

    TopMenuX8 := Round(1085 * ScaleMultiplier), TopMenuY8 := Round(107 * ScaleMultiplier) ; Scales position for fifth segmented header data track
    TopMenuW8 := Round(700 * ScaleMultiplier),  TopMenuH8 := Round(16 * ScaleMultiplier)  ; Scales dimensions for fifth segmented header data track
    TopMenuGui.AddText("x" . TopMenuX8 . " y" . TopMenuY8 . " w" . TopMenuW8 . " h" . TopMenuH8 . " Background" . COLOR_MAUVE) ; Renders fifth segmented header data track in mauve

    TopMenuX9 := Round(1791 * ScaleMultiplier), TopMenuY9 := Round(107 * ScaleMultiplier) ; Scales position for sixth segmented header terminal block
    TopMenuW9 := Round(129 * ScaleMultiplier),  TopMenuH9 := Round(16 * ScaleMultiplier)  ; Scales dimensions for sixth segmented header terminal block
    TopMenuGui.AddText("x" . TopMenuX9 . " y" . TopMenuY9 . " w" . TopMenuW9 . " h" . TopMenuH9 . " Background" . COLOR_LILAC) ; Renders sixth segmented header terminal block in lilac

    ; --- Scaled Grid Cutout Mask ---
    TopMenuXb := Round(140 * ScaleMultiplier) ; Scales starting horizontal origin for main shortcut grid cutout mask
    TopMenuWb := (TopMenuW - Round(40 * ScaleMultiplier) + Round(6 * ScaleMultiplier)) - TopMenuXb ; Calculates scaled width for primary top grid cutout field
    TopMenuHb := Round(107 * ScaleMultiplier) ; Fully scales cutout height to ensure complete coverage for 3 full button rows on High-DPI displays
    TopMenuGui.AddText("x" . TopMenuXb . " y0 w" . TopMenuWb . " h" . TopMenuHb . " Background" . COLOR_BACKGROUND) ; Renders cutout mask in solid background color to house the dynamic launcher matrix

    ; --- Sidebar Elements ---
    SideBarX := 0, SideBarY := Round(123 * ScaleMultiplier) ; Scales origin coordinates for upper sidebar block
    SideBarW := Round(126 * ScaleMultiplier), SideBarH := Round(100 * ScaleMultiplier) ; Scales width and height metrics for upper sidebar block
    TopMenuGui.AddText("x" . SideBarX . " y" . SideBarY . " w" . SideBarW . " h" . SideBarH . " Background" . COLOR_LIGHT_BLUE) ; Renders upper sidebar block in light blue

    SideBarX2 := 0, SideBarY2 := SideBarY + SideBarH ; Calculates starting coordinates for main vertical sidebar track
    SideBarW2 := Round(126 * ScaleMultiplier)        ; Sets scaled explicit width for main vertical sidebar track
    SideBarH2 := ScreenHeight - SideBarY2            ; Calculates remaining display height to extend vertical sidebar track down to screen bottom
    TopMenuGui.AddText("x" . SideBarX2 . " y" . SideBarY2 . " w" . SideBarW2 . " h" . SideBarH2 . " Background" . COLOR_MAUVE) ; Renders main vertical sidebar track in mauve

    ; --- Bottom Segmented Data Row ---
    BotRowY := ScreenHeight - Round(32 * ScaleMultiplier) ; Calculates vertical origin to anchor the bottom telemetry bar exactly 32 scaled pixels above screen bottom
    TopMenuGui.AddText("x" . Round(126 * ScaleMultiplier) . " y" . BotRowY . " w" . Round(700 * ScaleMultiplier) . " h" . Round(32 * ScaleMultiplier) . " Background" . COLOR_MAUVE)  ; Renders primary bottom-left mauve data track block starting adjacent to sidebar
    TopMenuGui.AddText("x" . Round(832 * ScaleMultiplier) . " y" . BotRowY . " w" . Round(65 * ScaleMultiplier) . " h" . Round(32 * ScaleMultiplier) . " Background" . COLOR_ORANGE) ; Renders first orange structural accent block in bottom telemetry row
    TopMenuGui.AddText("x" . Round(903 * ScaleMultiplier) . " y" . BotRowY . " w" . Round(200 * ScaleMultiplier) . " h" . Round(32 * ScaleMultiplier) . " Background" . COLOR_LILAC)  ; Renders middle lilac navigation segment in bottom telemetry row
    TopMenuGui.AddText("x" . Round(1109 * ScaleMultiplier) . " y" . BotRowY . " w" . Round(385 * ScaleMultiplier) . " h" . Round(32 * ScaleMultiplier) . " Background" . COLOR_PURPLE) ; Renders secondary purple data track block in bottom telemetry row
    TopMenuGui.AddText("x" . Round(1500 * ScaleMultiplier) . " y" . BotRowY . " w" . Round(65 * ScaleMultiplier) . " h" . Round(32 * ScaleMultiplier) . " Background" . COLOR_ORANGE) ; Renders second orange structural accent block in bottom telemetry row

    BotRowX9 := Round(1571 * ScaleMultiplier) ; Calculates scaled starting horizontal coordinate for terminal right bottom block
    BotRowW9 := ScreenWidth - BotRowX9        ; Dynamically calculates remaining pixel width to span terminal block to right screen edge
    TopMenuGui.AddText("x" . BotRowX9 . " y" . BotRowY . " w" . BotRowW9 . " h" . Round(32 * ScaleMultiplier) . " Background" . COLOR_LILAC) ; Renders final rightmost lilac terminal block extending to screen edge

; --- CALCULATE WORKSPACE DOCK BOUNDS ---
    global ActiveWinX := StaticX                              ; Sets horizontal pixel origin for snapped application viewport alignment
    global ActiveWinY := StaticY                              ; Sets vertical pixel origin for snapped application viewport alignment
    global ActiveWinW := ScreenWidth - StaticX + 10           ; Calculates viewport pixel width spanning from sidebar track to right edge

    ; Dynamically check for the taskbar, or fallback to your 40px guess
    try {                                                     ; Begins safe execution block to query system taskbar metrics
        WinGetPos(,,, &TaskbarH, "ahk_class Shell_TrayWnd")   ; Queries native Windows shell taskbar handle to extract physical height
    } catch {                                                 ; Handles exception if taskbar handle is inaccessible or hidden
        TaskbarH := 40                                        ; Assigns baseline 40-pixel fallback estimate for vertical clearance
    }
    
; Exact boundary assignment using the precise structural formula
    global ActiveWinH := ScreenHeight - ((TaskbarH > 1) ? TaskbarH : 0) - StaticY + 10 ; Evaluates target viewport height while subtracting taskbar and upper menu clearance

    ; --- LAYER 2: INTERACTIVE FOREGROUND LAYER ---
    InteractGui := Gui("-Caption +ToolWindow +E0x08000000 +Parent" . TopMenuGui.Hwnd)    ; Instantiates child GUI overlay bound to main canvas using WS_EX_NOACTIVATE style
    InteractGui.BackColor := CHROMA_KEY                                                  ; Applies global transparency mask color to establish click-through foreground layer

    ; --- RENDER EXECUTION ---
    TopMenuGui.Show("x0 y0 w" . ScreenWidth . " h" . ScreenHeight . " NoActivate")        ; Displays background canvas GUI maximized across full display screen without capturing focus
    WinSetTransColor(CHROMA_KEY, TopMenuGui.Hwnd)                                        ; Applies chroma key color mask to make transparent regions click-through to desktop

    InteractGui.Show("x" . StaticX . " y" . StaticY . " w400 h100 NoActivate")            ; Displays interactive foreground layer at viewport origin coordinates without capturing focus
    WinSetTransColor(CHROMA_KEY, InteractGui.Hwnd)                                       ; Applies chroma key color mask to interactive layer for seamless element transparency

    ; Primary layer placement below panels
    SendInterfaceToBottom()                                                              ; Forces main background canvas handle to bottom of window Z-order stack

    ; --- INITIALIZE VIEWPORT MANAGERS & SYSTEM HOOKS ---
    DllCall("RegisterShellHookWindow", "Ptr", A_ScriptHwnd)                              ; Registers script handle with Windows shell to listen for OS-wide window events
    OnMessage(DllCall("RegisterWindowMessage", "Str", "SHELLHOOK"), ShellEvent)          ; Binds shell hook message monitor to ShellEvent callback handler function
    SetTimer(WatchdogCheck, 500)                                                         ; Schedules repeating 500ms timer loop to monitor auxiliary menu layout integrity

    EnforceBoundaries()                                                                  ; Triggers immediate viewport snap evaluation for currently active foreground application

    ; Clean up rendering artifacts
    DllCall("user32\RedrawWindow", "ptr", DesktopHwnd, "ptr", 0, "ptr", 0, "uint", 1)    ; Issues forced user32 redraw refresh to native desktop canvas to clear visual artifacts
}

; ==============================================================================
; DYNAMIC TASKBAR SIDEBAR DOCK ENGINE
; ==============================================================================
InitializeTaskbarDock() {
    global LCARS_DockGui, TopBlackBar, BottomBlackBar, DockControls                     ; References global handles and control array for sidebar taskbar dock management
    
    VerticalOffset := 206                                                               ; Defines baseline vertical pixel offset to position dock below upper sidebar blocks
    
    LCARS_DockGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000")              ; Instantiates non-activating, frameless tool window overlay maintaining topmost layer status
    
    LCARS_DockGui.BackColor := COLOR_DOCK_BG                                           ; Applies dedicated dock background color key ("020202") to preserve solid black dividers
    WinSetTransColor(COLOR_DOCK_BG, LCARS_DockGui)                                     ; Sets transparency mask key so empty dock areas remain click-through to underlying elements

    TopBlackBar := LCARS_DockGui.Add("Pic", "x0 y0 w" . BlockWidth . " h6 Hidden", "HBITMAP:" . CreateSolidBitmap(COLOR_BACKGROUND))    ; Pre-renders upper 6px solid black framing bar bitmap control
    BottomBlackBar := LCARS_DockGui.Add("Pic", "x0 y0 w" . BlockWidth . " h6 Hidden", "HBITMAP:" . CreateSolidBitmap(COLOR_BACKGROUND)) ; Pre-renders lower 6px solid black framing bar bitmap control
	
    Loop MaxSlots                                                                       ; Iterates through pre-allocation loop to build reusable GUI slot controls up to capacity limit
    {
        Row := {}                                                                      ; Instantiates temporary object map to group control handles for current slot row
        
        ; Main Pill Background
        Row.Block := LCARS_DockGui.Add("Pic", "x0 y0 w" . BlockWidth . " h33 Hidden", "HBITMAP:" . CreateSolidBitmap(COLOR_CORNFLOWER)) ; Instantiates dynamic slot background picture control
        
        ; App Name (Top Line)
        LCARS_DockGui.SetFont("s8 Bold q5", "Arial")                                   ; Sets font parameters for process executable name readout with high-quality antialiasing
        Row.AppTxt := LCARS_DockGui.Add("Text", "x0 y0 w" . BlockWidth . " h14 c" . COLOR_BACKGROUND . " +BackgroundTrans +Hidden +0x4000") ; Instantiates executable label text control with path-trimming style
        
        ; File Title (Bottom Line)
        LCARS_DockGui.SetFont("s7 Norm", "Arial")                                   ; Sets font parameters for secondary active window title readout
        Row.Txt := LCARS_DockGui.Add("Text", "x0 y0 w" . BlockWidth . " h14 c" . COLOR_BACKGROUND . " +BackgroundTrans +Hidden +0x4000")    ; Instantiates window title label text control with path-trimming style
        
        ; Unicode Tactical Close Button
        LCARS_DockGui.SetFont("s38 q5", "Arial")                                   ; Sets font scale for tactical close button glyph rendering
        Row.Btn := LCARS_DockGui.Add("Text", "x0 y0 w40 h48 c" . COLOR_RED . " +BackgroundTrans +Hidden", Chr(0x25D7))                       ; Renders right-facing semi-circle Unicode character as tactical window termination button
        
        ; 1px Solid Interstitial Divider Line
        Row.Divider := LCARS_DockGui.Add("Pic", "x0 y0 w" . BlockWidth . " h1 Hidden", "HBITMAP:" . CreateSolidBitmap(COLOR_BACKGROUND)) ; Pre-renders 1px solid black interstitial row separator bitmap
        
        ; Bind native click events
        Row.Block.OnEvent("Click", DockControlClicked.Bind(A_Index, "Activate"))       ; Binds main slot pill click event to focus target application window
        Row.AppTxt.OnEvent("Click", DockControlClicked.Bind(A_Index, "Activate"))      ; Binds executable label text click event to focus target application window
        Row.Txt.OnEvent("Click", DockControlClicked.Bind(A_Index, "Activate"))         ; Binds window title text click event to focus target application window
        Row.Btn.OnEvent("Click", DockControlClicked.Bind(A_Index, "Close"))            ; Binds tactical close button click event to terminate target application window
        
        DockControls.Push(Row)                                                         ; Pushes configured row control object map to global DockControls array
    }

    LCARS_DockGui.Show("x0 y" . VerticalOffset . " w200 h" . (ScreenHeight - VerticalOffset) . " NoActivate") ; Displays taskbar dock sidebar GUI without capturing window focus
    
    RefreshTaskbarDock()                                                               ; Executes initial window process enumeration and renders active taskbar slots
}
; ==============================================================================
; DYNAMIC TASKBAR SIDEBAR DOCK REFRESH & INTERACTION ENGINE
; ==============================================================================
RefreshTaskbarDock() {
    global SlotHWNDs, DockControls, TopBlackBar, BottomBlackBar
    
    ActiveHWND := WinActive("A")               ; Caches window handle of currently active foreground application
    idList := WinGetList(,, "Program Manager") ; Captures list of all open window handles, excluding desktop manager
    
    ; --- 1. GATHER ALL CURRENTLY VALID OPEN WINDOWS ---
    CurrentWindows := Map()                    ; Instantiates lookup map for tracking valid taskbar windows
    for this_id in idList
    {
        Title := WinGetTitle(this_id)          ; Queries target window handle to retrieve title text
        
        ; Filter out empty titles, system shell components, and LCARS interface elements
        if (Title = "" || Title = "Start" || Title = "Program Manager" || Title = "Settings" || Title = "LCARS_Sidebar")
            continue
            
        Style := WinGetStyle(this_id)          ; Retrieves window style flags to check visibility
        ExStyle := WinGetExStyle(this_id)      ; Retrieves extended style flags to check taskbar inclusion
        
        ; Verify window is visible (WS_VISIBLE 0x10000000) and not hidden toolwindow (WS_EX_TOOLWINDOW 0x00000080)
        if !(Style & 0x10000000) || (ExStyle & 0x00000080)
            continue
            
        CurrentWindows[this_id] := Title       ; Maps valid window handle to its window title
    }
    
    ; --- 2. RE-INDEX / SHIFT UP ---
    NewSlotHWNDs := []                          ; Instantiates array to hold re-indexed active window handles
    for OldHWND in SlotHWNDs
    {
        ; Retain existing tracked window handles if they remain valid and open
        if (OldHWND != 0 && CurrentWindows.Has(OldHWND)) {
            NewSlotHWNDs.Push(OldHWND)
        }
    }
    
    ; --- 3. APPEND NEW WINDOWS ---
    for win_id, win_title in CurrentWindows
    {
        AlreadyTracked := false                ; Flag tracking whether window is already assigned a dock slot
        for tracked_id in NewSlotHWNDs
        {
            if (tracked_id = win_id) {
                AlreadyTracked := true
                break
            }
        }
        
        ; Append newly opened window handle if capacity limit is not exceeded
        if (!AlreadyTracked && NewSlotHWNDs.Length < MaxSlots) {
            NewSlotHWNDs.Push(win_id)
        }
    }
    
    SlotHWNDs := NewSlotHWNDs                  ; Updates global tracked slot handle array with refreshed state
    ActiveCount := SlotHWNDs.Length            ; Captures total count of actively tracked window slots

    TotalRenderedBlocks := (ActiveCount = 0) ? 1 : ActiveCount ; Ensures at least one slot block renders for empty placeholder state

    ; --- 4. RENDER ENGINE ---
    Loop MaxSlots
    {
        RowY := 6 + ((A_Index - 1) * 34)       ; Calculates vertical pixel offset for current sidebar dock row
        Row := DockControls[A_Index]            ; References control handle map for current dock slot row
        
        if (ActiveCount = 0 && A_Index = 1) {
            ; Render fallback grey placeholder block when no application windows are open
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
            ; Render dynamic active slot for valid tracked application window
            this_id := SlotHWNDs[A_Index]
            win_title := CurrentWindows[this_id]
            
            PName := WinGetProcessName(this_id) ; Queries executable process name associated with window handle
            PName := StrUpper(RegExReplace(PName, "\.exe$", "")) ; Truncates .exe extension and converts label to uppercase
            
            ; Highlight active foreground window in Operations Yellow; unselected windows in Light Blue
            TargetColor := (this_id = ActiveHWND) ? COLOR_BRIGHT_YELLOW : COLOR_LIGHT_BLUE
            
            ; Apply path and character truncation to fit pill bounding dimensions
            DisplayApp := (StrLen(PName) > 15) ? SubStr(PName, 1, 12) . "..." : PName
            DisplayTitle := (StrLen(win_title) > 28) ? SubStr(win_title, 1, 25) . "..." : win_title
            
            ; Update background color and position pill control
            Row.Block.Value := "HBITMAP:" . CreateSolidBitmap(TargetColor)
            Row.Block.Move(0, RowY, BlockWidth, 33)
            Row.Block.Visible := true
            
            ; Update primary executable label readout
            Row.AppTxt.Value := DisplayApp
            Row.AppTxt.Move(6, RowY + 2, BlockWidth, 14)
            Row.AppTxt.Visible := true
            
            ; Update secondary window title readout
            Row.Txt.Value := DisplayTitle
            Row.Txt.Move(6, RowY + 15, BlockWidth, 14)
            Row.Txt.Visible := true
            
            ; Position Unicode tactical window termination close button
            Row.Btn.Move(109, RowY - 15, 40, 48)
            Row.Btn.Visible := true

            ; Render 1px solid black interstitial divider between populated slots
            if (A_Index < ActiveCount) {
                Row.Divider.Move(0, RowY + 33, BlockWidth, 1)
                Row.Divider.Visible := true
            } else {
                Row.Divider.Visible := false
            }
        }
        else {
            ; Hide unused controls for unpopulated pre-allocated slots
            Row.Block.Visible := false
            Row.AppTxt.Visible := false
            Row.Txt.Visible := false
            Row.Btn.Visible := false
            Row.Divider.Visible := false
        }
    }

    ; --- 5. DYNAMIC BOUNDARY FRAME RENDERING ---
    TopBlackBar.Move(0, 0, BlockWidth, 6)      ; Positions upper 6px solid black framing bar
    TopBlackBar.Visible := true

    BottomY := 6 + (TotalRenderedBlocks * 34) - 1 ; Calculates vertical origin to snap lower bar flush against bottom block
    BottomBlackBar.Move(0, BottomY, BlockWidth, 6) ; Positions lower 6px solid black framing bar
    BottomBlackBar.Visible := true
}

; ==============================================================================
; DOCK SLOT CLICK EVENT ROUTER
; ==============================================================================
DockControlClicked(SlotNum, Action, CtrlObj, Info) {
    global SlotHWNDs
    if (SlotHWNDs.Length = 0 || SlotNum > SlotHWNDs.Length) ; Aborts execution if target slot index is out of bounds
        return
        
    TargetHWND := SlotHWNDs[SlotNum]            ; Retrieves target window handle associated with clicked slot
    if (!TargetHWND)
        return
        
    if (Action = "Close") {
        if WinExist(TargetHWND) {
            WinClose(TargetHWND)               ; Issues standard OS close signal to target application window
        }
        SetTimer(RefreshTaskbarDock, -1)       ; Triggers asynchronous immediate taskbar refresh cycle
    } else {
        if WinExist(TargetHWND) {
            WinActivate(TargetHWND)             ; Restores and shifts OS window focus to target application
        }
    }
}
; ==============================================================================
; INTERACTIVE CLOCK WIDGET MODULE
; ==============================================================================
InitializeClockWidget() {
    global ClockGui, DateDisplay, TimeDisplay
    
    ; Instantiates non-activating, frameless tool window overlay maintaining topmost layer status
    ClockGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08000000")
    ClockGui.BackColor := "000000"                                      ; Applies pure black canvas background
    WinSetTransColor("000000", ClockGui)                                ; Sets black as transparency mask so empty space remains click-through

    ; --- 1. DATE ELEMENT (TOP) ---
    ClockGui.SetFont("s22", "Impact")                                   ; Sets Impact typography for primary date readout
    DateDisplay := ClockGui.AddText("y0 w250 h30 c" . COLOR_ORANGE . " Right +0x0100", "YYYY.MM.DD") ; Instantiates right-aligned date text control in orange
    DateDisplay.OnEvent("Click", ToggleDate)                            ; Binds native click event to toggle date formatting

    ; --- 2. TIME ELEMENT (BOTTOM) ---
    ClockGui.SetFont("s33", "Impact")                                   ; Sets enlarged Impact typography for primary time readout
    TimeDisplay := ClockGui.AddText("y+0 w250 h50 c" . COLOR_OFF_WHITE . " Right +0x0100", "HH:MM:SS") ; Instantiates right-aligned time text control in off-white
    TimeDisplay.OnEvent("Click", ToggleTime)                            ; Binds native click event to toggle time formatting

    ; --- POSITIONING & SCALING ---
    ClockX := Round(1610 * ScaleMultiplier)                             ; Scales horizontal origin relative to primary monitor resolution
    ClockY := Round(10 * ScaleMultiplier)                               ; Scales vertical origin relative to primary monitor resolution
    ClockGui.Show("x" . ClockX . " y" . ClockY . " NoActivate")         ; Renders clock widget GUI without capturing window focus

    ; --- REFRESH LOOP ---
    UpdateClock()                                                       ; Performs immediate time string valuation and UI render
    SetTimer(UpdateClock, 1000)                                         ; Registers repeating 1-second timer cycle for real-time clock updates
}

; ==============================================================================
; CLOCK FORMAT TOGGLE HANDLERS & RENDER ENGINE
; ==============================================================================
ToggleDate(*) {
    global DateFormatState := !DateFormatState                           ; Flips date format toggle state flag (ISO 8601 vs. Standard US)
    UpdateClock()                                                       ; Forces immediate text refresh to reflect updated date format
}

ToggleTime(*) {
    global TimeFormatState := !TimeFormatState                           ; Flips time format toggle state flag (24-Hour Military vs. 12-Hour AM/PM)
    UpdateClock()                                                       ; Forces immediate text refresh to reflect updated time format
}

UpdateClock(*) {
    df := DateFormatState ? "yyyy.MM.dd" : "MM.dd.yyyy"                 ; Evaluates active format flag to derive date formatting template string
    tf := TimeFormatState ? "HH:mm:ss" : "h:mm tt"                       ; Evaluates active format flag to derive time formatting template string
    
    DateDisplay.Text := FormatTime(, df)                                ; Formats current system timestamp and writes to date text control
    TimeDisplay.Text := FormatTime(, tf)                                ; Formats current system timestamp and writes to time text control
}

; ==============================================================================
; INTEGRATED LCARS VOLUME CONTROL WIDGET MODULE
; ==============================================================================
InitializeVolumeWidget() {
    global volGui
    
    ; Instantiates non-activating, frameless tool window overlay maintaining topmost layer status
    volGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000", "LCARS VOLUME")
    volGui.BackColor := COLOR_BACKGROUND                               ; Applies solid black canvas background

    volGui.MarginX := 6                                                ; Defines horizontal pixel padding for interior controls
    volGui.MarginY := 6                                                ; Defines vertical pixel padding for interior controls

    currentVol := Round(SoundGetVolume())                              ; Queries OS audio endpoint to capture active volume percentage
    isMuted    := SoundGetMute() ? true : false                         ; Queries OS audio endpoint to capture system mute status

    ; --- VOLUME STATUS READOUT & SLIDER ---
    volGui.SetFont("s10 bold c" . (isMuted ? COLOR_RED : COLOR_AMBER), "Arial")
    volGui.AddText("vVolText w104 Center", isMuted ? "VOL: MUTED" : "VOL: " . currentVol . "%")

    volSlider := volGui.AddSlider("vVolSlider w104 Range0-100 ToolTip", currentVol)
    volSlider.OnEvent("Change", OnSliderChange)

    ; --- TACTICAL MUTE TOGGLE BUTTON ---
    volGui.SetFont("s10 bold cBlack", "Arial")

    btnMuteText  := isMuted ? "UNMUTE" : "MUTE"
    btnMuteColor := isMuted ? COLOR_RED : COLOR_LAV

    volGui.AddText("vBtnMute w104 h20 Center +0x200 Background" . btnMuteColor, btnMuteText).OnEvent("Click", ToggleMute)

    ; --- VOLUME STEP INCREMENT/DECREMENT BUTTONS ---
    volGui.SetFont("s15 bold cBlack", "Arial")

    volGui.AddText("w48 h18 x6 y+6 Center +0x200 Background" . COLOR_AMBER, "-").OnEvent("Click", (*) => AdjustVol(-5))
    volGui.AddText("w48 h18 x+8 yp Center +0x200 Background" . COLOR_AMBER, "+").OnEvent("Click", (*) => AdjustVol(+5))

    ; --- POSITIONING & RENDER ---
    volGui.Show("x0 y78 w116 NoActivate")                              ; Displays volume widget along left screen edge without capturing window focus
}

; ==============================================================================
; VOLUME CONTROL EVENT HANDLERS & OS AUDIO HOOKS
; ==============================================================================
OnSliderChange(ctrl, *) {
    newVol := ctrl.Value                                               ; Captures target slider position value
    SoundSetVolume(newVol)                                             ; Updates native Windows OS audio volume level
    
    if (SoundGetMute()) {                                              ; If system is currently muted, dragging slider auto-unmutes audio
        SoundSetMute(0)                                                ; Clears native OS mute state
        UpdateMuteUI(false)                                            ; Re-renders volume widget interface to active state
    } else {
        volGui["VolText"].Value := "VOL: " . newVol . "%"              ; Updates text readout control with current percentage
    }
}

AdjustVol(delta) {
    current := SoundGetVolume()                                        ; Queries active OS audio volume level
    target := Clamp(Round(current + delta), 0, 100)                     ; Calculates step adjustment and clamps result within 0-100 bounds
    SoundSetVolume(target)                                             ; Writes clamped volume level to OS audio endpoint
    volGui["VolSlider"].Value := target                                ; Syncs slider control position to updated volume value
    
    if (SoundGetMute()) {                                              ; If system is currently muted, pressing +/- auto-unmutes audio
        SoundSetMute(0)                                                ; Clears native OS mute state
        UpdateMuteUI(false)                                            ; Re-renders volume widget interface to active state
    } else {
        volGui["VolText"].Value := "VOL: " . target . "%"              ; Updates text readout control with adjusted percentage
    }
}

ToggleMute(*) {
    SoundSetMute(-1)                                                   ; Flips native Windows OS mute state
    realState := SoundGetMute() ? true : false                         ; Queries OS endpoint to verify real-time mute status
    UpdateMuteUI(realState)                                            ; Updates widget color scheme and text labels based on verified state
}

UpdateMuteUI(muted) {
    volTxt := volGui["VolText"]                                        ; References volume text readout control handle
    btnMuteCtrl := volGui["BtnMute"]                                   ; References mute button control handle
    
    if (muted) {
        btnMuteCtrl.Opt("+Background" . COLOR_RED)                      ; Shifts mute button background to critical alert red
        btnMuteCtrl.Value := "UNMUTE"                                  ; Updates button label to prompt unmute action
        
        volTxt.SetFont("c" . COLOR_RED)                                ; Shifts status text font color to alert red
        volTxt.Value := "VOL: MUTED"                                   ; Writes muted state string to status readout
    } else {
        btnMuteCtrl.Opt("+Background" . COLOR_LAV)                      ; Restores mute button background to standard lavender
        btnMuteCtrl.Value := "MUTE"                                    ; Updates button label to prompt mute action
        
        volTxt.SetFont("c" . COLOR_AMBER)                              ; Restores status text font color to Operations Yellow
        volTxt.Value := "VOL: " . Round(SoundGetVolume()) . "%"        ; Writes numeric volume percentage to status readout
    }
    
    WinRedraw(volGui.Hwnd)                                             ; Issues forced redraw refresh to clear rendering artifacts
}

; ==============================================================================
; UTILITY: VALUE CLAMPING ALGORITHM
; ==============================================================================
Clamp(val, low, high) {
    return Max(low, Min(val, high))                                    ; Restricts numeric input value to fall strictly within specified bounds
}

; ==============================================================================
; DYNAMIC SHORTCUT TOP MENU ENGINE
; ==============================================================================
InitializeShortcutMenu() {
    global ShortcutMenuGui, GlobalBoxWidth, GlobalBoxHeight, GlobalPadding, TopMenuCols
    
    ; Defines base baseline dimensions and pixel spacing for shortcut pill buttons
    BaseWidth   := 125
    BaseHeight  := 33
    BasePadding := 1

    ; Scales box metrics dynamically based on active display resolution relative to 1080p
    GlobalBoxWidth  := Round(BaseWidth * ScaleMultiplier)
    GlobalBoxHeight := Round(BaseHeight * ScaleMultiplier)
    GlobalPadding   := Round(BasePadding * ScaleMultiplier)

    ; Instantiates non-activating, frameless tool window overlay maintaining topmost layer status
    ShortcutMenuGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08000000")
    ShortcutMenuGui.BackColor := COLOR_BACKGROUND                         ; Applies pure black canvas background
    ShortcutMenuGui.SetFont("s" . MenuFontSize . " norm", "Impact")       ; Applies baseline Impact typography for menu controls

    ; Defines horizontal/vertical origins and overall height spanning 3 fixed button rows
    TopMenu_X := ActiveWinX
    TopMenu_Y := 0                               
    TopMenu_H := (GlobalBoxHeight * 3) + (GlobalPadding * 2) 

    ; Calculates available grid rendering width by subtracting viewport origin and stats panel reservation
    StatsReservation := Round(510 * ScaleMultiplier) 
    TopMenu_W := (ScreenWidth - ActiveWinX) - StatsReservation  

    ; Dynamically calculates maximum allowable column count based on available horizontal pixel width
    TopMenuCols := Floor((TopMenu_W + GlobalPadding) / (GlobalBoxWidth + GlobalPadding))

    ; --- GRID GENERATION & INI SHORTCUT DESERIALIZATION ---
    Loop TopMenuRows {
        currentRow := A_Index
        Loop TopMenuCols {
            currentCol := A_Index
            slotKey := "Slot_" . currentRow . "_" . currentCol           ; Generates unique cell identifier key (e.g., Slot_1_1)
            
            ; Calculates relative pixel placement coordinates within the shortcut grid GUI
            boxX := (currentCol - 1) * (GlobalBoxWidth + GlobalPadding)
            boxY := (currentRow - 1) * (GlobalBoxHeight + GlobalPadding)
            
            ; Reads saved label, target launch path, and accent color settings from INI configuration file
            btnName  := IniRead(IniFilePath, "Shortcuts", slotKey . "_Name", "")
            btnPath  := IniRead(IniFilePath, "Shortcuts", slotKey . "_Path", "")
            btnColor := IniRead(IniFilePath, "Shortcuts", slotKey . "_Color", COLOR_STEEL_BLUE)

            ; Instantiates picture control placeholder to house rendered bitmap pill button
            boxCtrl := ShortcutMenuGui.Add("Pic", "x" . boxX . " y" . boxY . " w" . GlobalBoxWidth . " h" . GlobalBoxHeight . " +0x0100", "")

            ; Binds unique key namespace property directly to control object for click/drag event tracking
            boxCtrl.Key := slotKey

            SetButtonTextAndFont(boxCtrl, btnName)                        ; Renders bitmap text/color onto pill control
            BoxControls[slotKey] := boxCtrl                              ; Caches control object handle in global BoxControls map
        }
    }

    ; Displays shortcut grid menu GUI overlay without capturing window focus and enforces topmost Z-order status
    ShortcutMenuGui.Show("x" . TopMenu_X . " y" . TopMenu_Y . " w" . TopMenu_W . " h" . TopMenu_H . " NoActivate")
    WinSetAlwaysOnTop(1, "ahk_id " . ShortcutMenuGui.Hwnd)
}

; ==============================================================================
; AUXILIARY THREE-DOT MENU ENGINE
; ==============================================================================
InitializeAuxMenu() {
    global AuxMenuGui
    
    ; Instantiates non-activating, frameless tool window overlay maintaining topmost layer status
    AuxMenuGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08000000")
    MaskColor := COLOR_BACKGROUND 
    AuxMenuGui.BackColor := MaskColor                                   ; Applies solid background color mask

    ; Calculates scaled diameter dimensions and pad spacing for vector indicator dots
    DotSize := Round(24 * ScaleMultiplier)
    AuxPad  := Round(12 * ScaleMultiplier)
    TotalW  := (DotSize * 3) + (AuxPad * 2)                             ; Computes total bounding width for three-dot array

    ; --- 1. RED DOT (KILL SWITCH / EXIT APP) ---
    AuxMenuGui.AddText("x0 y0 w" . DotSize . " h" . DotSize . " +BackgroundTrans +0x0100").Key := "SYS_KILL"

    ; --- 2. BLUE DOT (WINDOW VIEWPORT SNAPPER) ---
    AuxMenuGui.AddText("x" . (DotSize + AuxPad) . " y0 w" . DotSize . " h" . DotSize . " +BackgroundTrans +0x0100").Key := "SYS_SNAP"

    ; --- 3. GOLD DOT (DESKTOP ICON MATRIX REALIGNMENT) ---
    AuxMenuGui.AddText("x" . ((DotSize * 2) + (AuxPad * 2)) . " y0 w" . DotSize . " h" . DotSize . " +BackgroundTrans +0x0100").Key := "SYS_ICONS"

    ; Displays overlay window at blueprint coordinates without capturing OS window focus
    AuxMenuGui.Show("x15 y40 w" . (TotalW + 20) . " h" . (DotSize + 20) . " NoActivate")
    WinSetTransColor(MaskColor, AuxMenuGui)                             ; Applies transparency mask key to make empty panel areas click-through

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

    ; --- PAINT RED VECTOR DOT ---
    ColorRedARGB := 0xFFFF0000 
    DllCall("gdiplus.dll\GdipCreateSolidFill", "UInt", ColorRedARGB, "Ptr*", &pBrushRed:=0)
    DllCall("gdiplus.dll\GdipFillEllipse", "Ptr", pGraphics, "Ptr", pBrushRed, "Float", 0, "Float", 0, "Float", DotSize, "Float", DotSize)

    ; --- PAINT BLUE VECTOR DOT ---
    ColorBlueARGB := 0xFF0000FF 
    DllCall("gdiplus.dll\GdipCreateSolidFill", "UInt", ColorBlueARGB, "Ptr*", &pBrushBlue:=0)
    DllCall("gdiplus.dll\GdipFillEllipse", "Ptr", pGraphics, "Ptr", pBrushBlue, "Float", DotSize + AuxPad, "Float", 0, "Float", DotSize, "Float", DotSize)

    ; --- PAINT GOLD VECTOR DOT ---
    ColorGoldARGB := 0xFFFFAA00 
    DllCall("gdiplus.dll\GdipCreateSolidFill", "UInt", ColorGoldARGB, "Ptr*", &pBrushGold:=0)
    DllCall("gdiplus.dll\GdipFillEllipse", "Ptr", pGraphics, "Ptr", pBrushGold, "Float", (DotSize * 2) + (AuxPad * 2), "Float", 0, "Float", DotSize, "Float", DotSize)

    ; --- GDI+ CLEANUP ---
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
    
    ; Calculates horizontal placement based on screen width minus scaled telemetry reservation
    StatsReservation := Round(510 * ScaleMultiplier)
    StatsX := ScreenWidth - StatsReservation + Round(40 * ScaleMultiplier)
    StatsY := 0
    
    ; Instantiates non-activating, frameless tool window overlay maintaining topmost layer status
    StatsGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08000000")
    StatsGui.BackColor := COLOR_BACKGROUND                              ; Applies solid black canvas background
    
    ; --- TELEMETRY VALUE READOUT & ACCENT BAR ---
    StatsGui.SetFont("s24 norm", "Impact")                              ; Sets enlarged Impact typography for numeric telemetry readouts
    StatsReadout := StatsGui.AddText("w200 h35 c" . COLOR_OFF_WHITE, "") ; Instantiates primary telemetry text readout control
    
    ActiveColorBar := StatsGui.AddText("y+2 w200 h6 Background" . COLOR_RED, "") ; Instantiates 6px indicator bar showing mode accent color
    
    ; --- TELEMETRY MODE SELECTOR BUTTONS ---
    StatsGui.SetFont("s10", "Arial")                                    ; Reverts font scale for square selector button targets
    
    StatsGui.AddText("y+10 w15 h15 Background" . COLOR_RED . " +0x0100", "").Key := "STAT_CPU"   ; Binds STAT_CPU namespace key
    StatsGui.AddText("x+5 w15 h15 Background" . COLOR_BLUE . " +0x0100", "").Key := "STAT_RAM"  ; Binds STAT_RAM namespace key
    StatsGui.AddText("x+5 w15 h15 Background" . COLOR_GOLD . " +0x0100", "").Key := "STAT_NET"  ; Binds STAT_NET namespace key
    
    ; Iterates through system drive letters to generate interactive drive space monitors
    Loop Parse, DriveGetList() {
        StatsGui.AddText("x+5 w15 h15 Background" . COLOR_MUTED_GREEN . " +0x0100", "").Key := "STAT_DRIVE_" . A_LoopField ; Binds dynamic STAT_DRIVE_X namespace key
    }
    
    ; --- REFRESH LOOP ---
    UpdateStats()                                                       ; Performs immediate WMI telemetry evaluation and UI render
    StatsGui.Show("x" . StatsX . " y" . StatsY . " NoActivate")         ; Displays telemetry panel GUI without capturing window focus
    SetTimer(UpdateStats, 3000)                                         ; Registers 3000ms asynchronous polling cycle to sample system metrics
}

; ==============================================================================
; UTILITY: CANVAS Z-ORDER MANAGEMENT
; ==============================================================================
SendInterfaceToBottom() {
    if (MainGuiHwnd) {
        ; Issues user32 SetWindowPos DllCall (HWND_BOTTOM = 1) to push canvas underneath active application windows
        DllCall("SetWindowPos", "ptr", MainGuiHwnd, "ptr", 1, "int", 0, "int", 0, "int", 0, "int", 0, "uint", 0x0013)
    }
}

; ==============================================================================
; ACTIVE APPLICATION TRACKER (VIEWPORT FOCUS HOOK)
; ==============================================================================
~LButton::TrackActiveApp()                                              ; Low-level pass-through mouse click hook caching active application handles

TrackActiveApp() {
    global LastActiveAppHWND
    currentActive := WinExist("A")                                      ; Queries native OS handle for currently active window
    
    ; Ignores internal LCARS interface windows and system desktop workers to avoid losing active viewport target
    if (currentActive && currentActive != MainGuiHwnd && currentActive != AuxMenuGui && currentActive != ShortcutMenuGui.Hwnd && (!StatsGui || currentActive != StatsGui.Hwnd) && (!ClockGui || currentActive != ClockGui.Hwnd) && (!volGui || currentActive != volGui.Hwnd) && (!LCARS_DockGui || currentActive != LCARS_DockGui.Hwnd)) {
        try {
            winClass := WinGetClass("ahk_id " . currentActive)          ; Queries window class name
            if (winClass != "Shell_TrayWnd" && winClass != "Progman" && winClass != "WorkerW") {
                LastActiveAppHWND := currentActive                     ; Caches active window HWND for viewport snapper recalibration
            }
        }
    }
}

; ==============================================================================
; GLOBAL MOUSE EVENT INTERCEPTORS (INPUT MESSAGE POOL)
; ==============================================================================
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    global SourceBoxCtrl, DragStartX, DragStartY, CurrentSelection, SelectedDrive
    clickedCtrl := GuiCtrlFromHwnd(hwnd)                                ; Resolves target GUI control handle from click screen coordinates
    
    if (clickedCtrl && clickedCtrl.HasProp("Key")) {
        ; --- 1. HANDLE TELEMETRY SELECTORS (STAT_* Namespace) ---
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
            ActiveColorBar.Opt("Background" . barColor)                 ; Shifts telemetry bar accent color
            ActiveColorBar.Redraw()
            UpdateStats()                                              ; Triggers immediate WMI value refresh
            return 0
        }

        ; --- 2. HANDLE VECTOR COMMAND BUTTONS (SYS_* Namespace) ---
        if (clickedCtrl.Key == "SYS_KILL") {
            ExitApp()                                                  ; Triggers global script termination
            return 0  
        }
        if (clickedCtrl.Key == "SYS_SNAP") {
            ForceViewportRecalibration()                               ; Recalibrates target window boundaries to active viewport
            return 0  
        }
        if (clickedCtrl.Key == "SYS_ICONS") {
            AlignDesktopIcons()                                        ; Re-aligns desktop matrix icons adjacent to sidebar
            return 0
        }
        
        ; --- 3. SETUP DRAG-AND-DROP INTERCEPTION FOR SHORTCUT GRID ---
        SourceBoxCtrl := clickedCtrl                                   ; Caches origin control object for move evaluation
        CoordMode("Mouse", "Screen")
        MouseGetPos(&DragStartX, &DragStartY)                          ; Stores mouse origin coordinates to detect drag gestures
    }
}

WM_LBUTTONUP(wParam, lParam, msg, hwnd) {
    global SourceBoxCtrl, DragStartX, DragStartY
    
    if (!SourceBoxCtrl)
        return
        
    CoordMode("Mouse", "Screen")
    MouseGetPos(&currentX, &currentY)
    moveThreshold := 8                                                 ; Defines pixel displacement threshold distinguishing clicks from drags
    
    srcCtrl := SourceBoxCtrl
    SourceBoxCtrl := ""                                                ; Clears source box control buffer
    
    isClickGesture := (Abs(currentX - DragStartX) < moveThreshold && Abs(currentY - DragStartY) < moveThreshold)
    
    ; Execute application launch if movement stayed within click threshold
    if (isClickGesture) {
        ExecuteShortcutLaunch(srcCtrl)
        return
    }
    
    ; Resolve target box control handle under release point
    releasedHwnd := DllCall("user32.dll\WindowFromPoint", "Int64", GetMousePosInt64(), "Ptr")
    targetCtrl := GuiCtrlFromHwnd(releasedHwnd)
    
    if (!targetCtrl || !targetCtrl.HasProp("Key"))
        return
        
    ; Swap/move shortcut data if dropped onto a different valid grid slot
    if (srcCtrl.Key != targetCtrl.Key) {
        MoveShortcutData(srcCtrl, targetCtrl)
        return
    }
}
    
WM_RBUTTONUP(wParam, lParam, msg, hwnd) {
    clickedCtrl := GuiCtrlFromHwnd(hwnd)
    if (clickedCtrl && clickedCtrl.HasProp("Key")) {
        if (SubStr(clickedCtrl.Key, 1, 5) == "Slot_") {
            ; --- CTRL + RIGHT CLICK = DELETE SHORTCUT ---
            if GetKeyState("Control", "P") {
                DeleteShortcutData(clickedCtrl)
                return 0
            }
            
            ; --- ALT + RIGHT CLICK = CYCLE COLOR PALETTE ---
            if GetKeyState("Alt", "P") {
                CycleBoxColor(clickedCtrl)
                return 0
            }
            
            ; Suppress plain right-click to prevent accidental execution
            return 0
        }
    }
}

GetMousePosInt64() {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    return (my << 32) | (mx & 0xFFFFFFFF)                              ; Packs 32-bit mouse coordinates into 64-bit integer for WindowFromPoint
}

; ==============================================================================
; SHORTCUT GRID OPERATIONS & INI SERIALIZATION
; ==============================================================================
SetButtonTextAndFont(ctrlObj, text) {
    currentColor := IniRead(IniFilePath, "Shortcuts", ctrlObj.Key . "_Color", COLOR_BACKGROUND)
    currentTextColor := IniRead(IniFilePath, "Shortcuts", ctrlObj.Key . "_TextColor", COLOR_BACKGROUND)
    
    ; Default empty slots to pure black canvas color
    if (text == "" && IniRead(IniFilePath, "Shortcuts", ctrlObj.Key . "_Path", "") == "") {
        currentColor := COLOR_BACKGROUND
        currentTextColor := COLOR_BACKGROUND
    }
    
    ctrlObj.Opt("+Background" . COLOR_BACKGROUND)
    hBmp := CreatePillBitmap(currentColor, text, currentTextColor)      ; Generates dynamic GDI+ 32-bit bitmap pill
    ctrlObj.Value := "HBITMAP:" . hBmp
}

ExecuteShortcutLaunch(ctrlObj) {
    currentPath := IniRead(IniFilePath, "Shortcuts", ctrlObj.Key . "_Path", "")
    
    ; Prompt for new shortcut configuration if target slot is empty
    if (currentPath == "") {
        nameBox := InputBox("Enter LCARS button display label:", "LCARS Terminal - New Shortcut")
        if (nameBox.Result != "OK" || nameBox.Value == "")
            return
        pathBox := InputBox("Enter target application path, folder directory, or URL address:", "LCARS Terminal - Target Link")
        if (pathBox.Result != "OK" || pathBox.Value == "")
            return
            
        IniWrite(nameBox.Value,    IniFilePath, "Shortcuts", ctrlObj.Key . "_Name")
        IniWrite(pathBox.Value,    IniFilePath, "Shortcuts", ctrlObj.Key . "_Path")
        IniWrite(COLOR_GOLD,       IniFilePath, "Shortcuts", ctrlObj.Key . "_Color")
        IniWrite(COLOR_BACKGROUND, IniFilePath, "Shortcuts", ctrlObj.Key . "_TextColor") ; Defaults to solid black text

        SetButtonTextAndFont(ctrlObj, nameBox.Value)
    } 
    else {
        try {
            Run(currentPath, , "Max")                                  ; Launches target executable maximized
        } catch {
            MsgBox("System Error: Unable to launch target execution path.", "LCARS Command Failure", "Iconx")
        }
    }
}

MoveShortcutData(srcCtrl, targetCtrl) {
    srcName  := IniRead(IniFilePath, "Shortcuts", srcCtrl.Key . "_Name", "")
    srcPath  := IniRead(IniFilePath, "Shortcuts", srcCtrl.Key . "_Path", "")
    srcColor := IniRead(IniFilePath, "Shortcuts", srcCtrl.Key . "_Color", COLOR_GOLD)
    srcTxt   := IniRead(IniFilePath, "Shortcuts", srcCtrl.Key . "_TextColor", COLOR_BACKGROUND)
   
    targetPath := IniRead(IniFilePath, "Shortcuts", targetCtrl.Key . "_Path", "")
    if (targetPath != "") {
        MsgBox("Target cell is already occupied. Rearrangement aborted.", "LCARS Buffer Conflict", "Iconi")
        return
    }
    
    if (srcPath == "")
        return
        
    ; Write shortcut properties to new INI target slot
    IniWrite(srcName,  IniFilePath, "Shortcuts", targetCtrl.Key . "_Name")
    IniWrite(srcPath,  IniFilePath, "Shortcuts", targetCtrl.Key . "_Path")
    IniWrite(srcColor, IniFilePath, "Shortcuts", targetCtrl.Key . "_Color")
    IniWrite(srcTxt,   IniFilePath, "Shortcuts", targetCtrl.Key . "_TextColor")
    
    ; Purge shortcut properties from old INI source slot
    IniDelete(IniFilePath, "Shortcuts", srcCtrl.Key . "_Name")
    IniDelete(IniFilePath, "Shortcuts", srcCtrl.Key . "_Path")
    IniDelete(IniFilePath, "Shortcuts", srcCtrl.Key . "_Color")
    IniDelete(IniFilePath, "Shortcuts", srcCtrl.Key . "_TextColor")
    
    ; Re-render both source and destination pill bitmaps
    SetButtonTextAndFont(targetCtrl, srcName)
    SetButtonTextAndFont(srcCtrl, "")
    targetCtrl.Redraw()
    
    srcCtrl.Opt("Background" . COLOR_BACKGROUND)
    srcCtrl.Redraw()
}

DeleteShortcutData(srcCtrl) {
    srcName := IniRead(IniFilePath, "Shortcuts", srcCtrl.Key . "_Name", "Unknown Shortcut")
    
    confirm := MsgBox("Are you sure you want to permanently delete the shortcut '" . srcName . "'?", "LCARS Terminal - Confirm Deletion", "YesNo Icon! Default2")
    if (confirm == "No") {
        return 
    }
    
    ; Purge shortcut properties from INI configuration file
    IniDelete(IniFilePath, "Shortcuts", srcCtrl.Key . "_Name")
    IniDelete(IniFilePath, "Shortcuts", srcCtrl.Key . "_Path")
    IniDelete(IniFilePath, "Shortcuts", srcCtrl.Key . "_Color")
    IniDelete(IniFilePath, "Shortcuts", srcCtrl.Key . "_TextColor")
    
    ; Clear control display and reset bitmap to empty background canvas
    SetButtonTextAndFont(srcCtrl, "")
    srcCtrl.Opt("Background" . COLOR_BACKGROUND)
    srcCtrl.Redraw()
}

CycleBoxColor(ctrlObj) {
    currentPath := IniRead(IniFilePath, "Shortcuts", ctrlObj.Key . "_Path", "")
    if (currentPath == "")
        return
        
    currentColor := IniRead(IniFilePath, "Shortcuts", ctrlObj.Key . "_Color", COLOR_GOLD)
    currentTextColor := IniRead(IniFilePath, "Shortcuts", ctrlObj.Key . "_TextColor", COLOR_BACKGROUND)
    
    colorPalette := [COLOR_GOLD, COLOR_ORANGE, COLOR_PEACH, COLOR_LILAC, COLOR_CORNFLOWER, COLOR_LIGHT_BLUE, COLOR_MUTED_GREEN]
    
    ; Construct complete 3-Tier State Combination Table
    states := []
    
    ; Tier 1: Colored Buttons + Black Text
    for col in colorPalette {
        states.Push({bg: col, txt: COLOR_BACKGROUND})
    }
    
    ; Tier 2: Colored Buttons + Off-White Text
    for col in colorPalette {
        states.Push({bg: col, txt: COLOR_OFF_WHITE})
    }
    
    ; Tier 3: Black Buttons + Colored Text
    for col in colorPalette {
        states.Push({bg: COLOR_BACKGROUND, txt: col})
    }
    states.Push({bg: COLOR_BACKGROUND, txt: COLOR_OFF_WHITE})
    
    ; Find current combination index
    currentIndex := 1
    for idx, state in states {
        if (state.bg == currentColor && state.txt == currentTextColor) {
            currentIndex := idx
            break
        }
    }
    
    ; Advance to next combination index (loops back to 1)
    nextIndex := (currentIndex >= states.Length) ? 1 : currentIndex + 1
    nextState := states[nextIndex]
    
    ; Write updated background and text color assignments to INI configuration file
    IniWrite(nextState.bg,  IniFilePath, "Shortcuts", ctrlObj.Key . "_Color")
    IniWrite(nextState.txt, IniFilePath, "Shortcuts", ctrlObj.Key . "_TextColor")
    
    ; Re-render pill control bitmap
    btnName := IniRead(IniFilePath, "Shortcuts", ctrlObj.Key . "_Name", "")
    SetButtonTextAndFont(ctrlObj, btnName)
}

; ==============================================================================
; SYSTEM ACTIONS & DESKTOP MANAGEMENT
; ==============================================================================
ForceViewportRecalibration() {
    global LastActiveAppHWND
    
    ; Acquire secondary valid window target if cached handle is invalid
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
    
    ; Restore target window and force viewport boundaries using user32 MoveWindow
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
    
    iconCount := SendMessage(0x1004, 0, 0, LV)                         ; Queries SysListView32 control for total desktop icon count
    
    startX := ActiveWinX + 20
    startY := ActiveWinY + 20
    spacingX := 80
    spacingY := 100
    
    curX := startX
    curY := startY
    
    ; Reposition desktop icons sequentially adjacent to sidebar workspace origin
    Loop iconCount {
        idx := A_Index - 1
        lParam := (curY << 16) | (curX & 0xFFFF)
        SendMessage(0x100F, idx, lParam, LV)                            ; Issues LVM_SETITEMPOSITION message
        
        curY += spacingY
        if (curY > (ScreenHeight - spacingY - 40)) {
            curY := startY
            curX += spacingX
        }
    }
}
; ==============================================================================
; TELEMETRY SAMPLING ENGINE (PROTECTED WMI REFRESH)
; ==============================================================================
UpdateStats(*) {
    global CurrentSelection, SelectedDrive, StatsReadout
    if (!StatsReadout)                                                 ; Aborts update if text readout handle is invalid
        return

    val := ""
    ; Evaluate active telemetry selection state and format readout string
    if (CurrentSelection == "CPU")
        val := LoadPercentage("CPU") . "% CPU"
    else if (CurrentSelection == "RAM")
        val := LoadPercentage("RAM") . "% RAM"
    else if (CurrentSelection == "NET")
        val := LoadPercentage("NET") . "% NET"
    else if (CurrentSelection == "DRIVE")
        val := SelectedDrive . ": " . Round(100 - (DriveGetSpaceFree(SelectedDrive . ":") / DriveGetCapacity(SelectedDrive . ":") * 100)) . "% USED"
    
    StatsReadout.Text := val                                           ; Updates telemetry readout control string
}

LoadPercentage(type) {
    ; Connects to local WMI service repository via SWbemLocator COM Object
    static objWMI := ComObject("WbemScripting.SWbemLocator").ConnectServer(".", "root\cimv2")
    
    ; --- 1. CPU LOAD SAMPLING ---
    if (type == "CPU") {
        try {
            items := objWMI.ExecQuery("Select LoadPercentage from Win32_Processor")._NewEnum
            while items(&item, &i)
                return item.LoadPercentage                            ; Returns processor utilization percentage
        } catch {
            return 0                                                   ; Safe fallback on WMI query failure
        }
    }
    
    ; --- 2. PHYSICAL RAM SAMPLING ---
    if (type == "RAM") {
        try {
            mem := Buffer(64, 0), NumPut("UInt", 64, mem, 0)
            DllCall("GlobalMemoryStatusEx", "Ptr", mem)                 ; Queries system memory status via user32 DllCall
            return NumGet(mem, 4, "UInt")                              ; Extracts dwMemoryLoad percentage value
        } catch {
            return 0                                                   ; Safe fallback on API failure
        }
    }
    
    ; --- 3. NETWORK BANDWIDTH SAMPLING ---
    if (type == "NET") {
        try {
            items := objWMI.ExecQuery("Select BytesTotalPerSec from Win32_PerfFormattedData_Tcpip_NetworkInterface")._NewEnum
            totalNet := 0
            while items(&item, &i) {
                totalNet += item.BytesTotalPerSec                     ; Aggregates total throughput across active network adapters
            }
            
            maxCapacity := 12500000                                    ; Baseline threshold (100Mbps baseline estimate in bytes/sec)
            percent := Round((totalNet / maxCapacity) * 100)
            return Min(100, percent)                                   ; Clamps throughput utilization percentage to 100% max
        } catch {
            return 0                                                   ; Safe fallback on WMI performance counter failure
        }
    }
    return 0
}

; ==============================================================================
; WINDOW MANAGER & VIEWPORT SNAP ENGINE
; ==============================================================================
ShellEvent(wParam, lParam, *) {
    ; Monitors shell hook events: HSHELL_WINDOWCREATED (1), HSHELL_WINDOWDESTROYED (2), 
    ; HSHELL_ACTIVATESHELLWINDOW (4), or HSHELL_RUDEAPPACTIVATED (32772)
    if (wParam = 1 || wParam = 2 || wParam = 4 || wParam = 32772) {
        SetTimer(RefreshTaskbarDock, -1)                               ; Triggers asynchronous sidebar dock re-indexing cycle
        Sleep(100) 
        EnforceBoundaries()                                            ; Forces active window viewport snap evaluation
        SendInterfaceToBottom()                                        ; Re-asserts canvas layer HWND_BOTTOM placement
    }
}

WatchdogCheck() {
    EnforceBoundaries()                                                ; Evaluates active window boundaries every 500ms
    if (AuxMenuGui) {
        try {
            WinSetAlwaysOnTop(1, "ahk_id " . AuxMenuGui.Hwnd)          ; Maintains vector three-dot overlay topmost layer status
        }
    }
}

EnforceBoundaries() {
    activeHWND := WinActive("A")                                       ; Queries active foreground application window handle
    if (!activeHWND)
        return
        
    try {
        winClass := WinGetClass("ahk_id " . activeHWND)                ; Retrieves active window class name
        winTitle := WinGetTitle("ahk_id " . activeHWND)                ; Retrieves active window title string
    } catch {
        return 
    }
    
    ; Exclude system desktop components, core Windows shell frames, and internal LCARS GUI overlays
    if (winClass = "Shell_TrayWnd" || winClass = "Progman" || winClass = "WorkerW" 
        || winClass = "AutoHotkeyGUI" || winClass = "Windows.UI.Core.CoreWindow" 
        || winClass = "XamlExplorerHostIslandWindow" || InStr(winTitle, "Snipping Tool")
        || winTitle = "LCARS_Sidebar" || winTitle = "LCARS_TopMenu" || winTitle = "LCARS_SystemStats") {
        return
    }
    
    try {
        minMaxState := WinGetMinMax("ahk_id " . activeHWND)            ; Queries target window maximize/minimize state
    } catch {
        return
    }
	
    ; Intercept maximized windows (1) and force snap into target LCARS workspace viewport boundaries
    if (minMaxState = 1) {
        WinRestore("ahk_id " . activeHWND)                             ; Restores window to normal state to strip OS border locks
        ; Issues MoveWindow DllCall to position active viewport flush against LCARS header and sidebar borders
        DllCall("user32.dll\MoveWindow", "Ptr", activeHWND, "Int", ActiveWinX - Round(20 * ScaleMultiplier), "Int", ActiveWinY - Round(3 * ScaleMultiplier), "Int", ActiveWinW + Round(20 * ScaleMultiplier), "Int", ActiveWinH + Round(10 * ScaleMultiplier), "Int", 1)
    }
}

EnforceLayers() {
    try {
        ; Enforces HWND_TOPMOST Z-order status across interactive foreground overlays every 500ms
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
; DYNAMIC BITMAP GENERATORS
; ==============================================================================
StrUpper(String) {
    return Format("{:U}", String)                                      ; Helper function converting input string to uppercase
}

CreateSolidBitmap(HexColor) {
    ; Extracts individual RGB color byte components from input hexadecimal string
    R := "0x" SubStr(HexColor, 1, 2)
    G := "0x" SubStr(HexColor, 3, 2)
    B := "0x" SubStr(HexColor, 5, 2)
    
    ; Populates BITMAPINFOHEADER structure buffer (40 bytes header + metrics)
    Bmi := Buffer(44, 0)
    NumPut("UInt", 40, Bmi, 0)                                         ; biSize = 40 bytes
    NumPut("Int", 1, Bmi, 4)                                           ; biWidth = 1 pixel
    NumPut("Int", 1, Bmi, 8)                                           ; biHeight = 1 pixel
    NumPut("UShort", 1, Bmi, 12)                                       ; biPlanes = 1
    NumPut("UShort", 32, Bmi, 14)                                      ; biBitCount = 32-bit color depth
    
    pBits := 0
    ; Creates a device-independent bitmap (DIB) that applications can write to directly
    hBmd := DllCall("CreateDIBSection", "Ptr", 0, "Ptr", Bmi, "UInt", 0, "PtrP", &pBits, "Ptr", 0, "UInt", 0, "Ptr")
    NumPut("UInt", (R << 16) | (G << 8) | B, pBits, 0)                 ; Writes packed RGB pixel bytes to memory pointer
    return hBmd                                                        ; Returns bitmap handle
}

; ==============================================================================
; DYNAMIC GDI+ PILL BITMAP GENERATOR (125x33 CONSTANT GRID)
; ==============================================================================
CreatePillBitmap(HexColor, TextStr := "", TextColorHex := "000000") {
    w := 125                                                           ; Defines fixed pill canvas width in pixels
    h := 33                                                            ; Defines fixed pill canvas height in pixels

    ; --- 1. CONVERT HEX COLORS TO ARGB ---
    bgCol   := "0xFF" . HexColor                                       ; Appends full opacity alpha channel (0xFF) to background hex
    textCol := "0xFF" . TextColorHex                                   ; Appends full opacity alpha channel (0xFF) to text hex

    ; --- 2. CREATE DEVICE CONTEXTS & 32-BIT DIB SECTION ---
    hdcScreen := DllCall("GetDC", "Ptr", 0, "Ptr")                     ; Captures primary display screen device context
    hdcMem    := DllCall("CreateCompatibleDC", "Ptr", hdcScreen, "Ptr") ; Instantiates in-memory memory device context (DC)
    
    bi := Buffer(40, 0)
    NumPut("UInt", 40, "Int", w, "Int", -h, "UShort", 1, "UShort", 32, bi, 0) ; Configures 32-bit top-down DIB header
    hBitmap := DllCall("CreateDIBSection", "Ptr", hdcScreen, "Ptr", bi, "UInt", 0, "Ptr*", &pBits:=0, "Ptr", 0, "UInt", 0, "Ptr")
    hOldBmp := DllCall("SelectObject", "Ptr", hdcMem, "Ptr", hBitmap, "Ptr") ; Binds DIB section bitmap to memory DC

    ; --- 3. INITIALIZE GDI+ CANVAS WITH ANTIALIASING ---
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdcMem, "Ptr*", &pGraphics:=0) ; Instantiates GDI+ graphics engine bound to memory DC
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", pGraphics, "Int", 4)       ; Sets anti-aliased geometry rendering mode
    DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", pGraphics, "Int", 4)   ; Sets AntiAliasGridFit text rendering hint

    ; --- 4. DRAW PILL GEOMETRY (FULL ARC END-CAPS) ---
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &pPath:=0)     ; Instantiates new GDI+ graphics path object
    DllCall("gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", 0, "Float", 0, "Float", h, "Float", h, "Float", 90, "Float", 180) ; Left rounded semi-circle cap
    DllCall("gdiplus\GdipAddPathArc", "Ptr", pPath, "Float", w - h, "Float", 0, "Float", h, "Float", h, "Float", 270, "Float", 180) ; Right rounded semi-circle cap
    DllCall("gdiplus\GdipClosePathFigure", "Ptr", pPath)               ; Closes path figure to establish solid enclosed region

    ; --- 5. FILL BACKGROUND PATH ---
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", bgCol, "Ptr*", &pBrushBg:=0) ; Creates solid ARGB background brush
    DllCall("gdiplus\GdipFillPath", "Ptr", pGraphics, "Ptr", pBrushBg, "Ptr", pPath) ; Fills pill path geometry with active accent color

    ; --- 6. RENDER CENTERED IMPACT TEXT ---
    if (TextStr != "") {
        DllCall("gdiplus\GdipCreateStringFormat", "Int", 0, "UShort", 0, "Ptr*", &pFormat:=0)
        DllCall("gdiplus\GdipSetStringFormatAlign", "Ptr", pFormat, "Int", 1)     ; Horizontal text alignment: Center
        DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", pFormat, "Int", 1) ; Vertical text alignment: Center

        DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Impact", "Ptr", 0, "Ptr*", &pFamily:=0) ; Instantiates Impact font family
        
        ; Auto-scale font size down slightly if label string exceeds 10 characters to prevent clipping
        fontSize := (StrLen(TextStr) > 10) ? 16 : 20
        DllCall("gdiplus\GdipCreateFont", "Ptr", pFamily, "Float", fontSize, "Int", 0, "Int", 2, "Ptr*", &pFont:=0) ; Instantiates GDI+ font object

        rect := Buffer(16, 0)
        NumPut("Float", 0, "Float", 1.5, "Float", w, "Float", h, rect) ; Bounding rectangle offset for text rasterization

        DllCall("gdiplus\GdipCreateSolidFill", "UInt", textCol, "Ptr*", &pBrushText:=0) ; Creates solid ARGB text brush
        DllCall("gdiplus\GdipDrawString", "Ptr", pGraphics, "WStr", TextStr, "Int", -1, "Ptr", pFont, "Ptr", rect, "Ptr", pFormat, "Ptr", pBrushText) ; Rasterizes string onto bitmap

        ; Release text rendering resources
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", pBrushText)
        DllCall("gdiplus\GdipDeleteFont", "Ptr", pFont)
        DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", pFamily)
        DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", pFormat)
    }

    ; --- 7. CLEAN UP GDI+ HANDLES & RETURN BITMAP ---
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", pBrushBg)
    DllCall("gdiplus\GdipDeletePath", "Ptr", pPath)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", pGraphics)
    DllCall("SelectObject", "Ptr", hdcMem, "Ptr", hOldBmp)
    DllCall("DeleteDC", "Ptr", hdcMem)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdcScreen)

    return hBitmap                                                     ; Returns completed GDI+ 32-bit pill bitmap handle
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

; 10. SHORTCUT BUTTON COLOR CYCLING & DELETION
;    * Modifiers: To avoid accidental layout modifications:
;      - Ctrl + Right-Click: Triggers DeleteShortcutData() with a confirmation prompt.
;      - Alt + Right-Click: Cycles through the three-tier color palette via CycleBoxColor().
;      - Standard Right-Click: Ignored.

; 11. DYNAMIC GDI+ PILL TEXT SCALING
;    * Vector Rasterization: Shortcut pill labels are rendered dynamically as 32-bit GDI+ bitmaps 
;      inside CreatePillBitmap(), bypassing standard AHK GUI control font declarations (e.g., MenuFontSize).
;    * Threshold Scaling: Font sizes are controlled inside CreatePillBitmap() by evaluating label length:
;      - Short Labels (<=10 chars): Defaults to 20pt Impact font.
;      - Long Labels (>10 chars): Auto-scales down to 16pt Impact font to prevent end-cap clipping.
;    * Custom Adjustments: Adjust these point values directly inside CreatePillBitmap() when tweaking 
;      pill typography or string overflow constraints.

; 12. LOCAL CONTROL HANDLE PRUNING & INLINE BINDING
;    * Control Assignment Pattern: Controls in AuxMenuGui, StatsGui, and volGui do NOT 
;      store local variable handles (e.g. CpuBtn, KillSwitchBtn) during instantiation.
;    * Namespace Chaining: Instead, properties and event bindings are chained directly 
;      onto the instantiation call (e.g., Gui.AddText(...).Key := "SYS_KILL"). 
;    * Dynamic Lookups: Sub-routines reference controls dynamically via GUI indexing 
;      (e.g., volGui["VolText"]) or WM message interceptors checking clickedCtrl.Key.

; 13. COLOR PALETTE EXPANSION RESERVATION
;    * Structural Color Definitions: The global color palette contains extended LCARS hex 
;      definitions (e.g., COLOR_SCIENCE_TEAL, COLOR_BURGUNDY, COLOR_EGGPLANT) that are 
;      intentionally retained for future sub-panel and widget design expansions.

; 14. INI SHORTCUT KEY MAP PRESERVATION
;    * Grid Control Properties: Shortcut grid controls rely strictly on boxCtrl.Key 
;      (e.g., "Slot_1_1") for INI serialization. Do NOT attach redundant .Row or .Col 
;      properties inside InitializeShortcutMenu(), as all matrix placement and drag-and-drop 
;      actions use the explicit Key namespace.
; ==========================================================================================
