global MoveMethod := readSettings("Settings", "movemethod", true)
global HiveSlot := readSettings("Settings", "hiveslot")
global HiveBees := readSettings("Settings", "hivebees")
global function
global bitmaps

Jump2(movements*) {
    DllCall("GetSystemTimeAsFileTime", "int64p", &jumped := 0)
    send "{SC_Space down}"
    Sleep 100
    send "{space up}"
    for params in movements
        Move(params*)
    DllCall("GetSystemTimeAsFileTime", "int64p", &current := 0)
    Sleep Max(1400 - (current - jumped) // 10000, -1)
}

gt_ramp() {
    global HiveConfirmed, HiveSlot, FwdKey, RightKey
    HiveConfirmed := 0

    movement :=
        (
            '
    BSSWalk(5, FwdKey)
    BSSWalk(9.2 * ' . HiveSlot . ' - 4, RightKey)
    '
        )

    ; Create and run the walk script.
    CreatePath(movement)

    ; Wait for the walk script to signal it is finished.
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"

    ; Clean up and close the temporary walk script.
    EndWalk()
}

gt_redcannon() {

    Jump()
    Move(3, d)
    Move(1.5, w, d)
    success := 0
    Loop 10
    {
        DllCall("GetSystemTimeAsFileTime", "int64p", &s := 0)
        n := s, f := s + 100
        while (n < f)
        {
            Move(1.5, 'd')
            pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY "|400|125")
            if (Gdip_ImageSearch(pBMScreen, bitmaps["redcannon"], , , , , , 2, , 2) = 1)
            {
                success := 1, Gdip_DisposeImage(pBMScreen)
                break
            }
            Gdip_DisposeImage(pBMScreen)
            DllCall("GetSystemTimeAsFileTime", "int64p", &n)
        }
        StopMovement()

        if (success = 1) ; check that cannon was not overrun, at the expense of a small delay
        {
            Loop 10
            {
                if (A_Index = 10)
                {
                    success := 0
                    break
                }
                Sleep 500
                pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY "|400|125")
                if (Gdip_ImageSearch(pBMScreen, bitmaps["redcannon"], , , , , , 2, , 2) = 1)
                {
                    Gdip_DisposeImage(pBMScreen)
                    break 2
                }
                else
                {
                    Move(1.5, "a")
                    StopMovement()
                }
                Gdip_DisposeImage(pBMScreen)
            }
        }
    }
    if (success = 0) {
        SetStatus("Failed", "Traveling to path")
        ResetToHive()
        %function%.Call()
    }
    Sleep(1000)
}

