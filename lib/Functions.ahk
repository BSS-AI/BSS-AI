#Requires Autohotkey v2.0
global bitmaps
pToken := Gdip_Startup()

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

global serverIds := []
global JoinAttempts := 0
global CloseRobloxCounter := 0
global ShiftLockEnabled := 0
global resetTime := nowUnix()

Rotate(direction, amount)
{
	if (direction = "left") {
		loop amount {
			send "{" RotLeft "}"
			HyperSleep(50)
		}
	} else if (direction = "right") {
		loop amount {
			send "{" RotRight "}"
			HyperSleep(50)
		}
	} else if (direction = "up") {
		loop amount {
			send "{" RotUp "}"
			HyperSleep(50)
		}
	} else if (direction = "down") {
		loop amount {
			send "{" RotDown "}"
			HyperSleep(50)
		}
	}
}


ActivateGlider() {
	send "{" SC_Space " down}"
	HyperSleep(50)
	send "{" SC_Space " up}"
	HyperSleep(300)
	send "{" SC_Space " down}"
	HyperSleep(50)
	send "{" SC_Space " up}"
}

Jump() {
	send "{" SC_Space " down}"
	HyperSleep(50)
	send "{" SC_Space " up}"
}

ResetCharacter() {
	send "{" SC_Esc " down}"
	HyperSleep(50)
	send "{" SC_Esc " up}"
	HyperSleep(200)
	send "{" SC_R " down}"
	HyperSleep(50)
	send "{" SC_R " up}"
	HyperSleep(200)
	send "{" SC_Enter " down}"
	HyperSleep(50)
	send "{" SC_Enter " up}"
}

Move(tileamount, key1, key2 := 0) {
	send "{" key1 " down}"
	if key2 {
		send "{" key2 " down}"
	}

	Walk(tileamount)

	send "{" key1 " up}"
	if key2 {
		send "{" key2 " up}"
	}
}

MoveToSaturator() {
	global FwdKey, LeftKey, BackKey, RightKey

	GetRobloxClientPos()
	winUp := Floor(windowHeight / 2.14), winDown := Floor(windowHeight / 1.88)
	winLeft := Floor(windowWidth / 2.14), winRight := Floor(windowWidth / 1.88)

	hmove := vmove := 0
	if ((LocateSprinkler(&x, &y) = 1) && !(x >= winLeft && x <= winRight && y >= winUp && y <= winDown)) {
		if ((x < winleft) && (hmove := LeftKey))
			sendinput "{" LeftKey " down}"
		else if ((x > winRight) && (hmove := RightKey))
			sendinput "{" RightKey " down}"
		if ((y < winUp) && (vmove := FwdKey))
			sendinput "{" FwdKey " down}"
		else if ((y > winDown) && (vmove := BackKey))
			sendinput "{" BackKey " down}"
		while (hmove || vmove) {
			if (((hmove = LeftKey) && (x >= winLeft)) || ((hmove = RightKey) && (x <= winRight))) {
				sendinput "{" hmove " up}"
				hmove := ""
			}
			if (((vmove = FwdKey) && (y >= winUp)) || ((vmove = BackKey) && (y <= winDown))) {
				sendinput "{" vmove " up}"
				vmove := ""
			}
			Sleep 20
			if ((A_Index >= 300)) {
				sendinput "{" LeftKey " up}{" RightKey " up}{" FwdKey " up}{" BackKey " up}"
				break
			}
			if (LocateSprinkler(&x, &y) = 0) {
				sendinput "{" LeftKey " up}{" RightKey " up}{" FwdKey " up}{" BackKey " up}"
				Loop 25 {
					Sleep 20
					if (LocateSprinkler(&x, &y) = 1) {
						sendinput (hmove ? "{" hmove " down} " : "") (vmove ? "{" vmove " down} " : "")
						continue 2
					}
				}
				break
			}
		}
		click "up"
	}
}

sprinklerImages := ["saturator"]
bitmaps["saturator"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAsAAAANCAYAAAB/9ZQ7AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAZSURBVChTY2C88f8/sXhUMTIeVYzA//8DAD1Dlimzf8yLAAAAAElFTkSuQmCC")
bitmaps["saturatorWS"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAsAAAANCAIAAADwlwNsAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABWSURBVChTfY5RDsAgDEJx99+Z6zMujXYoXy2lQHsjmjzgQ3q+7QBEQ4HwAu/Ba0YPRelR1ppSzuDWdKpNSmJ6Hz3ybeuxmkGalL+UwaTApgEwKetZUgfv4wyvgpuHgQAAAABJRU5ErkJggg==")

LocateSprinkler(&X := "", &Y := "") { ; find client coordinates of approximately closest saturator to player/center
	global bitmaps, sprinklerImages
	n := sprinklerImages.Length

	hwnd := GetRobloxHWND()
	; offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" (windowY + offsetY + 75) "|" (hWidth := windowWidth) "|" (hHeight := windowHeight - offsetY - 75) "|")

	Gdip_LockBits(pBMScreen, 0, 0, hWidth, hHeight, &hStride, &hScan, &hBitmapData, 1)
	hWidth := NumGet(hBitmapData, 0, "UInt"), hHeight := NumGet(hBitmapData, 4, "UInt")

	local n1width, n1height, n1Stride, n1Scan, n1BitmapData
		, n1width, n1height, n2Stride, n2Scan, n2BitmapData
		, n1width, n1height, n3Stride, n3Scan, n3BitmapData ; this will give you errors in editors but it works.

	for i, k in sprinklerImages
	{
		Gdip_GetImageDimensions(bitmaps[k], &n%i%Width, &n%i%Height)
		Gdip_LockBits(bitmaps[k], 0, 0, n%i%Width, n%i%Height, &n%i%Stride, &n%i%Scan, &n%i%BitmapData)
		n%i%Width := NumGet(n%i%BitmapData, 0, "UInt"), n%i%Height := NumGet(n%i%BitmapData, 4, "UInt")
	}

	d := 11 ; divisions (odd positive integer such that w,h > n%i%Width,n%i%Height for all i<=n)
	m := d // 2 ; midpoint of d (along with m + 1), used frequently in calculations
	v := 50 ; variation
	w := hWidth // d, h := hHeight // d

	; to search from centre (approximately), we will split the rectangle like a pinwheel configuration and search outwards (notice SearchDirection)
	Loop m + 1
	{
		if (A_Index = 1)
		{
			; initial rectangle (center)
			d1 := m, d2 := m + 1
			OuterX1 := d1 * w, OuterX2 := d2 * w
			OuterY1 := d1 * h, OuterY2 := d2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2 - n%A_Index%Width + 1, OuterY2 - n%A_Index%Height + 1, v, 1, 1) > 0)
					break 2
		}
		else
		{
			; upper-right
			dx1 := m + 2 - A_Index, dx2 := m + A_Index
			OuterX1 := dx1 * w, OuterX2 := dx2 * w
			dy1 := m + 1 - A_Index, dy2 := m + 2 - A_Index
			OuterY1 := dy1 * h, OuterY2 := dy2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2 - n%A_Index%Width + 1, OuterY2 - n%A_Index%Height + 1, v, 2, 1) > 0)
					break 2

			; lower-right
			dx1 := m - 1 + A_Index, dx2 := m + A_Index
			OuterX1 := dx1 * w, OuterX2 := dx2 * w
			dy1 := m + 2 - A_Index, dy2 := m + A_Index
			OuterY1 := dy1 * h, OuterY2 := dy2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2 - n%A_Index%Width + 1, OuterY2 - n%A_Index%Height + 1, v, 5, 1) > 0)
					break 2

			; lower-left
			dx1 := m + 1 - A_Index, dx2 := m - 1 + A_Index
			OuterX1 := dx1 * w, OuterX2 := dx2 * w
			dy1 := m - 1 + A_Index, dy2 := m + A_Index
			OuterY1 := dy1 * h, OuterY2 := dy2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2 - n%A_Index%Width + 1, OuterY2 - n%A_Index%Height + 1, v, 4, 1) > 0)
					break 2

			; upper-left
			dx1 := m + 1 - A_Index, dx2 := m + 2 - A_Index
			OuterX1 := dx1 * w, OuterX2 := dx2 * w
			dy1 := m + 1 - A_Index, dy2 := m - 1 + A_Index
			OuterY1 := dy1 * h, OuterY2 := dy2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2 - n%A_Index%Width + 1, OuterY2 - n%A_Index%Height + 1, v, 7, 1) > 0)
					break 2
		}
	}

	Gdip_UnlockBits(pBMScreen, &hBitmapData)
	for i, k in sprinklerImages
		Gdip_UnlockBits(bitmaps[k], &n%i%BitmapData)
	Gdip_DisposeImage(pBMScreen)

	if pos
	{
		x := SubStr(pos, 1, InStr(pos, ",") - 1), y := 75 + SubStr(pos, InStr(pos, ",") + 1)
		return 1
	}
	else
	{
		x := "", y := ""
		return 0
	}
}

