global bosses := Map(
    "TunnelBear", 172800,
    "KingBeetle", 86400,
    "StumpSnail", 345600,
    "CommandoChick", 1800,
    "CoconutCrab", 129600
)

global mobs := Map(
    "Werewolf", 3630,
    "Spider", 1830,
    "Ladybug", 330,
    "RhinoBeetle", 330,
    "Mantis", 1230,
    "Scorpion", 1230
)


CheckKill(b) {
    for bossName in bosses {
        if (%bossName% && (nowUnix() - Last%bossName% >= floor(bosses[bossName] * (1 - (mobRespawnTime ? mobRespawnTime : 0) * 0.01)))) {
            if b
                return true
            KillBoss(bossName)
        }
    }
    for mobName in mobs {
        if (%mobName% && (nowUnix() - Last%mobName% >= floor(mobs[mobName] * (1 - (mobRespawnTime ? mobRespawnTime : 0) * 0.01)))) {
            KillMob(mobName)
            if b
                return true
        }
    }
}

KillMob(mob) {
    ResetToHive()
    switch mob {
        case "Werewolf":
            SetStatus("Traveling", "Werewolf")
            Kill_Werewolf()
            SetStatus("Killed", "Werewolf")
            LastWerewolf := nowUnix()
            writeSettings("Kill", "LastWerewolf", nowUnix(), "Settings\timers.ini")
        case "Spider":
            SetStatus("Traveling", "Spider")
            Kill_Spider()
            SetStatus("Killed", "Spider")
            LastSpider := nowUnix()
            writeSettings("Kill", "LastSpider", nowUnix(), "Settings\timers.ini")
        case "Mantis":
            SetStatus("Traveling", "Mantis")
            Kill_MantisPineTree()
            if (!rhinoBeetle) {
                ResetToHive()
                Kill_BeetleMantisPineapple()
            }
            SetStatus("Killed", "Mantis")
            LastMantis := nowUnix()
            writeSettings("Kill", "LastMantis", nowUnix(), "Settings\timers.ini")
        case "RhinoBeetle":
            SetStatus("Traveling", "Rhino Beetle")
            Kill_BeetleLadybugClover()
            ResetToHive()
            gt_bamboo()
            Loot(5, 5, "Right")
            if (!mantis) {
                ResetToHive()
                Kill_BeetleMantisPineapple()
            }
            SetStatus("Killed", "Rhino Beetle")
            LastRhinoBeetle := nowUnix()
            writeSettings("Kill", "LastRhinoBeetle", nowUnix(), "Settings\timers.ini")
        case "Ladybug":
            SetStatus("Traveling", "Ladybug")
            if (!rhinoBeetle) {
                Kill_BeetleLadybugClover()
                ResetToHive()
            }
            Kill_LadybugMushroom()
            ResetToHive()
            Kill_LadybugStrawberry()
            SetStatus("Killed", "Ladybug")
            LastLadybug := nowUnix()
            writeSettings("Kill", "LastLadybug", nowUnix(), "Settings\timers.ini")
        case "Scorpion":
            SetStatus("Traveling", "Scorpions")
            Kill_Scorpion()
            SetStatus("Killed", "Scorpions")
            LastLadybug := nowUnix()
            writeSettings("Kill", "LastScorpion", nowUnix(), "Settings\timers.ini")
    }
}

