CheckCollect() {
	BlenderRotation()
	TimeForBlender := (BlenderTime%LastBlenderRot% +0) - (TimerInterval + 0)

	if ((!wealthClock || (nowUnix() - LastClock) < 3600) && (!blenderCheck || (nowUnix() - TimeForBlender) < TimerInterval) && (!antPass || (nowUnix() - LastAntPass < 7200)) && (!roboPassDispenser || (nowUnix() - LastRoboPass) < 79200) && (!glueDispenser || (nowUnix() - LastGlue) < 79200) && (!nectarConsender || GetNectarPercent(StrLower(nectarPotNectar)) < 25) && !nectarPot && (!stickerPrinter || (nowUnix() - LastStickerPrinter < 3600)) && (!stickerStack || (nowUnix() - LastStickerStack < stickerStackTimer))) {
		return false
	}
	return true
}

BeginCollect() {
	Clock()
	Blender()
	Ant()
	RoboPass()
	GlueDis()

	NectarConsenderFunc()
	NectarPotFunc()

	StickerPrinterFunc()
	StickerStackFunc()

	if beesmas {
		DoStockings()
		DoFeast()
		GingerbreadHouse()
		DoSnowMachine()
		DoCandles()
		DoSamovar()
		DoLidArt()
		DoGummyBeacon()
		DoRBPDelevel()
	}
}

Clock() {
	global LastClock, LastHoneyStorm, wealthClock
	if (wealthClock && (nowUnix() - LastClock) > 3600) { ;1 hour
		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		GetRobloxClientPos(hwnd)

		Loop 2 {
			ResetToHive()
			SetStatus("Traveling", "Wealth Clock" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_clock()

			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY + 36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 500
				SetStatus("Collected", "Wealth Clock")
				break
			}
			Gdip_DisposeImage(pBMScreen)
		}

		LastClock := nowUnix()
		writeSettings("Collect", "LastClock", LastClock, "Settings\timers.ini")

		if (honeyStorm && (nowUnix() - LastHoneyStorm) > 21600) { ;6 hours
			SetStatus("Traveling", "Honey Storm")
			gtc_honeystormFromClock()
			Sleep 200
			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY + 36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 500
				SetStatus("Collected", "Honey Storm")
				loot_honeyStorm()

				LastHoneyStorm := nowUnix()
				writeSettings("Collect", "LastHoneyStorm", LastHoneyStorm, "Settings\timers.ini")
			} else {
				Gdip_DisposeImage(pBMScreen)
				SetStatus("Failed", "Honey Storm")
			}
		}
	}
}

global LastBlenderRot := 1
global BlenderRot := 1

