global GatherFields := []
if (gatherField1 != "None") {
    GatherFields.Push(gatherField1)
}
if (gatherField2 != "None") {
    GatherFields.Push(gatherField2)
}
if (gatherField3 != "None") {
    GatherFields.Push(gatherField3)
}
global bitmaps
path := A_AppData "\BSSAI\lib"

GotoFieldFromHive() {
    global GatherFields, currentFieldIndex, keyDelay

    if (currentFieldIndex > GatherFields.Length) {
        currentFieldIndex := 1
    }

    region := windowX "|" windowY + 3 * windowHeight // 4 "|" windowWidth "|" windowHeight // 4
    sconf := windowWidth ** 2 // 3200
    sleep 250 + keyDelay
    fieldName := GatherFields[currentFieldIndex]
    functionName := "gt_" . fieldName
    switch StrLower(fieldName) {
        case "pine tree": gt_pinetree()
        case "blue flower": gt_blueflower()
        case "mountain top": gt_mountaintop()
        default: %functionName%()
    }
}

GotoHiveFromField() {
    if (toHiveByMethod%currentFieldIndex% = "Walk") {
        global GatherFields, currentFieldIndex
        fieldName := GatherFields[currentFieldIndex]
        functionName := "wf_" . fieldName
        rotates := rotateAmmount%currentFieldIndex%
        rotated := rotate%currentFieldIndex%
        if (rotated = "left") {
            Rotate("right", rotates)
        } else if (rotated = "right") {
            Rotate("left", rotates)
        }
        switch StrLower(fieldName) {
            case "pine tree": wf_pinetree()
            case "blue flower": wf_blueflower()
            case "mountain top": wf_mountaintop()
            default: %functionName%()
        }
        Move(1.5, "s") ;walk backwards to avoid thicker hives
        Move(35, "d") ;walk to ramp
        Move(2.7, "s") ;center with hive pads
        findHiveSlot()
    } else {
        ResetToHive()
    }
}

GatherCode() {
    global aiGather1, aiGather2, aiGather3, gatherField1, gatherField1InvertFB, gatherField1InvertLR, gatherField1SprinklerDistance, gatherField1SprinklerLocation, gatherField2, gatherField2InvertFB, gatherField2InvertLR, gatherField2SprinklerDistance, gatherField2SprinklerLocation, gatherField3, gatherField3InvertFB, gatherField3InvertLR, gatherField3SprinklerDistance, gatherField3SprinklerLocation, gatherTime1, gatherTime2, gatherTime3, keyDelay
    global InField := true

    Loop 11 {
        send "{" RotUp " down}"
        Sleep(10 + keyDelay)
        send "{" RotUp " up}"
        Sleep(10 + keyDelay)
    }
    Loop 3 {
        send "{" RotDown " down}"
        Sleep(10 + keyDelay)
        send "{" RotDown " up}"
        Sleep(10 + keyDelay)
    } ;Consistent camera angle, maybe make it a function? or ai gather only

    if (rotate%currentFieldIndex% != "None") {
        rotates := rotateAmmount%currentFieldIndex%
        rotated := rotate%currentFieldIndex%
        if (rotated = "left") {
            Rotate("left", rotates)
        } else if (rotated = "right") {
            Rotate("right", rotates)
        }
    }

    UseSlots("Gather Start")
    SetStatus("Gathering", gatherField%currentFieldIndex% "`nLimit: " gatherTime%currentFieldIndex% " minutes")
    SetTimer(UseGatherSlots, 1000)

    MouseMove(A_ScreenWidth / 2, A_ScreenHeight / 2)
    if toolEnabled = true
        MouseClick("left", , , , , "down")

    if aiGather%currentFieldIndex% = false {
        startTime := A_TickCount
        loop {
            MoveToSaturator()
            RunPattern()
            if BackpackPercent() = true {
                if (UseSlots("Microconverter")) {
                    continue
                } else {
                    break ; bag full
                }
            }

            if (A_TickCount - startTime > gatherTime%currentFieldIndex% * 60000) ; if gather time passed
            {
                break
            }

            DisconnectCheck()
            if (allowGatherInterrupt) {
                interrupt := 0
                for bossName in bosses {
                    if (StrLower(bossName) && (nowUnix() - Last%bossName% >= floor(bosses[bossName] * (1 - (mobRespawnTime ? mobRespawnTime : 0) * 0.01)))) {
                        interrupt++
                    }
                }
                for mobName in mobs {
                    if (StrLower(mobName) && (nowUnix() - Last%mobName% >= floor(mobs[mobName] * (1 - (mobRespawnTime ? mobRespawnTime : 0) * 0.01)))) {
                        interrupt++
                    }
                }
                if (interrupt > 1) {
                    SetStatus("Interrupt", "Gathering interrupted by a mob or boss")
                    Sleep(1000)
                    GotoHiveFromField()
                    return
                }
            }
        }
    } else if aiGather%currentFieldIndex% = true {
        startTime := A_TickCount

        sharedPath := GetSharedPath()

        stateFile := sharedPath . "\gather_state.txt"
        try {
            LogMessage("AI Gather: Creating gather state file at " . stateFile)
            FileAppend("", stateFile)
        } catch Error as e {
            LogMessage("AI Gather ERROR: Could not create state file. " . e.Message)
        }

        interruptReason := "Time Limit"
        loop {
            DisconnectCheck()
            if (BackpackPercent()) {
                if (UseSlots("Microconverter")) {
                    continue
                } else {
                    interruptReason := "Bag Limit"
                    break ; bag full
                }
            }

            if (A_TickCount - startTime > gatherTime%currentFieldIndex% * 60000) {
                interruptReason := "Time Limit"
                break  ; gather time passed
            }

            Sleep(100)
        }

        SetStatus("Gathering", "Ended`nTime " gatherTime%currentFieldIndex% " - " interruptReason " - Return: " toHiveByMethod%currentFieldIndex%)


        ; Delete gather state file to signal python to stop inferencing
        try {
            LogMessage("AI Gather: Deleting gather state file from " . stateFile)
            FileDelete(stateFile)
        } catch {
            LogMessage("AI Gather ERROR: Could not delete state file.")
        }
    }


    if toolEnabled = true
        MouseClick("left", , , , , "up")

    SetTimer(UseGatherSlots, 0)
    UseSlots("Whirligig")
    global InField := false
}

