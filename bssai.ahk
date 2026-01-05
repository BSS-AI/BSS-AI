;@Ahk2Exe-SetName BSS-AI Macro
;@Ahk2Exe-SetDescription Property Of discord.gg/bssai
;@Ahk2Exe-SetVersion 0.0.2
;@Ahk2Exe-SetCopyright Copyright © 2025 BSS-AI
;@Ahk2Exe-SetCompanyName BSS-AI
;@Ahk2Exe-SetProductName BSS-AI Macro
;@Ahk2Exe-SetOrigFilename BSSAI.exe
#MaxThreads 255

global beesmas := true

global MacroState := 0
global MacroStartTime := 0
global ShiftLockEnabled := 0
global TCFBKey := FwdKey := w := "sc011" ; w
global TCLRKey := LeftKey := a := "sc01e" ; a
global AFCFBKey := BackKey := s := "sc01f" ; s
global AFCLRKey := RightKey := d := "sc020" ; d
global RotLeft := "sc033" ; ,
global RotRight := "sc034" ; .
global RotUp := "sc149" ; PgUp
global RotDown := "sc151" ; PgDn
global ZoomIn := "sc017" ; i
global ZoomOut := "sc018" ; o
global SC_E := E := "sc012" ; e
global SC_R := "sc013" ; r
global SC_L := "sc026" ; l
global SC_Esc := "sc001" ; Esc
global SC_Enter := "sc01c" ; Enter
global SC_LShift := "sc02a" ; LShift
global SC_Space := "sc039" ; Space
global AnotherJumpTime := 300
global Jumptime := 1200
global SC_1 := "sc002"
global youDied := 0
global yoloPid := 0
global VicDetectionResult := ""
global VicDetectionReady := false
; --- Communication Method Selection ---
global beesmas := true
global COMMUNICATION_METHOD := IniRead(A_ScriptDir . "\Settings\settings.ini", "AIGather", "communication_method", "COM")

global currentWalk := { pid: "", name: "" }

#Include %A_ScriptDir%\lib\Variables.ahk
InitilizeVariables()

SendMode "Event"
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"

#Include %A_ScriptDir%\lib\resources\Gdip_All.ahk
#Include %A_ScriptDir%\lib\resources\Gdip_ImageSearch.ahk
global pToken := Gdip_Startup()

#Include %A_ScriptDir%\lib\socket.ahk
#Include %A_ScriptDir%\lib\resources\AttachmentBuilder.ahk
#Include %A_ScriptDir%\lib\resources\DISCORD.ahk
#Include %A_ScriptDir%\lib\resources\discord_rich.ahk
#Include %A_ScriptDir%\lib\resources\EmbedBuilder.ahk
#Include %A_ScriptDir%\lib\resources\FormData.ahk
#Include %A_ScriptDir%\lib\resources\ImagePut.ahk
#Include %A_ScriptDir%\lib\resources\JSON.ahk
#Include %A_ScriptDir%\lib\resources\JSONN.ahk
#Include %A_ScriptDir%\lib\resources\OCR.ahk
#Include %A_ScriptDir%\lib\resources\Roblox.ahk
#Include %A_ScriptDir%\lib\resources\TakeScreenshot.ahk
#Include %A_ScriptDir%\lib\resources\CNG.ahk
#Include %A_ScriptDir%\lib\resources\DateParse.ahk

#Include %A_ScriptDir%\lib\Functions.ahk
#Include %A_ScriptDir%\lib\Paths.ahk
#Include %A_ScriptDir%\lib\Walk.ahk

#Include %A_ScriptDir%\Sections\Boost.ahk
#Include %A_ScriptDir%\Sections\Kill.ahk
#Include %A_ScriptDir%\Sections\Collect.ahk
#Include %A_ScriptDir%\Sections\Gather.ahk
#Include %A_ScriptDir%\Sections\Planter.ahk
#Include %A_ScriptDir%\Sections\Quest.ahk
#Include %A_ScriptDir%\Sections\Vichop.ahk

#Include %A_ScriptDir%\Patterns\Patterns.ahk
#Include %A_ScriptDir%\Assets\bitmaps.ahk

SetKeyDelay Integer(readSettings("Settings", "keydelay"))

global currentFieldIndex := 1
global CurrentField := gatherField%currentFieldIndex%

; --- Debug & Path Settings ---
global EnableLogging := IniRead(A_ScriptDir . "\Settings\settings.ini", "Debug", "enable_logging", true)
global SharedFilePath := IniRead(A_ScriptDir . "\Settings\settings.ini", "Debug", "shared_file_path", "DEFAULT")
global ConnectionTimeout := IniRead(A_ScriptDir . "\Settings\settings.ini", "Debug", "connection_timeout", 600)