ResetToHive(checkAll := 1, wait := 2000, conv := 1, force := 0) {
	VBState := 0 ; unsure what this is
	HiveConfirmed := 0 ; unsure what this is

	global resetTime, HiveConfirmed, bitmaps, KeyDelay
	static hivedown := 0
	youDied := 0
	;check for game frozen conditions
	DisconnectCheck()
	SetShiftLock(0)

	OpenMenu()

	while (!HiveConfirmed) {
		;failsafe game frozen
		if (Mod(A_Index, 10) = 0) {
			SetStatus("Closing", "Roblox")
			CloseRoblox()
			DisconnectCheck()
			continue
		}
		DisconnectCheck()
		ActivateRoblox()
		SetShiftLock(0)
		OpenMenu()

		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		;check that performance stats is disabled
		GetRobloxClientPos(hwnd)

		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + offsetY + 36 "|" windowWidth "|24")
		if ((Gdip_ImageSearch(pBMScreen, bitmaps["perfmem"], &pos, , , , , 2, , 5) = 1)
			&& (Gdip_ImageSearch(pBMScreen, bitmaps["perfwhitefill"], , x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1), y := SubStr(pos, comma + 1), x + 17, y + 7, 2) = 0)) {
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["perfcpu"], &pos, x + 17, y, , y + 7, 2) = 1)
				&& (Gdip_ImageSearch(pBMScreen, bitmaps["perfwhitefill"], , x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1), y := SubStr(pos, comma + 1), x + 17, y + 7, 2) = 0)) {
				if ((Gdip_ImageSearch(pBMScreen, bitmaps["perfgpu"], &pos, x + 17, y, , y + 7, 2) = 1)
					&& (Gdip_ImageSearch(pBMScreen, bitmaps["perfwhitefill"], , x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1), y := SubStr(pos, comma + 1), x + 17, y + 7, 2) = 0)) {
					Send "^{F7}"
				}
			}
		}
		Gdip_DisposeImage(pBMScreen)

		;check to make sure you are not in dialog before reset
		Loop 500
		{
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 50 "|" windowY + 2 * windowHeight // 3 "|100|" windowHeight // 3)
			if (Gdip_ImageSearch(pBMScreen, bitmaps["dialog"], &pos, , , , , 10, , 3) != 1) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			MouseMove windowX + windowWidth // 2, windowY + 2 * windowHeight // 3 + SubStr(pos, InStr(pos, ",") + 1) - 15
			Click
			Sleep 150
		}
		MouseMove windowX + 350, windowY + offsetY + 100
		;check to make sure you are not in a yes/no prompt
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 250 "|" windowY + windowHeight // 2 - 52 "|500|150")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["no"], &pos, , , , , 2, , 3) = 1) {
			MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + windowHeight // 2 - 52 + SubStr(pos, InStr(pos, ",") + 1)
			Click
			MouseMove windowX + 350, windowY + offsetY + 100
		}
		Gdip_DisposeImage(pBMScreen)
		;check to make sure you are not in feed window on accident
		imgPos := ImgSearch("cancel.png", 30)
		If (imgPos[1] = 0) {
			MouseMove windowX + (imgPos[2]), windowY + (imgPos[3])
			Click
			MouseMove windowX + 350, windowY + offsetY + 100
		}
		;check to make sure you are not in blender screen
		BlenderSS := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 275 "|" windowY + Floor(0.48 * windowHeight) - 220 "|550|400")
		if (Gdip_ImageSearch(BlenderSS, bitmaps["CloseGUI"], , , , , , 5) > 0) {
			MouseMove windowX + windowWidth // 2 - 250, windowY + Floor(0.48 * windowHeight) - 200
			Sleep 150
			click
		}
		Gdip_DisposeImage(BlenderSS)
		;check to make sure you are not in sticker screen
		pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 275 "|" windowY + 4 * windowHeight // 10 - 178 "|56|56")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["CloseGUI"], , , , , , 5) > 0) {
			MouseMove windowX + windowWidth // 2 - 250, windowY + 4 * windowHeight // 10 - 150
			sleep 150
			click
		}
		Gdip_DisposeImage(pBMScreen)
		;check to make sure you are not in shop before reset
		searchRet := ImgSearch("e_button.png", 30, "high")
		If (searchRet[1] = 0) {
			loop 2 {
				shopG := ImgSearch("shop_corner_G.png", 30, "right")
				shopR := ImgSearch("shop_corner_R.png", 30, "right")
				If (shopG[1] = 0 || shopR[1] = 0) {
					sendinput "{" SC_E " down}"
					Sleep 100
					sendinput "{" SC_E " up}"
					Sleep 1000
				}
			}
		}

		;check to make sure there is not a window open
		searchRet := ImgSearch("close.png", 30, "full")
		If (searchRet[1] = 0) {
			MouseMove windowX + searchRet[2], windowY + searchRet[3]
			click
			MouseMove windowX + 350, windowY + offsetY + 100
			Sleep 1000
		}
		;check to make sure there is no Memory Match
		SetStatus("Resetting", "Character " A_Index)
		MouseMove windowX + 350, windowY + offsetY + 100
		PrevKeyDelay := A_KeyDelay
		SetKeyDelay 250 + keyDelay
		Loop (VBState = 0) ? (1) : 1
		{
			resetTime := nowUnix()
			;PostSubmacroMessage("background", 0x5554, 1, resetTime)
			;reset
			ActivateRoblox()
			GetRobloxClientPos()
			send "{" SC_Esc "}"
			Sleep 100 + keyDelay
			send "{" SC_R "}"
			Sleep 100 + keyDelay
			send "{" SC_Enter "}"
			n := 0
			while ((n < 2) && (A_Index <= 80))
			{
				Sleep 100
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|50")
				n += (Gdip_ImageSearch(pBMScreen, bitmaps["emptyhealth"], , , , , , 10) = (n = 0))
				Gdip_DisposeImage(pBMScreen)
			}
			Sleep 1000
		}
		SetKeyDelay PrevKeyDelay

		; hive check
		if hivedown
			sendinput "{" RotDown "}"
		region := windowX "|" windowY + 3 * windowHeight // 4 "|" windowWidth "|" windowHeight // 4
		sconf := windowWidth ** 2 // 3200
		loop 4 {
			sleep 250 + keyDelay
			pBMScreen := Gdip_BitmapFromScreen(region), s := 0
			for i, k in bitmaps["hive"] {
				s := Max(s, Gdip_ImageSearch(pBMScreen, k, , , , , , 4, , , sconf))
				if (s >= sconf) {
					Gdip_DisposeImage(pBMScreen)
					HiveConfirmed := 1
					sendinput "{" RotRight " 4}" (hivedown ? ("{" RotUp "}") : "")
					break 2
				}
			}
			Gdip_DisposeImage(pBMScreen)
			sendinput "{" RotRight " 4}" ((A_Index = 2) ? ("{" ((hivedown := !hivedown) ? RotDown : RotUp) "}") : "")
		}
	}
	Send "{" ZoomOut "}"
	Sleep 100
	Send "{" ZoomOut "}"
	Sleep 100
	Send "{" ZoomOut "}"
	Sleep 100
	Send "{" ZoomOut "}"
	Sleep 100
	Send "{" ZoomOut "}"
	Sleep 100
	;convert
	(conv = 1) && convert()
	;ensure minimum delay has been met
	if ((nowUnix() - resetTime) < wait) {
		remaining := floor((wait - (nowUnix() - resetTime)) / 1000) ;seconds
		if (remaining > 5) {
			Sleep 1000
			SetStatus("Waiting", remaining . " Seconds")
			Sleep (remaining - 1) * 1000
		}
		else {
			Sleep (remaining * 1000) ;miliseconds
		}
	}
}

ShiftLock() {
	send "{" SC_LShift " down}"
	Sleep(50)
	send "{" SC_LShift " up}"
}