SetupField() {
    field := StrLower(gatherField%currentFieldIndex%)
    location := gatherField%currentFieldIndex%SprinklerLocation
    distance := gatherField%currentFieldIndex%SprinklerDistance
    SetSprinkler(field, location, distance)
}

SetSprinkler(field, loc, dist) {
    global FwdKey, LeftKey, BackKey, RightKey, SC_1, SC_Space, keyDelay, MoveSpeedNum
    global SprinklerType := SprinklerType

    if (SprinklerType = "None")
        return

    ;field dimensions
    switch field, 0
    {
        case "sunflower":
            flen := 1250 * dist / 10
            fwid := 2000 * dist / 10

        case "dandelion":
            flen := 2500 * dist / 10
            fwid := 1000 * dist / 10

        case "mushroom":
            flen := 1250 * dist / 10
            fwid := 1750 * dist / 10

        case "blue flower":
            flen := 2750 * dist / 10
            fwid := 750 * dist / 10

        case "clover":
            flen := 2000 * dist / 10
            fwid := 1500 * dist / 10

        case "spider":
            flen := 2000 * dist / 10
            fwid := 2000 * dist / 10

        case "strawberry":
            flen := 1500 * dist / 10
            fwid := 2000 * dist / 10

        case "bamboo":
            flen := 3000 * dist / 10
            fwid := 1250 * dist / 10

        case "pineapple":
            flen := 1750 * dist / 10
            fwid := 3000 * dist / 10

        case "stump":
            flen := 1500 * dist / 10
            fwid := 1500 * dist / 10

        case "cactus", "pumpkin":
            flen := 1500 * dist / 10
            fwid := 2500 * dist / 10

        case "pine tree":
            flen := 2500 * dist / 10
            fwid := 1750 * dist / 10

        case "rose":
            flen := 2500 * dist / 10
            fwid := 1500 * dist / 10

        case "mountain top":
            flen := 2250 * dist / 10
            fwid := 1500 * dist / 10

        case "pepper", "coconut":
            flen := 1500 * dist / 10
            fwid := 2250 * dist / 10
    }

    MoveSpeedFactor := round(18 / moveSpeed, 2)

    ;move to start position
    if (InStr(loc, "Upper")) {
        MoveD(flen * MoveSpeedFactor, FwdKey)
    } else if (InStr(loc, "Lower")) {
        MoveD(flen * MoveSpeedFactor, BackKey)
    }
    if (InStr(loc, "Left")) {
        MoveD(fwid * MoveSpeedFactor, LeftKey)
    } else if (InStr(loc, "Right")) {
        MoveD(fwid * MoveSpeedFactor, RightKey)
    }
    if (loc = "center")
        Sleep 1000
    ;set sprinkler(s)
    if (SprinklerType = "Supreme" || SprinklerType = "Basic") {
        Send "{" SC_1 "}"
        return
    } else {
        JumpSprinkler()
    }
    if (SprinklerType = "Silver" || SprinklerType = "Golden" || SprinklerType = "Diamond") {
        if (InStr(loc, "Upper")) {
            MoveD(1000 * MoveSpeedFactor, BackKey)
        } else {
            MoveD(1000 * MoveSpeedFactor, FwdKey)
        }
        DllCall("Sleep", "UInt", 500)
        JumpSprinkler()
    }
    if (SprinklerType = "Silver") {
        if (InStr(loc, "Upper")) {
            MoveD(1000 * MoveSpeedFactor, FwdKey)
        } else {
            MoveD(1000 * MoveSpeedFactor, BackKey)
        }
    }
    if (SprinklerType = "Golden" || SprinklerType = "Diamond") {
        if (InStr(loc, "Left")) {
            MoveD(1000 * MoveSpeedFactor, RightKey)
        } else {
            MoveD(1000 * MoveSpeedFactor, LeftKey)
        }
        DllCall("Sleep", "UInt", 500)
        JumpSprinkler()
    }
    if (SprinklerType = "Golden") {
        if (InStr(loc, "Upper")) {
            if (InStr(loc, "Left")) {
                MoveD(1400 * MoveSpeedFactor, FwdKey, LeftKey)
            } else {
                MoveD(1400 * MoveSpeedFactor, FwdKey, RightKey)
            }
        } else {
            if (InStr(loc, "Left")) {
                MoveD(1400 * MoveSpeedFactor, BackKey, LeftKey)
            } else {
                MoveD(1400 * MoveSpeedFactor, BackKey, RightKey)
            }
        }
    }
    if (SprinklerType = "Diamond") {
        if (InStr(loc, "Upper")) {
            MoveD(1000 * MoveSpeedFactor, FwdKey)
        } else {
            MoveD(1000 * MoveSpeedFactor, BackKey)
        }
        DllCall("Sleep", "UInt", 500)
        JumpSprinkler()
        if (InStr(loc, "Left")) {
            MoveD(1000 * MoveSpeedFactor, LeftKey)
        } else {
            MoveD(1000 * MoveSpeedFactor, RightKey)
        }
    }
}
JumpSprinkler() {
    static JumpDelay := 200

    GetRobloxClientPos()
    success := 0
    Loop 3 {
        Send "{" SC_Space " down}"
        Sleep JumpDelay
        Send "{" SC_1 "}{" SC_Space " up}"
        Sleep 500
        pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth - 356 "|" windowY + windowHeight - 326 "|340|300")
        if (Gdip_ImageSearch(pBMScreen, bitmaps["standing"], , , , , , 20) = 1) { ; jumped too high
            JumpDelay := Max(JumpDelay - 50, 100)
        } else if (Gdip_ImageSearch(pBMScreen, bitmaps["thisclose"], , , , , , 20) = 1) { ; not high enough
            JumpDelay := Min(JumpDelay + 50, 500)
        } else {
            success := 1
        }
        Gdip_DisposeImage(pBMScreen)
        Sleep 600 - JumpDelay
        if (success = 1)
            break
    }

    return success
}