GetSharedPath() {
    global SharedFilePath
    if (SharedFilePath = "DEFAULT" || SharedFilePath = "") {
        path := A_ScriptDir "\lib"
        LogMessage("Using DEFAULT shared file path: " . path)
        return path
    } else {
        if !DirExist(SharedFilePath) {
            LogMessage("WARNING: Custom shared path '" . SharedFilePath . "' does not exist. Falling back to DEFAULT.")
            path := A_ScriptDir "\lib"
            LogMessage("Using DEFAULT shared file path: " . path)
            return path
        }
        LogMessage("Using CUSTOM shared file path from INI: " . SharedFilePath)
        return SharedFilePath
    }
}

LogMessage(message) {
    global EnableLogging
    if (!EnableLogging) {
        return
    }
    try {
        logEntry := FormatTime(, "yyyy-MM-dd HH:mm:ss") . " - " . message . "`n"
        FileAppend(logEntry, A_ScriptDir "\lib\ahk_log.txt")
    } catch {
        ; Fail silently if logging fails
    }
}

; --- COM Server Implementation ---
global ComAPI := ""
global ComCLSID := ""

class ComApiHandler {
    static HandleMovement(direction1, distance1, direction2, distance2) {
        try {
            validDirections := ["w", "a", "s", "d"]
            if (!ComApiHandler.HasValue(validDirections, direction1) || !ComApiHandler.HasValue(validDirections, direction2)) {
                OutputDebug("Invalid directions: " . direction1 . ", " . direction2)
                return false
            }

            dist1 := Float(distance1)
            dist2 := Float(distance2)

            if (dist1 < 0 || dist2 < 0) {
                OutputDebug("Invalid distances: " . dist1 . ", " . dist2)
                return false
            }

            HasteMove(dist1, dist2, direction1, direction2)
            return true

        } catch Error as e {
            OutputDebug("Error executing COM command: " . e.Message)
            return false
        }
    }

    static HandleSaturator() {
        try {
            MoveToSaturator()
            return true
        } catch Error as e {
            OutputDebug("Error executing saturator command: " . e.Message)
            return false
        }
    }

    static HandleIdle() {
        ; Python found no tokens, just acknowledge
        return true
    }

    static HandleVicDetect(result := "") {
        ; Called BY Python with detection result
        global VicDetectionResult, VicDetectionReady
        if (result != "") {
            VicDetectionResult := result
            VicDetectionReady := true
            OutputDebug("VIC_DETECT result received: " . result)
        }
        return true
    }

    static HasValue(arr, value) {
        for item in arr {
            if (item = value) {
                return true
            }
        }
        return false
    }
}

InitializeCOMServer() {
    global ConnectionTimeout
    try {
        LogMessage("COM: Waiting for CLSID in settings.ini (Timeout: " . ConnectionTimeout . "s)")

        maxWait := ConnectionTimeout
        waited := 0

        while waited < maxWait {
            config_check := IniRead(A_ScriptDir . "\Settings\settings.ini", "Communication", "python_clsid", "")
            if (config_check != "") {
                global ComCLSID := config_check
                LogMessage("COM: Read CLSID " . ComCLSID . " from settings.ini")
                break
            }
            Sleep(1000)
            waited++
        }

        if (ComCLSID = "") {
            LogMessage("COM ERROR: CLSID not found in settings.ini after waiting " . waited . " seconds.")
            MsgBox("Python CLSID not found in settings.ini. AI Gather will not work.", "COM Error", 0x1030)
            ExitApp()
        }

        global ComAPI := ComApiClass()
        ObjRegisterActive(ComAPI, ComCLSID)

        SetStatus("Python COM", "Registered with CLSID " . ComCLSID)

    } catch Error as e {
        MsgBox("Failed to initialize COM server: " . e.Message, "COM Error", 0x1030)
        ExitApp()
    }
}

class ComApiClass {
    HandleCommand(command, param1 := "", param2 := "", param3 := "", param4 := "") {
        switch command {
            case "MOVEMENT":
                return ComApiHandler.HandleMovement(param1, param2, param3, param4)
            case "SATURATOR":
                return ComApiHandler.HandleSaturator()
            case "IDLE":
                return ComApiHandler.HandleIdle()
            case "VIC_DETECT":
                return ComApiHandler.HandleVicDetect(param1)
            case "VIC_DETECT_REQUEST":
                ; AHK requesting detection - Python will handle and call back with VIC_DETECT
                return true
            default:
                OutputDebug("Unknown COM command: " . command)
                return false
        }
    }
}