gt_blue() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(88.875, BackKey, LeftKey)
        BSSWalk(27, LeftKey)
        HyperSleep(50)
        Send "{' . RotLeft . ' 2}"
        ;inside
        BSSWalk(50, FwdKey)
        '
            )

        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{a down}"
        HyperSleep(700)
        Send "{space 2}"
        HyperSleep(4450)
        Send "{a up}{space}"
        HyperSleep(1000)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(4, BackKey, LeftKey)
        BSSWalk(8, FwdKey, LeftKey)
        BSSWalk(6, FwdKey)
        BSSWalk(5, BackKey)
        BSSWalk(8, RightKey)
        ;inside
        BSSWalk(30, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    movement :=
        (
            '
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(5, RightKey)
    BSSWalk(9, RightKey, BackKey)
    BSSWalk(4, RightKey)
    BSSWalk(2, LeftKey)
    BSSWalk(21, BackKey)
    BSSWalk(3.4, FwdKey, LeftKey)
    BSSWalk(16, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_mountain() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Mountain Top")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31.5, FwdKey)
        BSSWalk(9, LeftKey)
        BSSWalk(9, BackKey)
        BSSWalk(58.5, LeftKey)
        BSSWalk(49.5, FwdKey)
        BSSWalk(3.375, LeftKey)
        BSSWalk(36, FwdKey)
        BSSWalk(54, RightKey)
        BSSWalk(54, BackKey)
        BSSWalk(58.5, RightKey)
        BSSWalk(15.75, FwdKey, LeftKey)
        BSSWalk(13.5, FwdKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(27, RightKey)
        BSSWalk(18, BackKey)
        BSSWalk(27, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}"
        Sleep(3000)
        BSSWalk(40.5, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_red() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31.5, FwdKey)
        BSSWalk(9, LeftKey)
        BSSWalk(9, BackKey)
        BSSWalk(58.5, LeftKey)
        BSSWalk(49.5, FwdKey)
        BSSWalk(20.25, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(60.75, FwdKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(9, BackKey)
        BSSWalk(15.75, BackKey, RightKey)
        BSSWalk(29.7, LeftKey)
        BSSWalk(11.25, FwdKey)
        BSSWalk(13.5, LeftKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        movement :=
            (
                '
        Send "{space down}{d down}"
        Sleep(100)
        Send "{space up}"
        BSSWalk(50, RightKey)
        Send "{w down}"
        BSSWalk(45, FwdKey, RightKey)
        Send "{w up}"
        BSSWalk(750, RightKey)
        Send "{space down}"
        HyperSleep(300)
        Send "{space up}{w down}"
        BSSWalk(100, FwdKey, RightKey)
        Send "{w up}"
        BSSWalk(75, RightKey)
        Send "{d up}"
        Send "{' . RotRight . ' 2}"
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        BSSWalk(3, FwdKey)
        HyperSleep(1000)
        Send "{space down}{d down}"
        HyperSleep(100)
        Send "{space up}"
        HyperSleep(300)
        Send "{space}{d up}"
        HyperSleep(1000)
        BSSWalk(8, FwdKey, RightKey)
        BSSWalk(1, FwdKey)
        BSSWalk(6.75, RightKey)
        HyperSleep(1000)
        Send "{' . RotRight . ' 4}"
        HyperSleep(100)
        BSSWalk(9, FwdKey)
        BSSWalk(3, FwdKey, LeftKey)
        BSSWalk(5, FwdKey, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_antpass() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(3, FwdKey)
    BSSWalk(52, LeftKey)
    BSSWalk(3, FwdKey)
    Send "{w down}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(5, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}{w up}"
    HyperSleep(500)
    BSSWalk(2, FwdKey)
    BSSWalk(15, RightKey)
    BSSWalk(6, FwdKey, RightKey)
    BSSWalk(7, FwdKey)
    BSSWalk(5, BackKey, LeftKey)
    BSSWalk(23, FwdKey)
    BSSWalk(12, LeftKey)
    BSSWalk(8, LeftKey, FwdKey)
    BSSWalk(10, FwdKey)
    BSSWalk(5, RightKey)
    BSSWalk(25, FwdKey, RightKey)
    BSSWalk(25, LeftKey)
    BSSWalk(17, BackKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_blender() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7.8, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(5, RightKey)
        BSSWalk(1.5, FwdKey)
        BSSWalk(60, LeftKey)
        BSSWalk(3.75, RightKey)
        BSSWalk(38, FwdKey)
        Send "{' . RotLeft . ' 4}"
        BSSWalk(14, RightKey)
        BSSWalk(15, FwdKey, LeftKey)
        BSSWalk(1, BackKey)
        HyperSleep(200)
        BSSWalk(25, RightKey)
        HyperSleep(200)
        Send "{' . RotRight . ' 2}"
        HyperSleep(200)
        BSSWalk(15, FwdKey)
        BSSWalk(1, FwdKey, RightKey)
        BSSWalk(7, FwdKey)
        BSSWalk(3, BackKey)
        BSSWalk(26, LeftKey)
        BSSWalk(1, FwdKey, LeftKey)
        HyperSleep(300)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{d down}{s down}"
        HyperSleep(925)
        Send "{space 2}"
        HyperSleep(2850)
        Send "{s up}"
        HyperSleep(1450)
        Send "{space}{d up}"
        HyperSleep(600)
        ;corner align
        BSSWalk(10, FwdKey, LeftKey)
        BSSWalk(10, LeftKey, FwdKey)
        BSSWalk(1, BackKey)
        HyperSleep(200)
        BSSWalk(25, RightKey)
        HyperSleep(200)
        Send "{' . RotRight . ' 2}"
        HyperSleep(200)
        ;inside badge shop
        BSSWalk(15, FwdKey)
        BSSWalk(1, FwdKey, RightKey)
        ;align with corner
        BSSWalk(7, FwdKey)
        BSSWalk(3, BackKey)
        BSSWalk(26, LeftKey)
        BSSWalk(1.5, BackKey, LeftKey)
        HyperSleep(300)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_blueberrydis() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Blueberry Dispenser")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(88.875, BackKey, LeftKey)
        BSSWalk(27, LeftKey)
        HyperSleep(50)
        Send "{' . RotLeft . ' 2}"
        HyperSleep(50)
        BSSWalk(30, FwdKey)
        BSSWalk(11.5, FwdKey, RightKey)
        BSSWalk(2, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{a down}"
        HyperSleep(700)
        Send "{space 2}"
        HyperSleep(4450)
        Send "{a up}{space}"
        HyperSleep(1000)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(10, LeftKey)
        BSSWalk(8, RightKey)
        ;inside
        BSSWalk(10, FwdKey)
        Send "{' . RotRight . ' 1}"
        HyperSleep(100)
        BSSWalk(1.6, FwdKey)
        Send "{w down}{space down}"
        HyperSleep(300)
        Send "{space up}"
        Send "{space}"
        HyperSleep(1300)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_candles() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Candles")
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(750, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}{w down}"
    BSSWalk(100, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(75, RightKey)
    Send "{d up}"
    Send "{' . RotRight . ' 2}"
    Sleep(200)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(3, FwdKey)
    Sleep(1000)
    Send "{space down}{d down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(300)
    Send "{space}{d up}"
    HyperSleep(1000)
    BSSWalk(4, RightKey)
    BSSWalk(14, FwdKey)
    BSSWalk(8, RightKey)
    BSSWalk(5, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_clock() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(44.75, BackKey, LeftKey)
        BSSWalk(42.5, LeftKey)
        BSSWalk(8.5, BackKey)
        BSSWalk(22.5, LeftKey)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(40, FwdKey)
        BSSWalk(3, BackKey)
        BSSWalk(7, RightKey)
        Send "{w down}"
        BSSWalk(75, FwdKey)
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        BSSWalk(125, FwdKey)
        Send "{w up}"
        BSSWalk(5, LeftKey)
        BSSWalk(4, FwdKey)
        BSSWalk(4, RightKey)
        BSSWalk(10, FwdKey)
        BSSWalk(4, BackKey)
        BSSWalk(3, LeftKey)
        Send "{' . RotRight . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{w down}{a down}"
        HyperSleep(1500)
        Send "{space 2}"
        Sleep(8000)
        Send "{w up}{a up}"
        BSSWalk(15, BackKey)
        BSSWalk(3.5, RightKey)
        BSSWalk(2, RightKey, BackKey)
        BSSWalk(1, BackKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_coconutdis() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Travling", "Coconut Dispenser")
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(750, RightKey)
    Send "{d up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(4, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(3, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(2, LeftKey, FwdKey)
    BSSWalk(8, FwdKey)
    Send "{w down}{d down}"
    BSSWalk(275, FwdKey, RightKey)
    Send "{space down}{d up}"
    HyperSleep(200)
    Send "{space up}"
    HyperSleep(1100)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    BSSWalk(4, FwdKey)
    Send "{' . RotLeft . ' 1}"
    BSSWalk(30, FwdKey)
    Sleep(100)
    Send "{' . RotRight . ' 1}"
    BSSWalk(15.7, LeftKey)
    BSSWalk(8, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
    ;paths 230629 noobyguy
}

gt_extrememm() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    SetStatus("Going to Extreme Memory-Match")
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(750, RightKey)
    Send "{d up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(4, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(3, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(2, LeftKey, FwdKey)
    BSSWalk(8, FwdKey)
    Send "{w down}{d down}"
    BSSWalk(275, FwdKey, RightKey)
    Send "{space down}{d up}"
    HyperSleep(200)
    Send "{space up}"
    HyperSleep(1100)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    BSSWalk(450, FwdKey)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    BSSWalk(650, FwdKey)
    Send "{w up}"
    Send "{d down}"
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    BSSWalk(375, RightKey)
    Send "{d up}"
    BSSWalk(2, FwdKey)
    Sleep(1000)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_feast() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Feast")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31.5, FwdKey)
        BSSWalk(9, LeftKey)
        BSSWalk(9, BackKey)
        BSSWalk(58.5, LeftKey)
        BSSWalk(49.5, FwdKey)
        BSSWalk(3.375, LeftKey)
        BSSWalk(36, FwdKey)
        BSSWalk(60, RightKey)
        BSSWalk(60, BackKey)
        BSSWalk(9, LeftKey)
        BSSWalk(3.5, FwdKey, RightKey)
        BSSWalk(8.5, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{' . RotLeft . ' 4}"
        HyperSleep(100)
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{w down}"
        HyperSleep(760)
        Send "{space 2}"
        HyperSleep(2100)
        Send "{a down}"
        HyperSleep(100)
        Send "{space}{w up}{a up}"
        BSSWalk(10, LeftKey)
        BSSWalk(6, FwdKey)
        BSSWalk(2.2, RightKey)
        BSSWalk(2, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    movement :=
        (
            '
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(5, FwdKey)
    Sleep(1000)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_gingerbread() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Gingerbread")
    gt_ramp()
    movement :=
        (
            '
    Send "{' . RotRight . ' 2}"
    BSSWalk(4.7, RightKey)
    Send "{space down}"
    BSSWalk(1.5, FwdKey)
    Send "{space up}"
    HyperSleep(600)
    BSSWalk(6, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(25, FwdKey)
    BSSWalk(3, FwdKey, RightKey)
    BSSWalk(15, FwdKey)
    BSSWalk(2, FwdKey, RightKey)
    BSSWalk(12.5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_gummylair() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Gummy Lair")
    if (MoveMethod = "walk") {
        movement :=
            (
                '
        BSSWalk(3, FwdKey)
        BSSWalk(52, LeftKey)
        BSSWalk(3, FwdKey)
        Send "{w down}{space down}"
        HyperSleep(300)
        Send "{space up}"
        BSSWalk(5, RightKey)
        Send "{space down}"
        HyperSleep(300)
        Send "{space up}{w up}"
        HyperSleep(500)
        BSSWalk(2, FwdKey)
        BSSWalk(15, RightKey)
        BSSWalk(6, FwdKey, RightKey)
        BSSWalk(7, FwdKey)
        BSSWalk(5, BackKey, LeftKey)
        BSSWalk(23, FwdKey)
        BSSWalk(12, LeftKey)
        BSSWalk(8, LeftKey, FwdKey)
        BSSWalk(10, FwdKey)
        BSSWalk(5, RightKey)
        BSSWalk(25, FwdKey, RightKey)
        BSSWalk(50, LeftKey)
        BSSWalk(2, RightKey)
        BSSWalk(40, FwdKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(55, FwdKey)
        BSSWalk(10, LeftKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(5.79, FwdKey, RightKey)
        BSSWalk(50, FwdKey)
        Send "{space down}"
        HyperSleep(300)
        Send "{space up}"
        BSSWalk(6, FwdKey)
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        BSSWalk(4, FwdKey, RightKey)
        Send "{' . RotLeft . ' 4}"
        Sleep(1500)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{w down}"
        HyperSleep(1170)
        Send "{space 2}{w up}"
        HyperSleep(6750)
        BSSWalk(18, FwdKey)
        BSSWalk(8.5, LeftKey)
        BSSWalk(3, LeftKey, FwdKey)
        Sleep(1500)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_gummybeacon() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    SetStatus("Traveling", "Gummy Beacon")
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}{w down}"
    HyperSleep(1070)
    Send "{space 2}"
    HyperSleep(2200)
    Send "{a up}"
    HyperSleep(2200)
    Send "{space}{w up}"
    Sleep(1200)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_honeydis() {
    global function, MoveMethod, HiveSlot, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    SetStatus("Traveling", "Honey Dispenser")
    movement :=
        (
            '
    BSSWalk(1, FwdKey)
    BSSWalk(9.2 * (7 - ' . HiveSlot . ') + 10, LeftKey)
    BSSWalk(2, BackKey, RightKey)
    BSSWalk(2, BackKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_honeylb() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Honey Leaderboard")
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(13, LeftKey, BackKey)
    BSSWalk(10, BackKey)
    Send "{' . RotRight . ' 3}"
    Sleep(2000)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_honeystorm() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Honeystorm")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(44.75, BackKey, LeftKey)
        BSSWalk(52.5, LeftKey)
        BSSWalk(2.8, BackKey, RightKey)
        BSSWalk(6.7, BackKey)
        BSSWalk(40.5, LeftKey)
        BSSWalk(5, BackKey)
        Send "{' . RotRight . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{a down}{w down}"
        HyperSleep(1180)
        Send "{space 2}"
        HyperSleep(5000)
        Send "{w up}{a up}{space}"
        Sleep(1500)
        BSSWalk(10, FwdKey, LeftKey)
        BSSWalk(4, RightKey)
        BSSWalk(22.5, BackKey)
        Send "{' . RotRight . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    movement :=
        (
            '
    Sleep(250)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_lidart() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Lid Art")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31.5, FwdKey)
        BSSWalk(9, LeftKey)
        BSSWalk(9, BackKey)
        BSSWalk(58.5, LeftKey)
        BSSWalk(49.5, FwdKey)
        BSSWalk(3.375, LeftKey)
        BSSWalk(36, FwdKey)
        BSSWalk(54, RightKey)
        BSSWalk(54, BackKey)
        BSSWalk(58.5, RightKey)
        BSSWalk(3, LeftKey)
        BSSWalk(57, FwdKey)
        BSSWalk(16, LeftKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{a down}{s down}"
        HyperSleep(1400)
        Send "{space 2}"
        HyperSleep(1100)
        Send "{a up}"
        HyperSleep(650)
        Send "{s up}{space}"
        Send "{' . RotRight . ' 4}"
        Sleep(1500)
        BSSWalk(4, RightKey, FwdKey)
        BSSWalk(23, FwdKey)
        BSSWalk(9, LeftKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    movement :=
        (
            '
    BSSWalk(3, FwdKey)
    BSSWalk(8, LeftKey)
    BSSWalk(3.6, RightKey)
    BSSWalk(41, FwdKey)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(21, FwdKey)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(3, FwdKey)
    Sleep(1000)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_megamm() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Mega Memory-Match")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7.8, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(5, RightKey)
        BSSWalk(1.5, FwdKey)
        BSSWalk(60, LeftKey)
        BSSWalk(3.75, RightKey)
        BSSWalk(38, FwdKey)
        Send "{' . RotLeft . ' 4}"
        BSSWalk(14, RightKey)
        BSSWalk(15, FwdKey, LeftKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{d down}{s down}"
        HyperSleep(925)
        Send "{space 2}"
        HyperSleep(2850)
        Send "{s up}"
        HyperSleep(1450)
        Send "{space}{d up}"
        HyperSleep(600)
        BSSWalk(10, FwdKey, LeftKey)
        BSSWalk(10, LeftKey, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    movement :=
        (
            '
    BSSWalk(1, BackKey)
    HyperSleep(200)
    BSSWalk(25, RightKey)
    HyperSleep(200)
    Send "{' . RotRight . ' 2}"
    HyperSleep(200)
    BSSWalk(15, FwdKey)
    BSSWalk(1, FwdKey, RightKey)
    BSSWalk(7, FwdKey)
    BSSWalk(4, BackKey)
    BSSWalk(3, LeftKey)
    Sleep(1000)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_nightmm() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Night Memory-Match")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31.5, FwdKey)
        BSSWalk(9, LeftKey)
        BSSWalk(9, BackKey)
        BSSWalk(58.5, LeftKey)
        BSSWalk(49.5, FwdKey)
        BSSWalk(3.375, LeftKey)
        BSSWalk(36, FwdKey)
        BSSWalk(54, RightKey)
        BSSWalk(54, BackKey)
        BSSWalk(58.5, RightKey)
        BSSWalk(3, LeftKey)
        BSSWalk(57, FwdKey)
        BSSWalk(16, LeftKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{a down}{s down}"
        HyperSleep(1400)
        Send "{space 2}"
        HyperSleep(1100)
        Send "{a up}"
        HyperSleep(650)
        Send "{s up}{space}"
        Send "{' . RotRight . ' 4}"
        Sleep(1500)
        BSSWalk(4, RightKey, FwdKey)
        BSSWalk(23, FwdKey)
        BSSWalk(9, LeftKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    movement :=
        (
            '
    BSSWalk(3, FwdKey)
    BSSWalk(8, LeftKey)
    BSSWalk(3.6, RightKey)
    BSSWalk(41, FwdKey)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(8.8, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(25.6, FwdKey)
    Jump2([5, FwdKey])
    Send "{' . RotRight . ' 1}"
    BSSWalk(2, FwdKey)
    Jump2([5, FwdKey])
    Send "{' . RotRight . ' 1}"
    BSSWalk(1.5, FwdKey, LeftKey)
    BSSWalk(2, FwdKey)
    Jump2([2.5, FwdKey], [2.5, FwdKey, LeftKey])
    BSSWalk(2, FwdKey)
    Jump2([5, FwdKey])
    BSSWalk(2, FwdKey)
    Jump2([2, FwdKey, RightKey], [3, FwdKey])
    Send "{' . RotRight . ' 1}"
    BSSWalk(2, FwdKey)
    Jump2([2.5, FwdKey, LeftKey], [2, FwdKey])
    BSSWalk(2, FwdKey)
    Jump2([5, FwdKey])
    BSSWalk(2, FwdKey)
    Jump2([4, FwdKey])
    Send "{' . RotRight . ' 1}"
    BSSWalk(2, FwdKey)
    Jump2([8, FwdKey])
    BSSWalk(4, FwdKey)
    BSSWalk(8, FwdKey, LeftKey)
    BSSWalk(7, RightKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(3, BackKey, RightKey)
    BSSWalk(10, RightKey)
    BSSWalk(6, FwdKey, RightKey)
    Jump2([3, FwdKey, RightKey], [1, RightKey])
    Sleep(500)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()

}

gt_normalmm() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Normal Memory-Match")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(69, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(30, FwdKey)
        BSSWalk(20, FwdKey, RightKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(43.5, FwdKey)
        BSSWalk(16, RightKey)
        Send "{w down}"
        HyperSleep(200)
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        HyperSleep(800)
        Send "{w up}"
        Send "{' . RotLeft . ' 2}"
        BSSWalk(29.25, FwdKey)
        BSSWalk(15, FwdKey, LeftKey)
        BSSWalk(8, LeftKey)
        BSSWalk(15, FwdKey, LeftKey)
        BSSWalk(3.5, RightKey)
        BSSWalk(11, BackKey)
        Send "{' . RotLeft . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}"
        HyperSleep(2500)
        BSSWalk(30, FwdKey)
        BSSWalk(2, BackKey)
        BSSWalk(22, LeftKey)
        BSSWalk(12, RightKey)
        BSSWalk(3, LeftKey)
        BSSWalk(5, FwdKey)
        Send "{' . RotRight . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    movement :=
        (
            '
    Sleep(1000)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_rbpdelevel() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    SetStatus("Traveling", "Robo Party")
    ;Didnt add webhook here because unsure of function name what it actually does
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{d down}"
    HyperSleep(530)
    Send "{space 2}"
    Send "{d up}"
    HyperSleep(3500)
    Send "{space}"
    Sleep(1200)
    BSSWalk(20, RightKey, FwdKey)
    BSSWalk(8.5, BackKey)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}{d down}"
    HyperSleep(250)
    Send "{d up}"
    Sleep(1000)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_robopass() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk")
    {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31.5, FwdKey)
        BSSWalk(9, LeftKey)
        BSSWalk(9, BackKey)
        BSSWalk(58.5, LeftKey)
        BSSWalk(49.5, FwdKey)
        BSSWalk(3.375, LeftKey)
        BSSWalk(36, FwdKey)
        BSSWalk(54, RightKey)
        BSSWalk(54, BackKey)
        BSSWalk(58.5, RightKey)
        BSSWalk(3, LeftKey)
        BSSWalk(57, FwdKey)
        BSSWalk(16, LeftKey)
        BSSWalk(3, FwdKey)
        BSSWalk(8, LeftKey)
        BSSWalk(2, RightKey)
        BSSWalk(13, FwdKey)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(1.5, FwdKey)
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        BSSWalk(8.5, FwdKey)
        BSSWalk(3, LeftKey)
        BSSWalk(20, FwdKey)
        Sleep(500)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else
    {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . LeftKey . ' down}{' . BackKey . ' down}"
        HyperSleep(1400)
        Send "{space 2}"
        HyperSleep(1100)
        Send "{' . LeftKey . ' up}"
        HyperSleep(650)
        Send "{' . BackKey . ' up}{space}{' . RotRight . ' 4}"
        Sleep(1500)
        BSSWalk(4, RightKey, FwdKey)
        BSSWalk(23, FwdKey)
        BSSWalk(9, LeftKey)
        BSSWalk(3, FwdKey)
        BSSWalk(8, LeftKey)
        BSSWalk(2, RightKey)
        BSSWalk(13, FwdKey)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(1.5, FwdKey)
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        BSSWalk(8.5, FwdKey)
        BSSWalk(3, LeftKey)
        BSSWalk(20, FwdKey)
        Sleep(500)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;path 230629 noobyguy | 230909 reverted cannon path -noobyguy

}

gt_royaljellydis() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    SetStatus("Traveling", "Royal Jelly Dispenser")
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}"
    HyperSleep(750)
    Send "{space 2}"
    HyperSleep(2250)
    Send "{w down}"
    HyperSleep(1000)
    Send "{a up}"
    Sleep(1000)
    Send "{w up}"
    Sleep(2000)
    BSSWalk(13, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_samovar() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Samovar")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(45, FwdKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(58.5, FwdKey)
        BSSWalk(18, RightKey)
        Send "{w down}"
        HyperSleep(200)
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        HyperSleep(800)
        Send "{w up}"
        Send "{' . RotLeft . ' 2}"
        BSSWalk(63, FwdKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(45, FwdKey)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(27, FwdKey)
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        BSSWalk(3, FwdKey)
        BSSWalk(10, FwdKey, RightKey)
        BSSWalk(8, FwdKey, LeftKey)
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        BSSWalk(3.5, FwdKey, LeftKey)
        Send "{' . RotRight . ' 1}"
        BSSWalk(3, FwdKey)
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        BSSWalk(6, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{' . RotLeft . ' 2}"
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{w down}"
        HyperSleep(2000)
        Send "{space 2}"
        HyperSleep(2800)
        Send "{a down}"
        HyperSleep(900)
        Send "{a up}"
        HyperSleep(1000)
        Send "{w up}"
        HyperSleep(650)
        Send "{space}"
        HyperSleep(1000)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(36, FwdKey)
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        BSSWalk(3, FwdKey)
        BSSWalk(10, FwdKey, RightKey)
        BSSWalk(8, FwdKey, LeftKey)
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        BSSWalk(3.5, FwdKey, LeftKey)
        Send "{' . RotRight . ' 1}"
        BSSWalk(3, FwdKey)
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        BSSWalk(6, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_snowmachine() {
    global function, MoveMethod, HiveSlot, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Traveling", "Snow Machine")
    if (MoveMethod = "walk") {
        common_movement :=
            (
                '
        HyperSleep(800)
        Send "{space down}{a down}"
        HyperSleep(250)
        Send "{space up}"
        BSSWalk(425, LeftKey)
        Send "{a up}"
        HyperSleep(800)
        Send "{space down}{a down}"
        HyperSleep(250)
        Send "{space up}"
        BSSWalk(1000, LeftKey)
        Send "{a up}"
        BSSWalk(8, FwdKey)
        HyperSleep(250)
        Send "{space down}{a down}"
        HyperSleep(150)
        Send "{space up}"
        BSSWalk(375, LeftKey)
        Send "{a up}"
        BSSWalk(16.5, BackKey)
        Send "{' . RotLeft . ' 4}"
        Send "{w down}"
        HyperSleep(150)
        Send "{space down}"
        HyperSleep(300)
        Send "{space up}"
        HyperSleep(300)
        Send "{space down}"
        HyperSleep(500)
        Send "{space up}"
        HyperSleep(500)
        BSSWalk(225, FwdKey)
        Send "{w up}"
        Send "{' . RotLeft . ' 2}"
        BSSWalk(3, FwdKey)
        '
            )
        switch HiveSlot {
            case 2:
                gt_ramp()
                movement :=
                    (
                        '
                BSSWalk(41, BackKey, LeftKey)
                BSSWalk(48, LeftKey)
                BSSWalk(10, FwdKey)
                BSSWalk(1, RightKey)
                BSSWalk(6, BackKey)
                ' . common_movement . '
                '
                    )
                CreatePath(movement)
                KeyWait "F14", "D T5 L"
                KeyWait "F14", "T60 L"
                EndWalk()

            case 3:
                movement :=
                (
                    '
                BSSWalk(36, BackKey, LeftKey)
                BSSWalk(22, LeftKey)
                BSSWalk(10, FwdKey)
                BSSWalk(1, RightKey)
                BSSWalk(6, BackKey)
                ' . common_movement . '
                '
                )
                CreatePath(movement)
                KeyWait "F14", "D T5 L"
                KeyWait "F14", "T60 L"
                EndWalk()

            case 4:
                movement :=
                (
                    '
                BSSWalk(9, LeftKey)
                BSSWalk(23, BackKey)
                BSSWalk(30, LeftKey)
                BSSWalk(10, FwdKey)
                BSSWalk(1, RightKey)
                BSSWalk(6, BackKey)
                ' . common_movement . '
                '
                )
                CreatePath(movement)
                KeyWait "F14", "D T5 L"
                KeyWait "F14", "T60 L"
                EndWalk()

            case 5:
                movement :=
                (
                    '
                BSSWalk(23, BackKey)
                BSSWalk(30, LeftKey)
                BSSWalk(10, FwdKey)
                BSSWalk(1, RightKey)
                BSSWalk(6, BackKey)
                ' . common_movement . '
                '
                )
                CreatePath(movement)
                KeyWait "F14", "D T5 L"
                KeyWait "F14", "T60 L"
                EndWalk()

            case 6:
                movement :=
                (
                    '
                BSSWalk(8, RightKey)
                BSSWalk(23, BackKey)
                BSSWalk(30, LeftKey)
                BSSWalk(10, FwdKey)
                BSSWalk(1, RightKey)
                BSSWalk(6, BackKey)
                ' . common_movement . '
                '
                )
                CreatePath(movement)
                KeyWait "F14", "D T5 L"
                KeyWait "F14", "T60 L"
                EndWalk()

            default:
                gt_ramp()
                movement :=
                    (
                        '
                BSSWalk(41, LeftKey, BackKey)
                BSSWalk(48, LeftKey)
                BSSWalk(10, FwdKey)
                BSSWalk(1, RightKey)
                BSSWalk(6, BackKey)
                ' . common_movement . '
                '
                    )
                CreatePath(movement)
                KeyWait "F14", "D T5 L"
                KeyWait "F14", "T60 L"
                EndWalk()
        }

    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        Send "{' . RotLeft . ' 2}"
        HyperSleep(100)
        Send "{e up}{w down}"
        HyperSleep(1250)
        Send "{space 2}"
        HyperSleep(2200)
        Send "{d down}"
        HyperSleep(2650)
        Send "{space}{w up}{d up}"
        Send "{' . RotLeft . ' 4}"
        Sleep(1500)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_stickerPrinter() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7.8, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(5, RightKey)
        BSSWalk(1.5, FwdKey)
        BSSWalk(60, LeftKey)
        BSSWalk(3.75, RightKey)
        BSSWalk(85, FwdKey)
        BSSWalk(45, RightKey)
        BSSWalk(50, BackKey)
        BSSWalk(60, RightKey)
        BSSWalk(15.75, FwdKey, LeftKey)
        BSSWalk(18, FwdKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, LeftKey)
        BSSWalk(3, BackKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}"
        Sleep(4000)
        BSSWalk(31, LeftKey)
        BSSWalk(3, BackKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_stickerstack() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (MoveMethod = "cannon")
    {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        send "{e down}"
	    HyperSleep(100)
	    send "{e up}{" RightKey " down}"
	    HyperSleep(1200)
	    send "{space 2}"
	    send "{" RightKey " up}"
	    HyperSleep(6000)
	    BSSWalk(7, RightKey)
	    BSSWalk(11, BackKey)
	    send "{space down}"
	    BSSWalk(1.5, BackKey)
	    send "{space up}"
	    BSSWalk(1.5, BackKey)
	    send "{space down}"
	    BSSWalk(1.5, BackKey)
	    send "{space up}"
	    BSSWalk(2, BackKey)
	    HyperSleep(2000)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else
    {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
	    send "{" RotRight " 4}"
	    BSSWalk(31.5, FwdKey)
	    BSSWalk(9, LeftKey)
	    BSSWalk(9, BackKey)
	    BSSWalk(58.5, LeftKey)
	    BSSWalk(49.5, FwdKey)
	    BSSWalk(2.25, BackKey, LeftKey)
	    BSSWalk(36, LeftKey)
	    send "{" RotLeft " 2}"
	    send "{" FwdKey " down}"
	    send "{space down}"
	    HyperSleep(300)
	    send "{space up}"
	    HyperSleep(500)
	    send "{" RotRight " 2}"
	    HyperSleep(1000)
	    send "{space down}"
	    HyperSleep(300)
	    send "{space up}"
	    Walk(6)
	    send "{" FwdKey " up}"
	    BSSWalk(6, RightKey)
	    BSSWalk(7, FwdKey)
	    BSSWalk(6, LeftKey)
	    BSSWalk(3, RightKey)
	    BSSWalk(32, FwdKey)
	    BSSWalk(4, BackKey)
        BSSWalk(8, LeftKey)
	    send "{space down}"
	    HyperSleep(100)
	    send "{space up}"
	    BSSWalk(4, LeftKey)
        Sleep 500
        send "{space down}"
	    HyperSleep(100)
	    send "{space up}"
        BSSWalk(6, LeftKey)
        send "{" RotRight " 4}"
        BSSWalk(12, FwdKey)
        send "{space down}"
	    HyperSleep(100)
	    send "{space up}"
        BSSWalk(14, FwdKey, LeftKey)
        BSSWalk(3, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_stockings() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    SetStatus("Travling", "Stockings")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(47.25, BackKey, LeftKey)
        BSSWalk(40.5, LeftKey)
        BSSWalk(8.5, BackKey)
        BSSWalk(43, LeftKey)
        BSSWalk(13, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{a down}{w down}"
        HyperSleep(1180)
        Send "{space 2}"
        HyperSleep(4950)
        Send "{w up}{a up}{space}"
        Sleep(1500)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_strawberrydis() {
    global function, MoveMethod, HiveBees, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Strawberry Dispenser")
    if (HiveBees > 25) {
        gt_ramp()
        movement :=
            (
                '
        Send "{space down}{d down}"
        Sleep(100)
        Send "{space up}"
        BSSWalk(50, RightKey)
        Send "{w down}"
        BSSWalk(45, FwdKey, RightKey)
        Send "{w up}"
        BSSWalk(750, RightKey)
        Send "{d up}{space down}"
        HyperSleep(300)
        Send "{space up}"
        BSSWalk(6, RightKey)
        HyperSleep(500)
        Send "{' . RotRight . ' 2}"
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        BSSWalk(3, FwdKey)
        HyperSleep(1000)
        Send "{space down}{d down}"
        HyperSleep(100)
        Send "{space up}"
        HyperSleep(300)
        Send "{space}{d up}"
        HyperSleep(1000)
        BSSWalk(7.5, BackKey, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31.5, FwdKey)
        BSSWalk(9, LeftKey)
        BSSWalk(9, BackKey)
        BSSWalk(58.5, LeftKey)
        BSSWalk(49.5, FwdKey)
        BSSWalk(20.25, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(60.75, FwdKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(9, BackKey)
        BSSWalk(15.75, BackKey, RightKey)
        BSSWalk(30, LeftKey)
        BSSWalk(36, FwdKey)
        BSSWalk(28, LeftKey)
        BSSWalk(5, RightKey)
        BSSWalk(3.5, BackKey)
        BSSWalk(23.5, LeftKey)
        BSSWalk(3, BackKey)
        BSSWalk(10, RightKey)
        BSSWalk(3, LeftKey)
        BSSWalk(8, BackKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;dual path 230629 noobyguy
}

gt_treatdis() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Treat Dispenser")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(30, FwdKey)
        BSSWalk(20, FwdKey, RightKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(43.5, FwdKey)
        BSSWalk(16, RightKey)
        Send "{w down}"
        HyperSleep(200)
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        HyperSleep(800)
        Send "{w up}"
        Send "{' . RotLeft . ' 2}"
        BSSWalk(29.25, FwdKey)
        BSSWalk(17, FwdKey, LeftKey)
        BSSWalk(3, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{a down}"
        HyperSleep(1810)
        Send "{space 2}"
        HyperSleep(1925)
        Send "{a up}{space}"
        Send "{' . RotRight . ' 4}"
        Sleep(1500)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_windshrine() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Wind Shrine")
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(750, RightKey)
    Send "{d up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(4, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(3, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(2, LeftKey, FwdKey)
    BSSWalk(8, FwdKey)
    Send "{w down}{d down}"
    BSSWalk(275, FwdKey, RightKey)
    Send "{space down}{d up}"
    HyperSleep(200)
    Send "{space up}"
    HyperSleep(1100)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    BSSWalk(450, FwdKey)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    HyperSleep(200)
    BSSWalk(21, FwdKey, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(3, FwdKey)
    BSSWalk(19.5, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(3, RightKey)
    Send "{' . RotRight . ' 2}"
    HyperSleep(200)
    ;pepper
    BSSWalk(13, FwdKey, RightKey)
    BSSWalk(10, RightKey)
    BSSWalk(1, LeftKey)
    Send "{space down}"
    HyperSleep(120)
    Send "{d down}"
    HyperSleep(130)
    Send "{space up}{d up}"
    BSSWalk(15, RightKey)
    HyperSleep(300)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_wintermm() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Travling", "Winter Memory-Match")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31.5, FwdKey)
        BSSWalk(9, LeftKey)
        BSSWalk(9, BackKey)
        BSSWalk(58.5, LeftKey)
        BSSWalk(49.5, FwdKey)
        BSSWalk(2.25, BackKey, LeftKey)
        BSSWalk(36, LeftKey)
        Send "{' . RotLeft . ' 2}"
        Send "{w down}"
        Send "{space down}"
        HyperSleep(300)
        Send "{space up}"
        HyperSleep(500)
        Send "{' . RotRight . ' 2}"
        HyperSleep(1000)
        Send "{space down}"
        HyperSleep(300)
        Send "{space up}"
        BSSWalk(150, FwdKey)
        Send "{w up}"
        BSSWalk(6, RightKey)
        BSSWalk(42, FwdKey)
        Send "{a down}"
        BSSWalk(175, LeftKey)
        Send "{space down}"
        Sleep(100)
        Send "{space up}"
        BSSWalk(175, LeftKey)
        Send "{space down}"
        Sleep(100)
        Send "{space up}"
        BSSWalk(250, LeftKey)
        Send "{a up}"
        BSSWalk(3.75, RightKey)
        BSSWalk(6, BackKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{d down}{s down}"
        HyperSleep(1150)
        Send "{space 2}"
        HyperSleep(4050)
        Send "{s up}"
        HyperSleep(1000)
        Send "{d up}"
        Sleep(2200)
        Send "{' . RotRight . ' 4}"
        BSSWalk(14, LeftKey)
        BSSWalk(4, FwdKey, LeftKey)
        Send "{space down}"
        Sleep(500)
        Send "{space up}{a down}"
        BSSWalk(212.5, LeftKey)
        Send "{a up}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_wreath() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    SetStatus("Travling", "Wreath")
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(19, RightKey)
    BSSWalk(2.5, BackKey, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_bamboo() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Travling", "Bamboo Field")
    if (MoveMethod = "cannon") {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{a down}"
        HyperSleep(1250)
        Send "{space 2}"
        HyperSleep(1000)
        Send "{a up}"
        HyperSleep(1200)
        Send "{space}"
        Send "{' . RotLeft . ' 2}"
        Sleep(2000)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    } else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(23.5, FwdKey)
        BSSWalk(31.5, FwdKey, RightKey)
        BSSWalk(10, RightKey)
        Send "{' . RotRight . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;walk path 230212 zaappiix - adjusted line 9 and line 13 delays
    ;cannon path 230630 nooby - updated line 7 and 8
}

gt_blueflower(a := 0) {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    if (a == 0) {
        SetStatus("Travling", "Blue Flower Field")
    }
    if (MoveMethod = "cannon") {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{a down}"
        HyperSleep(675)
        Send "{space 2}"
        HyperSleep(2000)
        Send "{a up}"
        HyperSleep(1250)
        Send "{space}"
        Send "{' . RotLeft . ' 2}"
        Sleep(1000)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    } else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(86.875, BackKey, LeftKey)
        BSSWalk(28, LeftKey)
        Send "{' . RotLeft . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_cactus() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Travling", "Cactus Field")
    if (MoveMethod = "cannon") {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{d down}{s down}"
        HyperSleep(950)
        Send "{space 2}"
        HyperSleep(1700)
        Send "{d up}{s up}"
        HyperSleep(1000)
        Send "{space}"
        Sleep(2000)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    } else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7.8, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(5, RightKey)
        BSSWalk(1.5, FwdKey)
        BSSWalk(60, LeftKey)
        BSSWalk(49.5, FwdKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(13.5, LeftKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_clover() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    SetStatus("Traveling", "Clover Field")
    if (MoveMethod = "cannon") {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{a down}{w down}"
        HyperSleep(525)
        Send "{space 2}"
        HyperSleep(1250)
        Send "{w up}"
        HyperSleep(1850)
        Send "{a up}"
        HyperSleep(1000)
        Send "{space}"
        Sleep(1000)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    } else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(44.75, BackKey, LeftKey)
        BSSWalk(52.5, LeftKey)
        BSSWalk(2.8, BackKey, RightKey)
        BSSWalk(6.7, BackKey)
        BSSWalk(20.5, LeftKey)
        BSSWalk(4.5, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_coconut(a := 0) {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    if (a == 0) {
        SetStatus("Traveling", "Coconut Field")
    }
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{" RightKey " down}"
    Sleep 100
    Send "{space up}"
    Walk(2)
    Send "{" FwdKey " down}"
    Walk(1.8)
    Send "{" FwdKey " up}"
    Walk(30)
    send "{" RightKey " up}{space down}"
    HyperSleep(300)
    send "{space up}"
    BSSWalk(4, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(3, RightKey)
    send "{space down}"
    HyperSleep(300)
    send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(2, LeftKey, FwdKey)
    BSSWalk(8, FwdKey)
    Send "{" FwdKey " down}{" RightKey " down}"
    Walk(11)
    send "{space down}{" RightKey " up}"
    HyperSleep(200)
    send "{space up}"
    HyperSleep(1100)
    send "{space down}"
    HyperSleep(200)
    send "{space up}"
    Walk(18)
    Send "{" FwdKey " up}"
    BSSWalk(13.5, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_dandelion() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Traveling", "Dandelion Field")
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(39, BackKey, LeftKey)
    BSSWalk(14, LeftKey)
    Send "{' . RotLeft . ' 2}"
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_mountaintop() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Mountain Top Field")
    if (MoveMethod = "cannon") {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{a down}{s down}"
        HyperSleep(1525)
        Send "{space 2}"
        HyperSleep(1100)
        Send "{a up}"
        HyperSleep(350)
        Send "{s up}{space}"
        Sleep(1500)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    } else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7.8, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(5, RightKey)
        BSSWalk(1.5, FwdKey)
        BSSWalk(60, LeftKey)
        BSSWalk(3.75, RightKey)
        BSSWalk(85, FwdKey)
        BSSWalk(45, RightKey)
        BSSWalk(50, BackKey)
        BSSWalk(60, RightKey)
        BSSWalk(15.75, FwdKey, LeftKey)
        BSSWalk(13.5, FwdKey)
        Send "{' . RotRight . ' 4}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_mushroom() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Mushroom Field")
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(36, BackKey, LeftKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(31.5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_pepper() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Pepper Patch")
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(750, RightKey)
    Send "{d up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(4, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(3, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(2, LeftKey, FwdKey)
    BSSWalk(8, FwdKey)
    Send "{w down}{d down}"
    BSSWalk(275, FwdKey, RightKey)
    Send "{space down}{d up}"
    HyperSleep(200)
    Send "{space up}"
    HyperSleep(1100)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    BSSWalk(450, FwdKey)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    BSSWalk(500, FwdKey)
    Send "{d down}"
    BSSWalk(225, FwdKey, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(25, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(825, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(100, RightKey)
    Send "{d up}{w up}"
    Send "{' . RotRight . ' 2}"
    BSSWalk(9, FwdKey)
    BSSWalk(1.5, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_pineapple() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Pineapple Patch")
    if (MoveMethod = "cannon") {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{a down}"
        HyperSleep(1850)
        Send "{space 2}"
        HyperSleep(2750)
        Send "{a up}{s down}"
        HyperSleep(1150)
        Send "{s up}{space}"
        Send "{' . RotRight . ' 4}"
        Sleep(2000)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    } else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(30, FwdKey)
        BSSWalk(20, FwdKey, RightKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(43.5, FwdKey)
        BSSWalk(18, RightKey)
        BSSWalk(6, FwdKey)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(65.5, FwdKey)
        BSSWalk(1.5, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_pinetree() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    SetStatus("Traveling", "Pine Tree Forest")
    function := A_ThisFunc
    if (MoveMethod = "cannon") {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{d down}{s down}"
        HyperSleep(925)
        Send "{space 2}"
        HyperSleep(4500)
        Send "{s up}"
        HyperSleep(500)
        Send "{d up}{space}"
        Send "{' . RotLeft . ' 4}"
        Sleep(2000)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    } else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7.8, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(5, RightKey)
        BSSWalk(1.5, FwdKey)
        BSSWalk(60, LeftKey)
        BSSWalk(3.75, RightKey)
        BSSWalk(38, FwdKey)
        BSSWalk(33, LeftKey, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_pumpkin() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Pumpkin Patch")
    if (MoveMethod = "cannon") {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{d down}{s down}"
        HyperSleep(950)
        Send "{space 2}"
        HyperSleep(2700)
        Send "{d up}"
        HyperSleep(500)
        Send "{s up}"
        HyperSleep(600)
        Send "{space}"
        Send "{' . RotLeft . ' 4}"
        Sleep(1500)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    } else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7.8, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(5, RightKey)
        BSSWalk(1.5, FwdKey)
        BSSWalk(60, LeftKey)
        BSSWalk(3.75, RightKey)
        BSSWalk(38, FwdKey)
        BSSWalk(18, RightKey, FwdKey)
        BSSWalk(10, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_rose() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Rose Field")
    if (MoveMethod = "cannon") {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{d down}"
        HyperSleep(550)
        Send "{space 2}"
        HyperSleep(2000)
        Send "{d up}"
        HyperSleep(1000)
        Send "{space}"
        Send "{' . RotRight . ' 2}"
        Sleep(1000)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    } else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7.8, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(5, RightKey)
        BSSWalk(1.5, FwdKey)
        BSSWalk(60, LeftKey)
        BSSWalk(3.75, RightKey)
        BSSWalk(38, FwdKey)
        Send "{' . RotLeft . ' 4}"
        BSSWalk(14, RightKey)
        BSSWalk(15, FwdKey, LeftKey)
        BSSWalk(1, BackKey)
        HyperSleep(200)
        BSSWalk(16, RightKey)
        BSSWalk(49, FwdKey)
        Send "{' . RotRight . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_spider() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Spider Field")
    if (MoveMethod = "cannon") {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{s down}"
        HyperSleep(1050)
        Send "{space 2}"
        HyperSleep(300)
        Send "{s up}{space}"
        Send "{' . RotLeft . ' 4}"
        Sleep(1500)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    } else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31.5, FwdKey)
        BSSWalk(13, LeftKey, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_strawberry() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Strawberry Field")
    if (MoveMethod = "cannon") {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{d down}{s down}"
        HyperSleep(700)
        Send "{space 2}"
        HyperSleep(1700)
        Send "{d up}{s up}{space}"
        Send "{' . RotRight . ' 2}"
        Sleep(2000)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    } else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7, FwdKey, LeftKey)
        BSSWalk(33.25, LeftKey)
        BSSWalk(6.75, FwdKey, LeftKey)
        Send "{' . RotLeft . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_stump(a := 0) {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (a == 0) {
        SetStatus("Traveling", "Stump Field")
    }
    if (MoveMethod = "cannon") {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{a down}"
        HyperSleep(1850)
        Send "{space 2}"
        HyperSleep(2750)
        Send "{a up}"
        Send "{' . RotLeft . ' 2}"
        Send "{w down}{a down}"
        HyperSleep(900)
        Send "{a up}"
        HyperSleep(1650)
        Send "{w up}{space}"
        Sleep(1000)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    } else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(30, FwdKey)
        BSSWalk(20, FwdKey, RightKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(43.5, FwdKey)
        BSSWalk(18, RightKey)
        BSSWalk(6, FwdKey)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(43, FwdKey)
        BSSWalk(30, FwdKey, RightKey)
        BSSWalk(24, RightKey)
        BSSWalk(10, BackKey)
        Send "{' . RotRight . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_sunflower() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Sunflower Field")
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(9, BackKey)
    BSSWalk(6.75, BackKey, RightKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(29, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_black() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    SetStatus("Traveling", "Black Bear")
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(10, BackKey)
    BSSWalk(13.5, RightKey)
    BSSWalk(6, FwdKey)
    BSSWalk(6, BackKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_brown() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Traveling", "Brown Bear")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(44.75, BackKey, LeftKey)
        BSSWalk(42.5, LeftKey)
        BSSWalk(8.5, BackKey)
        BSSWalk(22.5, LeftKey)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(40, FwdKey)
        BSSWalk(1.2, BackKey)
        BSSWalk(15, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{w down}{a down}"
        HyperSleep(1500)
        Send "{space 2}"
        Sleep(8000)
        Send "{w up}{a up}"
        BSSWalk(20, RightKey)
        BSSWalk(8, LeftKey)
        BSSWalk(3, RightKey, BackKey)
        BSSWalk(2, BackKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_bucko() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Traveling", "Bucko Bee")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(88.875, BackKey, LeftKey)
        BSSWalk(27, LeftKey)
        HyperSleep(50)
        Send "{' . RotLeft . ' 2}"
        HyperSleep(50)
        BSSWalk(50, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{a down}"
        HyperSleep(700)
        Send "{space 2}"
        HyperSleep(4450)
        Send "{a up}{space}"
        HyperSleep(1000)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(4, BackKey, LeftKey)
        BSSWalk(8, FwdKey, LeftKey)
        BSSWalk(6, FwdKey)
        BSSWalk(5, BackKey)
        BSSWalk(8, RightKey)
        ;inside
        BSSWalk(30, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    movement :=
        (
            '
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(5, RightKey)
    BSSWalk(9, RightKey, BackKey)
    BSSWalk(4, RightKey)
    BSSWalk(2, LeftKey)
    BSSWalk(28, BackKey)
    BSSWalk(1.75, FwdKey)
    BSSWalk(9.5, LeftKey)
    BSSWalk(6.5, FwdKey)
    Sleep(100)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_honey() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Honey Bee")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31.5, FwdKey)
        BSSWalk(9, LeftKey)
        BSSWalk(9, BackKey)
        BSSWalk(58.5, LeftKey)
        BSSWalk(49.5, FwdKey)
        BSSWalk(2.25, BackKey, LeftKey)
        BSSWalk(36, LeftKey)
        Send "{' . RotLeft . ' 2}"
        Send "{w down}"
        Send "{space down}"
        HyperSleep(300)
        Send "{space up}"
        HyperSleep(500)
        Send "{' . RotRight . ' 2}"
        HyperSleep(1000)
        Send "{space down}"
        HyperSleep(300)
        Send "{space up}"
        BSSWalk(150, FwdKey)
        Send "{w up}"
        BSSWalk(6, RightKey)
        BSSWalk(7, FwdKey)
        BSSWalk(6, LeftKey)
        BSSWalk(3, RightKey)
        BSSWalk(32, FwdKey)
        BSSWalk(8.5, BackKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{d down}{s down}"
        HyperSleep(1150)
        Send "{space 2}"
        HyperSleep(4050)
        Send "{s up}"
        HyperSleep(1000)
        Send "{d up}"
        Sleep(2200)
        Send "{' . RotRight . ' 4}"
        BSSWalk(14, LeftKey)
        BSSWalk(4, FwdKey)
        BSSWalk(3, BackKey)
        BSSWalk(11, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_polar() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Polar Bear")
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31.5, FwdKey)
        BSSWalk(9, LeftKey)
        BSSWalk(9, BackKey)
        BSSWalk(58.5, LeftKey)
        BSSWalk(49.5, FwdKey)
        BSSWalk(3.375, LeftKey)
        BSSWalk(36, FwdKey)
        BSSWalk(60, RightKey)
        BSSWalk(60, BackKey)
        BSSWalk(9, LeftKey)
        BSSWalk(3, FwdKey, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{d down}"
        HyperSleep(1430)
        Send "{space 2}"
        HyperSleep(1375)
        Send "{space}{d up}"
        Send "{' . RotLeft . ' 4}"
        HyperSleep(2500)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gt_riley() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Riley Bee")
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(750, RightKey)
    Send "{d up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(6, RightKey)
    HyperSleep(500)
    Send "{' . RotRight . ' 2}"
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(3, FwdKey)
    HyperSleep(1000)
    Send "{space down}{d down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(300)
    Send "{space}{d up}"
    HyperSleep(1000)
    BSSWalk(26, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(1, BackKey)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(8, FwdKey)
    Sleep(1500)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

wf_bamboo() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(16, LeftKey)
    BSSWalk(5, RightKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(75, RightKey)
    BSSWalk(64, FwdKey)
    BSSWalk(5.5, FwdKey, RightKey)
    BSSWalk(36, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

wf_blueflower() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    movement :=
        (
            '
    Send "{' . RotRight . ' 2}"
    BSSWalk(13.5, FwdKey)
    BSSWalk(4.5, BackKey)
    BSSWalk(48, RightKey)
    BSSWalk(40.5, FwdKey)
    BSSWalk(33.5, RightKey)
    BSSWalk(27, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

wf_cactus() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(8, BackKey)
    BSSWalk(10, LeftKey, BackKey)
    BSSWalk(14.5, BackKey)
    BSSWalk(28, LeftKey)
    BSSWalk(36, FwdKey)
    BSSWalk(3, RightKey)
    BSSWalk(4, FwdKey)
    BSSWalk(4, LeftKey)
    BSSWalk(27, FwdKey)
    BSSWalk(2.75, FwdKey, LeftKey)
    BSSWalk(90, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

wf_clover() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(18, FwdKey)
    BSSWalk(36, RightKey)
    BSSWalk(4.5, BackKey)
    BSSWalk(50.5, RightKey)
    BSSWalk(36, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

wf_coconut() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(20.25, RightKey)
    Send "{s down}"
    BSSWalk(562.5, BackKey)
    Send "{space down}"
    HyperSleep(50)
    Send "{space up}"
    BSSWalk(787.5, BackKey)
    Send "{s up}"
    BSSWalk(33.75, LeftKey)
    BSSWalk(13.5, FwdKey)
    BSSWalk(10, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

wf_dandelion() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    movement :=
        (
            '
    Send "{' . RotRight . ' 2}"
    BSSWalk(13.5, FwdKey)
    BSSWalk(42, RightKey)
    BSSWalk(28, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

wf_mountaintop() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    zigzag_part := ''
    loop 15 {
        zigzag_part .= 'BSSWalk(3, BackKey)`n'
        zigzag_part .= 'BSSWalk(1, LeftKey)`n'
    }
    movement :=
        (
            '
    ' . zigzag_part . '
    BSSWalk(36, FwdKey, RightKey)
    BSSWalk(100, FwdKey)
    BSSWalk(32, RightKey)
    BSSWalk(37, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

wf_mushroom() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(13.5, FwdKey)
    BSSWalk(27, LeftKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(11.5, LeftKey)
    BSSWalk(72, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

wf_pepper() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(42, RightKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(45, FwdKey)
    BSSWalk(50, LeftKey)
    BSSWalk(49, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(13.5, FwdKey)
    BSSWalk(10, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

wf_pineapple() {
    global function, MoveMethod, HiveBees, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (HiveBees < 12) {
        movement :=
            (
                '
        BSSWalk(18, FwdKey)
        BSSWalk(31.5, RightKey)
        BSSWalk(4, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(4, RightKey)
        Send "{' . RotLeft . ' 4}"
        BSSWalk(60, FwdKey)
        BSSWalk(5.5, BackKey)
        BSSWalk(10, RightKey)
        BSSWalk(12, FwdKey)
        BSSWalk(8, RightKey)
        Send "{' . RotRight . ' 2}"
        Send "{w down}"
        Send "{space down}"
        HyperSleep(200)
        Send "{space up}"
        Send "{w up}"
        BSSWalk(30, FwdKey)
        BSSWalk(3, BackKey)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(30, FwdKey)
        BSSWalk(4.5, BackKey)
        BSSWalk(40.5, RightKey)
        BSSWalk(40.5, FwdKey)
        BSSWalk(34.5, RightKey)
        BSSWalk(27, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        movement :=
            (
                '
        BSSWalk(18, FwdKey)
        BSSWalk(31.5, RightKey)
        BSSWalk(4, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(4, RightKey)
        Send "{' . RotLeft . ' 4}"
        BSSWalk(60, FwdKey)
        BSSWalk(5.5, BackKey)
        BSSWalk(10, RightKey)
        Send "{space down}"
        HyperSleep(50)
        Send "{space up}"
        BSSWalk(4, RightKey)
        HyperSleep(1100)
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}"
        HyperSleep(3000)
        BSSWalk(34, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

wf_pinetree() {
    global function, MoveMethod, HiveBees, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    if ((HiveBees < 25) || (MoveMethod = "Walk")) {
        movement :=
            (
                '
        BSSWalk(31, FwdKey)
	    BSSWalk(75, RightKey)
	    send "{" RotLeft " 4}"
	    Sleep(50)
	    BSSWalk(20, FwdKey)
	    BSSWalk(3, FwdKey, LeftKey)
	    BSSWalk(18, FwdKey)
	    BSSWalk(6, FwdKey, RightKey)
	    BSSWalk(10, RightKey)
	    BSSWalk(2, LeftKey)
	    send "{" FwdKey " down}"
	    Walk(6)
	    send "{" SC_Space " down}"
	    HyperSleep(200)
	    send "{" SC_Space " up}"
	    BSSWalk(108)
	    send "{" FwdKey " up}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        movement :=
            (
                '
        BSSWalk(31, FwdKey)
	    BSSWalk(75, RightKey)
	    send "{" RotLeft " 4}"
	    Sleep(50)
	    BSSWalk(20, FwdKey)
	    BSSWalk(3, FwdKey, LeftKey)
	    BSSWalk(18, FwdKey)
	    BSSWalk(6, FwdKey, RightKey)
	    BSSWalk(10, RightKey)
	    BSSWalk(2, LeftKey)
	    send "{" FwdKey " down}"
	    Walk(6)
	    send "{" SC_Space " down}"
	    HyperSleep(200)
	    send "{" SC_Space " up}"
	    HyperSleep(200)
	    send "{" SC_Space " down}"
	    HyperSleep(200)
	    send "{" SC_Space " up}"
	    HyperSleep(3000)
	    send "{" FwdKey " up}"
	    HyperSleep(2600)
	    BSSWalk(15, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }

    ;added MoveMethod condition to no-glider option misc 181123
    ;slightly altered tile measurements and optimised glider deployment SP 230405
}

wf_pumpkin() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(9, RightKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(9, BackKey)
    Send "{s down}"
    Send "{a down}"
    HyperSleep(2000)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    HyperSleep(2000)
    Send "{s up}"
    Send "{a up}"
    BSSWalk(36, FwdKey)
    BSSWalk(4.5, FwdKey, RightKey)
    BSSWalk(4.5, FwdKey, LeftKey)
    BSSWalk(27, FwdKey)
    BSSWalk(3, FwdKey, LeftKey)
    BSSWalk(85.5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

wf_rose() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(12, FwdKey)
    BSSWalk(20, LeftKey)
    BSSWalk(8, RightKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(35, LeftKey)
    BSSWalk(41, FwdKey)
    BSSWalk(9, LeftKey)
    BSSWalk(28, FwdKey)
    BSSWalk(8, LeftKey)
    BSSWalk(6, FwdKey, LeftKey)
    BSSWalk(6, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

wf_spider() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(22.5, FwdKey)
    BSSWalk(27, LeftKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(64, FwdKey)
    BSSWalk(5.5, FwdKey, RightKey)
    BSSWalk(36, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

wf_strawberry() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    movement :=
        (
            '
    Send "{' . RotLeft . ' 2}"
    BSSWalk(12, BackKey)
    BSSWalk(15, BackKey, LeftKey)
    BSSWalk(18, LeftKey)
    BSSWalk(15, FwdKey)
    BSSWalk(6, LeftKey)
    BSSWalk(95, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

wf_stump() {
    global function, HiveBees, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (HiveBees < 12) { ;walk
        movement :=
            (
                '
        BSSWalk(40.5, RightKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(22.5, RightKey)
        BSSWalk(22.5, BackKey)
        BSSWalk(13, RightKey)
        BSSWalk(40.5, FwdKey)
        BSSWalk(5.5, BackKey)
        BSSWalk(10, RightKey)
        BSSWalk(12, FwdKey)
        BSSWalk(8, RightKey)
        Send "{' . RotRight . ' 2}"
        Send "{w down}"
        Send "{space down}"
        HyperSleep(200)
        Send "{space up}"
        Send "{w up}"
        BSSWalk(30, FwdKey)
        BSSWalk(3, BackKey)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(30, FwdKey)
        BSSWalk(4.5, BackKey)
        BSSWalk(40.5, RightKey)
        BSSWalk(40.5, FwdKey)
        BSSWalk(34.5, RightKey)
        BSSWalk(27, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else { ;use yellow cannon
        movement :=
            (
                '
        BSSWalk(40.5, RightKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(22.5, RightKey)
        BSSWalk(22.5, BackKey)
        BSSWalk(13, RightKey)
        BSSWalk(40.5, FwdKey)
        BSSWalk(5.5, BackKey)
        BSSWalk(10, RightKey)
        Send "{space down}"
        HyperSleep(50)
        Send "{space up}"
        BSSWalk(4, RightKey)
        HyperSleep(1100)
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}"
        HyperSleep(3000)
        BSSWalk(34, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

wf_sunflower() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    movement :=
        (
            '
    Send "{' . RotLeft . ' 2}"
    BSSWalk(13.5, RightKey)
    BSSWalk(45, FwdKey)
    BSSWalk(2.25, BackKey)
    BSSWalk(25, FwdKey, LeftKey)
    BSSWalk(13.5, FwdKey)
    BSSWalk(10, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_dailyhoneymakerslb() {
    global function, HiveSlot, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Traveling", "Daily Honeymaker Leaderboard")
    movement :=
        (
            '
    BSSWalk(9 * ' . HiveSlot . ' - 4, RightKey)
    HyperSleep(100)
    BSSWalk(1, LeftKey)
    HyperSleep(100)
    BSSWalk(20, LeftKey, BackKey)
    HyperSleep(100)
    Send "{' . RotLeft . ' 4}"
    HyperSleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_alltimehoneymakerslb() {
    global function, HiveSlot, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Traveling", "All-Time Honeymaker Leaderboard")
    movement :=
        (
            '
    BSSWalk(9 * ' . HiveSlot . ' - 4, RightKey)
    HyperSleep(100)
    BSSWalk(1, LeftKey)
    HyperSleep(100)
    BSSWalk(20, LeftKey, BackKey)
    Send "{' . RotLeft . ' 4}"
    HyperSleep(100)
    BSSWalk(14, RightKey)
    HyperSleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_tickettent() {
    global function, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    SetStatus("Traveling", "Ticket Tent")
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(4.5, RightKey)
    BSSWalk(8.25, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_basiceggshop() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Basic Egg Shop")
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(30, BackKey, LeftKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(7, FwdKey, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_bee() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    ; Not sure what this is
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(40, LeftKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(17.5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_beequipstorage() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Going to Beequip Storage")
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(47.5, LeftKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(17.5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_noobshop() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Going to Noob Shop")
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(47.5, LeftKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(19, FwdKey, LeftKey)
    BSSWalk(10, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_demonmaskshop() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Going to Demon Mask Shop")
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(58, LeftKey)
    BSSWalk(2, FwdKey)
    Send "{' . RotLeft . ' 2}"
    Jump()
    BSSWalk(10, FwdKey)
    BSSWalk(5, LeftKey)
    BSSWalk(13, FwdKey)
    ActivateGlider()
    HyperSleep(1000)
    ActivateGlider()
    HyperSleep(1000)
    BSSWalk(3, RightKey)
    Send "{Shift}"
    ActivateGlider()
    HyperSleep(1000)
    Jump()
    BSSWalk(4, FwdKey)
    Jump()
    BSSWalk(3, FwdKey)
    Send "{' . RotLeft . ' 2}"
    Jump()
    BSSWalk(3, FwdKey)
    ActivateGlider()
    HyperSleep(1000)
    Send "{Shift}"
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_treatshop() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Going to Treat Shop")
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(9, BackKey)
    BSSWalk(8, BackKey, RightKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(49, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_mother() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Mother Bear")
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(9, BackKey)
    BSSWalk(7, BackKey, RightKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(49, FwdKey)
    BSSWalk(10, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_instantconverterA() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Going to Instant Converter")
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(30, BackKey, LeftKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(15, RightKey)
    BSSWalk(9, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_stickbug() {
    global function, RotRight
    function := A_ThisFunc
    SetStatus("Traveling", "Stickbug")
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    HyperSleep(100)
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}"
    HyperSleep(100)
    ActivateGlider()
    HyperSleep(150)
    Jump()
    HyperSleep(100)
    Send "{' . RotRight . ' 2}"
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_stickbuglb() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Going to Stickbug Leaderboard")
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    HyperSleep(100)
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}"
    HyperSleep(100)
    ActivateGlider()
    HyperSleep(150)
    Jump()
    HyperSleep(100)
    Send "{' . RotRight . ' 2}"
    HyperSleep(100)
    BSSWalk(4, FwdKey, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_festivenymphs() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    SetStatus("Going to Festive Nymphs")
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    HyperSleep(100)
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}"
    HyperSleep(100)
    ActivateGlider()
    HyperSleep(150)
    Jump()
    HyperSleep(100)
    Send "{' . RotRight . ' 2}"
    HyperSleep(100)
    BSSWalk(5, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_royaljellydis2() {
    global function, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    SetStatus("Going to second Royal Jelly Dispenser")
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(44.75, LeftKey, BackKey)
    BSSWalk(44, LeftKey)
    BSSWalk(5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_slingshot() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(44.75, LeftKey, BackKey)
    BSSWalk(44, LeftKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(20, FwdKey)
    Jump()
    BSSWalk(3, FwdKey)
    HyperSleep(250)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_vines() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Going to Vines")
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(44.75, BackKey, LeftKey)
    BSSWalk(42.5, LeftKey)
    BSSWalk(8.5, BackKey)
    BSSWalk(22.5, LeftKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(27, FwdKey)
    BSSWalk(7, LeftKey, FwdKey)
    BSSWalk(19, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_bronzestaramulet() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Going to Bronze Star Amulet")
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}"
    HyperSleep(750)
    Send "{space 2}"
    HyperSleep(2250)
    Send "{w down}"
    HyperSleep(1000)
    Send "{a up}"
    Sleep(1000)
    Send "{w up}"
    Sleep(2000)
    Send "{' . RotLeft . ' 1}"
    BSSWalk(12, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_silverstaramulet() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Going to Silver Star Amulet")
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}"
    HyperSleep(750)
    Send "{space 2}"
    HyperSleep(2250)
    Send "{w down}"
    HyperSleep(1000)
    Send "{a up}"
    Sleep(1000)
    Send "{w up}"
    Sleep(2000)
    Send "{' . RotLeft . ' 1}"
    BSSWalk(20, FwdKey)
    Jump()
    BSSWalk(3, FwdKey)
    BSSWalk(5, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_goldstaramulet() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Going to Gold Star Amulet")
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}"
    HyperSleep(750)
    Send "{space 2}"
    HyperSleep(2250)
    Send "{w down}"
    HyperSleep(1000)
    Send "{a up}"
    Sleep(1000)
    Send "{w up}"
    Sleep(2000)
    Send "{' . RotLeft . ' 1}"
    BSSWalk(20, FwdKey)
    Jump()
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(3, FwdKey)
    BSSWalk(5, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_diamondstaramulet() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Going to Diamond Star Amulet")
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}"
    HyperSleep(750)
    Send "{space 2}"
    HyperSleep(2250)
    Send "{w down}"
    HyperSleep(1000)
    Send "{a up}"
    Sleep(1000)
    Send "{w up}"
    Sleep(2000)
    Send "{' . RotLeft . ' 1}"
    BSSWalk(20, FwdKey)
    Jump()
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(3, FwdKey)
    BSSWalk(5, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_supremestaramulet() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Going to Supreme Star Amulet")
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}"
    HyperSleep(750)
    Send "{space 2}"
    HyperSleep(2250)
    Send "{w down}"
    HyperSleep(1000)
    Send "{a up}"
    Sleep(1000)
    Send "{w up}"
    Sleep(2000)
    Send "{' . RotLeft . ' 1}"
    BSSWalk(20, FwdKey)
    Jump()
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(7, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_bluehq() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Going to Blue Headquarter")
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}"
    HyperSleep(700)
    Send "{space 2}"
    HyperSleep(4450)
    Send "{a up}{space}"
    HyperSleep(1000)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(4, BackKey, LeftKey)
    BSSWalk(8, FwdKey, LeftKey)
    BSSWalk(6, FwdKey)
    BSSWalk(5, BackKey)
    BSSWalk(8, RightKey)
    BSSWalk(16, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_blueteleporter() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    SetStatus("Going to Blue Teleporter")
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}"
    HyperSleep(700)
    Send "{space 2}"
    HyperSleep(4450)
    Send "{a up}{space}"
    HyperSleep(1000)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(4, BackKey, LeftKey)
    BSSWalk(8, FwdKey, LeftKey)
    BSSWalk(6, FwdKey)
    BSSWalk(5, BackKey)
    BSSWalk(8, RightKey)
    BSSWalk(17.5, FwdKey)
    BSSWalk(3, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_alltimebluecollectorslb() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}"
    HyperSleep(700)
    Send "{space 2}"
    HyperSleep(4450)
    Send "{a up}{space}"
    HyperSleep(1000)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(4, BackKey, LeftKey)
    BSSWalk(8, FwdKey, LeftKey)
    BSSWalk(6, FwdKey)
    BSSWalk(5, BackKey)
    BSSWalk(8, RightKey)
    BSSWalk(30, FwdKey)
    BSSWalk(6, LeftKey)
    BSSWalk(3, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_dailybluecollectorslb() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}"
    HyperSleep(700)
    Send "{space 2}"
    HyperSleep(4450)
    Send "{a up}{space}"
    HyperSleep(1000)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(4, BackKey, LeftKey)
    BSSWalk(8, FwdKey, LeftKey)
    BSSWalk(6, FwdKey)
    BSSWalk(5, BackKey)
    BSSWalk(8, RightKey)
    BSSWalk(30, FwdKey)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(5, RightKey)
    BSSWalk(9, RightKey, BackKey)
    BSSWalk(4, RightKey)
    BSSWalk(2, LeftKey)
    BSSWalk(28, BackKey)
    BSSWalk(1.75, FwdKey)
    BSSWalk(9.5, LeftKey)
    BSSWalk(6.5, FwdKey)
    BSSWalk(4, RightKey)
    BSSWalk(7, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_topbuckohelperslb() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}"
    HyperSleep(700)
    Send "{space 2}"
    HyperSleep(4450)
    Send "{a up}{space}"
    HyperSleep(1000)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(4, BackKey, LeftKey)
    BSSWalk(8, FwdKey, LeftKey)
    BSSWalk(6, FwdKey)
    BSSWalk(5, BackKey)
    BSSWalk(8, RightKey)
    BSSWalk(30, FwdKey)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(5, RightKey)
    BSSWalk(9, RightKey, BackKey)
    BSSWalk(4, RightKey)
    BSSWalk(2, LeftKey)
    BSSWalk(28, BackKey)
    BSSWalk(1.75, FwdKey)
    BSSWalk(9.5, LeftKey)
    BSSWalk(6.5, FwdKey)
    BSSWalk(4, LeftKey)
    BSSWalk(7, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_moonamuletgenerator() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{s down}{a down}"
    HyperSleep(1100)
    Send "{space 2}"
    HyperSleep(1050)
    Send "{s up}{a up}{space}"
    Send "{' . RotLeft . ' 4}"
    BSSWalk(1, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_snowbear() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{s down}"
    HyperSleep(1050)
    Send "{space 2}"
    HyperSleep(300)
    Send "{s up}{space}"
    HyperSleep(100)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(20, FwdKey)
    BSSWalk(15, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_gumdropshop() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{s down}"
    HyperSleep(1050)
    Send "{space 2}"
    HyperSleep(300)
    Send "{s up}{space}"
    HyperSleep(100)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(20, FwdKey)
    BSSWalk(15, RightKey)
    BSSWalk(8, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_panda() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{s down}"
    HyperSleep(1050)
    Send "{space 2}"
    HyperSleep(300)
    Send "{s up}{space}"
    HyperSleep(100)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(20, FwdKey)
    BSSWalk(17.5, RightKey)
    BSSWalk(12, FwdKey)
    Jump()
    BSSWalk(4, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_alltimebattlerslb() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{s down}"
    HyperSleep(1050)
    Send "{space 2}"
    HyperSleep(300)
    Send "{s up}{space}"
    HyperSleep(100)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(20, FwdKey)
    BSSWalk(17.5, RightKey)
    BSSWalk(12, FwdKey)
    Jump()
    BSSWalk(12, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(1.5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_viciouseggclaim() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{s down}"
    HyperSleep(1050)
    Send "{space 2}"
    HyperSleep(200)
    Send "{s up}{space}"
    HyperSleep(100)
    Send "{' . RotRight . ' 2}"
    BSSWalk(20, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(5, FwdKey)
    Jump()
    BSSWalk(4, FwdKey)
    BSSWalk(3, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_proshop() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}"
    HyperSleep(500)
    Send "{' . RotRight . ' 4}"
    Send "{d down}"
    HyperSleep(1000)
    Send "{space}"
    HyperSleep(500)
    Send "{space}"
    HyperSleep(2900)
    Send "{d up}"
    BSSWalk(15, BackKey)
    BSSWalk(15, LeftKey)
    BSSWalk(15, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_instantconverterB() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}"
    HyperSleep(500)
    Send "{' . RotRight . ' 4}"
    Send "{d down}"
    HyperSleep(1000)
    Send "{space}"
    HyperSleep(500)
    Send "{space}"
    HyperSleep(2900)
    Send "{d up}"
    BSSWalk(15, BackKey)
    BSSWalk(12.5, RightKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(12.5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_science() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}"
    HyperSleep(500)
    Send "{' . RotRight . ' 4}"
    Send "{d down}"
    HyperSleep(1000)
    Send "{space}"
    HyperSleep(500)
    Send "{space}"
    HyperSleep(2900)
    Send "{d up}"
    BSSWalk(10, BackKey)
    BSSWalk(22.5, RightKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(25, FwdKey)
    BSSWalk(20, FwdKey, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_yellowcannon() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}"
    HyperSleep(500)
    Send "{' . RotRight . ' 4}"
    Send "{d down}"
    HyperSleep(1000)
    Send "{space}"
    HyperSleep(500)
    Send "{space}"
    HyperSleep(2900)
    Send "{d up}"
    BSSWalk(10, BackKey)
    BSSWalk(22.5, RightKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(25, FwdKey)
    BSSWalk(5, FwdKey, RightKey)
    BSSWalk(10, RightKey)
    Jump()
    BSSWalk(5, RightKey)
    HyperSleep(250)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_magicbeanshop() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}"
    HyperSleep(500)
    Send "{' . RotRight . ' 4}"
    Send "{d down}"
    HyperSleep(1000)
    Send "{space}"
    HyperSleep(500)
    Send "{space}"
    HyperSleep(2900)
    Send "{d up}"
    BSSWalk(10, BackKey)
    BSSWalk(22.5, RightKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(12, FwdKey)
    BSSWalk(5, LeftKey)
    Jump()
    BSSWalk(4, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_dapper() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}"
    HyperSleep(500)
    Send "{' . RotRight . ' 4}"
    Send "{d down}"
    HyperSleep(1000)
    Send "{space}"
    HyperSleep(500)
    Send "{space}"
    HyperSleep(2900)
    Send "{d up}"
    BSSWalk(40, RightKey)
    BSSWalk(10, FwdKey)
    BSSWalk(20, RightKey)
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(2, FwdKey, LeftKey)
    HyperSleep(1000)
    Jump()
    BSSWalk(2, FwdKey, RightKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(12, FwdKey, RightKey)
    BSSWalk(10, FwdKey)
    BSSWalk(5, FwdKey, RightKey)
    BSSWalk(10, FwdKey)
    BSSWalk(5, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_dapperbeequipshop() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}"
    HyperSleep(500)
    Send "{' . RotRight . ' 4}"
    Send "{d down}"
    HyperSleep(1000)
    Send "{space}"
    HyperSleep(500)
    Send "{space}"
    HyperSleep(2900)
    Send "{d up}"
    BSSWalk(40, RightKey)
    BSSWalk(20, FwdKey)
    Jump()
    BSSWalk(10, FwdKey)
    BSSWalk(10, RightKey)
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(2, FwdKey, LeftKey)
    HyperSleep(1000)
    Jump()
    BSSWalk(1, FwdKey, RightKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(12, FwdKey, RightKey)
    BSSWalk(10, FwdKey)
    BSSWalk(5, FwdKey, RightKey)
    BSSWalk(7.5, FwdKey)
    BSSWalk(5, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_dapperplantershop() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}"
    HyperSleep(500)
    Send "{' . RotRight . ' 4}"
    Send "{d down}"
    HyperSleep(1000)
    Send "{space}"
    HyperSleep(500)
    Send "{space}"
    HyperSleep(2900)
    Send "{d up}"
    BSSWalk(40, RightKey)
    BSSWalk(20, FwdKey)
    Jump()
    BSSWalk(10, FwdKey)
    BSSWalk(10, RightKey)
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(2, FwdKey, LeftKey)
    HyperSleep(1000)
    Jump()
    BSSWalk(1, FwdKey, RightKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(12, FwdKey, RightKey)
    BSSWalk(10, FwdKey)
    BSSWalk(5, FwdKey, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(8, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_alltimepufflb() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}"
    HyperSleep(500)
    Send "{' . RotRight . ' 4}"
    Send "{d down}"
    HyperSleep(1000)
    Send "{space}"
    HyperSleep(500)
    Send "{space}"
    HyperSleep(2900)
    Send "{d up}"
    BSSWalk(40, RightKey)
    BSSWalk(20, FwdKey)
    Jump()
    BSSWalk(10, FwdKey)
    BSSWalk(10, RightKey)
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(2, FwdKey, LeftKey)
    HyperSleep(1000)
    Jump()
    BSSWalk(1, FwdKey, RightKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(12, FwdKey, RightKey)
    BSSWalk(10, FwdKey)
    BSSWalk(5, FwdKey, RightKey)
    BSSWalk(15, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_werewolfcave() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{d down}{s down}"
    HyperSleep(950)
    Send "{space 2}"
    HyperSleep(1700)
    Send "{d up}{s up}"
    HyperSleep(1000)
    Send "{space}"
    Send "{' . RotRight . ' 4}"
    BSSWalk(3, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(52, FwdKey)
    ActivateGlider()
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_diamondmaskshop()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}{s down}"
    HyperSleep(1525)
    Send "{space 2}"
    HyperSleep(1100)
    Send "{a up}"
    HyperSleep(350)
    Send "{s up}{space}"
    Sleep(1500)
    Send "{' . RotRight . ' 2}"
    BSSWalk(30, FwdKey, RightKey)
    BSSWalk(1, FwdKey)
    Jump()
    BSSWalk(8, FwdKey)
    Jump()
    BSSWalk(5, FwdKey)
    ActivateGlider()
    HyperSleep(5000)
    BSSWalk(3, FwdKey)
    ActivateGlider()
    BSSWalk(1, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(2, FwdKey)
    ActivateGlider()
    HyperSleep(400)
    Jump()
    HyperSleep(1000)
    ActivateGlider()
    HyperSleep(400)
    Jump()
    HyperSleep(1000)
    ActivateGlider()
    HyperSleep(400)
    Jump()
    HyperSleep(1000)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_badgeguild()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{d down}{s down}"
    HyperSleep(950)
    Send "{space 2}"
    HyperSleep(1700)
    Send "{d up}{s up}"
    HyperSleep(1000)
    Send "{space}"
    Send "{' . RotRight . ' 2}"
    BSSWalk(37.5, FwdKey)
    BSSWalk(17.5, FwdKey, LeftKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(10, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_aceshop()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{d down}{s down}"
    HyperSleep(950)
    Send "{space 2}"
    HyperSleep(1700)
    Send "{d up}{s up}"
    HyperSleep(1000)
    Send "{space}"
    BSSWalk(37.5, FwdKey)
    BSSWalk(17.5, FwdKey, LeftKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(10, RightKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(30, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_bluecannon()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{d down}{s down}"
    HyperSleep(950)
    Send "{space 2}"
    HyperSleep(1700)
    Send "{d up}{s up}"
    HyperSleep(1000)
    Send "{space}"
    BSSWalk(30, FwdKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(30, FwdKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(3, FwdKey)
    Jump()
    BSSWalk(3, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_royaljellyshop()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{d down}{s down}"
    HyperSleep(950)
    Send "{space 2}"
    HyperSleep(1700)
    Send "{d up}{s up}"
    HyperSleep(1000)
    Send "{space}"
    BSSWalk(30, FwdKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(40, FwdKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(3, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_robo()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{d down}{s down}"
    HyperSleep(950)
    Send "{space 2}"
    HyperSleep(1700)
    Send "{d up}{s up}"
    HyperSleep(1000)
    Send "{space}"
    BSSWalk(30, FwdKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(45, FwdKey)
    Send "{' . RotRight . ' 4}"
    ActivateGlider()
    BSSWalk(7, FwdKey, LeftKey)
    BSSWalk(5, FwdKey)
    Jump()
    BSSWalk(3, FwdKey)
    Jump()
    BSSWalk(3, FwdKey)
    BSSWalk(2, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_alltimerobolb()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{d down}{s down}"
    HyperSleep(950)
    Send "{space 2}"
    HyperSleep(1700)
    Send "{d up}{s up}"
    HyperSleep(1000)
    Send "{space}"
    BSSWalk(30, FwdKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(45, FwdKey)
    Send "{' . RotRight . ' 4}"
    ActivateGlider()
    BSSWalk(7, FwdKey, LeftKey)
    BSSWalk(5, FwdKey)
    Jump()
    BSSWalk(3, FwdKey)
    Jump()
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(3, FwdKey)
    BSSWalk(3, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_roboshop()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{d down}{s down}"
    HyperSleep(950)
    Send "{space 2}"
    HyperSleep(1700)
    Send "{d up}{s up}"
    HyperSleep(1000)
    Send "{space}"
    BSSWalk(30, FwdKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(45, FwdKey)
    Send "{' . RotRight . ' 4}"
    ActivateGlider()
    BSSWalk(7, FwdKey, LeftKey)
    BSSWalk(5, FwdKey)
    Jump()
    BSSWalk(3, FwdKey)
    Jump()
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(3, FwdKey)
    BSSWalk(10, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_redhq() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(67.5, BackKey, LeftKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(31.5, FwdKey)
    BSSWalk(9, LeftKey)
    BSSWalk(9, BackKey)
    BSSWalk(58.5, LeftKey)
    BSSWalk(49.5, FwdKey)
    BSSWalk(20.25, LeftKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(60.75, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(9, BackKey)
    BSSWalk(15.75, BackKey, RightKey)
    BSSWalk(29.7, LeftKey)
    BSSWalk(7.5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_redteleporter() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(67.5, BackKey, LeftKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(31.5, FwdKey)
    BSSWalk(9, LeftKey)
    BSSWalk(9, BackKey)
    BSSWalk(58.5, LeftKey)
    BSSWalk(49.5, FwdKey)
    BSSWalk(20.25, LeftKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(60.75, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(9, BackKey)
    BSSWalk(15.75, BackKey, RightKey)
    BSSWalk(29.7, LeftKey)
    BSSWalk(15, FwdKey)
    BSSWalk(5, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_dailyredcollectorslb() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(67.5, BackKey, LeftKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(31.5, FwdKey)
    BSSWalk(9, LeftKey)
    BSSWalk(9, BackKey)
    BSSWalk(58.5, LeftKey)
    BSSWalk(49.5, FwdKey)
    BSSWalk(20.25, LeftKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(60.75, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(9, BackKey)
    BSSWalk(15.75, BackKey, RightKey)
    BSSWalk(29.7, LeftKey)
    BSSWalk(15, FwdKey)
    BSSWalk(5, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_alltimeredcollectorslb() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(67.5, BackKey, LeftKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(31.5, FwdKey)
    BSSWalk(9, LeftKey)
    BSSWalk(9, BackKey)
    BSSWalk(58.5, LeftKey)
    BSSWalk(49.5, FwdKey)
    BSSWalk(20.25, LeftKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(60.75, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(9, BackKey)
    BSSWalk(15.75, BackKey, RightKey)
    BSSWalk(29.7, LeftKey)
    BSSWalk(25, FwdKey)
    BSSWalk(5, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_toprileyhelperslb()
{
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(750, RightKey)
    Send "{d up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(6, RightKey)
    HyperSleep(500)
    Send "{' . RotRight . ' 2}"
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(3, FwdKey)
    HyperSleep(1000)
    Send "{space down}{d down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(300)
    Send "{space}{d up}"
    HyperSleep(1000)
    BSSWalk(26, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(1, BackKey)
    Send "{space down}"
    Hypersleep(100)
    Send "{space up}"
    BSSWalk(8, FwdKey)
    BSSWalk(10, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_sproutsummoner() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(67.5, BackKey, LeftKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(31.5, FwdKey)
    BSSWalk(9, LeftKey)
    BSSWalk(9, BackKey)
    BSSWalk(58.5, LeftKey)
    BSSWalk(49.5, FwdKey)
    BSSWalk(20.25, LeftKey)
    Send "{' . RotRight . ' 4}"
    BSSWalk(60.75, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(9, BackKey)
    BSSWalk(15.75, BackKey, RightKey)
    BSSWalk(40, LeftKey)
    Send "{' . RotLeft . ' 2}"
    Jump()
    BSSWalk(2, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_antchallengeinfo()
{
    global function, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(3, FwdKey)
    BSSWalk(52, LeftKey)
    BSSWalk(3, FwdKey)
    Send "{w down}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(5, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}{w up}"
    HyperSleep(500)
    BSSWalk(2, FwdKey)
    BSSWalk(15, RightKey)
    BSSWalk(6, FwdKey, RightKey)
    BSSWalk(7, FwdKey)
    BSSWalk(5, BackKey, LeftKey)
    BSSWalk(23, FwdKey)
    BSSWalk(12, LeftKey)
    BSSWalk(8, LeftKey, FwdKey)
    BSSWalk(10, FwdKey)
    BSSWalk(5, RightKey)
    BSSWalk(5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_antchallenge()
{
    global function, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(3, FwdKey)
    BSSWalk(52, LeftKey)
    BSSWalk(3, FwdKey)
    Send "{w down}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(5, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}{w up}"
    HyperSleep(500)
    BSSWalk(2, FwdKey)
    BSSWalk(15, RightKey)
    BSSWalk(6, FwdKey, RightKey)
    BSSWalk(7, FwdKey)
    BSSWalk(5, BackKey, LeftKey)
    BSSWalk(23, FwdKey)
    BSSWalk(12, LeftKey)
    BSSWalk(11, LeftKey, FwdKey)
    BSSWalk(20, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_stingershop()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(3, FwdKey)
    BSSWalk(52, LeftKey)
    BSSWalk(3, FwdKey)
    Send "{w down}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(5, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}{w up}"
    HyperSleep(500)
    BSSWalk(2, FwdKey)
    BSSWalk(15, RightKey)
    BSSWalk(6, FwdKey, RightKey)
    BSSWalk(7, FwdKey)
    BSSWalk(5, BackKey, LeftKey)
    BSSWalk(23, FwdKey)
    BSSWalk(12, LeftKey)
    BSSWalk(11, LeftKey, FwdKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(15, FwdKey, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_antpass2() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(3, FwdKey)
    BSSWalk(52, LeftKey)
    BSSWalk(3, FwdKey)
    Send "{w down}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(5, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}{w up}"
    HyperSleep(500)
    BSSWalk(2, FwdKey)
    BSSWalk(15, RightKey)
    BSSWalk(6, FwdKey, RightKey)
    BSSWalk(7, FwdKey)
    BSSWalk(5, BackKey, LeftKey)
    BSSWalk(23, FwdKey)
    BSSWalk(12, LeftKey)
    BSSWalk(8, LeftKey, FwdKey)
    BSSWalk(10, FwdKey)
    BSSWalk(5, RightKey)
    BSSWalk(25, FwdKey, RightKey)
    BSSWalk(25, LeftKey)
    BSSWalk(17, BackKey)
    BSSWalk(7.5, FwdKey, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_gummyeggclaim()
{
    global function, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{w down}"
    HyperSleep(1170)
    Send "{space 2}{w up}"
    HyperSleep(6750)
    BSSWalk(18, FwdKey)
    BSSWalk(8.5, LeftKey)
    BSSWalk(3, LeftKey, FwdKey)
    BSSWalk(2, BackKey)
    BSSWalk(1, FwdKey)
    Sleep(1500)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_gluedis()
{
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk")
    {
        movement :=
            (
                '
        BSSWalk(3, FwdKey)
        BSSWalk(52, LeftKey)
        BSSWalk(3, FwdKey)
        Send "{' . FwdKey . ' down}{space down}"
        HyperSleep(300)
        Send "{space up}"
        BSSWalk(5, RightKey)
        Send "{space down}"
        HyperSleep(300)
        Send "{space up}{' . FwdKey . ' up}"
        HyperSleep(500)
        BSSWalk(2, FwdKey)
        BSSWalk(15, RightKey)
        BSSWalk(6, FwdKey, RightKey)
        BSSWalk(7, FwdKey)
        BSSWalk(5, BackKey, LeftKey)
        BSSWalk(23, FwdKey)
        BSSWalk(12, LeftKey)
        BSSWalk(8, LeftKey, FwdKey)
        BSSWalk(10, FwdKey)
        BSSWalk(5, RightKey)
        BSSWalk(25, FwdKey, RightKey)
        BSSWalk(50, LeftKey)
        BSSWalk(2, RightKey)
        BSSWalk(40, FwdKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(55, FwdKey)
        BSSWalk(10, LeftKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(5.79, FwdKey, RightKey)
        BSSWalk(50, FwdKey)
        Send "{space down}"
        Hypersleep(300)
        Send "{space up}"
        BSSWalk(6, FwdKey)
        Send "{space down}"
        HyperSleep(100)
        Send "{space up}"
        BSSWalk(4, FwdKey, RightKey)
        Send "{' . RotLeft . ' 4}"
        Sleep(1500)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else
    {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . FwdKey . ' down}"
        HyperSleep(1170)
        Send "{space 2}{' . FwdKey . ' up}"
        HyperSleep(6750)
        BSSWalk(18, FwdKey)
        BSSWalk(8.5, LeftKey)
        BSSWalk(3, LeftKey, FwdKey)
        Sleep(1500)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;path 230630 noobyguy - walk updated
}

gt_gummylairshop()
{
    global function, FwdKey
    function := A_ThisFunc
    gt_gummylair()
    if ((gumdropPos := InventorySearch("gumdrops")) = 0) { ;~ new function
        OpenMenu()
    } else {
        MouseMove windowX + gumdropPos[1], windowY + gumdropPos[2]
        Sleep(400)
        MouseClick("Left")
        Sleep(100)
        MouseClickDrag "Left", windowX + gumdropPos[1], windowY + gumdropPos[2], windowX + (windowWidth // 2), windowY + (windowHeight // 2), 5
        Sleep(200)
        pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 250 "|" windowY + windowHeight // 2 - 52 "|500|150")
        if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
            MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + windowHeight // 2 - 52 + SubStr(pos, InStr(pos, ",") + 1)
            Sleep(150)
            Click
            Sleep(200)
            Gdip_DisposeImage(pBMScreen)
        }
        OpenMenu()
    }
    movement :=
        (
            '
    HyperSleep(2000)
    BSSWalk(7.5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_gummy()
{
    global function, FwdKey
    function := A_ThisFunc
    gt_gummylair()
    if ((gumdropPos := InventorySearch("gumdrops")) = 0) { ;~ new function
        OpenMenu()
    } else {
        MouseMove windowX + gumdropPos[1], windowY + gumdropPos[2]
        Sleep(400)
        MouseClick("Left")
        Sleep(100)
        MouseClickDrag "Left", windowX + gumdropPos[1], windowY + gumdropPos[2], windowX + (windowWidth // 2), windowY + (windowHeight // 2), 5
        Sleep(200)
        pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 250 "|" windowY + windowHeight // 2 - 52 "|500|150")
        if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
            MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + windowHeight // 2 - 52 + SubStr(pos, InStr(pos, ",") + 1)
            Sleep(150)
            Click
            Sleep(200)
            Gdip_DisposeImage(pBMScreen)
        }
        OpenMenu()
    }
    movement :=
        (
            '
    HyperSleep(2000)
    BSSWalk(25, FwdKey)
    Jump()
    BSSWalk(3, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_alltimeantlb()
{
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(3, FwdKey)
    BSSWalk(52, LeftKey)
    BSSWalk(3, FwdKey)
    Send "{w down}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(5, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}{w up}"
    HyperSleep(500)
    BSSWalk(2, FwdKey)
    BSSWalk(15, RightKey)
    BSSWalk(6, FwdKey, RightKey)
    BSSWalk(7, FwdKey)
    BSSWalk(5, BackKey, LeftKey)
    BSSWalk(23, FwdKey)
    BSSWalk(12, LeftKey)
    BSSWalk(8, LeftKey, FwdKey)
    BSSWalk(10, FwdKey)
    BSSWalk(5, RightKey)
    BSSWalk(25, FwdKey, RightKey)
    BSSWalk(25, LeftKey)
    BSSWalk(17, BackKey)
    BSSWalk(7.5, FwdKey, LeftKey)
    BSSWalk(5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_hivehub()
{
    global function, FwdKey, LeftKey
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{w down}"
    Hypersleep(900)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(200)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(4200)
    BSSWalk(55, FwdKey, LeftKey)
    HyperSleep(20000)
    BSSWalk(43, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_hivehubbeequipstorage()
{
    global function, FwdKey, LeftKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{w down}"
    Hypersleep(900)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(200)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(4200)
    BSSWalk(55, FwdKey, LeftKey)
    HyperSleep(20000)
    BSSWalk(43, FwdKey)
    HyperSleep(15000)
    BSSWalk(25, FwdKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(15, FwdKey)
    BSSWalk(30, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_publicstickerboard()
{
    global function, FwdKey, LeftKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{w down}"
    Hypersleep(900)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(200)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(4200)
    BSSWalk(55, FwdKey, LeftKey)
    HyperSleep(20000)
    BSSWalk(43, FwdKey)
    HyperSleep(15000)
    BSSWalk(25, FwdKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(15, FwdKey)
    BSSWalk(15, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_stickerseekershop()
{
    global function, FwdKey, LeftKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{w down}"
    Hypersleep(900)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(200)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(4200)
    BSSWalk(55, FwdKey, LeftKey)
    HyperSleep(20000)
    BSSWalk(43, FwdKey)
    HyperSleep(15000)
    BSSWalk(25, FwdKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(15, FwdKey)
    BSSWalk(15, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_stickerseekerquestmachine()
{
    global function, FwdKey, LeftKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{w down}"
    Hypersleep(900)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(200)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(4200)
    BSSWalk(55, FwdKey, LeftKey)
    HyperSleep(20000)
    BSSWalk(43, FwdKey)
    HyperSleep(15000)
    BSSWalk(25, FwdKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(17.5, FwdKey)
    BSSWalk(10, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_stickerseekerlb()
{
    global function, FwdKey, LeftKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{w down}"
    Hypersleep(900)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(200)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    HyperSleep(4200)
    BSSWalk(55, FwdKey, LeftKey)
    HyperSleep(20000)
    BSSWalk(43, FwdKey)
    HyperSleep(15000)
    BSSWalk(25, FwdKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(10, FwdKey)
    Jump()
    BSSWalk(15, FwdKey)
    BSSWalk(20, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_ticketshop()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}{s down}"
    HyperSleep(1525)
    Send "{space 2}"
    HyperSleep(1100)
    Send "{a up}"
    HyperSleep(350)
    Send "{s up}{space}"
    Sleep(1500)
    Send "{' . RotRight . ' 2}"
    BSSWalk(30, FwdKey, RightKey)
    BSSWalk(1, FwdKey)
    Jump()
    BSSWalk(6, FwdKey)
    BSSWalk(3, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_instantconverterC()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}{s down}"
    HyperSleep(1525)
    Send "{space 2}"
    HyperSleep(1100)
    Send "{a up}"
    HyperSleep(350)
    Send "{s up}{space}"
    Sleep(1500)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(30, FwdKey, LeftKey)
    BSSWalk(1, FwdKey)
    Jump()
    BSSWalk(6, FwdKey, RightKey)
    BSSWalk(2, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_topshop()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}{s down}"
    HyperSleep(1525)
    Send "{space 2}"
    HyperSleep(1100)
    Send "{a up}"
    HyperSleep(350)
    Send "{s up}{space}"
    Sleep(1500)
    Send "{' . RotRight . ' 2}"
    BSSWalk(30, FwdKey, RightKey)
    BSSWalk(1, FwdKey)
    Jump()
    BSSWalk(6, FwdKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(15, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_nectarpot()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}{s down}"
    HyperSleep(1400)
    Send "{space 2}"
    HyperSleep(1100)
    Send "{a up}"
    HyperSleep(650)
    Send "{s up}{space}"
    Send "{' . RotRight . ' 4}"
    Sleep(1500)
    BSSWalk(4, RightKey, FwdKey)
    BSSWalk(23, FwdKey)
    BSSWalk(9, LeftKey)
    BSSWalk(3, FwdKey)
    BSSWalk(8, LeftKey)
    BSSWalk(2, RightKey)
    BSSWalk(14, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(35, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_onett()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{a down}{s down}"
    HyperSleep(1400)
    Send "{space 2}"
    HyperSleep(1100)
    Send "{a up}"
    HyperSleep(650)
    Send "{s up}{space}"
    Send "{' . RotRight . ' 4}"
    Sleep(1500)
    BSSWalk(4, RightKey, FwdKey)
    BSSWalk(23, FwdKey)
    BSSWalk(15, LeftKey)
    BSSWalk(50, FwdKey)
    Jump()
    BSSWalk(40, FwdKey)
    Jump()
    BSSWalk(1, FwdKey)
    BSSWalk(11, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_bbm() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{" SC_E " down}"
    HyperSleep(100)
    Send "{" SC_E " up}{a down}{s down}"
    HyperSleep(1400)
    Send "{space 2}"
    HyperSleep(1100)
    Send "{a up}"
    HyperSleep(650)
    Send "{s up}{space}"
    Send "{' . RotRight . ' 4}"
    Sleep(1500)
    BSSWalk(4, RightKey, FwdKey)
    BSSWalk(23, FwdKey)
    BSSWalk(9, LeftKey)
    BSSWalk(3, FwdKey)
    BSSWalk(8, LeftKey)
    BSSWalk(3.6, RightKey)
    BSSWalk(41, FwdKey)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(8.8, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(25.6, FwdKey)
    Jump()
    BSSWalk(5, FwdKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(5, FwdKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(1.5, FwdKey, LeftKey)
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(2.5, FwdKey)
    BSSWalk(2.5, FwdKey, LeftKey)
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(5, FwdKey)
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(2, FwdKey, RightKey)
    BSSWalk(3, FwdKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(2.5, FwdKey, LeftKey)
    BSSWalk(2, FwdKey)
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(5, FwdKey)
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(4, FwdKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(8, FwdKey)
    BSSWalk(4, FwdKey)
    BSSWalk(8, FwdKey, LeftKey)
    BSSWalk(7, RightKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(3, BackKey, RightKey)
    BSSWalk(12, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_naughtylist()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{" SC_E " down}"
    HyperSleep(100)
    Send "{" SC_E " up}{a down}{s down}"
    HyperSleep(1400)
    Send "{space 2}"
    HyperSleep(1100)
    Send "{a up}"
    HyperSleep(650)
    Send "{s up}{space}"
    Send "{' . RotRight . ' 4}"
    Sleep(1500)
    BSSWalk(4, RightKey, FwdKey)
    BSSWalk(23, FwdKey)
    BSSWalk(9, LeftKey)
    BSSWalk(3, FwdKey)
    BSSWalk(8, LeftKey)
    BSSWalk(3.6, RightKey)
    BSSWalk(41, FwdKey)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(8.8, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(25.6, FwdKey)
    Jump()
    BSSWalk(5, FwdKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(5, FwdKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(1.5, FwdKey, LeftKey)
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(2.5, FwdKey)
    BSSWalk(2.5, FwdKey, LeftKey)
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(5, FwdKey)
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(2, FwdKey, RightKey)
    BSSWalk(3, FwdKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(2.5, FwdKey, LeftKey)
    BSSWalk(2, FwdKey)
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(5, FwdKey)
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(4, FwdKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(2, FwdKey)
    Jump()
    BSSWalk(8, FwdKey)
    BSSWalk(4, FwdKey)
    BSSWalk(8, FwdKey, LeftKey)
    BSSWalk(7, RightKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(3, BackKey, RightKey)
    BSSWalk(10, RightKey)
    BSSWalk(6, FwdKey, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_coconutcave() {
    global function, MoveMethod, FwdKey, LeftKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(750, RightKey)
    Send "{d up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(4, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(3, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(2, LeftKey, FwdKey)
    BSSWalk(8, FwdKey)
    Send "{w down}{d down}"
    BSSWalk(275, FwdKey, RightKey)
    Send "{space down}{d up}"
    HyperSleep(200)
    Send "{space up}"
    HyperSleep(1100)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    BSSWalk(4, FwdKey)
    Send "{' . RotLeft . ' 1}"
    BSSWalk(30, FwdKey)
    Sleep(100)
    Send "{' . RotRight . ' 1}"
    BSSWalk(25, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_fastestcrabslayerslb() {
    global function, FwdKey, LeftKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(750, RightKey)
    Send "{d up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(4, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(3, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(2, LeftKey, FwdKey)
    BSSWalk(8, FwdKey)
    Send "{w down}{d down}"
    BSSWalk(275, FwdKey, RightKey)
    Send "{space down}{d up}"
    HyperSleep(200)
    Send "{space up}"
    HyperSleep(1100)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    BSSWalk(4, FwdKey)
    Send "{' . RotLeft . ' 1}"
    BSSWalk(30, FwdKey)
    Sleep(100)
    Send "{' . RotRight . ' 1}"
    BSSWalk(15.7, LeftKey)
    Send "{' . RotLeft . ' 4}"
    BSSWalk(3, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_petalshop()
{
    global function, FwdKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(750, RightKey)
    Send "{d up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(4, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(3, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(47.5, FwdKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(12, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_alltimewhitecollectorslb()
{
    global function, FwdKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(750, RightKey)
    Send "{d up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(4, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(3, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(47.5, FwdKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(10, FwdKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_dailytopwhitecollectorslb()
{
    global function, FwdKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(750, RightKey)
    Send "{d up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(4, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(3, RightKey)
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(47.5, FwdKey)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(10, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_spirit()
{
    global function, FwdKey, LeftKey, RightKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(750, RightKey)
    Send "{d up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(4, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(3, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(2, LeftKey, FwdKey)
    BSSWalk(8, FwdKey)
    Send "{w down}{d down}"
    BSSWalk(275, FwdKey, RightKey)
    Send "{space down}{d up}"
    HyperSleep(200)
    Send "{space up}"
    HyperSleep(1100)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    BSSWalk(10, FwdKey)
    Send "{' . RotLeft . ' 1}"
    BSSWalk(30, FwdKey)
    Jump()
    BSSWalk(4, FwdKey)
    BSSWalk(10, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_nectarcondenser()
{
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{d down}"
    Sleep(100)
    Send "{space up}"
    BSSWalk(50, RightKey)
    Send "{w down}"
    BSSWalk(45, FwdKey, RightKey)
    Send "{w up}"
    BSSWalk(750, RightKey)
    Send "{d up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(4, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(3, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(2, LeftKey, FwdKey)
    BSSWalk(8, FwdKey)
    Send "{w down}{d down}"
    BSSWalk(275, FwdKey, RightKey)
    Send "{space down}{d up}"
    HyperSleep(200)
    Send "{space up}"
    HyperSleep(1100)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    BSSWalk(450, FwdKey)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    HyperSleep(200)
    BSSWalk(21, FwdKey, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(3, FwdKey)
    BSSWalk(19.5, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(3, RightKey)
    Send "{' . RotRight . ' 2}"
    HyperSleep(200)
    ;pepper
    BSSWalk(13, FwdKey, RightKey)
    BSSWalk(10, RightKey)
    BSSWalk(1, LeftKey)
    Send "{space down}"
    HyperSleep(120)
    Send "{d down}"
    HyperSleep(130)
    Send "{space up}{d up}"
    BSSWalk(35, RightKey)
    BSSWalk(20, BackKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_retroswarm()
{
    global function, FwdKey, LeftKey, RotLeft
    function := A_ThisFunc
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{' . RotLeft . ' 2}"
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{w down}"
    HyperSleep(2000)
    Send "{space 2}"
    HyperSleep(2800)
    Send "{a down}"
    HyperSleep(900)
    Send "{a up}"
    HyperSleep(1000)
    Send "{w up}"
    HyperSleep(650)
    Send "{space}"
    HyperSleep(1000)
    Send "{' . RotLeft . ' 2}"
    BSSWalk(36, FwdKey)
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(3.5, FwdKey)
    BSSWalk(15, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

ClaimHiveFromSpawn() {
    global keyDelay
    GetBitmap() {
        pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY "|400|125")
        while ((A_Index <= 20) && (Gdip_ImageSearch(pBMScreen, bitmaps["FriendJoin"], , , , , , 6) = 1)) {
            Gdip_DisposeImage(pBMScreen)
            MouseMove windowX + windowWidth // 2 - 3, windowY + 24
            Click
            MouseMove windowX + 350, windowY + offsetY + 100
            Sleep 500
            pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY "|400|125")
        }
        return pBMScreen
    }

    hiveClaimed := false
    while !hiveClaimed {
        Loop 6 {
            send "{" ZoomOut " down}"
            Sleep 40 + keyDelay
            send "{" ZoomOut " up}"
        }

        Loop 2 {
            Send "{" RotUp "}"
            Sleep 40 + keyDelay
        }

        Move(2.5, "d")
        Move(28, "w", "d")
        Move(4, "s")
        Move(3, "a")

        attempts := 0

        while attempts < 1 {
            loop 6 {
                pBMScreen := GetBitmap()
                if (Gdip_ImageSearch(pBMScreen, bitmaps["claimhive"], , , , , , 2, , 6) = 1)
                {
                    Gdip_DisposeImage(pBMScreen)
                    global Hiveslot := A_Index
                    writeSettings("Settings", "hiveslot", HiveSlot)
                    send "{" SC_E " down}"
                    Sleep(50)
                    send "{" SC_E " up}"
                    SetStatus("Claimed", "Hiveslot " Hiveslot " successfully")
                    hiveClaimed := true
                    return
                }
                Move(9.25, "a")
                Sleep(400)
            }

            attempts++
            if attempts < 1 {
                Move(5, "w")
                Move(60, "d")
                Move(3, "s")
                Move(3, "a")
            }
        }

        CoordMode "Mouse", "Screen"

        pBMScreen := GetBitmap()
        if (Gdip_ImageSearch(pBMScreen, bitmaps["claimhive"], , , , , , 2, , 6) = 1)
        {
            Gdip_DisposeImage(pBMScreen)
            global Hiveslot := 1
            writeSettings("Settings", "hiveslot", HiveSlot)
        } else {
            Move(4, "w")
            Move(9 * HiveSlot, "d")
            Move(4, "s")
            Move(3, "a")

            loop 6 {
                pBMScreen := GetBitmap()
                if (Gdip_ImageSearch(pBMScreen, bitmaps["claimhive"], , , , , , 2, , 6) = 1)
                {
                    Gdip_DisposeImage(pBMScreen)
                    global Hiveslot := A_Index
                    writeSettings("Settings", "hiveslot", HiveSlot)
                    break
                }
                Move(9.25, "a")
                Sleep(400)
            }
        }

        pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY + 36 "|200|120")
        if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
        {
            Gdip_DisposeImage(pBMScreen)
            send "{" SC_E " down}" ; claims hive
            Sleep(50)
            send "{" SC_E " up}"
            SetStatus("Claimed", "Hiveslot " Hiveslot " successfully")
            hiveClaimed := true
            return
        }
        Gdip_DisposeImage(pBMScreen)
        SetStatus("Failed", "Could not claim hive! Retrying")
        ResetCharacter()
        Sleep 5000
    }
}


NoHiveFound() {
    Move(2.5, d)
    Rotate("right", 1)
    ShiftLock() ; activate
    ActivateGlider()
    Sleep 1000
    Move(9.5, w)
    Rotate("left", 1)
    ShiftLock() ; deactivate
    searchPhrase := "Claim"
    loop 6 {
        result := OCR.FromDesktop(, 2)
        found := result.FindStrings(searchPhrase, , RegExMatch)
        if found.Length {
            global Hiveslot := A_Index
            successv1 := 1
            break
        }
        Move(9.3, "a")
        Hypersleep 400
    }
    if successv1 := 0 {
        ;                   restart or so, fallback mechanism
    }
}

HiveSlot1Path() {
    global FwdKey, LeftKey, RightKey, RotLeft, RotRight
    movement :=
        (
            '
    BSSWalk(2.5, RightKey)
    Send "{' . RotRight . ' 1}"
    ShiftLock()
    ActivateGlider()
    Sleep(1000)
    BSSWalk(9.5, FwdKey)
    Send "{' . RotLeft . ' 1}"
    ShiftLock()
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

HiveSlot2Path() {
    global FwdKey, RotLeft, RotRight
    movement :=
        (
            '
    ShiftLock()
    BSSWalk(5, FwdKey)
    Send "{' . RotRight . ' 1}"
    ActivateGlider()
    Sleep(1000)
    BSSWalk(1.5, FwdKey)
    Send "{' . RotLeft . ' 1}"
    BSSWalk(0.5, FwdKey)
    ShiftLock()
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

HiveSlot3Path() {
    global FwdKey
    movement :=
        (
            '
    ShiftLock()
    ActivateGlider()
    Sleep(1000)
    BSSWalk(2, FwdKey)
    ShiftLock()
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

HiveSlot4Path() {
    global FwdKey, RotLeft, RotRight
    movement :=
        (
            '
    ShiftLock()
    BSSWalk(5, FwdKey)
    Send "{' . RotLeft . ' 1}"
    ActivateGlider()
    Sleep(1000)
    BSSWalk(1.5, FwdKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(0.5, FwdKey)
    ShiftLock()
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

HiveSlot5Path() {
    global FwdKey, LeftKey, RotLeft, RotRight
    movement :=
        (
            '
    BSSWalk(3.5, LeftKey)
    Send "{' . RotLeft . ' 1}"
    ShiftLock()
    ActivateGlider()
    Sleep(1000)
    BSSWalk(9.5, FwdKey)
    Send "{' . RotRight . ' 1}"
    ShiftLock()
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

HiveSlot6Path() {
    global FwdKey, LeftKey, RotLeft, RotRight
    movement :=
        (
            '
    ShiftLock()
    Send "{' . RotLeft . ' 1}"
    ActivateGlider()
    Sleep(1000)
    Send "{' . RotLeft . ' 1}"
    ActivateGlider()
    Sleep(1000)
    Send "{' . RotRight . ' 1}"
    BSSWalk(7.5, FwdKey)
    BSSWalk(1.5, FwdKey, LeftKey)
    Send "{' . RotRight . ' 1}"
    ShiftLock()
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

ChatClick() {
    areaXchat := GetRelativeX(180, 180)
    areaYchat := GetRelativeY(31, 33)

    MouseMove(areaXchat.min, areaYchat.min)
    Sleep 50
    MouseMove(areaXchat.max, areaYchat.max)
    MouseClick("left")
}

gt_robobear() {
    global function, FwdKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    ;Only works with cannon
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}{d down}"
    HyperSleep(550)
    Send "{space 2}"
    HyperSleep(2000)
    Send "{d up}"
    HyperSleep(2700)
    Send "{space}"
    Send "{' . RotRight . ' 2}"
    Hypersleep(500)
    BSSWalk(5, FwdKey)
    BSSWalk(8, BackKey, RightKey)
    BSSWalk(1, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_pinetree_from_rose() {
    global function, FwdKey, RotLeft, RotRight
    function := A_ThisFunc
    movement :=
        (
            '
    Send "{' . RotLeft . ' 2}"
    BSSWalk(82, FwdKey)
    Send "{' . RotRight . ' 2}"
    BSSWalk(1, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_pumpkin_from_rose() {
    global function, FwdKey, RotLeft, RotRight
    function := A_ThisFunc
    movement :=
        (
            '
    Send "{' . RotLeft . ' 2}"
    BSSWalk(60, FwdKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(30, FwdKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(14, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_cactus_from_rose() {
    global function, FwdKey, LeftKey, RotLeft, RotRight
    function := A_ThisFunc
    movement :=
        (
            '
    Send "{' . RotLeft . ' 2}"
    BSSWalk(59, FwdKey)
    Send "{' . RotRight . ' 1}"
    Send "{' . RotRight . ' 1}"
    BSSWalk(38, FwdKey)
    BSSWalk(2.5, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_strawberry_from_rose() {
    global function, FwdKey, LeftKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    ActivateGlider()
    Hypersleep(1100)
    BSSWalk(6, FwdKey)
    BSSWalk(3, RightKey)
    Jump()
    Hypersleep(300)
    BSSWalk(3, FwdKey)
    Hypersleep(300)
    BSSWalk(14, LeftKey)
    BSSWalk(29, FwdKey, LeftKey)
    BSSWalk(7, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_sunflower_from_rose() {
    global function, FwdKey, LeftKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(6, FwdKey)
    BSSWalk(17, FwdKey, RightKey)
    BSSWalk(12, FwdKey)
    BSSWalk(2, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_dandelion_from_rose() {
    global function, FwdKey, LeftKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(5, FwdKey)
    BSSWalk(19, FwdKey, RightKey)
    BSSWalk(14, FwdKey)
    BSSWalk(5, FwdKey, LeftKey)
    BSSWalk(19, FwdKey)
    BSSWalk(20, FwdKey, RightKey)
    BSSWalk(4.5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_mushroom_from_rose() {
    global function, FwdKey, LeftKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(6, FwdKey)
    BSSWalk(18, FwdKey, RightKey)
    BSSWalk(14, FwdKey)
    BSSWalk(6, FwdKey, LeftKey)
    BSSWalk(23, FwdKey)
    BSSWalk(14, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_spider_from_rose() {
    global function, FwdKey, LeftKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    ActivateGlider()
    Hypersleep(1100)
    BSSWalk(6, FwdKey)
    BSSWalk(3, RightKey)
    Jump()
    Hypersleep(300)
    BSSWalk(3, FwdKey)
    Hypersleep(300)
    BSSWalk(14, LeftKey)
    BSSWalk(28, FwdKey, LeftKey)
    BSSWalk(35, FwdKey)
    BSSWalk(8, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_bamboo_from_rose() {
    global function, FwdKey, LeftKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    ActivateGlider()
    Hypersleep(1100)
    BSSWalk(6, FwdKey)
    BSSWalk(3, RightKey)
    Jump()
    Hypersleep(300)
    BSSWalk(3, FwdKey)
    Hypersleep(300)
    BSSWalk(14, LeftKey)
    BSSWalk(28, FwdKey, LeftKey)
    BSSWalk(35, FwdKey)
    BSSWalk(6, LeftKey, FwdKey)
    BSSWalk(39, FwdKey)
    BSSWalk(6, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_blueflower_from_rose() {
    global function, FwdKey, LeftKey, RightKey
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(6, FwdKey)
    BSSWalk(19, FwdKey, RightKey)
    BSSWalk(16, FwdKey)
    BSSWalk(5, FwdKey, LeftKey)
    BSSWalk(35, FwdKey)
    BSSWalk(1, RightKey)
    BSSWalk(20, FwdKey)
    BSSWalk(18, LeftKey)
    BSSWalk(26, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_clover_from_rose() {
    global function, FwdKey, LeftKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(10, FwdKey)
    BSSWalk(4, RightKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(11, FwdKey)
    Send "{' . RotLeft . ' 1}"
    BSSWalk(15, FwdKey)
    BSSWalk(5, FwdKey, LeftKey)
    BSSWalk(15, FwdKey)
    BSSWalk(4, RightKey, FwdKey)
    BSSWalk(48, FwdKey)
    Jump()
    Hypersleep(400)
    BSSWalk(4, FwdKey)
    BSSWalk(4, LeftKey)
    BSSWalk(9, FwdKey)
    Jump()
    Hypersleep(350)
    BSSWalk(4, FwdKey)
    BSSWalk(12, FwdKey, RightKey)
    BSSWalk(2, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_mountaintop_from_rose() {
    global function, FwdKey, LeftKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(10, FwdKey)
    BSSWalk(4, RightKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(10, FwdKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(20, FwdKey)
    Jump()
    Hypersleep(150)
    BSSWalk(7.8, FwdKey, LeftKey)
    ActivateGlider()
    Hypersleep(730)
    Jump()
    Hypersleep(250)
    BSSWalk(2.5, FwdKey)
    BSSWalk(2, FwdKey, LeftKey)
    Send "{' . RotLeft . ' 2}"
    PressE()
    Hypersleep(3200)
    BSSWalk(5, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_pineapple_from_rose() {
    global function, FwdKey, LeftKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    movement :=
        (
            '
    BSSWalk(10, FwdKey)
    BSSWalk(4, RightKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(10, FwdKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(20, FwdKey)
    Jump()
    Hypersleep(150)
    BSSWalk(7.8, FwdKey, LeftKey)
    ActivateGlider()
    Hypersleep(730)
    Jump()
    Hypersleep(250)
    BSSWalk(2.5, FwdKey)
    BSSWalk(2, FwdKey, LeftKey)
    Send "{' . RotLeft . ' 2}"
    Send "{e down}"
    HyperSleep(100)
    Send "{e up}"
    HyperSleep(1850)
    Send "{space 2}"
    HyperSleep(3050)
    Send "{' . RotLeft . ' 2}"
    HyperSleep(850)
    Send "{space}"
    Send "{' . RotRight . ' 2}"
    Sleep(2000)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_cogmower_p1()
{
    global FwdKey, LeftKey, BackKey, RotLeft, RotRight
    gt_ramp()
    gt_redcannon()
    movement :=
        (
            '
    Send "{' . RotRight . ' 3}"
    PressE()
    Hypersleep(800)
    Jump()
    Hypersleep(100)
    Jump()
    Send "{w down}"
    Hypersleep(3200)
    Send "{' . RotLeft . ' 1}"
    Hypersleep(600)
    Send "{w up}"
    Jump()
    Send "{' . RotRight . ' 2}"
    Rotate("up", 9)
    Rotate("down", 4)
    Send "{' . RotRight . ' 1}"
    BSSWalk(3.5, BackKey)
    BSSWalk(1.5, FwdKey, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
    loop 10 {
        send "{" ZoomOut "}"
        Hypersleep Keydelay
    }
    send "{" ZoomIn "}"
}

gt_pinetree_from_cogmower_p1()
{
    global FwdKey, LeftKey
    movement :=
        (
            '
    Hypersleep(100)
    BSSWalk(21.25, FwdKey, LeftKey)
    Hypersleep(100)
    BSSWalk(5.3, FwdKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_cogmower_p1_from_pinetree()
{
    global BackKey, RightKey
    movement :=
        (
            '
    Hypersleep(100)
    BSSWalk(21.25, BackKey, RightKey)
    Hypersleep(100)
    BSSWalk(5.3, BackKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_pumpkin_from_cogmower_p1()
{
    global FwdKey, RightKey
    movement :=
        (
            '
    Hypersleep(100)
    BSSWalk(4.13, FwdKey)
    Hypersleep(100)
    BSSWalk(9.37, RightKey)
    Hypersleep(100)
    BSSWalk(18.00, RightKey, FwdKey)
    Hypersleep(100)
    BSSWalk(2.38, FwdKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_cogmower_p1_from_pumpkin()
{
    global LeftKey, BackKey
    movement :=
        (
            '
    Hypersleep(100)
    BSSWalk(2.38, BackKey)
    Hypersleep(100)
    BSSWalk(18.00, BackKey, LeftKey)
    Hypersleep(100)
    BSSWalk(9.37, LeftKey)
    Hypersleep(100)
    BSSWalk(4.13, BackKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_cactus_from_cogmower_p1()
{
    global FwdKey, BackKey, RightKey
    movement :=
        (
            '
    Hypersleep(100)
    BSSWalk(4.75, FwdKey)
    Hypersleep(100)
    BSSWalk(21.12, RightKey)
    Hypersleep(100)
    BSSWalk(5.74, BackKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_cogmower_p1_from_cactus()
{
    global FwdKey, LeftKey, BackKey
    movement :=
        (
            '
    Hypersleep(100)
    BSSWalk(5.74, FwdKey)
    Hypersleep(100)
    BSSWalk(21.12, LeftKey)
    Hypersleep(100)
    Hypersleep(500)
    BSSWalk(4.75, BackKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_cogmower_p2()
{
    global FwdKey, LeftKey, RotLeft
    movement :=
        (
            '
    Hypersleep(100)
    Send "{' . RotLeft . ' 4}"
    Hypersleep(100)
    BSSWalk(11.75, FwdKey, LeftKey)
    Hypersleep(100)
    BSSWalk(13.50, FwdKey)
    Hypersleep(100)
    Jump()
    Hypersleep(100)
    Jump()
    Hypersleep(1650)
    BSSWalk(3.75, LeftKey)
    Hypersleep(100)
    BSSWalk(3.62, FwdKey)
    Hypersleep(100)
    BSSWalk(2.00, LeftKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_dandelion_from_cogmower_p2()
{
    global FwdKey, LeftKey
    movement :=
        (
            '
    Hypersleep(100)
    Jump()
    Hypersleep(100)
    Jump()
    Hypersleep(1650)
    BSSWalk(8.38, LeftKey)
    Hypersleep(100)
    BSSWalk(24.26, FwdKey, LeftKey)
    Hypersleep(100)
    BSSWalk(5.25, LeftKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_cogmower_p2_from_dandelion()
{
    global FwdKey, LeftKey, BackKey, RightKey
    movement :=
        (
            '
    Hypersleep(100)
    BSSWalk(36.08, FwdKey, LeftKey)
    BSSWalk(0.15, LeftKey)
    Hypersleep(100)
    BSSWalk(23.44, FwdKey)
    Hypersleep(100)
    BSSWalk(14.92, FwdKey, LeftKey)
    Hypersleep(100)
    BSSWalk(0.57, FwdKey)
    Hypersleep(250)
    Jump()
    Hypersleep(100)
    BSSWalk(3.27, FwdKey)
    Hypersleep(100)
    BSSWalk(21.45, LeftKey)
    Hypersleep(100)
    BSSWalk(3.13, BackKey)
    Hypersleep(100)
    BSSWalk(11.93, RightKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_sunflower_from_cogmower_p2()
{
    global RightKey
    movement :=
        (
            '
    Hypersleep(100)
    Jump()
    Hypersleep(100)
    Jump()
    Hypersleep(100)
    Jump()
    Hypersleep(100)
    BSSWalk(10.13, RightKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_cogmower_p2_from_sunflower()
{
    global FwdKey, LeftKey, RightKey
    movement :=
        (
            '
    Hypersleep(100)
    BSSWalk(11.09, LeftKey)
    Hypersleep(100)
    Jump()
    Hypersleep(100)
    BSSWalk(1.77, LeftKey)
    Hypersleep(100)
    BSSWalk(23.16, FwdKey)
    Hypersleep(100)
    BSSWalk(20.39, RightKey)
    Hypersleep(100)
    BSSWalk(1.99, FwdKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_strawberry_from_cogmower_p2()
{
    global BackKey, RightKey
    movement :=
        (
            '
    Hypersleep(100)
    BSSWalk(21.02, BackKey)
    Hypersleep(100)
    BSSWalk(2, RightKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_cogmower_p2_from_strawberry()
{
    global FwdKey, LeftKey
    movement :=
        (
            '
    Hypersleep(100)
    Jump()
    Hypersleep(1100)
    Jump()
    Hypersleep(100)
    BSSWalk(29.50, FwdKey)
    Hypersleep(100)
    BSSWalk(1.88, LeftKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_cogmower_p3()
{
    global FwdKey, LeftKey, RightKey
    movement :=
        (
            '
    Hypersleep(100)
    BSSWalk(0.44, ",")
    Hypersleep(100)
    BSSWalk(0.67, ",")
    Hypersleep(100)
    BSSWalk(5.77, LeftKey)
    Hypersleep(100)
    BSSWalk(32.35, FwdKey)
    Hypersleep(100)
    BSSWalk(6.65, LeftKey)
    Hypersleep(100)
    BSSWalk(29.37, FwdKey)
    Hypersleep(100)
    Jump()
    Hypersleep(400)
    BSSWalk(1.33, FwdKey)
    Hypersleep(100)
    BSSWalk(6.75, RightKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_pineapple_from_cogmower_p3()
{
    global FwdKey, LeftKey, RightKey, RotLeft
    movement :=
        (
            '
    Hypersleep(100)
    BSSWalk(32.10, FwdKey)
    Hypersleep(100)
    BSSWalk(10.65, FwdKey, LeftKey)
    Hypersleep(100)
    BSSWalk(0.57, FwdKey)
    Hypersleep(150)
    Jump()
    Hypersleep(1200)
    BSSWalk(14.35, FwdKey, RightKey)
    BSSWalk(0.29, FwdKey)
    Hypersleep(100)
    Jump()
    Hypersleep(750)
    BSSWalk(5.68, FwdKey)
    Hypersleep(100)
    Send "{' . RotLeft . ' 2}"
    Hypersleep(100)
    BSSWalk(71.17, FwdKey)
    Hypersleep(100)
    BSSWalk(7.95, RightKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_bamboo_from_cogmower_p3()
{
    global FwdKey, LeftKey
    movement :=
        (
            '
    Hypersleep(100)
    BSSWalk(20.88, LeftKey)
    Hypersleep(100)
    BSSWalk(10.08, FwdKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_clover_from_cogmower_p3()
{
    global FwdKey, RightKey
    movement :=
        (
            '
    Hypersleep(100)
    BSSWalk(35.40, RightKey)
    Hypersleep(100)
    Jump()
    Hypersleep(350)
    BSSWalk(2.33, RightKey)
    Hypersleep(1300)
    BSSWalk(5.32, FwdKey)
    Hypersleep(300)
    Jump()
    Hypersleep(650)
    BSSWalk(14.63, FwdKey)
    Hypersleep(100)
    BSSWalk(16.63, RightKey)
    Hypersleep(100)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gtq_black() {
    global function, FwdKey, BackKey, RightKey
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(10, BackKey)
    BSSWalk(13.5, RightKey)
    BSSWalk(6, FwdKey)
    BSSWalk(6, BackKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gtq_brown() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    if (MoveMethod = "walk")
    {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(44.75, BackKey, LeftKey)
        BSSWalk(42.5, LeftKey)
        BSSWalk(8.5, BackKey)
        BSSWalk(22.5, LeftKey)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(40, FwdKey)
        BSSWalk(1.2, BackKey)
        BSSWalk(15, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else
    {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . FwdKey . ' down}{' . LeftKey . ' down}"
        HyperSleep(1500)
        Send "{space 2}"
        Sleep(8000)
        Send "{' . FwdKey . ' up}{' . LeftKey . ' up}"
        BSSWalk(20, RightKey)
        BSSWalk(8, LeftKey)
        BSSWalk(3, RightKey, BackKey)
        BSSWalk(2, BackKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gtq_bucko() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    if (MoveMethod = "walk")
    {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(88.875, BackKey, LeftKey)
        BSSWalk(27, LeftKey)
        HyperSleep(50)
        Send "{' . RotLeft . ' 2}"
        HyperSleep(50)
        BSSWalk(50, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else
    {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . LeftKey . ' down}"
        HyperSleep(700)
        Send "{space 2}"
        HyperSleep(4450)
        Send "{' . LeftKey . ' up}{space}"
        HyperSleep(1000)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(4, BackKey, LeftKey)
        BSSWalk(8, FwdKey, LeftKey)
        BSSWalk(6, FwdKey)
        BSSWalk(5, BackKey)
        BSSWalk(8, RightKey)
        ;inside
        BSSWalk(30, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    movement :=
        (
            '
    Send "{space down}"
    HyperSleep(100)
    Send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(5, RightKey)
    BSSWalk(9, RightKey, BackKey)
    BSSWalk(4, RightKey)
    BSSWalk(2, LeftKey)
    BSSWalk(28, BackKey)
    BSSWalk(1.75, FwdKey)
    BSSWalk(9.5, LeftKey)
    BSSWalk(6.5, FwdKey)
    Sleep(100)
    Send "{space down}"
    Hypersleep(300)
    Send "{space up}"
    BSSWalk(5, FwdKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
    ;path 230630 noobyguy
}

gtq_honey() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk")
    {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31.5, FwdKey)
        BSSWalk(9, LeftKey)
        BSSWalk(9, BackKey)
        BSSWalk(58.5, LeftKey)
        BSSWalk(49.5, FwdKey)
        BSSWalk(2.25, BackKey, LeftKey)
        BSSWalk(36, LeftKey)
        Send "{' . RotLeft . ' 2}"
        Send "{" FwdKey " down}"
        Send "{space down}"
        HyperSleep(300)
        Send "{space up}"
        HyperSleep(500)
        Send "{' . RotRight . ' 2}"
        HyperSleep(1000)
        Send "{space down}"
        HyperSleep(300)
        Send "{space up}"
        Walk(6)
        Send "{" FwdKey " up}"
        BSSWalk(6, RightKey)
        BSSWalk(7, FwdKey)
        BSSWalk(6, LeftKey)
        BSSWalk(3, RightKey)
        BSSWalk(32, FwdKey)
        BSSWalk(8.5, BackKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else
    {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . RightKey . ' down}{' . BackKey . ' down}"
        HyperSleep(1150)
        Send "{space 2}"
        HyperSleep(4050)
        Send "{" BackKey " up}"
        HyperSleep(1000)
        Send "{" RightKey " up}"
        Sleep(2200)
        Send "{' . RotRight . ' 4}"
        BSSWalk(14, LeftKey)
        BSSWalk(4, FwdKey)
        BSSWalk(3, BackKey)
        BSSWalk(11, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
}

gtq_polar() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31.5, FwdKey)
        BSSWalk(9, LeftKey)
        BSSWalk(9, BackKey)
        BSSWalk(58.5, LeftKey)
        BSSWalk(49.5, FwdKey)
        BSSWalk(3.375, LeftKey)
        BSSWalk(36, FwdKey)
        BSSWalk(60, RightKey)
        BSSWalk(60, BackKey)
        BSSWalk(9, LeftKey)
        BSSWalk(9, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    } else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{' . RotLeft . ' 4}"
        Sleep(100)
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . FwdKey . ' down}"
        HyperSleep(800)
        Send "{' . FwdKey . ' up}{space 2}"
        HyperSleep(2100)
        Send "{space}"
        Sleep(1000)
        BSSWalk(7, BackKey, LeftKey)
        BSSWalk(9, LeftKey, FwdKey)
        BSSWalk(5, FwdKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    movement :=
        (
            '
    BSSWalk(5, BackKey)
    BSSWalk(2, RightKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gtq_riley() {
    global function, FwdKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    send("{" SC_Space " down}"), sleep(100)
    send("{" SC_Space " up}")
    BSSWalk(2, RightKey)
    BSSWalk(1.8, FwdKey, RightKey)
    BSSWalk(32, RightKey)
    send("{" SC_Space " down}"), HyperSleep(300)
    send("{" SC_Space " up}")
    BSSWalk(2, RightKey)
    BSSWalk(6, RightKey, FwdKey)
    BSSWalk(3, RightKey)
    send("{" RotRight " 2}"), Sleep(100)
    Send "{" FwdKey " down}"
    send("{" SC_Space " down}"), HyperSleep(300)
    Send "{" FwdKey " up}"
    send("{" SC_Space " up}")
    BSSWalk(2, FwdKey), Sleep(1000)
    send("{" SC_Space " down}{" Rightkey " down}"), HyperSleep(100)
    send("{" SC_Space " up}"), HyperSleep(100)
    send("{" SC_Space " down}"), HyperSleep(100), send("{" SC_Space " up}"), HyperSleep(100)
    Send "{space}{' . RightKey . ' up}"
    Sleep(100)
    Send "{space up}"
    Sleep(1000)
    BSSWalk(1, FwdKey, RightKey)
    BSSWalk(20, RightKey)
    BSSWalk(2, FwdKey)
    BSSWalk(12, FwdKey, RightKey)
    BSSWalk(10, FwdKey)
    BSSWalk(6, BackKey)
    send("{" RotRight " 2}"), Sleep(100)
    BSSWalk(5, FwdKey)
    Sleep(100)
    send("{" SC_Space " down}"), HyperSleep(300)
    send("{" SC_Space " up}"), BSSWalk(6, FwdKey)
    Sleep(300)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
    ; 12/23/2024 - dully176 - Reworked Path.
}

gtp_bamboo()
{
    global MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    if (MoveMethod = "walk")
    {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(23.5, FwdKey)
        BSSWalk(31.5, FwdKey, RightKey)
        BSSWalk(10, RightKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(20, FwdKey)
        BSSWalk(5, FwdKey, LeftKey)
        BSSWalk(7, LeftKey)
        BSSWalk(1, FwdKey)
        BSSWalk(8, RightKey)
        BSSWalk(14, BackKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{' . RotLeft . ' 2}{e down}"
        HyperSleep(100)
        Send "{e up}{' . FwdKey . ' down}"
        HyperSleep(800)
        Send "{" SC_space " 2}"
        HyperSleep(3000)
        Send "{' . FwdKey . ' up}{' . LeftKey . ' down}"
        HyperSleep(1000)
        Send "{" SC_space "}"
        Send "{' . LeftKey . ' up}"
        HyperSleep(1000)
        BSSWalk(20, LeftKey)
        BSSWalk(30, FwdKey)
        BSSWalk(8, RightKey)
        BSSWalk(14, BackKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;path 230729 noobyguy
}

gtp_blueflower() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft
    function := A_ThisFunc
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(88.875, BackKey, LeftKey)
        BSSWalk(27, LeftKey)
        HyperSleep(50)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(17, FwdKey)
        BSSWalk(17, LeftKey)
        BSSWalk(18, FwdKey)
        BSSWalk(10, BackKey)
        BSSWalk(7, BackKey, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . LeftKey . ' down}"
        HyperSleep(700)
        Send "{space 2}"
        HyperSleep(4450)
        Send "{' . LeftKey . ' up}{space}"
        HyperSleep(1000)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(19, LeftKey)
        BSSWalk(18, FwdKey)
        BSSWalk(10, BackKey)
        BSSWalk(7, BackKey, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;path 230729 noobyguy
}

gtp_cactus() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk")
    {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7.8, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(5, RightKey)
        BSSWalk(1.5, FwdKey)
        BSSWalk(60, LeftKey)
        BSSWalk(49.5, FwdKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(35.5, FwdKey)
        BSSWalk(3, RightKey)
        BSSWalk(7, BackKey)
        Send "{' . RotRight . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . RightKey . ' down}{' . BackKey . ' down}"
        HyperSleep(890)
        Send "{space 2}"
        HyperSleep(2500)
        Send "{" RightKey " up}"
        HyperSleep(1100)
        Send "{' . BackKey . ' up}{space}{' . RotLeft . ' 4}"
        HyperSleep(600)
        BSSWalk(15, FwdKey, RightKey)
        BSSWalk(22, RightKey)
        BSSWalk(30, BackKey)
        BSSWalk(7, LeftKey)
        Send "{' . RotLeft . ' 4}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;path 230729 noobyguy
}

gtp_clover() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey
    function := A_ThisFunc
    if (MoveMethod = "walk")
    {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(44.75, BackKey, LeftKey)
        BSSWalk(52.5, LeftKey)
        BSSWalk(2.8, BackKey, RightKey)
        BSSWalk(6.7, BackKey)
        BSSWalk(25.5, LeftKey)
        BSSWalk(35, FwdKey, LeftKey)
        BSSWalk(7, BackKey, RightKey)
        BSSWalk(12, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else
    {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . LeftKey . ' down}{' . FwdKey . ' down}"
        HyperSleep(525)
        Send "{space 2}"
        HyperSleep(1250)
        Send "{" FwdKey " up}"
        HyperSleep(3850)
        Send "{' . LeftKey . ' up}{space}"
        HyperSleep(1000)
        BSSWalk(10, FwdKey, LeftKey)
        BSSWalk(15, LeftKey)
        BSSWalk(7, FwdKey)
        BSSWalk(7, BackKey, RightKey)
        BSSWalk(12, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;path 230729 noobyguy
}

gtp_coconut() {
    global function, FwdKey, LeftKey, RightKey
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{' . RightKey . ' down}"
    Sleep(100)
    Send "{space up}"
    Walk(2)
    Send "{" FwdKey " down}"
    BSSWalk(1.8)
    Send "{" FwdKey " up}"
    Walk(30)
    Send "{' . RightKey . ' up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(4, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(3, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(5, FwdKey)
    BSSWalk(2, LeftKey, FwdKey)
    BSSWalk(8, FwdKey)
    Send "{" FwdKey " down}{' . RightKey . ' down}"
    Walk(11)
    Send "{space down}{' . RightKey . ' up}"
    HyperSleep(200)
    Send "{space up}"
    HyperSleep(1100)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    Walk(18)
    Send "{" FwdKey " up}"
    BSSWalk(7, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
    ;path 230212 zaappiix
}

gtp_dandelion() {
    global function, FwdKey, BackKey, RotLeft, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    Send "{' . RotRight . '}"
    BSSWalk(39, BackKey)
    Send "{' . RotLeft . ' 3}"
    BSSWalk(51, FwdKey)
    BSSWalk(15, BackKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gtp_mountaintop() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk")
    {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7.8, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(5, RightKey)
        BSSWalk(1.5, FwdKey)
        BSSWalk(60, LeftKey)
        BSSWalk(3.75, RightKey)
        BSSWalk(85, FwdKey)
        BSSWalk(45, RightKey)
        BSSWalk(50, BackKey)
        BSSWalk(60, RightKey)
        BSSWalk(5, LeftKey)
        BSSWalk(7, FwdKey)
        BSSWalk(9, FwdKey, LeftKey)
        BSSWalk(16.5, FwdKey)
        Send "{' . RotRight . ' 4}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}"
        Sleep(2750)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;path 230729 noobyguy
}

gtp_mushroom() {
    global function, FwdKey, LeftKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    Send "{' . RotRight . ' 4}"
    HyperSleep(200)
    BSSWalk(55.75, FwdKey, RightKey)
    BSSWalk(26.5, FwdKey)
    BSSWalk(10, FwdKey, RightKey)
    BSSWalk(5, LeftKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
    ;path 230729 noobyguy
}

gtp_pepper() {
    global function, FwdKey, LeftKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    Send "{space down}{' . RightKey . ' down}"
    Sleep(100)
    Send "{space up}"
    Walk(2)
    Send "{" FwdKey " down}"
    BSSWalk(1.8)
    Send "{" FwdKey " up}"
    Walk(30)
    Send "{' . RightKey . ' up}{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(4, RightKey)
    BSSWalk(5, FwdKey)
    BSSWalk(3, RightKey)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    BSSWalk(6, FwdKey)
    BSSWalk(2, LeftKey, FwdKey)
    BSSWalk(8, FwdKey)
    Send "{" FwdKey " down}{' . RightKey . ' down}"
    Walk(11)
    Send "{space down}{' . RightKey . ' up}"
    HyperSleep(200)
    Send "{space up}"
    HyperSleep(1100)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    Walk(18)
    Send "{space down}"
    HyperSleep(200)
    Send "{space up}"
    Walk(20)
    Send "{" RightKey " down}"
    Walk(9)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    Walk(1)
    Send "{" FwdKey " up}"
    Walk(33)
    Send "{space down}"
    HyperSleep(300)
    Send "{space up}"
    Walk(6)
    Send "{' . RotRight . ' 2}"
    BSSWalk(30, FwdKey)
    Send "{" RightKey " up}"
    BSSWalk(10, FwdKey)
    BSSWalk(10, BackKey, LeftKey)
    BSSWalk(4, BackKey)
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
    ;path 230212 zaappiix

}

gtp_pineapple() {
    global function, MoveMethod, HiveBees, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    If (HiveBees >= 25) && (MoveMethod = "cannon")
    {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}"
        HyperSleep(500)
        Send "{' . RotRight . ' 4}{' . RightKey . ' down}"
        HyperSleep(1000)
        Send "{space}"
        HyperSleep(500)
        Send "{space}"
        HyperSleep(2900)
        Send "{' . RightKey . ' up}{' . FwdKey . ' down}{' . LeftKey . ' down}"
        HyperSleep(1600)
        Send "{space}"
        HyperSleep(1000)
        BSSWalk(14, FwdKey, LeftKey)
        BSSWalk(10, FwdKey)
        BSSWalk(7, BackKey, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(30, FwdKey)
        BSSWalk(20, FwdKey, RightKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(43.5, FwdKey)
        BSSWalk(18, RightKey)
        BSSWalk(6, FwdKey)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(66, FwdKey)
        BSSWalk(19, FwdKey, LeftKey)
        BSSWalk(7, BackKey, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;path 230212 zaappiix
    ;path 230729 noobyguy: If (HiveBees < 25) && (MoveMethod = "cannon") & walk path
    ;path ferox7274: cannon path

}

gtp_pinetree() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    If (MoveMethod = "walk")
    {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7.8, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(5, RightKey)
        BSSWalk(1.5, FwdKey)
        BSSWalk(60, LeftKey)
        BSSWalk(3.75, RightKey)
        BSSWalk(45, FwdKey)
        BSSWalk(47, LeftKey, FwdKey)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(9, RightKey)
        BSSWalk(9, FwdKey)
        BSSWalk(16, LeftKey)
        BSSWalk(5, BackKey)
        Send "{' . RotRight . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . RightKey . ' down}{' . BackKey . ' down}"
        HyperSleep(925)
        Send "{space 2}"
        HyperSleep(5000)
        Send "{" BackKey " up}{' . RightKey . ' up}{space}"
        Sleep(1000)
        Send "{' . RotRight . ' 3}{' . FwdKey . ' down}{space down}"
        HyperSleep(300)
        Send "{space up}"
        Send "{space}"
        HyperSleep(2000)
        Send "{" FwdKey " up}{' . RotLeft . ' 1}"
        BSSWalk(15, RightKey)
        BSSWalk(15, FwdKey)
        BSSWalk(16, LeftKey)
        BSSWalk(5, BackKey)
        Send "{' . RotRight . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;path 230212 zaappiix
    ;path 230729 noobyguy

}

gtp_pumpkin() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk")
    {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7.8, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(5, RightKey)
        BSSWalk(1.5, FwdKey)
        BSSWalk(60, LeftKey)
        BSSWalk(3.75, RightKey)
        BSSWalk(45, FwdKey)
        BSSWalk(34, RightKey, FwdKey)
        BSSWalk(10, RightKey)
        BSSWalk(12, LeftKey)
        BSSWalk(3, BackKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . RightKey . ' down}{' . BackKey . ' down}"
        HyperSleep(890)
        Send "{space 2}"
        HyperSleep(2500)
        Send "{" RightKey " up}"
        HyperSleep(1100)
        Send "{' . BackKey . ' up}{space}{' . RotLeft . ' 4}"
        HyperSleep(600)
        BSSWalk(15, FwdKey)
        BSSWalk(24, RightKey)
        BSSWalk(12, LeftKey)
        BSSWalk(3, BackKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;path 230729 noobyguy

}

gtp_rose() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk")
    {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7.8, LeftKey)
        BSSWalk(10, BackKey)
        BSSWalk(5, RightKey)
        BSSWalk(1.5, FwdKey)
        BSSWalk(60, LeftKey)
        BSSWalk(3.75, RightKey)
        BSSWalk(38, FwdKey)
        Send "{' . RotLeft . ' 4}"
        BSSWalk(14, RightKey)
        BSSWalk(15, FwdKey, LeftKey)
        BSSWalk(1, BackKey)
        HyperSleep(200)
        BSSWalk(16, RightKey)
        BSSWalk(49, FwdKey)
        Send "{' . RotLeft . ' 4}"
        BSSWalk(10, RightKey)
        BSSWalk(12, RightKey, FwdKey)
        BSSWalk(7, BackKey, LeftKey)
        Send "{' . RotLeft . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . RightKey . ' down}"
        HyperSleep(550)
        Send "{space 2}"
        HyperSleep(2500)
        Send "{' . RightKey . ' up}{space}{' . RotLeft . ' 4}"
        HyperSleep(1000)
        BSSWalk(17, FwdKey)
        BSSWalk(10, RightKey)
        BSSWalk(8, FwdKey, RightKey)
        BSSWalk(8, FwdKey)
        BSSWalk(7, BackKey, LeftKey)
        Send "{' . RotLeft . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;path 230729 noobyguy

}

gtp_spider() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(37.5, FwdKey)
        BSSWalk(38, LeftKey, FwdKey)
        BSSWalk(9, BackKey, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . BackKey . ' down}"
        HyperSleep(1050)
        Send "{space 2}"
        HyperSleep(300)
        Send "{' . BackKey . ' up}{space}{' . RotLeft . ' 4}"
        Sleep(1500)
        BSSWalk(20, FwdKey)
        BSSWalk(10, FwdKey, LeftKey)
        BSSWalk(10, LeftKey)
        BSSWalk(9, BackKey, RightKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;path 230729 noobyguy

}

gtp_strawberry() {
    global function, MoveMethod, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    if (MoveMethod = "walk") {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(31, FwdKey)
        BSSWalk(7, FwdKey, LeftKey)
        BSSWalk(30.25, LeftKey)
        BSSWalk(30, FwdKey, LeftKey)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(10, BackKey, LeftKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . RightKey . ' down}{' . BackKey . ' down}"
        HyperSleep(750)
        Send "{space 2}"
        HyperSleep(1000)
        Send "{" RightKey " up}{' . BackKey . ' up}"
        HyperSleep(800)
        Send "{space}{' . RotRight . ' 2}"
        Sleep(2000)
        BSSWalk(10, FwdKey, RightKey)
        BSSWalk(15, RightKey)
        BSSWalk(15, FwdKey)
        BSSWalk(10, BackKey, LeftKey)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    ;path 230729 noobyguy

}

gtp_stump() {
    global function, MoveMethod, HiveBees, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight
    function := A_ThisFunc
    If (HiveBees >= 25) && (MoveMethod = "cannon") {
        gt_ramp()
        gt_redcannon()
        movement :=
            (
                '
        Send "{e down}"
        HyperSleep(100)
        Send "{e up}{' . LeftKey . ' down}"
        HyperSleep(1800)
        Send "{space 2}"
        HyperSleep(2750)
        Send "{' . LeftKey . ' up}{' . RotLeft . ' 2}{' . FwdKey . ' down}{' . LeftKey . ' down}"
        HyperSleep(900)
        Send "{' . LeftKey . ' up}"
        HyperSleep(1500)
        Send "{' . FwdKey . ' up}{space}"
        Sleep(1000)
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }
    else {
        gt_ramp()
        movement :=
            (
                '
        BSSWalk(67.5, BackKey, LeftKey)
        Send "{' . RotRight . ' 4}"
        BSSWalk(30, FwdKey)
        BSSWalk(20, FwdKey, RightKey)
        Send "{' . RotRight . ' 2}"
        BSSWalk(43.5, FwdKey)
        BSSWalk(18, RightKey)
        BSSWalk(6, FwdKey)
        Send "{' . RotLeft . ' 2}"
        BSSWalk(43, FwdKey)
        BSSWalk(30, FwdKey, RightKey)
        BSSWalk(50, RightKey)
        BSSWalk(14, BackKey, LeftKey)
        BSSWalk(10, LeftKey)
        Send "{' . RotRight . ' 2}"
        '
            )
        CreatePath(movement)
        KeyWait "F14", "D T5 L"
        KeyWait "F14", "T60 L"
        EndWalk()
    }

}

gtp_sunflower() {
    global function, FwdKey, BackKey, RightKey, RotRight
    function := A_ThisFunc
    gt_ramp()
    movement :=
        (
            '
    BSSWalk(14, BackKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(25, RightKey)
    BSSWalk(15, FwdKey)
    BSSWalk(9, BackKey)
    Send "{' . RotRight . ' 1}"
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gtc_honeystormFromClock() {
    global LeftKey, BackKey, RightKey
    movement :=
        (
            '
    Hypersleep(550)
    Send "{d down}"
    BSSWalk(12.64)
    Send "{a down}"
    BSSWalk(0.44)
    Send "{d up}"
    BSSWalk(8.88)
    Send "{d down}"
    Send "{a up}"
    BSSWalk(10.68)
    Send "{s down}"
    Send "{d up}"
    BSSWalk(5.99)
    Send "{s up}"
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

loot_honeyStorm() {
    global FwdKey, LeftKey, BackKey, RightKey
    movement :=
        (
            '
    Hypersleep(2000)
    Send "{w down}"
    BSSWalk(8.63)
    Send "{d down}"
    Send "{w up}"
    BSSWalk(17.96)
    Send "{s down}"
    Send "{d up}"
    BSSWalk(7.80)
    Send "{a down}"
    BSSWalk(0.41)
    Send "{s up}"
    BSSWalk(6.39)
    Send "{w down}"
    BSSWalk(0.47)
    Send "{a up}"
    BSSWalk(6.73)
    Send "{d down}"
    BSSWalk(0.71)
    Send "{w up}"
    BSSWalk(4.95)
    Send "{s down}"
    Send "{d up}"
    BSSWalk(5.88)
    Send "{a down}"
    BSSWalk(0.44)
    Send "{s up}"
    BSSWalk(4.72)
    Send "{w down}"
    Send "{a up}"
    BSSWalk(1.57)
    Send "{d down}"
    BSSWalk(0.80)
    Send "{d up}"
    BSSWalk(3.27)
    Send "{d down}"
    Send "{w up}"
    BSSWalk(3.80)
    Send "{s down}"
    BSSWalk(0.43)
    Send "{d up}"
    BSSWalk(4.35)
    Send "{a down}"
    BSSWalk(0.36)
    Send "{s up}"
    BSSWalk(2.86)
    Send "{w down}"
    BSSWalk(0.62)
    Send "{a up}"
    BSSWalk(3.68)
    Send "{d down}"
    BSSWalk(0.39)
    Send "{w up}"
    BSSWalk(1.87)
    Send "{s down}"
    BSSWalk(0.65)
    Send "{d up}"
    BSSWalk(3.06)
    Send "{a down}"
    BSSWalk(0.60)
    Send "{s up}"
    BSSWalk(0.55)
    Send "{w down}"
    BSSWalk(0.74)
    Send "{a up}"
    BSSWalk(3.45)
    Send "{d down}"
    BSSWalk(0.55)
    Send "{w up}"
    BSSWalk(0.58)
    Send "{s down}"
    BSSWalk(0.44)
    Send "{d up}"
    BSSWalk(4.91)
    Send "{a down}"
    BSSWalk(0.70)
    Send "{s up}"
    BSSWalk(0.51)
    Send "{w down}"
    BSSWalk(0.51)
    Send "{a up}"
    BSSWalk(6.54)
    Send "{a down}"
    BSSWalk(0.52)
    Send "{w up}"
    BSSWalk(0.65)
    Send "{s down}"
    Send "{a up}"
    BSSWalk(7.00)
    Send "{a down}"
    BSSWalk(0.54)
    Send "{s up}"
    BSSWalk(0.43)
    Send "{w down}"
    Send "{a up}"
    BSSWalk(8.03)
    Send "{a down}"
    Send "{w up}"
    BSSWalk(0.67)
    Send "{s down}"
    BSSWalk(0.42)
    Send "{a up}"
    BSSWalk(8.09)
    Send "{d down}"
    Send "{s up}"
    BSSWalk(6.94)
    Send "{w down}"
    Send "{d up}"
    BSSWalk(7.36)
    Send "{a down}"
    BSSWalk(0.51)
    Send "{w up}"
    BSSWalk(7.73)
    Send "{a up}"
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_driveshop_from_robobear() {
    global FwdKey, LeftKey, BackKey, RightKey
    movement :=
        (
            '
    Send "{a down}"
    Walk(6)
    Send "{a up}"
    Send "{w down}"
    BSSWalk(9.38)
    Send "{w up}"
    Jump()
    Hypersleep(344)
    Send "{w down}"
    BSSWalk(9.62)
    Send "{d down}"
    Send "{w up}"
    BSSWalk(4.78)
    Send "{w down}"
    BSSWalk(4.48)
    Send "{w up}"
    Send "{d up}"
    Send "{a down}"
    BSSWalk(4.06)
    Send "{a up}"
    Send "{s down}"
    BSSWalk(3.11)
    Send "{s up}"
    Hypersleep(283)
    Send "{d down}"
    BSSWalk(12.21)
    Send "{d up}"
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_robobear_from_driveshop() {
    global FwdKey, LeftKey, BackKey, RightKey
    movement :=
        (
            '
    Send "{w down}"
    BSSWalk(5.80)
    Send "{w up}"
    Send "{d down}"
    BSSWalk(12.54)
    Send "{d up}"
    Send "{w down}"
    BSSWalk(7.72)
    Send "{w up}"
    Send "{a down}"
    BSSWalk(6.55)
    Send "{a up}"
    Hypersleep(230)
    Send "{s down}"
    BSSWalk(10.62)
    Send "{s up}"
    Send "{a down}"
    BSSWalk(3.13)
    Send "{a up}"
    Jump()
    Hypersleep(345)
    Send "{a down}"
    BSSWalk(5.35)
    Send "{a up}"
    Send "{s down}"
    BSSWalk(1.81)
    Send "{s up}"
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_hiveslot1() {
    global FwdKey, LeftKey, RightKey, RotLeft, RotRight
    movement :=
        (
            '
    BSSWalk(2.5, RightKey)
    Send "{' . RotRight . ' 1}"
    ShiftLock()
    ActivateGlider()
    Sleep(1000)
    BSSWalk(9.5, FwdKey)
    Send "{' . RotLeft . ' 1}"
    ShiftLock()
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_hiveslot2() {
    global FwdKey, RotLeft, RotRight
    movement :=
        (
            '
    ShiftLock()
    BSSWalk(5, FwdKey)
    Send "{' . RotRight . ' 1}"
    ActivateGlider()
    Sleep(1000)
    BSSWalk(1.5, FwdKey)
    Send "{' . RotLeft . ' 1}"
    BSSWalk(0.5, FwdKey)
    ShiftLock()
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_hiveslot3() {
    global FwdKey
    movement :=
        (
            '
    ShiftLock()
    ActivateGlider()
    Sleep(1000)
    BSSWalk(2, FwdKey)
    ShiftLock()
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

gt_hiveslot4() {
    global FwdKey, RotLeft, RotRight
    movement :=
        (
            '
    ShiftLock()
    BSSWalk(5, FwdKey)
    Send "{' . RotLeft . ' 1}"
    ActivateGlider()
    Sleep(1000)
    BSSWalk(1.5, FwdKey)
    Send "{' . RotRight . ' 1}"
    BSSWalk(0.5, FwdKey)
    ShiftLock()
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}
gt_hiveslot5() {
    global FwdKey, LeftKey, RotLeft, RotRight
    movement :=
        (
            '
    BSSWalk(3.5, LeftKey)
    Send "{' . RotLeft . ' 1}"
    ShiftLock()
    ActivateGlider()
    Sleep(1000)
    BSSWalk(9.5, FwdKey)
    Send "{' . RotRight . ' 1}"
    ShiftLock()
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}
gt_hiveslot6() {
    global FwdKey, LeftKey, RotLeft, RotRight
    movement :=
        (
            '
    ShiftLock()
    Send "{' . RotLeft . ' 1}"
    ActivateGlider()
    Sleep(1000)
    Send "{' . RotLeft . ' 1}"
    ActivateGlider()
    Sleep(1000)
    Send "{' . RotRight . ' 1}"
    BSSWalk(7.5, FwdKey)
    BSSWalk(1.5, FwdKey, LeftKey)
    Send "{' . RotRight . ' 1}"
    ShiftLock()
    '
        )
    CreatePath(movement)
    KeyWait "F14", "D T5 L"
    KeyWait "F14", "T60 L"
    EndWalk()
}

fallbackhiveclaimpath() {
    Move(2.5, d)
    Rotate("right", 1)
    ShiftLock() ; activate
    ActivateGlider()
    Sleep 1000
    Move(9.5, w)
    Rotate("left", 1)
    ShiftLock() ; deactivate
    searchPhrase := "Claim"
    loop 6 {
        result := OCR.FromDesktop(, 2)
        found := result.FindStrings(searchPhrase)
        if found.Length {
            global Hiveslot := A_Index
            successv1 := 1
            break
        }
        Move(9.3, "a")
        Hypersleep 400
    }
    if successv1 := 0 {
        ;                   restart or so, fallback mechanism
    }
}