SetShiftLock(state, *) {
	global bitmaps, SC_LShift

	if !(hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe")) ; Shift Lock is not supported on UWP app at the moment
		return

	ActivateRoblox()
	GetRobloxClientPos(hwnd)

	pBMScreen := Gdip_BitmapFromScreen(windowX + 5 "|" windowY + windowHeight - 54 "|50|50")

	switch (v := Gdip_ImageSearch(pBMScreen, bitmaps["shiftlock"], , , , , , 2))
	{
		; shift lock enabled - disable if needed
		case 1:
			if (state = 0)
			{
				send "{" SC_LShift "}"
				result := 0
			}
			else
				result := 1

			; shift lock disabled - enable if needed
		case 0:
			if (state = 1)
			{
				send "{" SC_LShift "}"
				result := 1
			}
			else
				result := 0
	}

	Gdip_DisposeImage(pBMScreen)
	;return (result) ;ShiftLockEnabled:=result before
}

OpenMenu(tab := "", refresh := 0) {
	global bitmaps
	static x := Map("itemmenu", 30, "questlog", 85, "beemenu", 140, "badgelist", 195, "settingsmenu", 250, "shopmenu", 305), open := ""

	if (hwnd := GetRobloxHWND())
		ActivateRoblox()
	else
		return 0

	; Get the client area position and size
	clientRect := Buffer(16, 0)
	DllCall("GetClientRect", "Ptr", hwnd, "Ptr", clientRect)
	DllCall("ClientToScreen", "Ptr", hwnd, "Ptr", clientRect)
	clientX := NumGet(clientRect, 0, "Int")
	clientY := NumGet(clientRect, 4, "Int")
	clientWidth := NumGet(clientRect, 8, "Int")
	clientHeight := NumGet(clientRect, 12, "Int")

	if ((tab = "") || (refresh = 1)) ; close
	{
		if open ; close the open tab
		{
			Loop 10
			{
				pBMScreen := Gdip_BitmapFromScreen(clientX "|" clientY + 72 "|350|80")
				if (Gdip_ImageSearch(pBMScreen, bitmaps[open], , , , , , 2) != 1) {
					Gdip_DisposeImage(pBMScreen)
					open := ""
					break
				}
				Gdip_DisposeImage(pBMScreen)
				SendEvent "{Click " clientX + x[open] " " clientY + 120 " 0}"
				Click
				SendEvent "{Click " clientX + 350 " " clientY + 100 " 0}"
				Sleep(500)
			}
		}
		else ; close any open tab
		{
			for k, v in x
			{
				Loop 10
				{
					pBMScreen := Gdip_BitmapFromScreen(clientX "|" clientY + 72 "|350|80")
					if (Gdip_ImageSearch(pBMScreen, bitmaps[k], , , , , , 2) != 1) {
						Gdip_DisposeImage(pBMScreen)
						break
					}
					Gdip_DisposeImage(pBMScreen)
					SendEvent "{Click " clientX + v " " clientY + 120 " 0}"
					Click
					SendEvent "{Click " clientX + 350 " " clientY + 100 " 0}"
					Sleep(500)
				}
			}
			open := ""
		}
	}
	else
	{
		if ((tab != open) && open) ; close the open tab
		{
			Loop 10
			{
				pBMScreen := Gdip_BitmapFromScreen(clientX "|" clientY + 72 "|350|80")
				if (Gdip_ImageSearch(pBMScreen, bitmaps[open], , , , , , 2) != 1) {
					Gdip_DisposeImage(pBMScreen)
					open := ""
					break
				}
				Gdip_DisposeImage(pBMScreen)
				SendEvent "{Click " clientX + x[open] " " clientY + 120 " 0}"
				Click
				SendEvent "{Click " clientX + 350 " " clientY + 100 " 0}"
				Sleep(500)
			}
		}
		; open the desired tab
		Loop 10
		{
			pBMScreen := Gdip_BitmapFromScreen(clientX "|" clientY + 72 "|350|80")
			if (Gdip_ImageSearch(pBMScreen, bitmaps[tab], , , , , , 2) = 1) {
				Gdip_DisposeImage(pBMScreen)
				open := tab
				break
			}
			Gdip_DisposeImage(pBMScreen)
			SendEvent "{Click " clientX + x[tab] " " clientY + 120 " 0}"
			Click
			SendEvent "{Click " clientX + 350 " " clientY + 100 " 0}"
			Sleep(500)
		}
	}
}

PressE() {
	hwnd := GetRobloxHWND()
	GetRobloxClientPos(hwnd)
	checker := ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight / 2, "*10 " A_ScriptDir "/Assets/images/e.png")
	if (checker = 0) {
		return false
	}
	send "{" SC_E " down}"
	Sleep(50 + keyDelay)
	send "{" SC_E " up}"
	return true
}

InventorySearch(item, direction := "down", prescroll := 0, prescrolldir := "", scrolltoend := 1, max := 70) { ;~ item: string of item; direction: down or up; prescroll: number of scrolls before direction switch; prescrolldir: direction to prescroll, set blank for same as direction; scrolltoend: set 0 to omit scrolling to top/bottom after prescrolls; max: number of scrolls in total
	global bitmaps
	static hRoblox := 0, l := 0

	OpenMenu("itemmenu")

	; detect inventory end for current hwnd
	if (hwnd := GetRobloxHWND())
	{
		if (hwnd != hRoblox)
		{
			ActivateRoblox()
			;offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + offsetY + 150 "|306|" windowHeight - offsetY - 150)

			Loop 40
			{
				if (Gdip_ImageSearch(pBMScreen, bitmaps["item"], &lpos, , , 6, , 2, , 2) = 1)
				{
					Gdip_DisposeImage(pBMScreen)
					l := SubStr(lpos, InStr(lpos, ",") + 1) - 60 ; image 20px, item 80px => y+20-80 = y-60
					hRoblox := hwnd
					break
				}
				else
				{
					if (A_Index = 40)
					{
						Gdip_DisposeImage(pBMScreen)
						return 0
					}
					else
					{
						Sleep 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + offsetY + 150 "|306|" windowHeight - offsetY - 150)
					}
				}
			}
		}
	}
	else
		return 0 ; no roblox
	;woffsetY := GetYOffset(hwnd)

	; search inventory
	Loop max
	{
		ActivateRoblox()
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + offsetY + 150 "|306|" l)

		; wait for red vignette effect to disappear
		Loop 40
		{
			if (Gdip_ImageSearch(pBMScreen, bitmaps["item"], , , , 6, , 2) = 1)
				break
			else
			{
				if (A_Index = 40)
				{
					Gdip_DisposeImage(pBMScreen)
					return 0
				}
				else
				{
					Sleep 50
					Gdip_DisposeImage(pBMScreen)
					pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + offsetY + 150 "|306|" l)
				}
			}
		}

		if (Gdip_ImageSearch(pBMScreen, bitmaps[item], &pos, , , , , 10, , 5) = 1) {
			Gdip_DisposeImage(pBMScreen)
			break ; item found
		}
		Gdip_DisposeImage(pBMScreen)

		switch A_Index
		{
			case (prescroll + 1): ; scroll entire inventory on (prescroll+1)th search
				if (scrolltoend = 1)
				{
					Loop 100
					{
						SendEvent "{Click " windowX + 30 " " windowY + offsetY + 200 " 0}"
						SendInput "{Wheel" ((direction = "down") ? "Up" : "Down") "}"
						Sleep 50
					}
				}
			default: ; scroll once
				SendEvent "{Click " windowX + 30 " " windowY + offsetY + 200 " 0}"
				SendInput "{Wheel" ((A_Index <= prescroll) ? (prescrolldir ? ((prescrolldir = "Down") ? "Down" : "Up") : ((direction = "down") ? "Down" : "Up")) : ((direction = "down") ? "Down" : "Up")) "}"
				Sleep 50
		}
		Sleep 500 ; wait for scroll to finish
	}
	return (pos ? [30, SubStr(pos, InStr(pos, ",") + 1) + 190] : 0) ; return list of coordinates for dragging
}

ClickOnInventory() {
	/*x := GetRelativeX(43, 40)
	y := GetRelativeY(173, 170) ; This is broken and needs a detection (Finding the correct spot)
	
	MouseMove(x.max, y.max+10, 3)
	Sleep 20
	MouseMove(x.min, y.min+10, 3)
	Sleep 20
	MouseClick("Left")
	*/

	OpenMenu("itemmenu")
}

FindItem(item) {
	if item = "The Planter Of Plenty" {
		item := "The Planter" ; better detection
	}
	OpenMenu("itemmenu")
	Sleep 500
	MouseMove(250, A_ScreenHeight / 2 - 5, 3)
	Sleep 100
	MouseClick("Left", 253, A_ScreenHeight / 2)
	Sleep 100

	Loop 75 {
		MouseClick("WheelUp")
		Sleep 20
	} ; to top

	global itemfoundstatement := false
	Sleep 300
	loop
	{
		result := OCR.FromDesktop(, 2)
		found := result.FindStrings(item, , RegExMatch)
		if found.Length {
			global itemfoundstatement := true
		}

		if itemfoundstatement = true {
			global itemfoundstatement := false
			break
		}

		MouseClick("WheelDown")
		Sleep 200

		if A_Index > 100 {
			SetStatus("Error", "Item not found " item)
			return false
		}
	}

	try {
		result.click(result.FindString(Item))
	}
	catch Error as e
	{
		SetStatus("Error", "Failed to use item " . Item "\nError: " e)
		return false
	}
	Sleep 50

	MouseGetPos &x, &y

	ItemX := GetRelativeX(40, 42)
	MouseMove(ItemX.min, y)
	Sleep 50
	MouseMove(ItemX.max, y + 10)
	return true
	; close inventory after
}

GetRelativeX(min, max) {
	sw := A_ScreenWidth
	return { Min: Round(min * sw / 1920), Max: Round(max * sw / 1920) }
}