; --- VIC Detection Helper Function ---
RequestVicDetection(timeout := 10000) {
    global VicDetectionResult, VicDetectionReady

    settingsIni := A_ScriptDir . "\\Settings\\settings.ini"

    ; Reset local state
    VicDetectionResult := ""
    VicDetectionReady := false

    ; Raise request flag (used by both COM and SOCKET paths)
    try {
        IniWrite("true", settingsIni, "Vichop", "vic_detect_request")
        LogMessage("RequestVicDetection: Set vic_detect_request flag")
    } catch Error as e {
        LogMessage("RequestVicDetection: ERROR setting flag - " . e.Message)
        return false
    }

    ; Wait for result with timeout - rely on live COM/Socket callbacks only
    startTime := A_TickCount
    LogMessage("RequestVicDetection: Waiting for VIC detection result via " . COMMUNICATION_METHOD)
    while (!VicDetectionReady && (A_TickCount - startTime < timeout)) {
        Sleep(50)
    }

    if (!VicDetectionReady) {
        LogMessage("RequestVicDetection: TIMEOUT after " . timeout . "ms")
        return false
    }

    result := (VicDetectionResult = "true")
    LogMessage("RequestVicDetection: Live callback received with result: " . VicDetectionResult)
    LogMessage("RequestVicDetection: Received result: " . (result ? "TRUE (Vicious Bee Found)" : "FALSE (No Vicious Bee)"))

    return result
}

; ObjRegisterActive implementation
ObjRegisterActive(obj, CLSID, Flags := 0) {
    static cookieJar := Map()
    if (!CLSID) {
        if (cookie := cookieJar.Remove(obj)) != ""
            DllCall("oleaut32\RevokeActiveObject", "uint", cookie, "ptr", 0)
        return
    }
    if cookieJar.Has(obj)
        throw Error("Object is already registered", -1)
    _clsid := Buffer(16, 0)
    if (hr := DllCall("ole32\CLSIDFromString", "wstr", CLSID, "ptr", _clsid)) < 0
        throw Error("Invalid CLSID", -1, CLSID)
    hr := DllCall("oleaut32\RegisterActiveObject", "ptr", ObjPtr(obj), "ptr", _clsid, "uint", Flags, "uint*", &cookie := 0, "uint")
    if hr < 0
        throw Error(format("Error 0x{:x}", hr), -1)
    cookieJar[obj] := cookie
}

; --- Socket Client Implementation ---
global SocketClient := ""
class SocketHandler {
    __New() {
        this.client := ""
        this.port := 0
        this.maxRetries := 600
        this.retryDelay := 1000
        this.WaitForPortInINI()
        this.ConnectToServer()
    }

    WaitForPortInINI() {
        global ConnectionTimeout
        maxWait := ConnectionTimeout
        waited := 0

        LogMessage("Socket: Waiting for port in settings.ini (Timeout: " . maxWait . "s)")

        while waited < maxWait {
            portStr := IniRead(A_ScriptDir . "\Settings\settings.ini", "Communication", "python_port", "")
            if (portStr != "") {
                this.port := Integer(portStr)
                LogMessage("Socket: Read port " . this.port . " from settings.ini")
                return
            }
            Sleep(1000)
            waited++
        }

        LogMessage("Socket ERROR: Port not found in settings.ini after waiting " . waited . " seconds.")
        MsgBox("Python socket port not found in settings.ini. AI Gather will not work.", "Socket Error", 0x1030)
        ExitApp()
    }

    ConnectToServer() {
        attempt := 1
        while attempt <= this.maxRetries {
            try {
                this.client := Socket.Client("127.0.0.1", this.port)
                this.client.OnRead := (sock, err) => this.OnRead(sock, err)
                this.client.OnClose := (sock, err) => this.OnClose(err)
                SetStatus("Python Socket", "Connected on port " . this.port)
                return
            } catch Error as e {
                Sleep(this.retryDelay)
                attempt++
            }
        }
        MsgBox("Failed to connect to Python socket after " . this.maxRetries . " attempts.", "Socket Error", 0x1030)
        ExitApp()
    }

