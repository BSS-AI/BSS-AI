CornerXSnake(size, reps, facingcorner) {
    Move(4 * size, TCLRKey)
    Move(2 * size, TCFBKey)
    Move(8 * size, AFCLRKey)
    Move(2 * size, TCFBKey)
    Move(8 * size, TCLRKey)
    Move(Sqrt(((8 * size) ** 2) + ((8 * size) ** 2)), AFCLRKey, AFCFBKey)
    Move(8 * size, TCLRKey)
    Move(2 * size, TCFBKey)
    Move(8 * size, AFCLRKey)
    Move(6.7 * size + 10, TCFBKey)
    Move(6 + reps, AFCLRKey)
    Move(3, TCFBKey)
    Move(2 + reps, TCLRKey)
    Move(5, AFCFBKey)
    Move(8 * size, TCLRKey)
    Move(2 * size, AFCFBKey)
    Move(8 * size, AFCLRKey)
    Move(2 * size, AFCFBKey)
    Move(8 * size, TCLRKey)
    Move(2 * size, AFCFBKey)
    Move(8 * size, AFCLRKey)
    Move(3 * size, AFCFBKey)
    Move(8 * size, TCLRKey)
    Move(Sqrt(((4 * size) ** 2) + ((4 * size) ** 2)), TCFBKey, AFCLRKey)
}
Fork(size, reps, facingcorner) {
    CForkGap := 0.75 ; flowers between lines
    CForkDiagonal := CForkGap * sqrt(2)
    CForkLength := (40 - CForkGap * 16 - CForkDiagonal * 4) / 6

    if (facingcorner) {
        Move(1.5, 10, FwdKey)
    }

    Move(CForkDiagonal * 2, TCLRKey, AFCFBKey)
    Move(((reps - 1) * 4 + 2) * CForkGap, TCFBKey)
    Move(CForkDiagonal * 2, TCFBKey, TCLRKey)

    loop reps {
        Move(CForkLength * size, TCFBKey)
        Move(CForkGap * 2, AFCLRKey)
        Move(CForkLength * size, AFCLRKey)
        Move(CForkGap * 2, AFCFBKey)
        Move(CForkLength * size, AFCFBKey)
        Move(CForkGap * 2, TCFBKey)
    }

    Move(CForkLength * size, TCFBKey)
    Move(CForkGap * 2, AFCLRKey)
    Move(CForkLength * size, AFCLRKey)
}
Lines(size, reps, facingcorner) {
    loop reps {
        Move(11 * size, TCFBKey)
        Move(1, TCLRKey)
        Move(11 * size, AFCFBKey)
        Move(1, TCLRKey)
    }
    ; away from center
    loop reps {
        Move(11 * size, TCFBKey)
        Move(1, AFCLRKey)
        Move(11 * size, AFCFBKey)
        Move(1, AFCLRKey)
    }
}
Slimline(size, reps, facingcorner) {
    Move((4 * size) + (reps * 0.1) - 0.1, TCLRKey,)
    Move(8 * size, AFCLRKey)
    Move(4 * size, TCLRKey)
}
Snake(size, reps, facingcorner) {
    loop reps {
        Move(11 * size, TCLRKey)
        Move(1, TCFBKey)
        Move(11 * size, AFCLRKey)
        Move(1, TCFBKey)
    }
    loop reps {
        Move(11 * size, TCLRKey)
        Move(1, AFCFBKey)
        Move(11 * size, AFCLRKey)
        Move(1, AFCFBKey)
    }
}
Squares(size, reps, facingcorner) {
    loop reps {
        Move(5 * size + A_Index, TCFBKey)
        Move(5 * size + A_Index, TCLRKey)
        Move(5 * size + A_Index, AFCFBKey)
        Move(5 * size + A_Index, AFCLRKey)
    }
}
SuperCat(size, reps, facingcorner) {
    loop reps {
        Move(1.25 * size, TCLRKey) ; Left 1.5
        Move(7 * size, TCFBKey) ; Left forward 78
        Move(1.25 * size, TCLRKey) ; Forward Left 1.5
        Move(6.66 * size, AFCFBKey) ; Left Back 6.66
        Move(1.25 * size, TCLRKey) ; Back Left 1.5
        Move(7 * size, TCFBKey) ; Left forward 78
        Move(2 * size, TCLRKey) ; Forward Left 1.5
        Move(6.5 * size, AFCFBKey) ; Left Back 6.66
    }
    loop reps {
        Move(1.25 * size, AFCLRKey) ; Right 1.5
        Move(7 * size, TCFBKey) ; Right Forward 7
        Move(1 * size, AFCLRKey) ; Forward Right 1.5
        Move(6.66 * size, AFCFBKey) ; Right Back 6.66
        Move(1.25 * size, AFCLRKey) ; Back Right 1.5
        Move(7 * size, TCFBKey) ; Right Forward 6.66
        Move(1.25 * size, AFCLRKey) ; Forward Right 1.5
        Move(6.5 * size, AFCFBKey) ; Right Back 6.66
    }
}
XSnake(size, reps, facingcorner) {
    loop reps {
        Move(4 * size, TCLRKey)
        Move(2 * size, TCFBKey)
        Move(8 * size, AFCLRKey)
        Move(2 * size, TCFBKey)
        Move(8 * size, TCLRKey)
        Move(Sqrt(((8 * size) ** 2) + ((8 * size) ** 2)), AFCLRKey, AFCFBKey)
        Move(8 * size, TCLRKey)
        Move(2 * size, TCFBKey)
        Move(8 * size, AFCLRKey)
        Move(6.7 * size, TCFBKey)
        Move(8 * size, TCLRKey)
        Move(2 * size, AFCFBKey)
        Move(8 * size, AFCLRKey)
        Move(2 * size, AFCFBKey)
        Move(8 * size, TCLRKey)
        Move(2 * size, AFCFBKey)
        Move(8 * size, AFCLRKey)
        Move(3 * size, AFCFBKey)
        Move(8 * size, TCLRKey)
        Move(Sqrt(((4 * size) ** 2) + ((4 * size) ** 2)), TCFBKey, AFCLRKey)
    }
}
Bowl(size, reps, facingcorner) {
    StepSize := 3
    rightDrift := 2
    rightOff := 2
    downDrift := 1
    downOff := 3
    digistops := 0
    PassiveFDC := 0.3
    ; ^^^ Passive field drift comp, recommend having it low.
    Send("{" RotUp " 4}"), Sleep(50)
    one(type := 0, digi := 0) {
        Move(StepSize * size, BackKey)
        Move(StepSize * size, RightKey)
        Move(StepSize * size, FwdKey)
        if (type = 1) {
            Rotate("left", 2), Sleep(50)
            Move(rightDrift + rightOff, BackKey)
            Move(rightOff, FwdKey)
            DS(800, digi)
            Rotate("right", 2), Sleep(50)
        }
        Move(StepSize * size * 2, LeftKey)
        DS(850, digi)
        Rotate("left", 1), Sleep(50)
        Move(StepSize * size, BackKey, LeftKey)
        if (type = 2) {
            Rotate("left", 1), Sleep(50)
            Move(downDrift + downOff, LeftKey)
            Move(downOff, RightKey)
            Rotate("right", 1), Sleep(50)
        }
        Move(StepSize * size, BackKey, RightKey)
        Move(StepSize * size * 2, FwdKey, RightKey)
        Rotate("right", 1), Sleep(50)
        Move(StepSize * size, LeftKey)
        DS(850, digi)
        Move(StepSize * size, BackKey)
        Move(StepSize * size * 2, RightKey)
        Rotate("left", 1), Sleep(50)
        Move(StepSize * size, FwdKey, RightKey)
        ;DS(850, digi) ; duplicate
        Move(StepSize * size, FwdKey, LeftKey)
        Move(StepSize * size, BackKey, LeftKey)
        Rotate("right", 1), Sleep(50)
    }
    two(digi := 0) {
        Move(StepSize * size + PassiveFDC, BackKey, RightKey)
        DS(850, digi)
        Move(StepSize * size, FwdKey, RightKey)
        Move(StepSize * size, FwdKey, LeftKey)
        ;if(type=1){
        ;    nm_cameraRotation("left", 2), Sleep(50)
        ;    Move(rightDrift+rightOff, BackKey)
        ;    Move(rightOff, FwdKey)
        ;    nm_cameraRotation("right", 2), Sleep(50)
        ;}
        Move(StepSize * size * 2, BackKey, LeftKey)
        Rotate("left", 1), Sleep(50)
        Move(StepSize * size + PassiveFDC, BackKey)
        ;if (type=2){
        ;    nm_cameraRotation("left", 1), Sleep(50)
        ;    Move(downDrift+downOff, LeftKey)
        ;    Move(downOff, RigthKey)
        ;    nm_cameraRotation("right", 1), Sleep(50)
        ;}
        Move(StepSize * size, RightKey)
        ;DS(850, digi) ; duplicate
        Move(StepSize * size * 2, FwdKey)
        Rotate("right", 1), Sleep(50)
        Move(StepSize * size, BackKey, LeftKey)
        DS(850, digi)
        Move(StepSize * size + PassiveFDC, BackKey, RightKey)
        Move(StepSize * size * 2, FwdKey, RightKey)
        Rotate("left", 1), Sleep(50)
        Move(StepSize * size, FwdKey)
        DS(850, digi)
        Move(StepSize * size, LeftKey)
        Move(StepSize * size + PassiveFDC, BackKey)
        Rotate("right", 1), Sleep(50)
    }
    DS(ms, digi) => (digistops && digi) ? (Sleep(ms), 1) : 0
    one(1, 1), two(1), one(2), two()
    Send("{" RotDown " 4}"), Sleep(50)
    ; made by dully176 with care, ported to bss ai by money_mountain
}
PineDriftRedux(size, reps, facingcorner) {
    ; your config
    x := 0 ; Height Offset
    y := 0 ; Width Offset
    z := 0 ; Alignment Offset, should be bigger than Height Offset
    Send("{" RotUp " 4}")
    Move(7 + x, RightKey, BackKey)
    Move(1.75 + y, LeftKey, BackKey)
    Move(7 + x, FwdKey, LeftKey)
    Move(1.75 + y, LeftKey, BackKey)
    Move(8 + z, BackKey, RightKey)
    Move(1, FwdKey)
    Move(1.75 + y, LeftKey, BackKey)
    Move(6 + x, FwdKey, LeftKey)
    Move(1.75 + y, LeftKey, BackKey)

    send "{" RotLeft "}"
    Move(6 + x, BackKey)
    Move(1.75 + y, RightKey)
    Move(6 + x, FwdKey)
    Move(1.75 + y, RightKey)
    Move(6 + x, BackKey)
    Move(1.75 + y, RightKey)
    Move(6 + x, FwdKey)
    Move(2 + y, RightKey)

    send "{" RotLeft "}"
    Move(7 + z, LeftKey, BackKey)
    Move(1.75 + y, LeftKey, FwdKey)
    Move(6 + z, FwdKey, RightKey)
    Move(1.75 + y, LeftKey, FwdKey)
    Move(7 + z, LeftKey, BackKey)
    Move(1.75 + y, LeftKey, FwdKey)
    Move(6 + z, FwdKey, RightKey)
    Move(2 + y, LeftKey, FwdKey)

    loop 2
        send("{" RotRight "}"), Sleep(50)
    Move(7 + z, BackKey, RightKey)
    Move(1.75 + y, FwdKey, RightKey)
    Move(6 + z, LeftKey, FwdKey)
    Move(1.75 + y, FwdKey, RightKey)
    Move(7 + z, BackKey, RightKey)
    Move(1.75 + y, FwdKey, RightKey)
    Move(6 + z, LeftKey, FwdKey)
    Move(2 + y, FwdKey, RightKey)

    send "{" RotLeft "}"
    Move(6 + x, BackKey)
    Move(1.75 + y, LeftKey)
    Move(6 + x, FwdKey)
    Move(1.75 + y, LeftKey)
    Move(6 + x, BackKey)
    Move(1.75 + y, LeftKey)
    Move(6 + x, FwdKey)
    Move(2 + y, LeftKey)

    send "{" RotLeft "}"
    Move(7 + z, LeftKey, BackKey)
    Move(1.75 + y, BackKey, RightKey)
    Move(6 + z, FwdKey, RightKey)
    Move(1.75 + y, BackKey, RightKey)
    Move(7 + z, LeftKey, BackKey)
    Move(1.75 + y, BackKey, RightKey)
    Move(6 + z, FwdKey, RightKey)
    Move(2 + y, BackKey RightKey)

    loop 2
        send("{" RotRight "}"), Sleep(50)
    Send("{" RotDown " 4}"), Sleep(30)
    ; fixed with care - dully
    ; ported with care - money_mountain
}