GetRelativeY(min, max) {
	sh := A_ScreenHeight
	return { Min: Round(min * sh / 1080), Max: Round(max * sh / 1080) }
}

FullyCloseRoblox() {
	RunWait('taskkill /F /IM RobloxPlayerBeta.exe')
	RunWait('taskkill /F /IM ApplicationFrameHost.exe')
}

CloseRoblox() {
	global CloseRobloxCounter += 1
	if CloseRobloxCounter < 10 ; 10 times normal close before full close
	{
		send "{" SC_Esc " down}"
		HyperSleep(50)
		send "{" SC_Esc " up}"
		HyperSleep(100)
		send "{" SC_L " down}"
		HyperSleep(50)
		send "{" SC_L " up}"
		HyperSleep(200)
		send "{" SC_Enter " down}"
		HyperSleep(50)
		send "{" SC_Enter " up}"

		Sleep 500 ; optional
	}
	else
	{
		RunWait('taskkill /F /IM RobloxPlayerBeta.exe')
		RunWait('taskkill /F /IM ApplicationFrameHost.exe')
		global CloseRobloxCounter := 0
	}
}

nowUnix() => DateDiff(A_NowUTC, "19700101000000", "Seconds")

StopMovement() {
	send "{" w " up}"
	send "{" a " up}"
	send "{" s " up}"
	send "{" d " up}"
	send "{" RotLeft " up}"
	send "{" RotRight " up}"
	send "{" SC_E " up}"
	send "{" SC_Enter " up}"
	send "{" SC_Space " up}"
	; Could Add more
}

DisconnectCheck()
{
	global bitmaps
	;static ServerLabels := Map(0,"Public Server", 1,"Private Server", 2,"Fallback Server 1", 3,"Fallback Server 2", 4,"Fallback Server 3", 5, "Vic Hop Server")

	; return if not disconnected or crashed
	ActivateRoblox()
	GetRobloxClientPos()
	if ((windowWidth > 0) && !WinExist("Roblox Crash")) {
		pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 "|" windowY + windowHeight // 2 "|200|80")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["disconnected"], , , , , , 2) != 1) {
			Gdip_DisposeImage(pBMScreen)
			return 0
		}
		Gdip_DisposeImage(pBMScreen)
	}

	; end any residual movement and set reconnect start time
	Click "Up"
	StopMovement()
	ReconnectStart := nowUnix()
	; main reconnect loop
	Loop {
		;Decide Server
		;server := ((A_Index <= 20) && linkCodes.Has(n := (A_Index-1)//5 + 1)) ? n : ((PublicFallback = 0) && (n := ObjMinIndex(linkcodes))) ? n : 0

		;Wait For Success
		;i := A_Index, success := 1
		;Loop 5 {
		;
		;}

		if privateServerUrl != "" or usePrivateServer = true
			JoinSetPrivateServer(privateServerUrl) ; really basic system, not using fallback.
		else
			JoinNormalServer()

		waitTillLoaded()
		offsetY := GetYOffset()
		ClaimHiveFromSpawn()
		break
	}
}

HyperSleep(ms)
{
	static freq := (DllCall("QueryPerformanceFrequency", "Int64*", &f := 0), f)
	DllCall("QueryPerformanceCounter", "Int64*", &begin := 0)
	current := 0, finish := begin + ms * freq / 1000
	while (current < finish)
	{
		if ((finish - current) > 30000)
		{
			DllCall("Winmm.dll\timeBeginPeriod", "UInt", 1)
			DllCall("Sleep", "UInt", 1)
			DllCall("Winmm.dll\timeEndPeriod", "UInt", 1)
		}
		DllCall("QueryPerformanceCounter", "Int64*", &current)
	}
}

QPC() {
	static _ := 0, f := (DllCall("QueryPerformanceFrequency", "int64p", &_), _ /= 1000)
	return (DllCall("QueryPerformanceCounter", "int64p", &_), _ / f)
}

JoinNormalServer() {
	run('roblox://placeId=1537690962')
}

JoinPublicServerID(id) {
	run '"roblox://placeId=1537690962&gameInstanceId=' id '"'
}

JoinSetPrivateServer(serverlink) {
	RegExMatch(serverlink, "privateServerLinkCode=(\d+)", &match)
	linkcode := match[1]
	Run "roblox://placeID=1537690962&linkcode=" . linkcode
}

checkjoinerror() {
	;el := PixelSearch(&x,&y,0,0,A_ScreenWidth,A_ScreenHeight, 0x393B3D)
	el := ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight, "*35 " A_ScriptDir "/Assets/images/joinerror.png")
	if el = 1
		return true
}

checkjoindisconnect() {
	el := ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight, "*35 " A_ScriptDir "/Assets/images/disconnected.png")
	if el = 1
		return true
}

checkrestricted() {
	el := ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight, "*35 " A_ScriptDir "/Assets/images/restricted.png")
	if el = 1
		return true
}

ServerHop(*) {
TryServerHop:
	try {
		static lastServers := []
		Whr := ComObject("WinHTTP.WinHTTPRequest.5.1")
		Whr.open("GET", "https://games.roblox.com/v1/games/1537690962/servers/Public?sortOrder=Asc&limit=100", true)
		whr.send()
		whr.waitForResponse()
		data := JSON.parse(whr.responsetext)["data"]
		loop {
			global id := data[random(1, data.length)]["id"]
			for i in lastServers
				if (i == id)
					continue 2
			lastServers.InsertAt(1, id)
			if (lastServers.length > 5)
				lastServers.Pop()
			break
		}
		run "roblox://placeId=1537690962&gameInstanceId=" id
		;WebhookSendMessage("joins new Server")
	} catch {
		Sleep 500
		Goto TryServerHop
	}
}

CheckIfJoined() {
	try {
		FoundX := 0, FoundY := 0
		ImagePath := A_ScriptDir "\Assets\images\Pollen.png"
		ErrorLevel := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_screenHeight, "*70 " ImagePath) ; 60

		if WinExist("Roblox") {
			try {
				WinActivate("Roblox")
			}
		}

		if (ErrorLevel = 0)
		{
			return false
		} else if (ErrorLevel = 1) {
			return true
		}
	}
}

SetStatus(newState := 0, newObjective := 0) {
	global state, objective

	if (newState != "Detected") {
		if (newState)
			state := newState
		if (newObjective)
			objective := newObjective
	}
	stateString := ((newState ? newState : state) . ": " . (newObjective ? newObjective : objective))
	status("[" A_MM "/" A_DD "][" A_Hour ":" A_Min ":" A_Sec "] " stateString)
}

/*return_pollen_bag() {
    x1 := GetRelativeX(1018, 1018).Min
    y1 := GetRelativeY(23, 23).Min
    x2 := GetRelativeX(1280, 1280).Min
    y2 := GetRelativeY(75, 75).Min

    width := x2 - x1
    height := y2 - y1

    tempFile := A_Temp "\screen_capture.png"
    upscaledFile := A_Temp "\upscaled.png"

    try {
        FileDelete(tempFile)
        FileDelete(upscaledFile)
    } catch {

    }

    pBitmap := Gdip_BitmapFromScreen(x1 "|" y1 "|" width "|" height)
    Gdip_SaveBitmapToFile(pBitmap, tempFile)
    Gdip_DisposeImage(pBitmap)

    ; Upscale and replace green color with gray in one command
    RunWait(A_ComSpec " /c magick " tempFile " -resize 200% -fuzz 15% -fill `"#696C6E`" -opaque `"#41FF86`" " upscaledFile, , "Hide") ; IMAGEMAGICK NEEDS TO BE INSTALLED

    ocrText := RP_OCR(upscaledFile)

    try {
        FileDelete(tempFile)
        FileDelete(upscaledFile)
    } catch {

    }

    slashPos := InStr(ocrText, "/")
    if (slashPos > 0) {
        numberPart := SubStr(ocrText, 1, slashPos - 1)
    } else {
        numberPart := ocrText
    }

    numberPart := StrReplace(numberPart, ",", "")

    ; Convert to integer if possible
    try {
        return Integer(numberPart)
    } catch {
        return numberPart
    }
}*/

