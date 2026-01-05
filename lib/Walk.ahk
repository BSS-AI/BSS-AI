pToken := Gdip_Startup()

buff_characters := Map()
buff_characters[0] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAgAAAAKCAAAAACsrEBcAAAAAnRSTlMAAHaTzTgAAAArSURBVHgBY2Rg+MzAwMALxCAaQoDBZyYYmwlMYmXAAFApWPVnBkYIi5cBAJNvCLCTFAy9AAAAAElFTkSuQmCC")
buff_characters[1] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAIAAAAMCAAAAABt1zOIAAAAAnRSTlMAAHaTzTgAAAACYktHRAD/h4/MvwAAABZJREFUeAFjYPjM+JmBgeEzEwMDLgQAWo0C7U3u8hAAAAAASUVORK5CYII=")
buff_characters[2] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAALCAAAAAB9zHN3AAAAAnRSTlMAAHaTzTgAAABCSURBVHgBATcAyP8BAPMAAADzAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPMAAADzAAAA8wAAAPMAAAAB8wAAAAIAAAAAtc8GqohTl5oAAAAASUVORK5CYII=")
buff_characters[3] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAKCAAAAAC2kKDSAAAAAnRSTlMAAHaTzTgAAAA9SURBVHgBATIAzf8BAPMAAAAAAAAAAAAAAAAAAAAAAAAAAADzAAAAAAAAAAAAAAAAAAAAAPMAAAABAPMAAFILA8/B68+8AAAAAElFTkSuQmCC")
buff_characters[4] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAGCAAAAADBUmCpAAAAAnRSTlMAAHaTzTgAAAApSURBVHgBAR4A4f8AAAAA8wAAAAAAAAAA8wAAAPMAAALzAAAAAfMAAABBtgTDARckPAAAAABJRU5ErkJggg==")
buff_characters[5] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAALCAAAAAB9zHN3AAAAAnRSTlMAAHaTzTgAAABCSURBVHgBATcAyP8B8wAAAAIAAAAAAPMAAAACAAAAAAHzAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHzAAAAgmID1KbRt+YAAAAASUVORK5CYII=")
buff_characters[6] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAJCAAAAAAwBNJ8AAAAAnRSTlMAAHaTzTgAAAA4SURBVHgBAS0A0v8AAAAA8wAAAPMAAADzAAACAAAAAAEA8wAAAPPzAAAA8wAAAAAA8wAAAQAA8wC5oAiQ09KYngAAAABJRU5ErkJggg==")
buff_characters[7] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAMCAAAAABgyUPPAAAAAnRSTlMAAHaTzTgAAABHSURBVHgBATwAw/8B8wAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8wIAAAAAAgAAAABDdgHu70cIeQAAAABJRU5ErkJggg==")
buff_characters[8] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAKCAAAAAC2kKDSAAAAAnRSTlMAAHaTzTgAAAA9SURBVHgBATIAzf8BAADzAAAA8wAAAgAAAAABAPMAAAEAAPMAAADzAAAAAAAAAADzAAAAAADzAAABAADzALv5B59oKTe0AAAAAElFTkSuQmCC")
buff_characters[9] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAKCAAAAAC2kKDSAAAAAnRSTlMAAHaTzTgAAAA9SURBVHgBATIAzf8BAADzAAAA8wAAAPMAAAAAAPMAAAEAAPMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA87TcBbXcfy3eAAAAAElFTkSuQmCC")

try  {
	WinGetClientPos(&windowX, &windowY, &windowWidth, &windowHeight, "ahk_exe RobloxPlayerBeta.exe")
} catch {
	
}

Walk(n, hasteCap:=0)
{
    global both            := (Mod(moveSpeed*1000, 1265) = 0) || (Mod(Round((moveSpeed+0.005)*1000), 1265) = 0)
    global hasty_guard     := (both || Mod(moveSpeed*1000, 1100) < 0.00001)
    global gifted_hasty    := (both || Mod(moveSpeed*1000, 1150) < 0.00001)
    global base_movespeed  := round(moveSpeed / (both ? 1.265 : (hasty_guard ? 1.1 : (gifted_hasty ? 1.15 : 1))), 0)
	;hasteCap values > 0 will cause all haste values lower than it to be treated as no haste but haste values above it will be treated as the cap value.
	;In otherwords, no haste compensation up to the cap and then 100% compensation after that.
	static freq := 0, init := DllCall("QueryPerformanceFrequency", "Int64*", &freq) ; obtain frequency on first execution
	
	d := freq // 8, l := n * freq * 4 ; 4 studs in a tile
	
	d += (v := DetectMovespeed(&s, &f, hasteCap)) * (f - s)
	while (d < l)
		d += ((v + 0) + (v := DetectMovespeed(&s, &f, hasteCap)))/2 * (f - s)
}

