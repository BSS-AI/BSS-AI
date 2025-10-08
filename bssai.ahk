;@Ahk2Exe-SetName BSS-AI Macro
;@Ahk2Exe-SetDescription Property Of discord.gg/bssai
;@Ahk2Exe-SetVersion 0.0.1
;@Ahk2Exe-SetCopyright Copyright © 2025 BSS-AI
;@Ahk2Exe-SetCompanyName BSS-AI
;@Ahk2Exe-SetProductName BSS-AI Macro
;@Ahk2Exe-SetOrigFilename BSSAI.exe
#MaxThreads 255

global MacroState := 0
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
global currentWalk := { pid: "", name: "" }

#Include %A_ScriptDir%\lib\Variables.ahk
InitilizeVariables()

SendMode "Event"

#Include %A_ScriptDir%\lib\resources\Gdip_All.ahk
#Include %A_ScriptDir%\lib\resources\Gdip_ImageSearch.ahk
global pToken := Gdip_Startup()

#Include %A_ScriptDir%\lib\socket.ahk
#Include %A_ScriptDir%\lib\resources\AttachmentBuilder.ahk
#Include %A_ScriptDir%\lib\resources\DISCORD.ahk
#Include %A_ScriptDir%\lib\resources\EmbedBuilder.ahk
#Include %A_ScriptDir%\lib\resources\FormData.ahk
#Include %A_ScriptDir%\lib\resources\ImagePut.ahk
#Include %A_ScriptDir%\lib\resources\JSON.ahk
#Include %A_ScriptDir%\lib\resources\JSONN.ahk
#Include %A_ScriptDir%\lib\resources\OCR.ahk
#Include %A_ScriptDir%\lib\resources\RapidOcr.ahk
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

#Include %A_ScriptDir%\Patterns\Patterns.ahk
#Include %A_ScriptDir%\Assets\bitmaps.ahk

SetKeyDelay Integer(readSettings("Settings", "keydelay"))
global COMMUNICATION_METHOD := readSettings("AIGather", "communication_method")

global currentFieldIndex := 1
global CurrentField := gatherField%currentFieldIndex%

; --- Debug & Path Settings ---
global EnableLogging := readSettings("Debug", "enable_logging")
global SharedFilePath := readSettings("Debug", "shared_file_path")
global ConnectionTimeout := readSettings("Debug", "connection_timeout")

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
        FileAppend(logEntry, A_ScriptDir "\ahk_log.txt")
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
            config_check := readSettings("Communication", "python_clsid")
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
            default:
                OutputDebug("Unknown COM command: " . command)
                return false
        }
    }
}

; ObjRegisterActive implementation (exact copy from demonstration)
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
            portStr := readSettings("Communication", "python_port")
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
        if err {
            OutputDebug("Socket OnRead error: " . err)
            return
        }
        data := sock.RecvText()
        if !data
            return

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

        commands := StrSplit(data, "`n", "`r")
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

Start()

;global exe_path32 := A_AhkPath
;global exe_path64 := (A_Is64bitOS && FileExist("lib\AutoHotkey64.exe")) ? (A_WorkingDir "\lib\AutoHotkey64.exe") : A_AhkPath

Start() {
    LogMessage("--- Macro Start() function called ---")
    LogMessage("Cleaning up old communication data from settings.ini")

    try {
        writeSettings("Communication", "python_port", "", , false)
        writeSettings("Communication", "python_clsid", "", , false)
        LogMessage("Deleted old communication data from settings.ini")
    }

    try {
        sharedPath := GetSharedPath()
        LogMessage("Cleaning up old communication files from: " . sharedPath)

        gatherStateFile := sharedPath . "\gather_state.txt"
        if FileExist(gatherStateFile) {
            FileDelete(gatherStateFile)
            LogMessage("Deleted old gather state file.")
        }

        resetPosFile := sharedPath . "\reset_position.txt"
        if FileExist(resetPosFile) {
            FileDelete(resetPosFile)
            LogMessage("Deleted old reset position file.")
        }
    }
    MsgBox "YOLO.exe (AI Program) takes ~10 seconds to load. The macro will not start until YOLO.exe is done loading.`n`nPress OK to start loading!", "Attention", 0x40
    installPath := FileRead("C:\ProgramData\BSSAI\.install-location.txt", "UTF-8")
    writeSettings("Debug", "shared_file_path", installPath)
    SetStatus("Startup", "BSS AI")
    yoloPid := Run('"' . installPath . '\lib\yolo.exe" ' . COMMUNICATION_METHOD, , "Hide")
    if (COMMUNICATION_METHOD = "COM") {
        InitializeCOMServer()
    } else {
        SocketClient := SocketHandler()
    }

    SetStatus("Startup", "BSS AI")
    MacroState := 1
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
    } else {
        Run("taskkill /F /IM yolo.exe /T", , "Hide")
    }
    Gdip_Shutdown(pToken)
    StopMovement()
    Sleep(1000)
    if WinExist("BSS AI")
        WinActivate("BSS AI")
    Sleep(500)
    if (close == 1) {
        ExitApp()
    }
}

BSSAI() {
    global Actions := [action1, action2, action3, action4, action5]
    global GatherFields, currentFieldIndex
    for ActionName in Actions {
        if (ActionName == "Testing") {
            SetStatus("Starting", "Testing")
            gt_pinetree()
            Sleep(1000)
            wf_pinetree()
            Move(1.5, "s") ;walk backwards to avoid thicker hives
            Move(35, "d") ;walk to ramp
            Move(2.7, "s") ;center with hive pads
            findHiveSlot()
        }
        if (ActionName == "Gather") {
            if (GatherFields.Length > 0) {
                SetStatus("Starting", "Gather")
                ResetToHive()
                GotoFieldFromHive()
                SetupField()
                GatherCode()
                GotoHiveFromField()
                currentFieldIndex := currentFieldIndex + 1
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
            }
        }
    }
}

F1:: Start()
F2:: PauseUnpause()
F3:: Stop(1)