ImgSearch(fileName, v, aim := "full", trans := "none") {
	GetRobloxClientPos()
	;xi := 0
	;yi := 0
	;ww := windowWidth
	;wh := windowHeight
	xi := (aim = "actionbar") ? windowWidth // 4 : (aim = "highright") ? windowWidth // 2 : (aim = "right") ? windowWidth // 2 : (aim = "center") ? windowWidth // 4 : (aim = "lowright") ? windowWidth // 2 : 0
	yi := (aim = "low") ? windowHeight // 2 : (aim = "actionbar") ? (windowHeight // 4) * 3 : (aim = "center") ? windowHeight // 4 : (aim = "lowright") ? windowHeight // 2 : (aim = "quest") ? 150 : 0
	ww := (aim = "actionbar") ? xi * 3 : (aim = "highleft") ? windowWidth // 2 : (aim = "left") ? windowWidth // 2 : (aim = "center") ? xi * 3 : (aim = "quest" || aim = "questbrown") ? 310 : windowWidth
	wh := (aim = "high") ? windowHeight // 2 : (aim = "highright") ? windowHeight // 2 : (aim = "highleft") ? windowHeight // 2 : (aim = "buff") ? 150 : (aim = "abovebuff") ? 30 : (aim = "center") ? yi * 3 : (aim = "quest") ? Max(560, windowHeight - 100) : (aim = "questbrown") ? windowHeight // 2 : windowHeight
	if DirExist(A_WorkingDir "\Assets\images\")
	{
		try result := ImageSearch(&FoundX, &FoundY, windowX + xi, windowY + yi, windowX + ww, windowY + wh, "*" v ((trans != "none") ? (" *Trans" trans) : "") " " A_WorkingDir "\Assets\images\" fileName)
		catch {
			SetStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\Assets\images\" fileName)
			Sleep 5000
			ProcessClose DllCall("GetCurrentProcessId")
		}
		if (result = 1)
			return [0, FoundX - windowX, FoundY - windowY]
		else
			return [1, 0, 0]
	} else {
		MsgBox "Folder location cannot be found:`n" A_WorkingDir "\Assets\images\"
		return [3, 0, 0]
	}
}

HealthDetection(w := 0)
{
	static pBMHealth, pBMDamage
	HealthBars := []
	if !(IsSet(pBMHealth) && IsSet(pBMDamage))
	{
		pBMHealth := Gdip_CreateBitmap(1, 4)
		pGraphics := Gdip_GraphicsFromImage(pBMHealth), Gdip_GraphicsClear(pGraphics, 0xff1fe744), Gdip_DeleteGraphics(pGraphics)
		pBMDamage := Gdip_CreateBitmap(1, 4)
		pGraphics := Gdip_GraphicsFromImage(pBMDamage), Gdip_GraphicsClear(pGraphics, 0xff6b131a), Gdip_DeleteGraphics(pGraphics)
	}
	ActivateRoblox()
	GetRobloxClientPos()
	if w = 1 ; king beetle, right half search only to avoid false detections
		pBMScreen := Gdip_BitmapFromScreen((windowX + windowWidth // 2) "|" windowY "|" windowWidth // 2 "|" windowHeight)
	else
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight)
	G := Gdip_GraphicsFromImage(pBMScreen)
	pBrush := Gdip_BrushCreateSolid(0xff000000)
	while ((Gdip_ImageSearch(pBMScreen, pBMHealth, &HPStart, , , , , , , 5) > 0) || (Gdip_ImageSearch(pBMScreen, pBMDamage, &HPStart, , , , , , , 5) > 0))
	{
		x := SubStr(HPStart, 1, InStr(HPStart, ",") - 1), y := SubStr(HPStart, InStr(HPStart, ",") + 1)
		x1 := x, y1 := y
		Loop (windowWidth - x)
		{
			i := x + A_Index - 1
			switch Gdip_GetPixel(pBMScreen, i, y)
			{
				case 4280280900:
					x1++

				case 4285207322:
					x2 := i

				default:
					Break
			}
		}
		Loop (windowHeight - y)
		{
			switch Gdip_GetPixel(pBMScreen, x, y1)
			{
				case 4280280900, 4285207322:
					y1++

				default:
					Break
			}
		}
		HealthBarPercent := (x1 > x) ? ((IsSet(x2) && (x2 > x)) ? Round((x1 - x) / (x2 - x) * 100, 2) : 100.00) : 0.00
		Gdip_FillRectangle(G, pBrush, x, y, i - x, y1 - y)
		HealthBars.Push(HealthBarPercent)
		if (A_Index > 100)
		{
			Break
		}
	}
	Gdip_DeleteBrush(pBrush), Gdip_DisposeImage(pBMScreen), Gdip_DeleteGraphics(G)
	Return HealthBars
}

AmuletPrompt(decision := 0, type := 0, *) {
	global bitmaps, ShiftLockEnabled

	Prev_ShiftLock := ShiftLockEnabled
	SetShiftLock(0)

	GetRobloxClientPos()
	if (windowWidth = 0)
		return 2
	else
		ActivateRoblox()

	pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 250 "|" windowY "|500|" windowHeight)

	if (Gdip_ImageSearch(pBMScreen, bitmaps["keep"], &pos, , , , , 2, , 2) = 1)
	{
		switch decision, 0
		{
			case "keep", 1:
				if type = "Ant" || type = "King Beetle" || type = "Shell"
					SetStatus("Keeping", type " Amulet")
				Gdip_DisposeImage(pBMScreen)
				loop 10
				{
					MouseMove windowX + 350, windowY + offsetY + 100
					pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 250 "|" windowY "|500|" windowHeight)
					if (Gdip_ImageSearch(pBMScreen, bitmaps["keep"], &pos, , , , , 2, , 2) = 1)
					{
						MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1) + 10, windowY + SubStr(pos, InStr(pos, ",") + 1) + 10, 5
						Sleep 200
						Click
					}
					Gdip_DisposeImage(pBMScreen)
				}
				SetShiftLock(Prev_ShiftLock)
				return 1

			case "replace", 2:
				MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1) + 190, windowY + SubStr(pos, InStr(pos, ",") + 1) + 10, 5
				Click
				Gdip_DisposeImage(pBMScreen)
				Loop 25
				{
					pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 250 "|" windowY "|500|" windowHeight)
					if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1)
					{
						MouseMove windowX + windowWidth // 2 - 250 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + SubStr(pos, InStr(pos, ",") + 1), 5
						Click
						Gdip_DisposeImage(pBMScreen)
						break
					}
					Gdip_DisposeImage(pBMScreen)
					Sleep 100
				}
				SetShiftLock(Prev_ShiftLock)
				return 1

			case "obtained", 3:
				SetStatus("Obtained", type " Amulet")
				Gdip_DisposeImage(pBMScreen)
				SetShiftLock(Prev_ShiftLock)
				return 1

			default:
				Gdip_DisposeImage(pBMScreen)
				SetShiftLock(Prev_ShiftLock)
				return 1
		}
	}
	else
	{
		Gdip_DisposeImage(pBMScreen)
		SetShiftLock(Prev_ShiftLock)
		return 0
	}
}

Loot(length, reps, direction, tokenlink := 0) { ; length in tiles instead of ms (old)
	global FwdKey, LeftKey, BackKey, RightKey, keyDelay, bitmaps

	loop reps {
		Move(length, FwdKey)
		Move(1.5, %direction%Key)
		Move(length, BackKey)
		Move(1.5, %direction%Key)
	}

	if (tokenlink = 0) ; wait for pattern finish
		KeyWait "F14", "T" length * reps " L"
	else ; wait for token link or pattern finish
	{
		GetRobloxClientPos()
		Sleep 1000 ; primary delay, only accept token links after this
		DllCall("GetSystemTimeAsFileTime", "int64p", &s := 0)
		n := s, f := s + length * reps * 10000000 ; timeout at length * reps
		while ((n < f))
		{
			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth - 400 "|" windowY + windowHeight - 400 "|400|400")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["tokenlink"], , , , , , 50, , 7) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			Sleep 50
			DllCall("GetSystemTimeAsFileTime", "int64p", &n)
		}
	}
}

ActiveHoney() {
	global GameFrozenCounter := 0
	if (hwnd := GetRobloxHWND()) {
		GetRobloxClientPos(hwnd)
		offsetY := GetYOffset(hwnd)
		x1 := windowX + windowWidth // 2 - 90
		y1 := windowY + offsetY
		try
			result := PixelSearch(&bx2, &by2, x1, y1, x1 + 70, y1 + 34, 0xFFE280, 20)
		catch
			result := 0
		if (result = 1) {
			GameFrozenCounter := 0
			return 1
		} else {
			if (HiveBees < 25) {
				x1 := windowX + windowWidth // 2 + 210
				y1 := windowY + offsetY
				try
					result := PixelSearch(&bx2, &by2, x1, y1, x1 + 70, y1 + 34, 0xFFFFFF, 20)
				catch
					result := 0
				return result
			} else {
				return 0
			}
		}
	} else {
		return 0
	}
}