    OnRead(sock, err) {
        global VicDetectionResult, VicDetectionReady
        if err {
            OutputDebug("Socket OnRead error: " . err)
            return
        }
        data := sock.RecvText()
        if !data
            return

        OutputDebug("Socket OnRead raw: [" . StrLen(data) . "] '" . data . "'")
        trimmed_data := Trim(data)

        if (trimmed_data = "w,0") {
            sock.SendText("READY")
            return
        }

        if (trimmed_data = "MOVE_TO_SATURATOR") {
            MoveToSaturator()
            sock.SendText("READY")
            return
        }

        ; Handle VIC detection result from Python robustly (may contain multiple lines)
        lines := StrSplit(data, "`n", "`r")
        for line in lines {
            l := Trim(line)
            if (l = "true" || l = "false") {
                VicDetectionResult := l
                VicDetectionReady := true
                OutputDebug("VIC detection result received via Socket: " . l)
                return
            }
        }

        commands := lines
        this.ExecutePythonMovement(commands)
    }

    OnClose(err) {
        SetStatus("Python Socket", "Disconnected")
        OutputDebug("Socket connection to Python closed. Error: " . err)
    }

    ExecutePythonMovement(commands) {
        try {
            parts1 := StrSplit(commands[1], ",")
            parts2 := StrSplit(commands[2], ",")

            if (parts1.Length != 2 || parts2.Length != 2) {
                OutputDebug("Invalid command parts: " . commands[1] . " | " . commands[2])
                this.client.SendText("READY")
                return false
            }

            direction1 := Trim(parts1[1])
            direction2 := Trim(parts2[1])

            validDirections := ["w", "a", "s", "d"]
            if (!this.HasValue(validDirections, direction1) || !this.HasValue(validDirections, direction2)) {
                OutputDebug("Invalid directions: " . direction1 . ", " . direction2)
                this.client.SendText("READY")
                return false
            }

            distance1 := Float(Trim(parts1[2]))
            distance2 := Float(Trim(parts2[2]))

            if (distance1 < 0 || distance2 < 0) {
                OutputDebug("Invalid distances: " . distance1 . ", " . distance2)
                this.client.SendText("READY")
                return false
            }

            HasteMove(distance1, distance2, direction1, direction2)
            this.client.SendText("READY")
            return true

        } catch Error as e {
            OutputDebug("Error executing python command: " . e.Message)
            this.client.SendText("READY")
            return false
        }
    }

    HasValue(arr, value) {
        for item in arr {
            if (item = value) {
                return true
            }
        }
        return false
    }
}
; --- End Socket Client Implementation ---

Start() {
    LogMessage("--- Macro Start() function called ---")
    LogMessage("Cleaning up old communication data from settings.ini")

    try {
        IniDelete(A_ScriptDir . "\Settings\settings.ini", "Communication", "python_port")
        IniDelete(A_ScriptDir . "\Settings\settings.ini", "Communication", "python_clsid")
        LogMessage("Deleted old communication data from settings.ini")
    }

    try {
        sharedPath := GetSharedPath()
        LogMessage("Cleaning up old communication files from: " . sharedPath)

        try {
            IniWrite("false", "settings/settings.ini", "AIGather", "currently_gathering")
            LogMessage("Reset gather state to 'false' in settings.ini")
        } catch Error as e {
            LogMessage("Warning: Failed to reset gather state in settings.ini - Error: " . e.Message)
        }

        resetPosFile := sharedPath . "\reset_position.txt"
        if FileExist(resetPosFile) {
            FileDelete(resetPosFile)
            LogMessage("Deleted old reset position file.")
        }
    }

    global pythonCheck
    global SocketClient
    global COMMUNICATION_METHOD
    global yoloPid

    yoloLogPath := A_ScriptDir . "\lib\yolo_log.txt"
    if !FileExist(yoloLogPath) {
        try {
            FileAppend("", yoloLogPath)
            LogMessage("Created yolo_log.txt file for Python script at " yoloLogPath)
        } catch Error as e {
            LogMessage("Warning: Failed to create yolo_log.txt at " yoloLogPath " Error: " . e.Message)
        }
    }

    yoloPid := Run("yolo.exe " . COMMUNICATION_METHOD, "lib")

    if (COMMUNICATION_METHOD = "COM") {
        InitializeCOMServer()
    } else {
        SocketClient := SocketHandler()
    }

    SetStatus("Startup", "BSS AI")
    MacroState := 1
    global MacroStartTime := nowUnix()  ; Set macro start time for Discord Rich Presence
    SetTimer(PressAlwaysSlots, 1000)
    global resetTime := nowUnix()
    SetTimer(DeathCheck, 1000)
    loop {
        DisconnectCheck()
        BSSAI()
    }
}

PauseUnpause() {
    if (A_IsPaused == 1) {
        Pause(0)
    } else {
        MacroState := 2
        StopMovement()
        Pause()
    }
}