Blender() {
	global BlenderRot, TimerInterval, BlenderTime1, BlenderTime2, BlenderTime3, BlenderEnd, blenderSlot1Amount, blenderSlot2Amount, blenderSlot3Amount, blenderSlot1Item, blenderSlot2Item, blenderSlot3Item, blenderSlot1Repeat, blenderSlot2Repeat, blenderSlot3Repeat
	BlenderRotation()
	TimeForBlender := (BlenderTime%LastBlenderRot% +0) - (TimerInterval + 0)

	if (blenderCheck && (nowUnix() - TimeForBlender) > TimerInterval) {
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)

			z := A_Index ;Set variable for fail safe
			ResetToHive()
			SetStatus("Traveling", "Blender" ((A_Index > 1) ? " (Attempt 2)" : ""))
			gt_blender()

			If (CollectItem()) {
				Sleep 500

				SearchX := windowX + windowWidth // 2 - 275, SearchY := windowY + Floor(0.48 * windowHeight) - 220, BlenderSS := Gdip_BitmapFromScreen(SearchX "|" SearchY "|550|400")

				if (Gdip_ImageSearch(BlenderSS, bitmaps["CancelCraft"], , , , , , 2, , 7) > 0) {
					MouseMove windowX + windowWidth // 2 + 230, windowY + Floor(0.48 * windowHeight) + 130 ; click cancel button
					Sleep 150
					Click
				}

				if (!BlenderEnd && Gdip_ImageSearch(BlenderSS, bitmaps["EndCraftR"], , , , , , 3, , 6) > 0)
				{
					SetStatus("Confirmed", "Blender is already in use")
					MouseMove windowX + windowwidth // 2 - 250, windowY + Floor(0.48 * windowHeight) - 200
					Gdip_disposeimage(BlenderSS) ;Close GUI and dispose of bitmap
					Sleep 150
					Click
					break
				} else if (BlenderEnd && Gdip_ImageSearch(BlenderSS, bitmaps["EndCraftR"], , , , , , 3, , 6) > 0) {
					writeSettings("Blender", "BlenderEnd", 0, "Settings\timers.ini")
					BlenderEnd := 0
					MouseMove windowX + windowWidth // 2 - 120, windowY + Floor(0.48 * windowHeight) + 120 ; close red craft button
					Sleep 150
					Click
				}

				if (Gdip_ImageSearch(BlenderSS, bitmaps["EndCraftG"], , , , , , 4, , 6) > 0) {
					MouseMove windowX + WindowWidth // 2 - 120, windowY + Floor(0.48 * windowHeight) + 120 ; close green craft button
					Sleep 150
					Click
				}
				gdip_disposeimage(BlenderSS)
				Sleep 800
				loop
				{
					BlenderSS := Gdip_BitmapFromScreen(SearchX "|" SearchY "|170|245")

					Blender := %("blenderSlot" BlenderRot "Item")%
					BlenderIMG := StrReplace(Blender, " ", "") "B"

					if (Gdip_ImageSearch(BlenderSS, bitmaps[BlenderIMG], , , , , , 2, , 4) > 0)
					{
						gdip_disposeimage(BlenderSS)  ; Dispose of the bitmap
						Sleep 200
						BlenderSS := Gdip_BitmapFromScreen(SearchX "|" SearchY "|553|400")
						if (Gdip_ImageSearch(BlenderSS, bitmaps["NoItems"], , , , , , 2) > 0) {
							blenderSlot%BlenderRot%Item := "None", blenderSlot%BlenderRot%Amount := 0, blenderSlot%BlenderRot%Repeat := 1, BlenderTime%BlenderRot% := 0

							writeSettings("Collect", "blenderslot" BlenderRot "item", "None", , false)
							writeSettings("Collect", "blenderslot" BlenderRot "amount", 0, , false)
							writeSettings("Collect", "blenderslot" BlenderRot "repeat", 1, , false)
							writeSettings("Collect", "BlenderTime" BlenderRot, 0, "Settings\timers.ini")

							gdip_disposeimage(BlenderSS)
							BlenderRotation()
							if !(blenderCheck)
								break 2
							break
						}
						gdip_disposeimage(BlenderSS)
						MouseMove windowX + windowWidth // 2, windowY + Floor(0.48 * windowHeight) + 130 ;Open item menu
						Sleep 150
						click
						Sleep 150
						MouseMove windowX + windowWidth // 2 - 60, windowY + Floor(0.48 * windowHeight) + 140 ;Add more of x item
						Sleep 150
						While (A_Index < blenderSlot%BlenderRot%Amount) {
							Click
							Sleep 30
						}
						Sleep 200
						writeSettings("Collect", "BlenderCount" LastBlenderRot, 0, "Settings\timers.ini")

						SetStatus("Collected", "Blender")

						BlenderTime%BlenderRot% := blenderSlot%BlenderRot%Amount * 300 ;calculate first time variable
						BlenderTimeTemp := BlenderTime%BlenderRot% ;set up a temporary varible to hold time
						TempBlenderRot := BlenderRot ; save a temporary rotation holder

						BlenderTime%TempBlenderRot% := BlenderTime%TempBlenderRot% +nowUnix() ;add nowunix for time after temporoary varible has been created
						writeSettings("Collect", "BlenderTime" TempBlenderRot, BlenderTime%TempBlenderRot%, "Settings\timers.ini")

						loop {
							TempBlenderRot := Mod(TempBlenderRot, 3) + 1
							if (TempBlenderRot = BlenderRot) ;makes sure it doesnt do the already calculated time again
								break

							if ((blenderSlot%TempBlenderRot%Repeat = "Infinite" || blenderSlot%TempBlenderRot%Repeat > 0) && (blenderSlot%TempBlenderRot%Item != "None" && blenderSlot%TempBlenderRot%Item != "")) { ;start time calculation process
								BlenderTime%TempBlenderRot% := (blenderSlot%TempBlenderRot%Amount * 300) + BlenderTimeTemp ;add previous time to this one after to show time until its done
								BlenderTimeTemp := BlenderTime%TempBlenderRot% ;create a new temp for next
								BlenderTime%TempBlenderRot% := BlenderTime%TempBlenderRot% +nowUnix() ;add now unix to it for the counter
								writeSettings("Collect", "BlenderTime" TempBlenderRot, BlenderTime%TempBlenderRot%, "Settings\timers.ini")
							}
						}
						TimerInterval := blenderSlot%BlenderRot%Amount * 300 ;set up time
						writeSettings("Collect", "LastBlenderRot", BlenderRot, "Settings\timers.ini")

						BlenderRot := Mod(BlenderRot, 3) + 1
						BlenderRotation()
						if (blenderSlot%BlenderRot%Repeat != "Infinite") {
							blenderSlot%BlenderRot%Repeat-- ;subtract from blenderindex for looping only if its a number
							writeSettings("Collect", "blenderslot" BlenderRot "repeat", blenderSlot%BlenderRot%Repeat)
						}
						Sleep 100
						MouseMove windowX + windowWidth // 2 + 70, windowY + Floor(0.48 * windowHeight) + 130 ;Click Confirm
						Sleep 150
						Click
						Sleep 100
						MouseMove windowX + windowWidth // 2 - 250, windowY + Floor(0.48 * windowHeight) - 200 ;Close GUI
						Sleep 150
						Click
						break 2
					} else {
						Sleep 50
						MouseMove windowX + windowWidth // 2 + 230, windowY + Floor(0.48 * windowHeight) + 110 ;not found go next item
						Sleep 150
						Click
						Sleep 100
						if (A_Index = 60) {
							if (z = 2) {
								SetStatus("Failed", "Blender")
								MouseMove windowX + windowWidth // 2 - 250, windowY + Floor(0.48 * windowHeight) - 200 ;Close GUI
								Sleep 150
								Click

								BlenderTime%BlenderRot% := blenderSlot%BlenderRot%Amount * 300 ;calculate first time variable
								BlenderTimeTemp := BlenderTime%BlenderRot% ;set up a temporary varible to hold time
								TempBlenderRot := BlenderRot ; save a temporary rotation holder

								BlenderTime%TempBlenderRot% := BlenderTime%TempBlenderRot% +nowUnix() ;add nowunix for time after temporoary varible has been created
								writeSettings("Collect", "BlenderTime" TempBlenderRot, BlenderTime%TempBlenderRot%, "Settings\timers.ini")

								loop {
									TempBlenderRot := Mod(TempBlenderRot, 3) + 1
									if (TempBlenderRot = BlenderRot) ;makes sure it doesnt do the already calculated time again
										break

									if ((blenderSlot%TempBlenderRot%Repeat = "Infinite" || blenderSlot%TempBlenderRot%Repeat > 0) && (blenderSlot%TempBlenderRot%Item != "None" && blenderSlot%TempBlenderRot%Item != "")) { ;start time calculation process
										BlenderTime%TempBlenderRot% := (blenderSlot%TempBlenderRot%Amount * 300) + BlenderTimeTemp ;add previous time to this one after to show time until its done
										BlenderTimeTemp := BlenderTime%TempBlenderRot% ;create a new temp for next
										BlenderTime%TempBlenderRot% := BlenderTime%TempBlenderRot% +nowUnix() ;add now unix to it for the counter
										writeSettings("Collect", "BlenderTime" TempBlenderRot, BlenderTime%TempBlenderRot%, "Settings\timers.ini")
									}
								}
							}
							break
						}
					}
				}
			}
		}
		writeSettings("Collect", "TimerInterval", TimerInterval, "Settings\timers.ini", false)
		writeSettings("Collect", "BlenderRot", BlenderRot, "Settings\timers.ini", false)
		writeSettings("Collect", "blenderslot" BlenderRot "repeat", blenderSlot%BlenderRot%Repeat)
	}
}
BlenderRotation() {
	global BlenderRot, blenderCheck
	loop {
		BlenderRot := readSettings("Collect", "BlenderRot", , "settings\timers.ini")
		if ((blenderSlot%BlenderRot%Repeat = "Infinite" || blenderSlot%BlenderRot%Repeat > 0) && (blenderSlot%BlenderRot%Item != "None" && blenderSlot%BlenderRot%Item != "")) {
			blenderCheck := 1
			writeSettings("Collect", "blenderCheck", blenderCheck)
			break
		} else {
			BlenderRot := Mod(BlenderRot, 3) + 1
			writeSettings("Collect", "BlenderRot", BlenderRot, "settings\timers.ini")
			if (A_Index = 4) {
				if (blenderCheck) {
					blenderCheck := 0
					writeSettings("Collect", "blenderCheck", false)
					SetStatus("Confirmed", "No more items to rotate through. Turning blender off")
				}
				break
			}
		}
	}
}