DeathCheck() {
	global youDied
	static LastDeathDetected := 0
	if (((nowUnix() - resetTime) > 20) && ((nowUnix() - LastDeathDetected) > 10)) {
		try
			result := ImageSearch(&FoundX, &FoundY, windowX + windowWidth // 2, windowY + windowHeight // 2, windowX + windowWidth, windowY + windowHeight, "*50 Assets\images\died.png")
		catch
			return
		if (result = 1) {
			youDied := 1
			LastDeathDetected := nowUnix()
		}
	}
}

GotoQuestgiver(giver) {
	SetShiftLock(0)
	success := 0
	Loop 2
	{
		ResetToHive()
		SetStatus("Traveling", "Questgiver: " giver)
		gtq_%giver%()
		Loop 2
		{
			Sleep 500
			searchRet := ImgSearch("e_button.png", 30, "high")
			If (searchRet[1] = 0) {
				success := 1
				SendInput "{" SC_E " down}"
				Sleep 100
				SendInput "{" SC_E " up}"
				Sleep 2000
				hwnd := GetRobloxHWND()
				offsetY := GetYOffset(hwnd)
				Loop 500
				{
					GetRobloxClientPos(hwnd)
					pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 50 "|" windowY + 2 * windowHeight // 3 "|100|" windowHeight // 3)
					if (Gdip_ImageSearch(pBMScreen, bitmaps["dialog"], &pos, , , , , 10, , 3) != 1) {
						Gdip_DisposeImage(pBMScreen)
						break
					}
					Gdip_DisposeImage(pBMScreen)
					MouseMove windowX + windowWidth // 2, windowY + 2 * windowHeight // 3 + SubStr(pos, InStr(pos, ",") + 1) - 15
					Click
					Sleep 150
				}
				MouseMove windowX + 350, windowY + offsetY + 100
			}
		}
		if (success)
			return
	}
}

SearchForE() {
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, bitmaps

	Loop 8
	{
		i := A_Index
		Loop 2
		{
			Send "{' FwdKey ' down}"
			Walk(3 * i)
			Send "{' FwdKey ' up}{' RotRight ' 2}"
		}
	}

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	MouseMove windowX + 350, windowY + offsetY + 100
	success := 0
	DllCall("GetSystemTimeAsFileTime", "int64p", &s := 0)
	n := s, f := s + 90 * 10000000 ; 90 second timeout
	while (n < f && GetKeyState("F14"))
	{
		pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY + 36 "|200|120")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
		{
			success := 1, Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		DllCall("GetSystemTimeAsFileTime", "int64p", &n)
	}

	if (success = 1) ; check that planter was not overrun, at the expense of a small delay
	{
		Loop 10
		{
			if (A_Index = 10)
			{
				success := 0
				break
			}
			Sleep 500
			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY + 36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				break
			}
			else
			{
				Move(1.5, BackKey)
			}
			Gdip_DisposeImage(pBMScreen)
		}
	}
	return success
}

walkFrom(field) {
	SetShiftLock(0)
	SetStatus("Traveling", "Hive")
	wf_%StrReplace(field, " ")%()
}

findHiveSlot() {
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, ZoomIn, ZoomOut, keyDelay, HiveConfirmed, bitmaps

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	MouseMove windowX + 350, windowY + offsetY + 100

	pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY "|400|125")
	if ((Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["collectpollen"], , , , , , 2, , 2) = 1))
		HiveConfirmed := 1, Gdip_DisposeImage(pBMScreen)
	else
	{
		Gdip_DisposeImage(pBMScreen)

		; find hive slot
		DllCall("GetSystemTimeAsFileTime", "int64p", &s := 0)
		n := s, f := s + 150000000
		SendInput "{" LeftKey " down}"
		while (n < f)
		{
			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY "|400|125")
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["collectpollen"], , , , , , 2, , 2) = 1))
			{
				HiveConfirmed := 1, Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			DllCall("GetSystemTimeAsFileTime", "int64p", &n)
		}
		SendInput "{" LeftKey " up}"
	}

	if (HiveConfirmed = 1) ; check that hive slot was not overrun, at the expense of a small delay
	{
		Loop 10
		{
			if (A_Index = 10)
			{
				HiveConfirmed := 0
				break
			}
			Sleep 500
			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY "|400|125")
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["collectpollen"], , , , , , 2, , 2) = 1))
			{
				Gdip_DisposeImage(pBMScreen)
				convert()
				break
			}
			else
			{
				Move(1.5, RightKey)
			}
			Gdip_DisposeImage(pBMScreen)
		}
	}

	return HiveConfirmed
}

convert() {
	global AFBrollingDice, AFBuseGlitter, AFBuseBooster, CurrentField, HiveConfirmed, EnzymesKey, LastEnzymes
		, ConvertStartTime, TotalConvertTime, SessionConvertTime, BackpackPercentFiltered
		, PFieldBoosted, GatherFieldBoosted, GatherFieldBoostedStart, LastGlitter, GlitterKey
		, GameFrozenCounter, LastConvertBalloon, ConvertBalloon, ConvertMins, HiveBees, ConvertDelay, ConvertGatherFlag

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY + 36 "|400|120")
	if ((HiveConfirmed = 0) || (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0)) {
		Gdip_DisposeImage(pBMScreen)
		return
	}
	if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) {
		SendInput "{" SC_E " down}"
		Sleep 100
		SendInput "{" SC_E " up}"
	}
	Gdip_DisposeImage(pBMScreen)
	ConvertStartTime := nowUnix()
	inactiveHoney := 0
	ballooncomplete := 0
	;empty pack
	if (BackpackPercent(1) > 0) {
		SetStatus("Converting", "Backpack")
		while (((BackpackConvertTime := nowUnix() - ConvertStartTime) < 300) && (BackpackPercent(1) > 0)) { ;5 mins
			Sleep 1000
			UseSlots("At Hive")
			if (disconnectcheck()) {
				return
			}
			inactiveHoney := (ActiveHoney() = 0) ? inactiveHoney + 1 : 0
			if (BackpackConvertTime > 60 && inactiveHoney > 30) {
				SetStatus("Interupted", "Inactive Honey")
				GameFrozenCounter++
				return
			}
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY + 36 "|" windowWidth // 2 + 200 "|" windowHeight - offsetY - 36)
			if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , 400, 120, 2, , 2) = 1) {
				SendInput "{" SC_E " down}"
				Sleep 100
				SendInput "{" SC_E " up}"
			}
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , 400, 120, 2, , 6) = 0)
				|| ((Gdip_ImageSearch(pBMScreen, bitmaps["hiveballoon"], , windowWidth // 2, windowHeight - offsetY - 36 - 400, , , 40, , 3) = 1) && (ballooncomplete := 1))) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
		}
		duration := DurationFromSeconds(BackpackConvertTime, "mm:ss")
		SetStatus("Converting", "Backpack Emptied`nTime: " duration)
	}
	;empty balloon
	;(ConvertBalloon = "always") || (ConvertBalloon = "Every" && (nowUnix() - LastConvertBalloon) > (ConvertMins * 60)) || (ConvertBalloon = "Gather" && (ConvertGatherFlag = 1 || (nowUnix() - LastConvertBalloon) > 2700))
	if (true) {
		ConvertGatherFlag := 0
		;balloon check
		strikes := 0
		while ((strikes <= 5) && (A_Index <= 50)) {
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY + 36 "|" windowWidth // 2 + 200 "|" windowHeight - offsetY - 36)
			if ((ballooncomplete = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["hiveballoon"], , windowWidth // 2, windowHeight - offsetY - 36 - 400, , , 40, , 3) = 1)) {
				Gdip_DisposeImage(pBMScreen)
				SetStatus("Converting", "Balloon Refreshed")
				writeSettings("Collect", "LastConvertBalloon", LastConvertBalloon := nowUnix(), "settings\timers.ini")
				;PostSubmacroMessage("background", 0x5554, 6, LastConvertBalloon)
				strikes := 10
				break
			}
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , 400, 120, 2, , 6) != 1)
				strikes++
			Gdip_DisposeImage(pBMScreen)
			Sleep 100
		}
		if (strikes <= 5) {
			BalloonStartTime := nowUnix()
			inactiveHoney := 0
			SetStatus("Converting", "Balloon")
			while ((BalloonConvertTime := nowUnix() - BalloonStartTime) < 600) { ;10 mins
				inactiveHoney := (ActiveHoney() = 0) ? inactiveHoney + 1 : 0
				if (BalloonConvertTime > 60 && inactiveHoney > 30) {
					SetStatus("Interupted", "Inactive Honey")
					GameFrozenCounter++
					return
				}
				if (disconnectcheck()) {
					return
				}
				GetRobloxClientPos(hwnd)
				if (Mod(A_Index, 30) = 0) {
					MouseMove windowX + windowWidth - 30, windowY + offsetY + 16
					click
				}
				pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 - 200 "|" windowY + offsetY + 36 "|" windowWidth // 2 + 200 "|" windowHeight - offsetY - 36)
				if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , 400, 120, 2, , 2) = 1) {
					SendInput "{" SC_E " down}"
					Sleep 100
					SendInput "{" SC_E " up}"
				}
				if ((Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , 400, 120, 2, , 6) = 0)
					|| (Gdip_ImageSearch(pBMScreen, bitmaps["hiveballoon"], , windowWidth // 2, windowHeight - offsetY - 36 - 400, , , 40, , 3) = 1)) {
					Gdip_DisposeImage(pBMScreen)
					ballooncomplete := 1
					break
				}
				Gdip_DisposeImage(pBMScreen)
				Sleep 1000
			}
			if (ballooncomplete) {
				duration := DurationFromSeconds(BalloonConvertTime, "mm:ss")
				SetStatus("Converting", "Balloon Refreshed`nTime: " duration)
				writeSettings("Collect", "LastConvertBalloon", LastConvertBalloon := nowUnix(), "Settings\timers.ini")
				;PostSubmacroMessage("background", 0x5554, 6, LastConvertBalloon)
			}
		}
	}

	;hive wait
	;Sleep 500+((5-Min(HiveBees, 50)/10)**0.5)*10000
	Sleep 500 + (IsNumber(delayAfterConvert) ? delayAfterConvert : 0) * 1000
}

