; rich presence lib made by slymi

SetDiscordStatus(details, state) {
    static APP_ID := "1441752672876105899"
    static IMAGE_KEY := "bssai"
    static Pipe := -1
    
    ; 1. Connect if not connected
    if (Pipe == -1) {
        Loop 10 {
            pipeName := "\\.\pipe\discord-ipc-" . (A_Index - 1)
            Pipe := DllCall("CreateFile", "Str", pipeName, "UInt", 0xC0000000, "UInt", 0, "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0, "Ptr")
            if (Pipe != -1)
                break
        }
        if (Pipe == -1) ; Failed to find open pipe
            return 
            
        ; Handshake
        payload := '{"v": 1, "client_id": "' . APP_ID . '"}'
        SendPacket(Pipe, 0, payload)
        ReadPacket(Pipe) ; Clear the "Ready" response
    }

    ; 2. Update Presence
    PID := ProcessExist()
    
    ; Escape special characters for JSON
    Esc(str) {
        str := StrReplace(str, "\", "\\")
        str := StrReplace(str, '"', '\"')
        str := StrReplace(str, "`n", "\n")
        return StrReplace(str, "`r", "")
    }

    global MacroStartTime
    timestampJson := ""
    if (IsSet(MacroStartTime) && MacroStartTime > 0) {
        timestampJson := ',"timestamps":{"start":' . MacroStartTime . '}'
    }

    activity := '{"details":"' . Esc(details) . '","state":"' . Esc(state) . '","type":0,"assets":{"large_image":"' . IMAGE_KEY . '","large_text":"AHK v2"}' . timestampJson . '}'
    payload  := '{"cmd":"SET_ACTIVITY","args":{"pid":' . PID . ',"activity":' . activity . '},"nonce":"' . A_TickCount . '"}'
    
    if !SendPacket(Pipe, 1, payload) {
        ; If sending fails, reset pipe to force reconnect next time
        if (Pipe != -1)
            DllCall("CloseHandle", "Ptr", Pipe)
        Pipe := -1
    }
}

SendPacket(hPipe, opcode, json) {
    bufSize := StrPut(json, "UTF-8")
    header := Buffer(8)
    NumPut("UInt", opcode, header, 0)
    NumPut("UInt", bufSize - 1, header, 4)
    
    if !DllCall("WriteFile", "Ptr", hPipe, "Ptr", header, "UInt", 8, "Ptr*", 0, "Ptr", 0)
        return false
        
    payloadBuf := Buffer(bufSize)
    StrPut(json, payloadBuf, "UTF-8")
    return DllCall("WriteFile", "Ptr", hPipe, "Ptr", payloadBuf, "UInt", bufSize - 1, "Ptr*", 0, "Ptr", 0)
}

ReadPacket(hPipe) {
    header := Buffer(8), bytesRead := 0
    if DllCall("ReadFile", "Ptr", hPipe, "Ptr", header, "UInt", 8, "UInt*", &bytesRead, "Ptr", 0) {
        len := NumGet(header, 4, "UInt")
        if (len > 0) {
            payload := Buffer(len + 1)
            DllCall("ReadFile", "Ptr", hPipe, "Ptr", payload, "UInt", len, "UInt*", &bytesRead, "Ptr", 0)
        }
    }
}