Ant() { ;collect Ant Pass then do Challenge
	static AntPassNum := 2

	if (((antPass && ((AntPassNum < 10))) && (nowUnix() - LastAntPass > 7200))) { ;2 hours OR ant quest
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)

			ResetToHive(1, 2000)
			SetStatus("Traveling", "Ant Pass" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_antpass()

			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY + 36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				updateConfig()
				Sleep 500
				SetStatus("Collected", "Ant Pass")
				++AntPassNum
				break
			}
			else {
				pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passfull"], , , , , , 2, , 2) = 1) {
					(AntPassNum < 10) && SetStatus("Confirmed", "10/10 Ant Passes")
					AntPassNum := 10
					writeSettings("Collect", "antpass", false)
					Gdip_DisposeImage(pBMScreen)
					break
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passcooldown"], , , , , , 2, , 2) = 1) {
					updateConfig()
					Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}
	}

	updateConfig() {
		LastAntPass := nowUnix()
		writeSettings("Collect", "LastAntPass", LastAntPass, "Settings\timers.ini")
	}
}

RoboPass() {
	static RoboPassNum := 1

	if (roboPassDispenser && (RoboPassNum < 10) && (nowUnix() - LastRoboPass) > 79200) { ;22 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)

			ResetToHive()
			SetStatus("Traveling", "Robo Pass" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_robopass()

			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY + 36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				updateConfig()
				Sleep 500
				SetStatus("Collected", "Robo Pass")
				++RoboPassNum
				break
			}
			else {
				pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passfull"], , , , , , 2, , 2) = 1) {
					(RoboPassNum < 10) && SetStatus("Confirmed", "10/10 Robo Passes")
					RoboPassNum := 10
					Gdip_DisposeImage(pBMScreen)
					break
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passcooldown"], , , , , , 2, , 2) = 1) {
					updateConfig()
					Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}
	}

	updateConfig() {
		LastRoboPass := nowUnix()
		writeSettings("Collect", "LastRoboPass", LastRoboPass, "Settings\timers.ini")
	}
}