DurationFromSeconds(secs, format := "hh:mm:ss", capacity := 64)
{
	dur := Buffer(capacity), DllCall("GetDurationFormatEx"
		, "Ptr", 0
		, "UInt", 0
		, "Ptr", 0
		, "Int64", secs * 10000000
		, "Str", format
		, "Ptr", dur.Ptr
		, "Int", 32)
	return StrGet(dur)
}
hmsFromSeconds(secs) => DurationFromSeconds(secs, ((secs >= 3600) ? "h'h' m" : "") ((secs >= 60) ? "m'm' s" : "") "s's'")

Feed(food) {
	global bitmaps
	SetShiftLock(0)
	ResetToHive(0, 0, 0, 1)
	SetStatus("Feeding", food)
	;feed
	InventorySearch(food)
	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	Loop 10
	{
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + offsetY + 150 "|" (54 * windowWidth) // 100 - 50 "|" Max(480, windowHeight - offsetY - 150))

		if (A_Index = 1)
		{
			; wait for red vignette effect to disappear
			Loop 40
			{
				if (Gdip_ImageSearch(pBMScreen, bitmaps["item"], , , , 6, , 2) = 1)
					break
				else
				{
					if (A_Index = 40)
					{
						Gdip_DisposeImage(pBMScreen)
						SetStatus("Missing", food)
						return 0
					}
					else
					{
						Sleep 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + offsetY + 150 "|" (54 * windowWidth) // 100 - 50 "|" Max(480, windowHeight - offsetY - 150))
					}
				}
			}
		}

		if ((Gdip_ImageSearch(pBMScreen, bitmaps[food], &pos, , , 306, , 10, , 5) != 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["feed"], , (54 * windowWidth) // 100 - 300, , , , 2, , 2) = 1)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)

		MouseClickDrag "Left", windowX + 30, windowY + SubStr(pos, InStr(pos, ",") + 1) + 190, windowX + windowWidth // 2, windowY + 41 * windowHeight // 100 - 10 * (A_Index - 1), 5
		Sleep 500
	}
	Loop 20 {
		Sleep 100
		pBMScreen := Gdip_BitmapFromScreen(windowX + (54 * windowWidth) // 100 - 300 "|" windowY + offsetY + (46 * windowHeight) // 100 - 59 "|250|100")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["feed"], &pos, , , , , 2, , 2) = 1) {
			Gdip_DisposeImage(pBMScreen)
			MouseMove windowX + (54 * windowWidth) // 100 - 300 + SubStr(pos, 1, InStr(pos, ",") - 1) + 140, windowY + offsetY + (46 * windowHeight) // 100 - 59 + SubStr(pos, InStr(pos, ",") + 1) + 5 ; Number
			Sleep 100
			Click
			Sleep 100
			Send "{Text}100"
			Sleep 1000
			MouseMove windowX + (54 * windowWidth) // 100 - 300 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + offsetY + (46 * windowHeight) // 100 - 59 + SubStr(pos, InStr(pos, ",") + 1) ; Feed
			Sleep 100
			Click
			SetStatus("Completed", "Feed " food)
			break
		} else {
			Gdip_DisposeImage(pBMScreen)
			if (A_Index = 20) {
				MouseMove windowX + (54 * windowWidth) // 100 - 300 + SubStr(pos, 1, InStr(pos, ",") - 1), windowY + offsetY + (46 * windowHeight) // 100 - 59 + SubStr(pos, InStr(pos, ",") + 1) + 64 ; Cancel
				Sleep 100
				Click
				SetStatus("Failed", "Feed " food)
			}
		}
	}
	MouseMove windowX + 350, windowY + offsetY + 100
	;close inventory
	OpenMenu()
}

RotateCameraDown(amount) {
	; direction, left:=1, right:=0,
	; amount can be a decimal, but it has to be a number divisible by 48
	ActivateRoblox()
	hwnd := GetRobloxHWND()
	GetRobloxClientPos(hwnd)
	MouseMove((windowX + windowWidth) / 2, (windowY + windowHeight) / 2)
	MouseGetPos(&xx, &yy)
	Click "Down R"
	sleep 300
	DllCall("user32.dll\mouse_event", "UInt", 0x0001, "Int", 0, "Int", -amount)
	sleep 300
	Click "Up R"
}

CheckIfVicSummoned() {
	ActiveChat()
	ErrorLevel := PixelSearch(&outputX, &outputY, A_ScreenWidth / 2, 0, A_ScreenWidth, A_ScreenHeight - 300, 0xFFCC4D, 3)
	if (ErrorLevel = 1) {
		return true
	} else if (ErrorLevel = 0) {
		return false
	}
}

ActiveChat() {
	x := GetRelativeX(1465, 1467)
	y := GetRelativeY(162, 165)
	MouseMove(x.min, y.min, 1)
	Hypersleep 50
	MouseMove(x.max, y.max, 1)
	HyperSleep 50
}

MoveD(MoveTime, MoveKey1, MoveKey2 := "None") {
	PrevKeyDelay := A_KeyDelay
	SetKeyDelay 5
	Send "{" MoveKey1 " down}"
	if (MoveKey2 != "None")
		Send "{" MoveKey2 " down}"
	DllCall("Sleep", "UInt", MoveTime)
	Send "{" MoveKey1 " up}"
	if (MoveKey2 != "None")
		Send "{" MoveKey2 " up}"
	SetKeyDelay PrevKeyDelay
}

WaitTillLoaded(random := true, private := "", public := "") {
	; This function attempts to wait for Roblox to load the game.
	; It returns 1 on success, 0 on failure after retries.

	; Define a maximum number of retry attempts for joining/loading
	MaxRetries := 5
	CurrentRetry := 0

	Loop {
		CurrentRetry++
		if (CurrentRetry > MaxRetries) {
			setStatus("Error", "Exceeded max join/load retries. Aborting.")
			return 0 ; Indicate failure after too many retries
		}

		setStatus("Info", "Attempt " CurrentRetry " of " MaxRetries ": Joining/Loading Roblox.")

		; --- Step 1: Ensure Roblox is launched and window is present ---
		; This part assumes your main script has already launched Roblox via deeplink
		; or other method. If not, you'd launch it here before the loop.

		; Wait for Roblox window to appear
		RobloxWindowFound := false
		Loop 240 { ; Loop for up to 240 seconds (4 minutes) for the window to appear
			if GetRobloxHWND() {
				ActivateRoblox()
				setStatus("Detected", "Roblox Window Open")
				RobloxWindowFound := true
				break
			}
			Sleep 1000 ; Wait 1 second before checking again
		}

		if (!RobloxWindowFound) {
			setStatus("Error", "Roblox window did not appear within timeout. Retrying...")
			FullyCloseRoblox() ; Ensure a clean slate before retrying
			; The outer loop will handle the retry
			continue
		}

		; --- Step 2: Check for loading errors or successful game load ---
		GameLoaded := false
		RobloxBugDetected := false

		; STAGE 2 - wait for loading screen (or loaded game)
		Loop 180 { ; Loop for up to 180 seconds (3 minutes)
			ActivateRoblox()
			if !GetRobloxClientPos() {
				setStatus("Warning", "Disconnected during Reconnect (GetRobloxClientPos failed)")
				RobloxBugDetected := true
				break
			}

			; Check for immediate join errors/disconnects
			if checkjoindisconnect() or checkjoinerror() or checkrestricted() {
				setStatus("Detected", "Roblox Bug (Join Error/Restricted)")
				RobloxBugDetected := true
				break
			}

			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)

			; Check for game loaded (e.g., Science Bear image)
			if (Gdip_ImageSearch(pBMScreen, bitmaps["science"], , , , , 150, 2) = 1) {
				Gdip_DisposeImage(pBMScreen)
				setStatus("Detected", "Game Loaded")
				GameLoaded := true
				break
			}

			; Check for loading screen (if still present, continue waiting)
			if (Gdip_ImageSearch(pBMScreen, bitmaps["loading"], , , , , 150, 4) = 1) {
				Gdip_DisposeImage(pBMScreen)
				setStatus("Detected", "Game Open (Loading)")
				; Continue waiting in this loop
			} else {
				; If loading screen is gone and science image not found, it might be loaded or something else
				; This implies it might have loaded without the science image being immediately visible
				; or it's stuck. We'll rely on STAGE 3 for final confirmation.
				Gdip_DisposeImage(pBMScreen)
			}

			Gdip_DisposeImage(pBMScreen)
			Sleep 1000 ; Wait for 1 second before next check
		}

		if (GameLoaded) {
			setStatus("Success", "Game is ready!")
			return 1 ; Successfully loaded
		}

		if (RobloxBugDetected) {
			setStatus("Info", "Handling Roblox bug and retrying join...")
			FullyCloseRoblox()
			; Rejoin logic based on original request
			if private != "" {
				JoinSetPrivateServer(private)
			} else if public != "" {
				JoinPublicServerID(public)
			}
			; The outer loop will handle the retry from the beginning
			continue
		}

		; If we reach here, STAGE 2 timed out without loading or a detected bug
		setStatus("Warning", "Game did not load in STAGE 2 timeout. Proceeding to STAGE 3 or retrying...")

		; STAGE 3 - final wait for loaded game (if still in loading screen after STAGE 2 timeout)
		Loop 180 { ; Loop for up to 180 seconds (3 minutes)
			ActivateRoblox()
			if !GetRobloxClientPos() {
				setStatus("Warning", "Disconnected during Reconnect (GetRobloxClientPos failed in STAGE 3)")
				RobloxBugDetected := true
				break
			}

			; Check for immediate join errors/disconnects
			if checkjoindisconnect() or checkjoinerror() or checkrestricted() {
				setStatus("Detected", "Roblox Bug (Join Error/Restricted) in STAGE 3")
				RobloxBugDetected := true
				break
			}

			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)

			; Check if loading screen is gone OR science image is present
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["loading"], , , , , 150, 4) = 0) || (Gdip_ImageSearch(pBMScreen, bitmaps["science"], , , , , 150, 2) = 1)) {
				Gdip_DisposeImage(pBMScreen)
				setStatus("Detected", "Game Loaded (Confirmed in STAGE 3)")
				GameLoaded := true
				break
			}

			Gdip_DisposeImage(pBMScreen)
			Sleep 1000 ; Wait for 1 second before next check
		}

		if (GameLoaded) {
			setStatus("Success", "Game is ready!")
			return 1 ; Successfully loaded
		}

		if (RobloxBugDetected) {
			setStatus("Info", "Handling Roblox bug and retrying join (from STAGE 3)...")
			FullyCloseRoblox()
			; Rejoin logic based on original request
			if privateServerUrl != "" or usePrivateServer = true
				JoinSetPrivateServer(privateServerUrl) ; really basic system, not using fallback.
			else
				JoinNormalServer()
			; The outer loop will handle the retry from the beginning
			continue
		}

		; If we reach here, game did not load within the given timeframes after all stages
		setStatus("Error", "Game Load Timeout after all stages. Retrying...")
		FullyCloseRoblox()
		; Rejoin logic based on original request
		if privateServerUrl != "" or usePrivateServer = true
			JoinSetPrivateServer(privateServerUrl) ; really basic system, not using fallback.
		else
			JoinNormalServer()
		; The outer loop will handle the retry from the beginning
		continue
	}
}