KillBoss(boss) {
    global MoveMethod, moveSpeed, HiveBees, youDied
    MoveSpeedFactor := round(18 / moveSpeed, 2)
    if (boss == "TunnelBear") {
        loop 2 {
            ResetToHive()
            SetStatus("Traveling", "Tunnel Bear")
            if (moveMethod = "walk") {
                gt_ramp()
                Move(67.5, BackKey, LeftKey)
                Rotate("right", 4)
                Move(23.5, FwdKey)
                Move(31.5, FwdKey, RightKey)
                Move(10, RightKey)
                Rotate("right", 2)
                Move(28, FwdKey)
                Move(13, LeftKey)
                Move(25, RightKey)
                send '{' SC_Space ' down}{' FwdKey ' down}'
                Walk(12)
                send '{' SC_Space ' up}{' FwdKey ' up}{' RotLeft ' 2}'
                Move(35, FwdKey)
                Move(25, RightKey)
                Move(12, FwdKey)
                Move(3.5, RightKey)
                Rotate('right', 4)
                Move(37, Fwdkey)
                Move(10, FwdKey, LeftKey)
                Move(5, Backkey)
                Move(15, RightKey)
                Move(10, BackKey)
                Sleep(3000)
                send '{' RotRight ' 4}{' RotUp ' 3}'
            } else {
                gt_ramp()
                gt_redcannon()
                send '{' SC_E ' down}'
                sleep 100
                send '{' SC_E ' up}'
                HyperSleep(1000)
                send '{' LeftKey ' down}'
                HyperSleep(100)
                send '{' SC_space ' 2}'
                HyperSleep(900)
                send '{' LeftKey ' up}'
                HyperSleep(6000)
                Move(10, FwdKey, LeftKey)
                Move(5, Backkey)
                Move(15, RightKey)
                Move(10, BackKey)
                Sleep(3000)
                send '{' RotRight ' 4}{' RotUp ' 3}'
            }
            ;confirm tunnel
            GetRobloxClientPos()
            pBM := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight // 2)
            for , value in bitmaps["tunnelbearconfirm"] {
                if (Gdip_ImageSearch(pBM, value, , , , , , 15) = 1)
                    break
                if A_Index = bitmaps["tunnelbearconfirm"].Count {
                    Gdip_DisposeImage(pBM)
                    continue 2 ;retry
                }
            }
            Gdip_DisposeImage(pBM)
            Send "{" RotLeft " 2}{" RotDown " 3}"
            ;wait for baby love
            DllCall("Sleep", "UInt", 2000)
            if (tunnelBearBabyLove) {
                SetStatus("Waiting", "BabyLove Buff")
                DllCall("Sleep", "UInt", 1500)
                loop 30 {
                    if (ImgSearch("blove.png", 25, "buff")[1] = 0) {
                        break
                    }
                    DllCall("Sleep", "UInt", 1000)
                }
            }
            ;search for tunnel bear
            SetStatus("Searching", "Tunnel Bear")
            MoveD(6000 * MoveSpeedFactor, BackKey)
            MoveD(550 * MoveSpeedFactor, LeftKey)
            found := 0
            ;(+) new detection here
            loop 20
            {
                tBear := HealthDetection()
                if (tBear.Length > 0)
                {
                    found := 1
                    break
                }
                DllCall("Sleep", "UInt", 250)
            }
            ;attack tunnel bear
            TBdead := 0
            if (found) {
                SendInput "{" RotUp " 3}"
                SetStatus("Attacking", "Tunnel Bear")
                loop 120 {
                    loop 15 {
                        if (ImgSearch("tunnelbear.png", 5, "high")[1] = 0)
                            Move(2, BackKey)
                        else
                            break
                    }
                    if (ImgSearch("tunnelbeardead.png", 25, "lowright")[1] = 0) {
                        TBdead := 1
                        SendInput "{" RotDown " 3}"
                        break
                    }
                    Sleep 1000
                }
            } else { ;No TunnelBear here...try again in 2 hours
                LastTunnelBear := nowUnix() - floor(172800 * (1 - (mobRespawnTime ? mobRespawnTime : 0) * 0.01)) + 7200
                writeSettings("Kill", "LastTunnelBear", LastTunnelBear, "Settings\timers.ini")
            }
            ;loot
            if (TBdead) {
                SetStatus("Looting")
                MoveD(12000 * MoveSpeedFactor, FwdKey)
                MoveD(18000 * MoveSpeedFactor, BackKey)
                LastTunnelBear := nowUnix()
                writeSettings("Kill", "LastTunnelBear", LastTunnelBear, "Settings\timers.ini")
                break
            }
        }
    } else if (boss = "KingBeetle") {
        loop 2 {
            ResetToHive()
            SetStatus("Traveling", "King Beetle")
            gt_blueflower(1)
            MoveD(5000 * MoveSpeedFactor, RightKey, FwdKey)
            MoveD(4000 * MoveSpeedFactor, FwdKey)
            Rotate("right", 2)
            ;wait for baby love
            DllCall("Sleep", "UInt", 1000)
            if (kingbeetleBabyLove) {
                SetStatus("Waiting", "BabyLove Buff")
                MoveD(2000 * MoveSpeedFactor, BackKey)
                DllCall("Sleep", "UInt", 1500)
                loop 30 {
                    if (ImgSearch("blove.png", 25, "buff")[1] = 0) {
                        break
                    }
                    DllCall("Sleep", "UInt", 1000)
                }
                MoveD(1500 * MoveSpeedFactor, FwdKey)
                MoveD(1500 * MoveSpeedFactor, LeftKey)
            }
            lairConfirmed := 0
            ;Go inside
            Move(5, RightKey)
            Send '{' SC_Space ' down}'
            Sleep 200
            Send '{' SC_Space ' up}'
            Move(3, RightKey)
            Move(5, RightKey, FwdKey)
            loop 5 {
                if (ImgSearch("kingfloor.png", 10, "low")[1] = 0) {
                    lairConfirmed := 1
                    break
                }
                sleep 200
            }
            if (!lairConfirmed)
                continue
            ;search for king beetle
            SetStatus("Searching", "King Beetle")
            found := 0
            ;(+) new detection here
            ;(+) Update health detection
            loop 20
            {
                kBeetle := HealthDetection(1)
                if (kBeetle.Length > 0)
                {
                    found := 1
                    break
                }
                Sleep 250
            }
            if (!found) { ;No King Beetle here...try again in 2 hours
                if (A_Index = 2) {
                    LastKingBeetle := nowUnix() + 7200
                    writeSettings("Kill", "LastKingBeetle", LastKingBeetle, "Settings\timers.ini")
                }
                continue
            }
            SetStatus("Attacking", "King Beetle")
            kingdead := 0
            Sleep 2000
            loop 1 {
                if (ImgSearch("king.png", 25, "lowright")[1] = 0) {
                    kingdead := 1
                    MoveD(1000 * MoveSpeedFactor, BackKey, RightKey)
                    MoveD(2500 * MoveSpeedFactor, BackKey)
                    MoveD(500 * MoveSpeedFactor, RightKey)
                    break
                }
                MoveD(2000 * MoveSpeedFactor, BackKey)
                Sleep 1000
                if (ImgSearch("king.png", 25, "lowright")[1] = 0) {
                    kingdead := 1
                    MoveD(1000 * MoveSpeedFactor, BackKey, RightKey)
                    MoveD(1000 * MoveSpeedFactor, BackKey)
                    MoveD(500 * MoveSpeedFactor, RightKey)
                    break
                }
                MoveD(2000 * MoveSpeedFactor, RightKey)
                Sleep 100
                if (ImgSearch("king.png", 25, "lowright")[1] = 0) {
                    kingdead := 1
                    MoveD(1500 * MoveSpeedFactor, BackKey)
                    MoveD(1000 * MoveSpeedFactor, LeftKey)
                    break
                }
                MoveD(2000 * MoveSpeedFactor, BackKey)
                Sleep 1000
                if (ImgSearch("king.png", 25, "lowright")[1] = 0) {
                    kingdead := 1
                    MoveD(1250 * MoveSpeedFactor, FwdKey)
                    MoveD(1000 * MoveSpeedFactor, LeftKey)
                    break
                }
                MoveD(2000 * MoveSpeedFactor, RightKey)
                Sleep 1000
                if (ImgSearch("king.png", 25, "lowright")[1] = 0) {
                    kingdead := 1
                    MoveD(1250 * MoveSpeedFactor, FwdKey)
                    MoveD(2000 * MoveSpeedFactor, LeftKey)
                    break
                }
                loop 2 {
                    MoveD(2000 * MoveSpeedFactor, BackKey, RightKey)
                    if (ImgSearch("king.png", 25, "lowright")[1] = 0) {
                        kingdead := 1
                        MoveD(2500 * MoveSpeedFactor, FwdKey, LeftKey)
                        MoveD(2500 * MoveSpeedFactor, LeftKey)
                        break
                    }
                }
                if (kingdead)
                    break
                Sleep 500
                Send "{" RotLeft "}"
                loop 300 {
                    if (ImgSearch("king.png", 25, "lowright")[1] = 0) {
                        kingdead := 1
                        Send "{" RotRight "}"
                        MoveD(3500 * MoveSpeedFactor, FwdKey, LeftKey)
                        MoveD(2500 * MoveSpeedFactor, LeftKey)
                        break
                    }
                    sleep 1000
                }
            }
            if (kingdead) {
                ;check for amulet
                if !AmuletPrompt(((kingBeetleKeepOld = 1) ? 1 : 3), "King Beetle") {
                    SetStatus("Looting", "King Beetle")
                    Move(10, LeftKey)
                    Loot(13.5, 7, "right", 1)
                }
                writeSettings("Kill", "LastKingBeetle", LastKingBeetle := nowUnix(), "Settings\timers.ini")
                break
            }
        }
    } else if (boss = "StumpSnail") { ;4 days
        loop 2 {
            ResetToHive()
            SetStatus("Traveling", "Stump Snail")
            gt_stump(1)
            Move(5, RightKey, BackKey)
            ;search for Stump snail
            SetStatus("Searching", "Stump Snail")
            found := 0
            loop 20
            {
                sSnail := HealthDetection()
                if (sSnail.Length > 0)
                {
                    found := 1
                    break
                }
                Sleep 150
            }
            ;attack Snail
            Move(1, FwdKey)
            Move(2.5, RightKey)
            Move(2.5, FwdKey)
            Move(2.5, Leftkey)
            Move(5, BackKey)
            Move(2.5, Leftkey)
            Move(2.5, FwdKey)
            Move(5, RightKey)
            Move(2.5, BackKey)
            Move(2.5, Leftkey)
            Move(5, FwdKey)
            Move(2.5, Leftkey)
            Move(2.5, BackKey)
            Move(2.5, Rightkey)

            Ssdead := 0
            if (found) {
                SetStatus("Attacking", "Stump Snail")
                DllCall("GetSystemTimeAsFileTime", "int64p", &SnailStartTime := 0)
                KillCheck := SnailStartTime
                UpdateTimer := SnailStartTime
                Send "{" SC_1 "}"
                loop 2
                {
                    Send "{" RotUp "}"
                }
                inactiveHoney := 0
                loop ;Custom Stump timer to keep blessings, Will rehunt in an hour
                {
                    if (SprinklerType = "Supreme")
                    {
                        Move(2.5, RightKey)
                        Move(2.5, FwdKey)
                        Move(2.5, Leftkey)
                        Move(5, BackKey)
                        Move(2.5, Leftkey)
                        Move(2.5, FwdKey)
                        Move(5, RightKey)
                        Move(2.5, BackKey)
                        Move(2.5, Leftkey)
                        Move(5, FwdKey)
                        Move(2.5, Leftkey)
                        Move(2.5, BackKey)
                        Move(2.5, Rightkey)
                    }
                    Click "Down"
                    Loop 600
                    {
                        Sleep 50
                        If ((AmuletPrompt(((stumpSnailKeepOld = 1) ? 1 : 3), "Shell")) = 1)
                        {
                            Ssdead := 1
                            Send "{" RotDown " 2}"
                            break 2
                        }
                        if ((Mod(A_Index, 10) = 0) && ( not ActiveHoney())) {
                            inactiveHoney++
                            if (inactiveHoney >= 10)
                                MsgBox("inactive honey")
                            break 2
                        }
                        if (Mod(A_Index, 20) = 0) {
                            if (disconnectCheck())
                                break
                        }
                        if (youDied == 1) {
                            MsgBox("You dided")
                            break 2
                        }
                        if (SprinklerType = "Supreme")
                        {
                            if (A_Index = 600)
                            {
                                MoveToSaturator()
                                Break
                            }
                        }
                    }
                    Click "Up"
                    ;(+) New detection system for snail
                    DllCall("GetSystemTimeAsFileTime", "int64p", &currentTime := 0)
                    ElaspedSnailTime := (currentTime - SnailStartTime) // 10000
                    LastHealthCheck := (currentTime - KillCheck) // 10000
                    LastUpdate := (currentTime - UpdateTimer) // 10000
                    If (ElaspedSnailTime > 20 * 60000)
                    {
                        SetStatus("Time Limit", "Stump Snail")
                        writeSettings("Kill", "LastStumpSnail", nowUnix(), "Settings\timers.ini")
                        break
                    }
                }
            }
            else { ;No Stump Snail try again in 2 hours
                writeSettings("Kill", "LastStumpSnail", nowUnix() + 338400, "Settings\timers.ini")
                SetStatus("Missing", "Stump Snail")
            }

            ;loot
            if (SSdead) {
                writeSettings("Kill", "LastStumpSnail", nowUnix(), "Settings\timers.ini")
                break
            }
            else if (A_Index = 2) { ;stump snail not dead, come again in 30 mins
                writeSettings("Kill", "LastStumpSnail", nowUnix() + 343800, "Settings\timers.ini")
            }
        }
    }
    ;Commando
    if (boss == "CommandoChick") { ;30 minutes
        Loop 2 {
            ResetToHive()
            ;Go to Commando tunnel
            SetStatus("Traveling", "Commando")
            youDied := 0
            gt_ramp()
            if (MoveMethod = "Walk")
            {
                movement :=
                    (
                        BSSWalk(44.75, BackKey, LeftKey) '
					' BSSWalk(42.5, LeftKey) '
					' BSSWalk(8.5, BackKey) '
					' BSSWalk(22.5, LeftKey) '
					send "{' RotLeft ' 2}"
					' BSSWalk(27, FwdKey) '
					' BSSWalk(12, LeftKey, FwdKey) '
					' BSSWalk(11, FwdKey)
                    )
            }
            else
            {
                gt_redcannon()
                movement :=
                    (
                        '
					send "{' SC_E ' down}"
					HyperSleep(100)
					send "{' SC_E ' up}"
					HyperSleep(400)
					send "{' LeftKey ' down}{' FwdKey ' down}"
					HyperSleep(1050)
					send "{' SC_Space ' 2}"
					HyperSleep(5850)
					send "{' FwdKey ' up}"
					HyperSleep(750)
					send "{' SC_Space '}{' RotLeft ' 2}"
					HyperSleep(1500)
					send "{' LeftKey ' up}"
					' BSSWalk(4, BackKey) '
					' BSSWalk(4.5, LeftKey)
                    )
            }

            if (moveSpeed < 34)
            {
                movement .=
                    (
                        '
					' BSSWalk(10, LeftKey) '
					HyperSleep(50)
					' BSSWalk(6, RightKey) '
					HyperSleep(50)
					' BSSWalk(2, LeftKey) '
					HyperSleep(50)
					' BSSWalk(7, FwdKey) '
					HyperSleep(750)
					send "{' SC_Space ' down}"
					HyperSleep(50)
					send "{' SC_Space ' up}"
					' BSSWalk(5.5, FwdKey) '
					HyperSleep(750)
					Loop 3
					{
						send "{' SC_Space ' down}"
						HyperSleep(50)
						send "{' SC_Space ' up}"
						' BSSWalk(6, FwdKey) '
						HyperSleep(750)
					}
					' BSSWalk(1, FwdKey) '
					send "{' SC_Space ' down}"
					HyperSleep(50)
					send "{' SC_Space ' up}"
					' BSSWalk(6, FwdKey) '
					HyperSleep(750)
					' BSSWalk(5, FwdKey) '
					HyperSleep(50)
					' BSSWalk(9, BackKey) '
					Sleep 4000
					send "{' SC_Space ' down}"
					HyperSleep(50)
					send "{' SC_Space ' up}"
					' BSSWalk(0.5, BackKey) '
					HyperSleep(1500)'
                    )
            }
            else
            {
                movement .=
                    (
                        '
					' BSSWalk(10, LeftKey) '
					HyperSleep(50)
					' BSSWalk(6, RightKey) '
					HyperSleep(50)
					' BSSWalk(2, LeftKey) '
					HyperSleep(50)
					' BSSWalk(7, FwdKey) '
					HyperSleep(750)
					send "{' SC_Space ' down}"
					HyperSleep(50)
					send "{' SC_Space ' up}"
					' BSSWalk(4.5, FwdKey) '
					HyperSleep(750)
					Loop 3
					{
						send "{' SC_Space ' down}"
						HyperSleep(50)
						send "{' SC_Space ' up}"
						' BSSWalk(5, FwdKey) '
						HyperSleep(750)
					}
					' BSSWalk(1, FwdKey) '
					send "{' SC_Space ' down}"
					HyperSleep(50)
					send "{' SC_Space ' up}"
					' BSSWalk(6, FwdKey) '
					HyperSleep(750)
					' BSSWalk(5, FwdKey) '
					HyperSleep(50)
					' BSSWalk(9, BackKey) '
					Sleep 4000
					send "{' SC_Space ' down}"
					HyperSleep(50)
					send "{' SC_Space ' up}"
					' BSSWalk(0.5, BackKey) '
					HyperSleep(1500)'
                    )
            }

            CreateWalk(movement)
            KeyWait "F14", "D T5 L"
            KeyWait "F14", "T90 L"
            EndWalk()

            if (youDied == 1) {
                SetStatus("You Died", "Commando Chick")
                continue
            }

            while (ImgSearch("ChickFled.png", 50, "lowright")[1] = 0)
            {
                if (A_Index = 5)
                {
                    EndWalk()
                    continue 2
                }
                if ((A_Index = 1) || (currentWalk.name != "commando"))
                {
                    movement :=
                        (
                            BSSWalk(5, FwdKey) '
						HyperSleep(50)
						' BSSWalk(9, BackKey) '
						Sleep 4000
						send "{' SC_Space ' down}"
						HyperSleep(50)
						send "{' SC_Space ' up}"
						' BSSWalk(0.5, BackKey) '
						HyperSleep(1500)'
                        )
                    CreateWalk(movement, "commando")
                }
                else
                    Send "{F13}"

                KeyWait "F14", "D T5 L"
                KeyWait "F14", "T20 L"
            }
            EndWalk()

            SetStatus("Searching", "Commando Chick")
            found := 0
            loop 4 {
                Send "{" ZoomIn "}"
            }
            ;(+) Update health detection
            loop 20
            {
                cChick := HealthDetection()
                if (cChick.Length > 0)
                {
                    found := 1
                    break
                }
                Sleep 250
            }
            Global ChickStartTime
            Global ElaspedChickTime
            Ccdead := 0
            if (found) {
                SetStatus("Attacking", "Commando Chick")

                DllCall("GetSystemTimeAsFileTime", "int64p", &ChickStartTime := 0)
                chickStrikes := 0
                loop { ;10 minute chick timer to keep blessings, Will rehunt in an hour
                    click
                    sleep 100
                    ;do later
                    if (ImgSearch("ChickDead.png", 50, "lowright")[1] = 0) {
                        CCdead := 1
                        break
                    }
                    if (youDied == 1)
                        break
                    if (Mod(A_Index, 20) = 0) {
                        if (disconnectCheck())
                            break
                    }
                    ;(+) New detection system for Chick
                    DllCall("GetSystemTimeAsFileTime", "int64p", &currentTime := 0)
                    ElaspedChickTime := (currentTime - ChickStartTime) // 10000
                    If (ElaspedChickTime > 20 * 60000)
                    {
                        SetStatus("Time Limit", "Commando Chick")
                        Break
                    }
                    loop 20
                    {
                        comChick := HealthDetection()
                        if (comChick.Length > 0)
                            break
                        if (A_Index = 20)
                        {
                            if (chickStrikes <= 10)
                            {
                                chickStrikes += 1
                            }
                            else
                            {
                                CCdead := 1
                                break 2
                            }
                        }
                        if (ImgSearch("ChickDead.png", 50, "lowright")[1] = 0) {
                            CCdead := 1
                            break 2
                        }
                        Sleep 250
                    }
                }
            }
            else { ;No Commando chick try again in 30 mins
                LastCommandoChick := nowUnix() + 1800
                writeSettings("Kill", "LastCommandoChick", LastCommandoChick, "Settings\timers.ini")
                SetStatus("Missing", "Commando Chick")
            }

            ;loot
            if (CCdead) {
                SetStatus("Defeated", "Commando Chick")
                writeSettings("Kill", "LastCommandoChick", nowUnix(), "Settings\timers.ini")
                break
            }
        }
    }
    ;crab
    if (boss == "CoconutCrab") { ;1.5 days
        loop 3 {
            wait := min(20000, (50 - HiveBees) * 1000)
            ResetToHive(1, wait)
            SetStatus("Traveling", "Coco Crab")
            gt_coconut(1)
            Send "{" SC_1 "}"
            MoveD(1400, RightKey)
            MoveD(1000, BackKey)

            ;search for Crab
            SetStatus("Searching", "Coco Crab")
            found := 0

            ;(+) new detection here
            loop 20
            {
                cCrab := HealthDetection()
                if (cCrab.Length > 0)
                {
                    found := 1
                    break
                }
                Sleep 250
            }
            ;attack Crab

            Global CrabStartTime
            Global ElaspedCrabTime

            ;CRAB TIMERS
            ;timers in ms
            leftright_start := 500
            leftright_end := 19000
            cycle_end := 24000

            ;left-right movement
            moves := 14
            move_delay := 310

            movement :=
                (
                    '
			DllCall("GetSystemTimeAsFileTime", "int64p", &start_time:=0)
			' BSSWalk(4, FwdKey) '
			DllCall("GetSystemTimeAsFileTime", "int64p", &time:=0)
			Sleep ' leftright_start ' -(time-start_time)//10000
			loop 2 {
				i := A_Index
				' BSSWalk(1, FwdKey) '
				Loop ' moves ' {
					' BSSWalk(2, LeftKey) '
					DllCall("GetSystemTimeAsFileTime", "int64p", &time)
					Sleep i*' 2 * move_delay * moves '-' 2 * move_delay * moves - leftright_start '+A_Index*' move_delay '-(time-start_time)//10000
				}
				' BSSWalk(1, BackKey) '
				Loop ' moves ' {
					' BSSWalk(2, RightKey) '
					DllCall("GetSystemTimeAsFileTime", "int64p", &time)
					Sleep i*' 2 * move_delay * moves '-' move_delay * moves - leftright_start '+A_Index*' move_delay '-(time-start_time)//10000
				}
			}
			DllCall("GetSystemTimeAsFileTime", "int64p", &time)
			Sleep ' leftright_end '-(time-start_time)//10000
			' BSSWalk(6.5, BackKey) '
			DllCall("GetSystemTimeAsFileTime", "int64p", &time)
			Sleep ' cycle_end '-(time-start_time)//10000
			'
                )

            Crdead := 0
            if (found) {

                SetStatus("Attacking", "Coco Crab")
                DllCall("GetSystemTimeAsFileTime", "int64p", &CrabStartTime := 0)
                inactiveHoney := 0
                loop { ;30 minute crab timer to keep blessings, Will rehunt in an hour
                    DllCall("GetSystemTimeAsFileTime", "int64p", &PatternStartTime := 0)
                    if (currentWalk.name != "crab")
                        CreateWalk(movement, "crab") ; create cycled walk script for this gather session
                    else
                        Send "{F13}" ; start new cycle

                    KeyWait "F14", "D T5 L" ; wait for pattern start

                    Loop 600
                    {
                        sendinput "{click down}"
                        sleep 50
                        sendinput "{click up}"
                        if (ImgSearch("crab.png", 70, "lowright")[1] = 0) {
                            Crdead := 1
                            Send "{" RotUp " 2}"
                            break 2
                        }
                        if ((Mod(A_Index, 10) = 0) && ( not ActiveHoney())) {
                            inactiveHoney++
                            if (inactiveHoney >= 10)
                                break 2
                        }
                        if (youDied)
                            break 2
                        if ((A_Index = 600) || !GetKeyState("F14"))
                            break
                        Sleep 50
                    }
                    DllCall("GetSystemTimeAsFileTime", "int64p", &time := 0)
                    ElaspedCrabTime := (time - CrabStartTime) // 10000
                    If (ElaspedCrabTime > 900000) {
                        SetStatus("Time Limit", "Coco Crab")
                        LastCocoCrab := nowUnix() - floor(129600 * (1 - (mobRespawnTime ? mobRespawnTime : 0) * 0.01)) + 1800
                        writeSettings("Kill", "LastCoconutCrab", LastCocoCrab, "Settings\timers.ini")
                        EndWalk()
                        Return
                    }
                }
                EndWalk()
            }
            else { ;No Crab try again in 2 hours
                writeSettings("Kill", "LastCoconutCrab", nowUnix() + 129600, "Settings\timers.ini")
                SetStatus("Missing", "Coco Crab")
            }

            ;loot
            if (Crdead) {
                DllCall("GetSystemTimeAsFileTime", "int64p", &time := 0)
                duration := DurationFromSeconds((time - CrabStartTime) // 10000000, "mm:ss")
                SetStatus("Defeated", "Coco Crab`nTime: " duration)
                ElapsedPatternTime := (time - PatternStartTime) // 10000
                movement :=
                    (
                        BSSWalk(((ElapsedPatternTime > leftright_start) && (ElapsedPatternTime < leftright_start + 4 * moves * move_delay)) ? Abs(Abs(Mod((ElapsedPatternTime - moves * move_delay - leftright_start) * 2 / move_delay, moves * 4) - moves * 2) - moves * 3 / 2) : moves * 3 / 2, (((ElapsedPatternTime > leftright_start + moves / 2 * move_delay) && (ElapsedPatternTime < leftright_start + 3 * moves / 2 * move_delay)) || ((ElapsedPatternTime > leftright_start + 5 * moves / 2 * move_delay) && (ElapsedPatternTime < leftright_start + 7 * moves / 2 * move_delay))) ? RightKey : LeftKey) "
				" (((ElapsedPatternTime < leftright_start) || (ElapsedPatternTime > leftright_end)) ? BSSWalk(4, FwdKey) : "")
                    )
                CreateWalk(movement)
                KeyWait "F14", "D T5 L"
                KeyWait "F14", "T20 L"
                EndWalk()
                SetStatus("Looting", "Coco Crab")
                Loot(9, 4, "right")
                Loot(9, 4, "left")
                Loot(9, 4, "right")
                Loot(9, 4, "left")
                Loot(9, 4, "right")
                Loot(9, 4, "left")
                LastCocoCrab := nowUnix()
                writeSettings("Kill", "LastCoconutCrab", LastCocoCrab, "Settings\timers.ini")
                break
            }
            else if (A_Index = 2) {
                LastCocoCrab := nowUnix() - floor(129600 * (1 - (mobRespawnTime ? mobRespawnTime : 0) * 0.01)) + 1800
                writeSettings("Kill", "LastCoconutCrab", LastCocoCrab, "Settings\timers.ini")
                SetStatus("Failed", "Coco Crab")
            }
        }
    }
}

Kill_Werewolf() {
    gt_pumpkin()
    HyperSleep(1000)
    Move(10, "s")
    loop 5 {
        Move(7, "d")
        Move(7, "s")
        Move(7, "a")
        Move(7, "w")
        HyperSleep(250)
    }
    loop 3 {
        Move(6, "s")
        Move(2, "d")
        Move(6, "w")
        Move(2, "d")
        HyperSleep(250)
    }
}

Kill_Spider() {
    gt_spider()
    HyperSleep(1000)
    loop 5 {
        Move(5, "d")
        Move(5, "s")
        Move(5, "a")
        Move(5, "w")
        HyperSleep(250)
    }
    Move(4, "d")
    loop 4 {
        Move(10, "w")
        Move(1.5, "a")
        Move(10, "s")
        Move(1.5, "a")
    }
}

Kill_MantisPineTree() {
    gt_pinetree()
    HyperSleep(1000)
    loop 5 {
        Move(6, "d")
        Move(6, "s")
        Move(6, "a")
        Move(6, "w")
        HyperSleep(250)
    }
    Move(12, "a")
    Move(8, "w")
    Move(1.5, "d")
    Move(7, "s")
    Move(1.5, "d")
    Move(8, "w")
    Move(1.5, "d")
    Move(8, "s")
    Move(1.5, "d")
    Move(8, "w")
    Move(1.5, "d")
    Move(8, "s")
    Move(15, "w")
    Move(14, "d")
    Move(13, "s")
    Move(1.5, "a")
    Move(13, "w")
    Move(1.5, "a")
    Move(13, "s")
    Move(1.5, "a")
    Move(13, "w")
    Move(1.5, "a")
    Move(13, "s")
    Move(1.5, "a")
    Move(13, "w")
    Move(1.5, "a")
    Move(13, "s")
}

Kill_Scorpion() {
    gt_rose()
    HyperSleep(1000)
    loop 5 {
        Move(6, "d")
        Move(6, "s")
        Move(6, "a")
        Move(6, "w")
        HyperSleep(250)
    }
    Move(11, "s")
    Move(1.5, "d")
    Move(11, "w")
    Move(1.5, "d")
    Move(11, "s")
    Move(1.5, "d")
    Move(11, "w")
    Move(1.5, "d")
    Move(11, "s")
    Move(1.5, "d")
    Move(11, "w")
    Move(4, "a")
    loop 4 {
        Move(10, "w")
        Move(1.5, "a")
        Move(10, "s")
        Move(1.5, "a")
    }
}

Kill_BeetleMantisPineapple() {
    gt_pineapple()
    HyperSleep(1000)
    loop 5 {
        Move(6, "d")
        Move(6, "s")
        Move(6, "a")
        Move(6, "w")
        HyperSleep(250)
    }
    Move(6, "d")
    loop 4 {
        Move(11, "w")
        Move(1.5, "a")
        Move(11, "s")
        Move(1.5, "a")
    }
}

Kill_LadybugStrawberry() {
    gt_strawberry()
    HyperSleep(1000)
    loop 5 {
        Move(6, "d")
        Move(6, "s")
        Move(6, "a")
        Move(6, "w")
        HyperSleep(250)
    }
    Move(2, "s")
    Move(8, "d", "s")
    loop 2 {
        Move(14, "w")
        Move(1.5, "a")
        Move(14, "s")
        Move(1.5, "a")
    }
    Move(14, "w")
}

Kill_LadybugMushroom() {
    gt_mushroom()
    HyperSleep(1000)
    Move(5, "a")
    loop 5 {
        Move(6, "d")
        Move(6, "s")
        Move(6, "a")
        Move(6, "w")
        HyperSleep(50)
    }
    Move(5, "d", "s")
    Move(2, "d")
}


Kill_BeetleLadybugClover() {
    gt_clover()
    HyperSleep(1000)
    loop 5 {
        Move(6, "d")
        Move(6, "s")
        Move(6, "a")
        Move(6, "w")
        HyperSleep(250)
    }
    Move(4, "d")
    Move(8, "w")
    Move(1.5, "a")
    Move(8, "s")
    Move(1.5, "a")
    Move(8, "w")
    Move(1.5, "a")
    Move(16, "s")
    loop 2 {
        Move(1.5, "a")
        Move(8, "w")
        Move(1.5, "a")
        Move(8, "s")
    }
}