GlueDis() {
	global LastGlue
	if (glueDispenser && (nowUnix() - LastGlue) > (79200)) { ;22 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)

			ResetToHive()
			OpenMenu("itemmenu")

			SetStatus("Traveling", "Glue Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_gluedis()

			;locate gumdrops
			if ((gumdropPos := InventorySearch("gumdrops")) = 0) { ;~ new function
				OpenMenu()
				continue
			}
			MouseMove windowX + gumdropPos[1], windowY + gumdropPos[2]

			MouseClickDrag "Left", windowX + gumdropPos[1], windowY + gumdropPos[2], windowX + (windowWidth // 2), windowY + (windowHeight // 2), 5
			;close inventory
			OpenMenu()
			Sleep 500
			;inside gummy lair
			Move(6, FwdKey)
			Sleep 500
			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY + 36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 1000
				SetStatus("Collected", "Glue Dispenser")
				break
			}
		}
		LastGlue := nowUnix()
		writeSettings("Collect", "LastGlue", LastGlue, "Settings\timers.ini")
	}
}

NectarConsenderFunc() {
	if (nectarConsender && GetNectarPercent(StrLower(nectarConsenderNectar)) > 55) {
		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		GetRobloxClientPos(hwnd)

		Loop 2 {
			ResetToHive()
			SetStatus("Traveling", "Nectar Condenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_nectarcondenser()

			If (CollectItem()) {
				Sleep 500

				switch nectarConsenderNectar {
					case "Refreshing":
						MouseMove windowWidth * 0.5 - 188, windowHeight * 0.4 + 69
						Sleep 100
						Click
						Sleep 1000
						if (potConsenderCheck(true)) {
							SetStatus("Collected", "Nectar Condenser")
						} else {
							if (potConsenderCheck(false)) {
								SetStatus("Failed", "Nectar Condenser")
								continue
							} else {
								SetStatus("Collected", "Nectar Condenser")
							}
						}
						break
					case "Comforting":
						MouseMove windowWidth * 0.5 - 6, windowHeight * 0.4 + 69
						Sleep 100
						Click
						Sleep 1000
						if (potConsenderCheck(true)) {
							SetStatus("Collected", "Nectar Condenser")
						} else {
							if (potConsenderCheck(false)) {
								SetStatus("Failed", "Nectar Condenser")
								continue
							} else {
								SetStatus("Collected", "Nectar Condenser")
							}
						}
						break
					case "Satisfying":
						MouseMove windowWidth * 0.5 + 162, windowHeight * 0.4 + 69
						Sleep 100
						Click
						Sleep 1000
						if (potConsenderCheck(true)) {
							SetStatus("Collected", "Nectar Condenser")
						} else {
							if (potConsenderCheck(false)) {
								SetStatus("Failed", "Nectar Condenser")
								continue
							} else {
								SetStatus("Collected", "Nectar Condenser")
							}
						}
						break
					case "Motivating":
						MouseMove windowWidth * 0.63 - 207, windowHeight * 0.4 + 162
						Sleep 100
						Click
						Sleep 1000
						if (potConsenderCheck(true)) {
							SetStatus("Collected", "Nectar Condenser")
						} else {
							if (potConsenderCheck(false)) {
								SetStatus("Failed", "Nectar Condenser")
								continue
							} else {
								SetStatus("Collected", "Nectar Condenser")
							}
						}
						break
					case "Invigorating":
						MouseMove windowWidth * 0.63 - 26, windowHeight * 0.4 + 162
						Sleep 100
						Click
						Sleep 1000
						if (potConsenderCheck(true)) {
							SetStatus("Collected", "Nectar Condenser")
						} else {
							if (potConsenderCheck(false)) {
								SetStatus("Failed", "Nectar Condenser")
								continue
							} else {
								SetStatus("Collected", "Nectar Condenser")
							}
						}
						break
				}
			}
		}
	}
}

NectarPotFunc() {
	if (nectarPot && GetNectarPercent(StrLower(nectarPotNectar)) > 25) { ;1 hour
		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		GetRobloxClientPos(hwnd)

		Loop 2 {
			ResetToHive()
			SetStatus("Traveling", "Nectar Pot" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_nectarpot()

			If (CollectItem()) {
				Sleep 500

				switch nectarPotNectar {
					case "Refreshing":
						MouseMove windowWidth * 0.5 - 188, windowHeight * 0.4 + 69
						Sleep 100
						Click
						Sleep 1000
						if (potConsenderCheck(true)) {
							SetStatus("Collected", "Nectar Pot`nDisabling Nectar Pot")
							writeSettings("Collect", "nectarpot", false)
						} else {
							if (potConsenderCheck(false)) {
								SetStatus("Failed", "Nectar Pot")
								continue
							} else {
								SetStatus("Collected", "Nectar Pot`nDisabling Nectar Pot")
								writeSettings("Collect", "nectarpot", false)
							}
						}
						break
					case "Comforting":
						MouseMove windowWidth * 0.5 - 6, windowHeight * 0.4 + 69
						Sleep 100
						Click
						Sleep 1000
						if (potConsenderCheck(true)) {
							SetStatus("Collected", "Nectar Pot`nDisabling Nectar Pot")
							writeSettings("Collect", "nectarpot", false)
						} else {
							if (potConsenderCheck(false)) {
								SetStatus("Failed", "Nectar Pot")
								continue
							} else {
								SetStatus("Collected", "Nectar Pot`nDisabling Nectar Pot")
								writeSettings("Collect", "nectarpot", false)
							}
						}
						break
					case "Satisfying":
						MouseMove windowWidth * 0.5 + 162, windowHeight * 0.4 + 69
						Sleep 100
						Click
						Sleep 1000
						if (potConsenderCheck(true)) {
							SetStatus("Collected", "Nectar Pot`nDisabling Nectar Pot")
							writeSettings("Collect", "nectarpot", false)
						} else {
							if (potConsenderCheck(false)) {
								SetStatus("Failed", "Nectar Pot")
								continue
							} else {
								SetStatus("Collected", "Nectar Pot`nDisabling Nectar Pot")
								writeSettings("Collect", "nectarpot", false)
							}
						}
						break
					case "Motivating":
						MouseMove windowWidth * 0.63 - 207, windowHeight * 0.4 + 162
						Sleep 100
						Click
						Sleep 1000
						if (potConsenderCheck(true)) {
							SetStatus("Collected", "Nectar Pot`nDisabling Nectar Pot")
							writeSettings("Collect", "nectarpot", false)
						} else {
							if (potConsenderCheck(false)) {
								SetStatus("Failed", "Nectar Pot")
								continue
							} else {
								SetStatus("Collected", "Nectar Pot`nDisabling Nectar Pot")
								writeSettings("Collect", "nectarpot", false)
							}
						}
						break
					case "Invigorating":
						MouseMove windowWidth * 0.63 - 26, windowHeight * 0.4 + 162
						Sleep 100
						Click
						Sleep 1000
						if (potConsenderCheck(true)) {
							SetStatus("Collected", "Nectar Pot`nDisabling Nectar Pot")
							writeSettings("Collect", "nectarpot", false)
						} else {
							if (potConsenderCheck(false)) {
								SetStatus("Failed", "Nectar Pot")
								continue
							} else {
								SetStatus("Collected", "Nectar Pot`nDisabling Nectar Pot")
								writeSettings("Collect", "nectarpot", false)
							}
						}
						break
				}
			}
		}
	}
}

potConsenderCheck(a) {
	i := 0
	if (a) {
		loop 16 {
			sleep 250
			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 250 "|" windowY + windowHeight // 2 - 52 "|500|150")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
				MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + windowHeight // 2 - 52 + SubStr(pos, InStr(pos, ",") + 1)
				Sleep 800
				Click
				if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
					MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + windowHeight // 2 - 52 + SubStr(pos, InStr(pos, ",") + 1)
					Sleep 200
					Click
				}
				sleep 100
				i++
				return true
			} else if (i > 0) {
				Gdip_DisposeImage(pBMScreen)
				return true
			}
			Gdip_DisposeImage(pBMScreen)
			if (A_Index = 16)
				break
			return false
		}
	} else {
		BlenderSS := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 275 "|" windowY + Floor(0.48 * windowHeight) - 220 "|550|400")
		if (Gdip_ImageSearch(BlenderSS, bitmaps["CloseGUI"], , , , , , 5) > 0) {
			MouseMove windowX + windowWidth // 2 - 250, windowY + Floor(0.48 * windowHeight) - 200
			Sleep 150
			click
			return false
		} else {
			return true
		}
	}
}