Stop(close) {
    global SocketClient
    global ComAPI
    global ComCLSID
    global COMMUNICATION_METHOD
    global yoloPid

    SetStatus("End", "BSS AI")
    MacroState := 0
    global MacroStartTime := 0

    try {
        IniDelete(A_ScriptDir . "\Settings\settings.ini", "Communication", "python_port")
        IniDelete(A_ScriptDir . "\Settings\settings.ini", "Communication", "python_clsid")
        LogMessage("Cleaned up communication data from settings.ini on stop")
    }

    if (COMMUNICATION_METHOD = "COM") {
        try {
            if (IsObject(ComAPI) && ComCLSID != "") {
                ObjRegisterActive(ComAPI, "")
            }
        } catch {
        }
    } else {
        try {
            if (IsObject(SocketClient) && IsObject(SocketClient.client)) {
                SocketClient.client.Close()
            }
        } catch {
        }
    }

    if (yoloPid) {
        Run("taskkill /F /T /PID " . yoloPid, , "Hide")
        Run("taskkill /IM yolo.exe /F", , 'Hide')
    }
    Gdip_Shutdown(pToken)
    StopMovement()
    SetTimer(PressAlwaysSlots, 0)
    SetTimer(DeathCheck, 0)
    SetTimer(ScheduleCommandFetch, 0)
    SetTimer(ProcessCommandBuffer, 0)
    Sleep(1000)
    if WinExist("BSS AI")
        WinActivate("BSS AI")
    Sleep(500)
    if (close == 1) {
        ExitApp()
    } else {
        loop {
            Sleep 2000
            discord.GetCommands(MainChannelID)
            if (command_buffer.Length > 0)
            {
                command(command_buffer[1])
            }
        }
    }
}

BSSAI() {
    global Actions := [action1, action2, action3, action4, action5, action6]
    global GatherFields, currentFieldIndex, VichopExclusive

    for ActionName in Actions {
        if (ActionName == "Gather") {
            if (GatherFields.Length > 0) {
                SetStatus("Starting", "Gather")
                ResetToHive()
                GotoFieldFromHive()
                SetupField()
                GatherCode()
                GotoHiveFromField()
                currentFieldIndex := currentFieldIndex + 1 == 4 ? 1 : currentFieldIndex + 1
                CurrentField := gatherField%currentFieldIndex%
            }
        } else {
            switch ActionName {
                case "Kill":
                    if (CheckKill(true)) {
                        SetStatus("Starting", "Kill")
                        CheckKill(false)
                    }
                case "Planters":
                    if (planterOption == "Planters +") {
                        planter()
                    } else if (planterOption == "Manual") {
                        iniFile := "planters.ini"

                        if (cycle1Planter1 = "None"
                            && cycle2Planter1 = "None"
                            && cycle3Planter1 = "None") {
                            continue
                        }

                        for cycle in [1, 2, 3] {
                            if (!CycleActivated[cycle])
                                continue

                            planterCount := PlanterCountCycle%cycle%
                            lastCycleTime := readSettings("MPlanters", "lastcycletime" . cycle, , "settings\timers.ini")

                            if (lastCycleTime = 0)
                                Collectplanters()

                            planterTimeValue := readSettings("Planters", "cycle" cycle "time" planterCount + 1)
                            global planterTime := 60
                            switch planterTimeValue {
                                case "30 mins": planterTime := 30
                                case "1 hour": planterTime := 60
                                case "1h 30 mins": planterTime := 90
                                case "2 hour": planterTime := 120
                                case "2h 30 min": planterTime := 150
                                case "3 hour": planterTime := 180
                                case "3h 30 min": planterTime := 210
                                case "4 hour": planterTime := 240
                                case "4h 30 min": planterTime := 270
                                case "5 hour": planterTime := 300
                                case "5h 30 min": planterTime := 330
                                case "6 hour": planterTime := 360
                            }
                            if (nowUnix() - lastCycleTime > planterTime * 60)
                                Collectplanters()
                        }
                        continue
                    }
                case "Collect":
                    if (CheckCollect()) {
                        SetStatus("Starting", "Collect")
                        BeginCollect()
                    }
                case "Quest":
                    if (polar) {
                        SetStatus("Starting", "Quest")
                        DoPolarQuest()
                    }
                case "Vichop":
                    result := vichop()
                    if (result == "SKIP") {
                        continue ; vichop quota exhausted for this hour
                    }
                    if (result == "EXCLUSIVE_RESTART") {
                        break ; restart from priority 1
                    }
            }
        }
    }
}

Start()

F1:: Start()
F2:: PauseUnpause()
F3:: Stop(1)