CreateWalk(movement, name := "", vars := "")
{
	global currentWalk, keyDelay, moveSpeed

	DetectHiddenWindows 1

	if WinExist("ahk_pid " currentWalk.pid " ahk_class AutoHotkey")
		EndWalk()

	script :=
		(
			'
	#SingleInstance Off
	#NoTrayIcon
	ProcessSetPriority("AboveNormal")
	KeyHistory 0
	ListLines 0
	OnExit(ExitFunc)

	#Include "%A_ScriptDir%\lib\resources\Gdip_All.ahk"
	#Include "%A_ScriptDir%\lib\resources\Gdip_ImageSearch.ahk"
	#Include "%A_ScriptDir%\lib\resources\Roblox.ahk"
	#Include "%A_ScriptDir%\lib\Walk.ahk" 
	#Include "%A_ScriptDir%\assets\bitmaps.ahk" 

	movespeed := ' moveSpeed '
	both            := (Mod(movespeed*1000, 1265) = 0) || (Mod(Round((movespeed+0.005)*1000), 1265) = 0)
	hasty_guard     := (both || Mod(movespeed*1000, 1100) < 0.00001)
	gifted_hasty    := (both || Mod(movespeed*1000, 1150) < 0.00001)
	base_movespeed  := round(movespeed / (both ? 1.265 : (hasty_guard ? 1.1 : (gifted_hasty ? 1.15 : 1))), 0)
	offsetY := GetYOffset()

	' KeyVars() '
	' vars '

	start()
	return

	HyperSleep(ms)
	{
		static freq := (DllCall("QueryPerformanceFrequency", "Int64*", &f := 0), f)
		DllCall("QueryPerformanceCounter", "Int64*", &begin := 0)
		current := 0, finish := begin + ms * freq / 1000
		while (current < finish)
		{
			if ((finish - current) > 30000)
			{
				DllCall("Winmm.dll\timeBeginPeriod", "UInt", 1)
				DllCall("Sleep", "UInt", 1)
				DllCall("Winmm.dll\timeEndPeriod", "UInt", 1)
			}
			DllCall("QueryPerformanceCounter", "Int64*", &current)
		}
	}

	BSSWalk(tiles, MoveKey1, MoveKey2:=0)
	{
		Send "{" MoveKey1 " down}" (MoveKey2 ? "{" MoveKey2 " down}" : "")
		Walk(tiles)
		Send "{" MoveKey1 " up}" (MoveKey2 ? "{" MoveKey2 " up}" : "")
	}

	F13::
		start(hk?)
		{
			Send "{F14 down}"
			' movement '
			Send "{F14 up}"
		}

	F16::
	{
		static key_states := Map(LeftKey,0, RightKey,0, FwdKey,0, BackKey,0, "LButton",0, "RButton",0, SC_E,0)
		if A_IsPaused
		{
			for k,v in key_states
				if (v = 1)
					Send "{" k " down}"
		}
		else
		{
			for k,v in key_states
			{
				key_states[k] := GetKeyState(k)
				Send "{" k " up}"
			}
		}
		Pause -1
	}

	ExitFunc(*)
	{
		Send "{LeftKey up}{RightKey up}{FwdKey up}{BackKey up}{SC_Space up}{F14 up}{SC_E up}"
		try Gdip_Shutdown(pToken)
	}
	'
		)

	shell := ComObject("WScript.Shell")
	exec := shell.Exec('"' A_AhkPath '" /script /force *')
	exec.StdIn.Write(script), exec.StdIn.Close()

	if WinWait("ahk_class AutoHotkey ahk_pid " exec.ProcessID, , 2) {
		DetectHiddenWindows 0
		currentWalk.pid := exec.ProcessID, currentWalk.name := name
		return 1
	}
	else {
		DetectHiddenWindows 0
		return 0
	}
}

EndWalk()
{
	global currentWalk
	DetectHiddenWindows 1
	try WinClose "ahk_class AutoHotkey ahk_pid " currentWalk.pid
	DetectHiddenWindows 0
	currentWalk.pid := currentWalk.name := ""
}

KeyVars() {
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, RotUp, RotDown, ZoomIn, ZoomOut, SC_E, SC_R, SC_L, SC_Esc, SC_Enter, SC_LShift, SC_Space, SC_1, TCFBKey, AFCFBKey, TCLRKey, AFCLRKey
	return
	(
		'
	FwdKey:="' FwdKey '"
	LeftKey:="' LeftKey '"
	BackKey:="' BackKey '"
	RightKey:="' RightKey '"
	RotLeft:="' RotLeft '"
	RotRight:="' RotRight '"
	RotUp:="' RotUp '"
	RotDown:="' RotDown '"
	ZoomIn:="' ZoomIn '"
	ZoomOut:="' ZoomOut '"
	SC_E:="' SC_E '"
	SC_R:="' SC_R '"
	SC_L:="' SC_L '"
	SC_Esc:="' SC_Esc '"
	SC_Enter:="' SC_Enter '"
	SC_LShift:="' SC_LShift '"
	SC_Space:="' SC_Space '"
	SC_1:="' SC_1 '"
	TCFBKey:="' TCFBKey '"
	AFCFBKey:="' AFCFBKey '"
	TCLRKey:="' TCLRKey '"
	AFCLRKey:="' AFCLRKey '"
	'
	)
}

PathVars() {
	global HiveSlot, MoveMethod, HiveBees, keyDelay
	return
	(
		'
	HiveSlot:=' HiveSlot '
	MoveMethod:="' MoveMethod '"
	HiveBees:=' HiveBees '
	KeyDelay:=' keyDelay '
    '
	)
}

CreatePath(path) => CreateWalk(path, , PathVars())

BSSWalk(tiles, MoveKey1, MoveKey2 := 0) {
	return
	(
		'Send "{' MoveKey1 ' down}' (MoveKey2 ? '{' MoveKey2 ' down}"' : '"') '
	Walk(' tiles ')
	Send "{' MoveKey1 ' up}' (MoveKey2 ? '{' MoveKey2 ' up}"' : '"')
	)
}