StickerPrinterFunc() {
	global LastStickerPrinter
	If (stickerPrinter && (nowUnix() - LastStickerPrinter) > 3600) { ;1 hour
		loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)

			ResetToHive()
			SetStatus("Traveling", "Sticker Printer" ((A_Index > 1) ? " (Attempt 2)" : ""))
			gt_stickerPrinter()

			If (CollectItem()) {
				Sleep 1000 ;//todo: wait for GUI with timeout instead of fixed time
				GetRobloxClientPos()
				pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 + 150 "|" windowY + 4 * windowHeight // 10 + 160 "|100|60")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["stickerprinterCD"], , , , , , 10) = 1) {
					Gdip_DisposeImage(pBMScreen)
					SetStatus("Detected", "Sticker Printer on Cooldown")
					Sleep 500
					sendinput "{" SC_E " down}"
					Sleep 100
					sendinput "{" SC_E " up}"
					break
				}
				Gdip_DisposeImage(pBMScreen)
				pos := Map("basic", -95, "silver", -40, "gold", 15, "diamond", 70, "mythic", 125)
				MouseMove windowX + windowWidth // 2 + pos[StrLower(stickerPrinterEgg)], windowY + 4 * windowHeight // 10 - 20
				Sleep 200
				Click
				Sleep 200
				pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 + 150 "|" windowY + 4 * windowHeight // 10 + 160 "|100|60")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["stickerprinterConfirm"], , , , , , 10) != 1) {
					Gdip_DisposeImage(pBMScreen)
					SetStatus("Error", "No Eggs left in inventory!`nSticker Printer has been disabled.")
					writeSettings("Collect", "stickerPrinter", false)
					Sleep 500
					sendinput "{" SC_E " down}"
					Sleep 100
					sendinput "{" SC_E " up}"
					break
				}
				Gdip_DisposeImage(pBMScreen)
				MouseMove windowX + windowWidth // 2 + 225, windowY + 4 * windowHeight // 10 + 195
				Sleep 200
				Click
				i := 0
				loop 16 {
					sleep 250
					pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 250 "|" windowY + windowHeight // 2 - 52 "|500|150")
					if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
						MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + windowHeight // 2 - 52 + SubStr(pos, InStr(pos, ",") + 1)
						Sleep 800
						Click
						if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
							MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + windowHeight // 2 - 52 + SubStr(pos, InStr(pos, ",") + 1)
							Sleep 200
							Click
						}
						sleep 100
						i++
					} else if (i > 0) {
						Gdip_DisposeImage(pBMScreen)
						break
					}
					Gdip_DisposeImage(pBMScreen)
					if (A_Index = 16)
						break
				}
				Sleep 8000 ; wait for printer to print
				SetStatus("Collected", "Sticker Printer (" StickerPrinterEgg " Egg)")
				break
			}
		}
		if (stickerPrinter = 1) {
			LastStickerPrinter := nowUnix()
			writeSettings("Collect", "LastStickerPrinter", LastStickerPrinter, "Settings\timers.ini")
		}
	}
}