; backpack
BackpackPercent(rtn := 0) {
    global maxFillBag1, maxFillBag2, maxFillBag3
    static LastBackpackPercent := ""
    ;WinGetPos , windowX, windowY, windowWidth, windowHeight, Roblox
    ;UpperLeft X1 = windowWidth/2+59
    ;UpperLeft Y1 = 3
    ;LowerRight X2 = windowWidth/2+59+220
    ;LowerRight Y2 = 3+5
    ;Bar = 220 pixels wide = 11 pixels per 5%
    backpackColor := PixelGetColor(windowX + windowWidth // 2 + 59 + 3, windowY + offsetY + 6)
    BackpackPercent := 0

    if ((backpackColor & 0xFF0000 <= 0x690000)) { ;less or equal to 50%
        if (backpackColor & 0xFF0000 <= 0x4B0000) { ;less or equal to 25%
            if (backpackColor & 0xFF0000 <= 0x420000) { ;less or equal to 10%
                if ((backpackColor & 0xFF0000 <= 0x410000) && (backpackColor & 0x00FFFF <= 0x00FF80) && (backpackColor &
                    0x00FFFF > 0x00FF86)) { ;less or equal to 5%
                    BackpackPercent := 0
                } else if ((backpackColor & 0xFF0000 > 0x410000) && (backpackColor & 0x00FFFF <= 0x00FF80) && (
                    backpackColor & 0x00FFFF > 0x00FC85)) { ;greater than 5%
                    BackpackPercent := 5
                } else {
                    BackpackPercent := 0
                }
            } else { ;greater than 10%
                if ((backpackColor & 0xFF0000 <= 0x470000)) { ;less or equal to 20%
                    if ((backpackColor & 0xFF0000 <= 0x440000) && (backpackColor & 0x00FFFF <= 0x00FE85) && (
                        backpackColor & 0x00FFFF > 0x00F984)) { ;less or equal to 15%
                        BackpackPercent := 10
                    } else if ((backpackColor & 0xFF0000 > 0x440000) && (backpackColor & 0x00FFFF <= 0x00FB84) && (
                        backpackColor & 0x00FFFF > 0x00F582)) { ;greater than 15%
                        BackpackPercent := 15
                    } else {
                        BackpackPercent := 0
                    }
                } else if ((backpackColor & 0xFF0000 > 0x470000) && (backpackColor & 0x00FFFF <= 0x00F782) && (
                    backpackColor & 0x00FFFF > 0x00F080)) { ;greater than 20%
                    BackpackPercent := 20
                } else {
                    BackpackPercent := 0
                }
            }
        } else { ;greater than 25%
            if (backpackColor & 0xFF0000 <= 0x5B0000) { ;less or equal to 40%
                if ((backpackColor & 0xFF0000 <= 0x4F0000) && (backpackColor & 0x00FFFF <= 0x00F280) && (backpackColor &
                    0x00FFFF > 0x00EA7D)) { ;less or equal to 30%
                    BackpackPercent := 25
                } else { ;greater than 30%
                    if ((backpackColor & 0xFF0000 <= 0x550000) && (backpackColor & 0x00FFFF <= 0x00EC7D) && (
                        backpackColor & 0x00FFFF > 0x00E37A)) { ;less or equal to 35%
                        BackpackPercent := 30
                    } else if ((backpackColor & 0xFF0000 > 0x550000) && (backpackColor & 0x00FFFF <= 0x00E57A) && (
                        backpackColor & 0x00FFFF > 0x00DA76)) { ;greater than 35%
                        BackpackPercent := 35
                    } else {
                        BackpackPercent := 0
                    }
                }
            } else { ;greater than 40%
                if ((backpackColor & 0xFF0000 <= 0x620000) && (backpackColor & 0x00FFFF <= 0x00DC76) && (backpackColor &
                    0x00FFFF > 0x00D072)) { ;less or equal to 45%
                    BackpackPercent := 40
                } else if ((backpackColor & 0xFF0000 > 0x620000) && (backpackColor & 0x00FFFF <= 0x00D272) && (
                    backpackColor & 0x00FFFF > 0x00C66D)) { ;greater than 45%
                    BackpackPercent := 45
                } else {
                    BackpackPercent := 0
                }
            }
        }
    } else { ;greater than 50%
        if (backpackColor & 0xFF0000 <= 0x9C0000) { ;less or equal to 75%
            if (backpackColor & 0xFF0000 <= 0x850000) { ;less or equal to 65%
                if (backpackColor & 0xFF0000 <= 0x7B0000) { ;less or equal to 60%
                    if ((backpackColor & 0xFF0000 <= 0x720000) && (backpackColor & 0x00FFFF <= 0x00C86D) && (
                        backpackColor & 0x00FFFF > 0x00BA68)) { ;less or equal to 55%
                        BackpackPercent := 50
                    } else if ((backpackColor & 0xFF0000 > 0x720000) && (backpackColor & 0x00FFFF <= 0x00BC68) && (
                        backpackColor & 0x00FFFF > 0x00AD62)) { ;greater than 55%
                        BackpackPercent := 55
                    } else {
                        BackpackPercent := 0
                    }
                } else if ((backpackColor & 0xFF0000 > 0x7B0000) && (backpackColor & 0x00FFFF <= 0x00AF62) && (
                    backpackColor & 0x00FFFF > 0x009E5C)) { ;greater than 60%
                    BackpackPercent := 60
                } else {
                    BackpackPercent := 0
                }
            } else { ;greater than 65%
                if ((backpackColor & 0xFF0000 <= 0x900000) && (backpackColor & 0x00FFFF <= 0x00A05C) && (backpackColor &
                    0x00FFFF > 0x008F55)) { ;less or equal to 70%
                    BackpackPercent := 65
                } else if ((backpackColor & 0xFF0000 > 0x900000) && (backpackColor & 0x00FFFF <= 0x009155) && (
                    backpackColor & 0x00FFFF > 0x007E4E)) { ;greater than 70%
                    BackpackPercent := 70
                } else {
                    BackpackPercent := 0
                }
            }
        } else { ;greater than 75%
            if ((backpackColor & 0xFF0000 <= 0xC40000)) { ;less or equal to 90%
                if ((backpackColor & 0xFF0000 <= 0xA90000) && (backpackColor & 0x00FFFF <= 0x00804E) && (backpackColor &
                    0x00FFFF > 0x006C46)) { ;less or equal to 80%
                    BackpackPercent := 75
                } else { ;greater than 80%
                    if ((backpackColor & 0xFF0000 <= 0xB60000) && (backpackColor & 0x00FFFF <= 0x006E46) && (
                        backpackColor & 0x00FFFF > 0x005A3F)) { ;less or equal to 85%
                        BackpackPercent := 80
                    } else if ((backpackColor & 0xFF0000 > 0xB60000) && (backpackColor & 0x00FFFF <= 0x005D3F) && (
                        backpackColor & 0x00FFFF > 0x004637)) { ;greater than 85%
                        BackpackPercent := 85
                    } else {
                        BackpackPercent := 0
                    }
                }
            } else { ;greater than 90%
                if ((backpackColor & 0xFF0000 <= 0xD30000) && (backpackColor & 0x00FFFF <= 0x004A37) && (backpackColor &
                    0x00FFFF > 0x00322E)) { ;less or equal to 95%
                    BackpackPercent := 90
                } else { ;greater than 95%
                    if ((backpackColor = 0xF70017) || ((backpackColor & 0xFF0000 >= 0xE00000) && (backpackColor &
                        0x00FFFF <= 0x002427) && (backpackColor & 0x00FFFF > 0x001000))) { ;is equal to 100%
                        BackpackPercent := 100
                    } else if ((backpackColor & 0x00FFFF <= 0x00342E)) {
                        BackpackPercent := 95
                    } else {
                        BackpackPercent := 0
                    }
                }
            }
        }
    }
    if ((BackpackPercent != LastBackpackPercent) && rtn == 1) {
        LastBackpackPercent := BackpackPercent
        return BackpackPercent
    }
    ;Return BackpackPercent
    if BackpackPercent > maxFillBag%currentFieldIndex% {
        return true ; bag full
    } else {
        return false
    }
}

RunPattern() {
    FacingFieldCorner := 0
    if ((gatherField%currentFieldIndex% = "pine tree" && ((gatherField%currentFieldIndex%SprinklerLocation = "upper" || gatherField%currentFieldIndex%SprinklerLocation = "upper left") && rotate%currentFieldIndex% = "left" && rotateAmmount%currentFieldIndex% = 1)) || ((gatherField%currentFieldIndex% = "pineapple" && (gatherField%currentFieldIndex%SprinklerLocation = "upper left" && rotate%currentFieldIndex% = "left" && rotateAmmount%currentFieldIndex% = 1))) || (gatherField%currentFieldIndex% = "spider" && ((gatherField%currentFieldIndex%SprinklerLocation = "upper" || gatherField%currentFieldIndex%SprinklerLocation = "upper left") && rotate1%currentFieldIndex% = "left" && rotateAmmount%currentFieldIndex% = 1))) {
        FacingFieldCorner := 1
    }
    pattern := patternField%currentFieldIndex%
    patternsize := patternField%currentFieldIndex%Length
    size := (patternsize = "XS") ? 0.25
        : (patternsize = "S") ? 0.5
        : (patternsize = "L") ? 1.5
        : (patternsize = "XL") ? 2
        : 1 ; medium (default)
    reps := patternField%currentFieldIndex%Width
    %pattern%(size, reps, FacingFieldCorner)
}