DetectMovespeed(&s, &f, hasteCap:=0)
{
	DllCall("QueryPerformanceCounter", "Int64*", &s := 0)
	global hasty_guard, gifted_hasty, base_movespeed, buff_characters, bitmaps, offsetY, windowWidth, pGraphics

	; check roblox window exists
	GetRobloxClientPos()
	if (windowWidth = 0)
		return (DllCall("QueryPerformanceCounter", "Int64*", &f := 0), 10000000) ; large number to break walk loop
	
	; get screen bitmap of buff area from client window
	chdc := CreateCompatibleDC(), hbm := CreateDIBSection(windowWidth, 30, chdc), obm := SelectObject(chdc, hbm), hhdc := GetDC()
	BitBlt(chdc, 0, 0, windowWidth, 30, hhdc, windowX, windowY+offsetY+48)
	ReleaseDC(hhdc)
	pBMArea := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(chdc, obm), DeleteObject(hbm), DeleteDC(hhdc), DeleteDC(chdc)
	
	; find haste buffs (haste, coconut haste)
	x := 0
	haste := 0 ; initially haste is number of hastes found (since haste = coconut haste icon)
	Loop 3 ; melody, haste, coconut haste
	{
		if (Gdip_ImageSearch(pBMArea, bitmaps["pBMHaste"], &list, x, 14, , , , , 6) != 1)
			break ; no possibility of haste
		
		x := SubStr(list, 1, InStr(list, ",")-1), y := SubStr(list, InStr(list, ",")+1)
		
		if (Gdip_ImageSearch(pBMArea, bitmaps["pBMMelody"], , x+2, , x+Max(16, 2*y-24), y, 12) = 0)
		{
			haste++ ; not melody, so haste
			if (haste = 1)
				x1 := x, y1 := y ; normal haste is always leftmost image
		}
		
		x += 2*y-14 ; skip this buff on next search
	}
	
	; analyse haste stacks (haste: 0=none, 1=haste, 2=haste+coconut)
	coconut_haste := (haste = 2) ? 1 : 0
	if haste
	{
		Loop 9 ; look for each digit
		{
			if (Gdip_ImageSearch(pBMArea, buff_characters[10-A_Index], , x1+2*y1-44, Max(0, y1-18), x1+2*y1-14, y1-1) = 1)
			{
				haste := (A_Index = 9) ? 10 : 10 - A_Index ; haste now becomes stack number
				break
			}
			if (A_Index = 9)
				haste := 1 ; no multiplier, therefore 1x
		}
	}
	
	; find other movespeed affecting buffs (haste+, bear, oil, super smoothie)
	haste_plus := (Gdip_ImageSearch(pBMArea, bitmaps["pBMHastePlus"], , , 25, , 27, , , 2) = 1) ; SearchDirection 2 is faster for on/off
	oil := (Gdip_ImageSearch(pBMArea, bitmaps["pBMOil"], , , 25, , 27, 4, , 2) = 1)
	smoothie := (Gdip_ImageSearch(pBMArea, bitmaps["pBMSmoothie"], , , 25, , 27, 4, , 2) = 1)
	bear := 0
	for v in ["Brown","Black","Panda","Polar","Gummy","Science","Mother"]
	{
		if (Gdip_ImageSearch(pBMArea, bitmaps["pBMBear" v], , , 25, , 27, 8, , 2) = 1)
		{
			bear := 1
			break
		}
	}
	Gdip_DisposeImage(pBMArea)
	
	; use movespeed formula on obtained values
	v := ((base_movespeed + (coconut_haste ? 10 : 0) + (bear ? 4 : 0)) * (hasty_guard ? 1.1 : 1) * (gifted_hasty ? 1.15 : 1) * (1 + max(0, haste-hasteCap)*0.1) * (haste_plus ? 2 : 1) * (oil ? 1.2 : 1) * (smoothie ? 1.25 : 1))
	return (DllCall("QueryPerformanceCounter", "Int64*", &f := 0), v)
}

s := 0.0
f := 0.0

HasteMove(distance1, distance2, key1, key2) {
	; distance1 refers to the distance using both keys
	; distance2 refers to the distance using key1 only (let go of key2 after distance1)

	send "{" key1 " down}"
	

	if (distance1 != 0) {
		; There will be a diagonal, so there is a minor direction.
		send "{" key2 " down}"
		Walk(distance1)
		send "{" key2 " up}"
	}

	if (distance2 != 0) {
		; There will be a horizontal movement, there is a major movement
		Walk(distance2)
	}

	send "{" key1 " up}"
}

DrawRectangle(x1, y1, x2, y2, color := "Red") {
    static Overlay := Gui("+AlwaysOnTop -Caption +ToolWindow")
    Overlay.Destroy()
    Overlay := Gui("+AlwaysOnTop -Caption +ToolWindow")
    Overlay.Color := color
    Overlay.Border := true
    Overlay.Show("x" x1 " y" y1 " w" (x2 - x1) " h" (y2 - y1))
}