StickerStackFunc() {
	global LastStickerStack, stickerStackTimer
	if (stickerStack && (nowUnix() - LastStickerStack) > stickerStackTimer) {
		loop 2 {
			ResetToHive()
			SetStatus("Traveling", "Sticker Stack" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_stickerstack()

			GetRobloxClientPos()

			If (CollectItem()) {
				sleep 1000 ;//todo: wait for GUI with timeout instead of fixed time

				; detect stack boost time
				pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 275 "|" windowY + 4 * windowHeight // 10 "|550|220")
				Loop 3 {
					if (Gdip_ImageSearch(pBMScreen, bitmaps["stickerstackdigits"][")"], &pos, 275, , , 45, 20) = 1) {
						x := SubStr(pos, 1, InStr(pos, ",") - 1)
						(digits := Map()).Default := ""
						Loop 10 {
							n := 10 - A_Index
							Gdip_ImageSearch(pBMScreen, bitmaps["stickerstackdigits"][n], &pos, x, , , 45, 20, , , 4, , "`n")
							Loop Parse pos, "`n"
								if (A_Index & 1)
									digits[Integer(A_LoopField)] := n
						}

						num := ""
						for x, y in digits
							num .= y

						if ((StrLen(num) = 4) && (SubStr(num, 4) = "0")) { ; check valid time before updating
							SetStatus("Detected", "Stack Boost Time: " hmsFromSeconds(time := 60 * SubStr(num, 1, 2) + SubStr(num, 3)))
							if (stickerStackTimerDetect)
								stickerStackTimer := time
								writeSettings('Collect', "stickerstacktimer", stickerStackTimer)
							break
						}
					}
					SetStatus("Error", "Unable to detect Stack Boost time!")
				}

				; check if sticker is available to donate
				if (InStr(stickerStackItem, "Sticker") && (((Gdip_ImageSearch(pBMScreen, bitmaps["stickernormal"], &pos, , , 275, , 25) = 1) && (stack := "Sticker"))
					|| ((Gdip_ImageSearch(pBMScreen, bitmaps["stickernormalalt"], &pos, , , 275, , 25) = 1) && (stack := "Sticker"))
					|| ((stickerStackHives = 1) && (Gdip_ImageSearch(pBMScreen, bitmaps["stickerhive"], &pos, , , 275, , 25) = 1) && (stack := "Hive Skin"))
					|| ((stickerStackCubs = 1) && (Gdip_ImageSearch(pBMScreen, bitmaps["stickercub"], &pos, , , 275, , 25) = 1) && (stack := "Cub Skin"))
					|| ((stickerStackVouches = 1) && (Gdip_ImageSearch(pBMScreen, bitmaps["stickervoucher"], &pos, , , 275, , 25) = 1) && (stack := "Voucher")))) {
					SetStatus("Stacking", stack)
					MouseMove windowX + windowWidth // 2 - 275 + SubStr(pos, 1, InStr(pos, ",") - 1) + 26, windowY + 4 * windowHeight // 10 + SubStr(pos, InStr(pos, ",") + 1) - 10 ; select sticker
					if (stickerStackTimerDetect)
						stickerStackTimer += 10
						writeSettings('Collect', "stickerstacktimer", stickerStackTimer)
				} else if InStr(stickerStackItem, "Tickets") {
					SetStatus("Stacking", stack := "Tickets")
					MouseMove windowX + windowWidth // 2 + 105, windowY + 4 * windowHeight // 10 - 78 ; select tickets
				} else { ; StickerStackItem = "Sticker", and nosticker was found or error
					SetStatus("Error", "No Stickers left to stack!`nSticker Stack has been disabled.")
					writeSettings("Collect", "stickerstack", false)
					Sleep 500
					sendinput "{" SC_E " down}"
					Sleep 100
					sendinput "{" SC_E " up}"
					break
				}
				Sleep 100
				Click
				Gdip_DisposeImage(pBMScreen)

				i := 0
				loop 16 {
					sleep 250
					pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 250 "|" windowY + windowHeight // 2 - 52 "|500|150")
					if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
						MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + windowHeight // 2 - 52 + SubStr(pos, InStr(pos, ",") + 1)
						Sleep 800
						Click
						if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
							MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + windowHeight // 2 - 52 + SubStr(pos, InStr(pos, ",") + 1)
							Sleep 200
							Click
						}
						sleep 100
						; voucher separate for aesthetic
						if ((++i >= 4) && !InStr(stack, "Skin") && !(stack = "Voucher")) { ; Yes/No prompt appeared too many times, assume this is not a regular sticker
							Gdip_DisposeImage(pBMScreen)
							SetStatus("Error", "Yes/No appeared too many times!")
							Sleep 500
							sendinput "{" SC_E " down}"
							Sleep 100
							sendinput "{" SC_E " up}"
							break 2
						}
					} else if (i > 0) {
						Gdip_DisposeImage(pBMScreen)
						break
					} else if (A_Index = 16) {
						Gdip_DisposeImage(pBMScreen)
						SetStatus("Error", "No Tickets left to use!`nSticker Stack has been disabled.")
						writeSettings("Collect", "stickerstack", false)
						Sleep 500
						sendinput "{" SC_E " down}"
						Sleep 100
						sendinput "{" SC_E " up}"
						break 2
					}
					Gdip_DisposeImage(pBMScreen)
				}
				Sleep 2000
				SetStatus("Collected", "Sticker Stack")
				break
			}
		}
		if (stickerStack) {
			LastStickerStack := nowUnix()
			writeSettings("Collect", "LastStickerStack", LastStickerStack, "Settings\timers.ini")
			if (!stickerStackTimerDetect) {
				writeSettings("Collect", "stickerstacktimer", StickerStackTimer)
			}
		}
	}
}

DoStockings() {
	global stockings, LastStockings
	if (stockings && (nowUnix() - LastStockings) > 3600) {
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)

			ResetToHive()
			SetStatus("Traveling", "Stockings" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_stockings()

			If (CollectItem()) {
				Sleep 500

				movement :=
					(
						BSSWalk(8, FwdKey) '
				' BSSWalk(2.5, BackKey) '
				' BSSWalk(3, RightKey) '
				Send "{' SC_Space ' down}"
				HyperSleep(500)
				Send "{' SC_Space ' up}"
				DllCall("GetSystemTimeAsFileTime", "int64p", &s:=0)
				' BSSWalk(3, RightKey) '
				DllCall("GetSystemTimeAsFileTime", "int64p", &t:=0)
				Sleep 600-(t-s)//10000
				' BSSWalk(9, LeftKey) '
				Send "{' SC_Space ' down}"
				HyperSleep(500)
				Send "{' SC_Space ' up}"
				DllCall("GetSystemTimeAsFileTime", "int64p", &s:=0)
				' BSSWalk(3, LeftKey) '
				DllCall("GetSystemTimeAsFileTime", "int64p", &t:=0)
				Sleep 600-(t-s)//10000
				' BSSWalk(6, RightKey)
					)
				CreateWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				EndWalk()

				SetStatus("Collected", "Stockings")
				break
			}
		}
		LastStockings := nowUnix()
		writeSettings('Collect', 'LastStockings', LastStockings, "settings\timers.ini")
	}
}
DoFeast() { ; Beesmas Feast
	global Feast, LastFeast
	if (Feast && (nowUnix() - LastFeast) > 5400) { ;1.5 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)

			ResetToHive()
			SetStatus("Traveling", "Beesmas Feast" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_feast()

			If (CollectItem()) {
				Sleep 3000
				sendinput "{" RotLeft "}"

				movement :=
					(
						BSSWalk(3, FwdKey, RightKey) '
				' BSSWalk(1, RightKey) '
				Loop 2 {
					' BSSWalk(5, BackKey) '
					' BSSWalk(1.5, LeftKey) '
					' BSSWalk(5, FwdKey) '
					' BSSWalk(1.5, LeftKey) '
				}
				' BSSWalk(5, BackKey)
					)
				CreateWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				EndWalk()

				SetStatus("Collected", "Beesmas Feast")
				break
			}
		}
		LastFeast := nowUnix()
		writeSettings('Collect', 'LastFeast', LastFeast, "settings\timers.ini")
	}
}
GingerbreadHouse() {
	global Gingerbread, LastGingerbread
	if (Gingerbread && (nowUnix() - LastGingerbread) > 7200) { ;2 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)

			ResetToHive()
			SetStatus("Traveling", "Gingerbread House" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_gingerbread()

			If (CollectItem()) {
				Sleep 3000
				SetStatus("Collected", "Gingerbread House")
				break
			}
		}
		LastGingerbread := nowUnix()
		writeSettings('Collect', 'LastGingerbread', LastGingerbread, "settings\timers.ini")
	}
}
DoSnowMachine() {
	global SnowMachine, LastSnowMachine
	if (SnowMachine && (nowUnix() - LastSnowMachine) > 7200) { ;2 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)

			ResetToHive()
			SetStatus("Traveling", "Snow Machine" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_snowmachine()

			if (CollectItem()) {
				Sleep 500
				SetStatus("Collected", "Snow Machine")
				updateConfig()
				return
			}
		}
		updateConfig()
	}
	updateConfig() {
		LastSnowMachine := nowUnix()
		writeSettings('Collect', 'LastSnowMachine', LastSnowMachine, "settings\timers.ini")
	}
}
DoCandles() {
	global Candles, LastCandles
	if (Candles && (nowUnix() - LastCandles) > 14400) { ;4 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)

			ResetToHive()
			SetStatus("Traveling", "Candles" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_candles()

			If (CollectItem()) {
				Sleep 4000

				movement :=
					(
						BSSWalk(4, FwdKey) "
				" BSSWalk(6, RightKey) "
				" BSSWalk(10, LeftKey)
					)
				CreateWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				EndWalk()

				SetStatus("Collected", "Candles")
				break
			}
		}
		LastCandles := nowUnix()
		writeSettings('Collect', 'LastCandles', LastCandles, "settings\timers.ini")
	}
}
DoSamovar() {
	global Samovar, LastSamovar
	if (Samovar && (nowUnix() - LastSamovar) > 21600) { ;6 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)

			ResetToHive()
			SetStatus("Traveling", "Samovar" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_samovar()

			If (CollectItem()) {
				Sleep 5000

				movement :=
					(
						BSSWalk(4, FwdKey, RightKey) "
				" BSSWalk(1, RightKey) "
				Loop 3 {
					" BSSWalk(6, BackKey) "
					" BSSWalk(1.25, LeftKey) "
					" BSSWalk(6, FwdKey) "
					" BSSWalk(1.25, LeftKey) "
				}
				" BSSWalk(6, BackKey)
					)
				CreateWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				EndWalk()

				SetStatus("Collected", "Samovar")
				break
			}
		}
		LastSamovar := nowUnix()
		writeSettings('Collect', 'LastSamovar', LastSamovar, "settings\timers.ini")
	}
}
DoLidArt() {
	global LidArt, LastLidArt
	if (LidArt && (nowUnix() - LastLidArt) > 28800) { ;8 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)

			ResetToHive()
			SetStatus("Traveling", "Lid Art" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_lidart()

			If (CollectItem()) {
				Sleep 5000

				movement :=
					(
						BSSWalk(3, FwdKey, RightKey) "
				Loop 2 {
					" BSSWalk(4.5, BackKey) "
					" BSSWalk(1.25, LeftKey) "
					" BSSWalk(4.5, FwdKey) "
					" BSSWalk(1.25, LeftKey) "
				}
				" BSSWalk(4.5, BackKey)
					)
				CreateWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				EndWalk()

				SetStatus("Collected", "Lid Art")
				break
			}
		}
		LastLidArt := nowUnix()
		writeSettings('Collect', 'LastLidArt', LastLidArt, "settings\timers.ini")
	}
}
DoGummyBeacon() {
	global GummyBeacon, LastGummyBeacon
	if (GummyBeacon && (nowUnix() - LastGummyBeacon) > 28800 && (MoveMethod != "Walk")) { ;8 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)

			ResetToHive()
			SetStatus("Traveling", "Gummy Beacon" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_gummybeacon()

			If (CollectItem()) {
				Sleep 500
				SetStatus("Collected", "Gummy Beacon")
				break
			}
		}
		LastGummyBeacon := nowUnix()
		writeSettings('Collect', 'LastGummyBeacon', LastGummyBeacon, "settings\timers.ini")
	}
}
DoRBPDelevel() { ;Robo Bear Party De-level
	global RBPDelevel, LastRBPDelevel
	if (RBPDelevel && (nowUnix() - LastRBPDelevel) > 10800 && (MoveMethod != "Walk")) { ;3 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)

			ResetToHive()
			SetStatus("Traveling", "RBP De-Level" ((A_Index > 1) ? " (Attempt 2)" : ""))

			gt_rbpdelevel()

			If (CollectItem()) {
				Sleep 500
				SetStatus("Collected", "RBP De-Level")
				break
			}
		}
		LastRBPDelevel := nowUnix()
		writeSettings('Collect', 'LastRBPDelevel', LastRBPDelevel, "settings\timers.ini")
	}
}