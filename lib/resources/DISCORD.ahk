global discordCheck := (readSettings("Settings", "usebot") || readSettings("Settings", "usewebhook")) ? 1 : 0
global discordMode := (readSettings("Settings", "usebot") ? 1 : 0)
global bottoken := readSettings("Settings", "bottoken")
global webhook := readSettings("Settings", "webhookurl")
global MainChannelID := readSettings("Settings", "channelid")
global WebhookEasterEgg := readSettings("Settings", "easteregg")
global commandPrefix := readSettings("Settings", "commandprefix")
global status_buffer := [], command_buffer := []

; 1. THE SCHEDULER: Schedules a network check every 5 seconds. This is a safe and reasonable interval.
SetTimer(ScheduleCommandFetch, 2000)

; 2. THE PROCESSOR: Checks for commands to run very frequently. This is a lightweight, non-blocking check.
SetTimer(ProcessCommandBuffer, 250) ; Runs 4 times per second

ScheduleCommandFetch()
{
    ; This function's only job is to launch the worker on its own thread.
    ; The negative value means it runs once, as soon as possible, without disrupting other timers.
    SetTimer(FetchCommandsWorker, -1)
}

FetchCommandsWorker()
{
    ; This is the "worker" function. It runs on a separate thread.
    ; The blocking network call inside discord.GetCommands() happens here.
    ; Because it's on its own thread, it WILL NOT freeze your main macro's movement or actions.
    ; It adds any found commands to the global 'command_buffer'.
    discord.GetCommands(MainChannelID)
}

ProcessCommandBuffer()
{
    ; This function is very fast. It just checks if the command buffer has items.
    ; If the FetchCommandsWorker added commands, this will execute the oldest one.
    if (command_buffer.Length > 0)
    {
        ; The command() function is responsible for processing and removing the item from the buffer.
        command(command_buffer[1])
    }
}

discord.SendEmbed("Connected to discord!", 5066239)

status(status)
{
	stateString := SubStr(status, InStr(status, "] ") + 2)
	state := SubStr(stateString, 1, InStr(stateString, ": ") - 1), objective := SubStr(stateString, InStr(stateString, ": ") + 2)

	; send to discord
	if (discordCheck = 1)
	{
		; set colour based on state string
		static colorIndex := 0, colors := [16711680, 16744192, 16776960, 65280, 255, 4915330, 9699539]
		if (WebhookEasterEgg = 1)
			color := colors[colorIndex := Mod(colorIndex, 7) + 1]
		else
		{
			color := ((state = "Disconnected") || (state = "You Died") || (state = "Failed") || (state = "Error") || (state = "Aborting") || (state = "Missing") || (state = "Canceling") || InStr(objective, "Phantom") || InStr(objective, "No Balloon Convert")) ? 15085139 ; red - error
				: (InStr(objective, "Tunnel Bear") || InStr(objective, "King Beetle") || InStr(objective, "Vicious Bee") || InStr(objective, "Snail") || InStr(objective, "Crab") || InStr(objective, "Mondo") || InStr(objective, "Commando")) ? 7036559 ; purple - boss / attacking
				: ((state = "Vichop") && (InStr(objective, "Killed") || InStr(objective, "Session:"))) ? 48128 ; green - vichop success
				: ((state = "Vichop") && (InStr(objective, "Vicious bee found") || InStr(objective, "Night detected"))) ? 7036559 ; purple - vichop action
				: (InStr(objective, "Planter") || (state = "Placing") || (state = "Collecting") || (state = "Holding")) ? 48355 ; blue - planters
				: ((state = "Interupted") || (state = "Reporting") || (state = "Warning")) ? 14408468 ; yellow - alert
				: ((state = "Gathering")) ? 9755247 ; light green - gathering
				: ((state = "Converting")) ? 8871681 ; yellow-brown - converting
				: ((state = "Boosted") || (state = "Looting") || (state = "Keeping") || (state = "Claimed") || (state = "Completed") || (state = "Collected") || (state = "Obtained") || InStr(stateString, "confirmed") || InStr(stateString, "found")) ? 48128 ; green - success
				: ((state = "Starting")) ? 16366336 ; orange - quests
				: ((state = "Startup") || (state = "GUI") || (state = "Detected") || (state = "Closing") || (state = "Begin") || (state = "End")) ? 15658739 ; white - startup / utility
				: 3223350
		}

		message := StrReplace(StrReplace(StrReplace(StrReplace(SubStr(status, InStr(status, "]") + 1), "\", "\\"), "`n", "\n"), Chr(9), "  "), "`r")

		; screenshot
		if ((true)
			&& ((state = "Collected"))
			|| (stateString = "Converting: Balloon")
			|| (state = "You Died")
			|| ((state = "Error") || (state = "Aborting") || (state = "Missing") || (state = "Timeout") || (state = "Failed"))
			|| ((((state = "Placing") || (state = "Planted") || (state = "Detected")) && InStr(stateString, "Planter"))))
		{
			if !IsSet(pBM)
				hwnd := GetRobloxHWND(), GetRobloxClientPos(hwnd), pBM := Gdip_BitmapFromScreen((windowWidth > 0) ? (windowX "|" windowY "|" windowWidth "|" windowHeight) : 0)
		}

		discord.SendEmbed(message, color, ,pBM?, channel?), IsSet(pBM) && pBM > 0 && Gdip_DisposeImage(pBM)
	}
}

command(command)
{
	global commandPrefix, MacroState, planters
	static ssmode := "All"
		, defaultPriorityList := ["Night", "Mondo", "Planter", "Bugrun", "Collect", "QuestRotate", "Boost", "GoGather"]

	id := command.id, params := []
	Loop Parse SubStr(command.content, StrLen(commandPrefix) + 1), A_Space
		if (A_LoopField != "")
			params.Push(A_LoopField)
	params.Length := 10, params.Default := ""

	switch (name := params[1]), 0
	{
		case "ss", "screenshot":
			switch params[2], 0
			{
				case "mode":
					if ((params[3] = "all") || (params[3] = "window") || (params[3] = "screen"))
					{
						ssmode := RegExReplace(params[3], "(?:^|\.|\R)[- 0-9\*\(]*\K(.)([^\.\r\n]*)", "$U1$L2")
						discord.SendEmbed("Set screenshot mode to " ssmode "!", 5066239, , , , id)
					}
					else
						discord.SendEmbed("Invalid ``Mode``!\nMust be either ``All``, ``Window``, or ``Screen``", 16711731, , , , id)

				default:
					switch ssmode, 0
					{
						case "all":
							pBM := Gdip_BitmapFromScreen()

						case "window":
							WinGetClientPos &x, &y, &w, &h, "A"
							pBM := Gdip_BitmapFromScreen((w > 0) ? (x "|" y "|" w "|" h) : 0)

						case "screen":
							pBM := Gdip_BitmapFromScreen(1)

						default:
							discord.SendEmbed("Error: Invalid screenshot mode!", 16711731, , , , id)
							pBM := Gdip_BitmapFromScreen()
					}
					discord.SendImage(pBM, "ss.png", id)
					Gdip_DisposeImage(pBM)
			}


		case "stop", "reload":
			discord.SendEmbed("Stopping Macro...", 5066239, , , , id)
			Stop(1)


		case "pause", "unpause":
			if (MacroState = 0)
				discord.SendEmbed("Macro is not running!", 16711731, , , , id)
			else
			{
				discord.SendEmbed(((MacroState = 2) ? "Pausing" : "Unpausing") " Macro...", 5066239, , , , id)
				PauseUnpause()
			}


		case "start":
			if (MacroState = 0)
			{
				discord.SendEmbed("Starting Macro...", 5066239, , , , id)
				Start()
			}
			else
				discord.SendEmbed("Macro has already been started!", 16711731, , , , id)


		case "close":
			DetectHiddenWindows 0
			if (hwnd := WinExist(window := Trim(SubStr(command.content, InStr(command.content, name) + StrLen(name)))))
			{
				windowPid := WinGetPID()
				DetectHiddenWindows 1
				if WinExist("ahk_exe macrocore.exe")
					natroPID := WinGetPID()
				DetectHiddenWindows 0
				if (windowPID = natroPID)
					discord.SendEmbed("Cannot close BSS AI window!", 16711731, , , , id)
				else
				{
					title := WinGetTitle("ahk_id " hwnd)
					Loop 3
						if WinExist("ahk_id" hwnd)
							WinKill
					discord.SendEmbed('Closed Window: ``' StrReplace(StrReplace(title, "\", "\\"), '"', '\"') '``', 5066239, , , , id)
				}
			}
			else
				discord.SendEmbed('Window ``' StrReplace(StrReplace(window, "\", "\\"), '"', '\"') '`` not found!', 16711731, , , , id)


		case "activate":
			DetectHiddenWindows 0
			if (hwnd := WinExist(window := Trim(SubStr(command.content, InStr(command.content, name) + StrLen(name)))))
			{
				title := WinGetTitle("ahk_id " hwnd)
				try
				{
					WinActivate "ahk_id " hwnd
					discord.SendEmbed('Activated Window: ``' StrReplace(StrReplace(title, "\", "\\"), '"', '\"') '``', 5066239, , , , id)
				}
				catch as e
					discord.SendEmbed("Error:\n" e.Message " " e.What, 16711731, , , , id)
			}
			else
				discord.SendEmbed('Window ``' StrReplace(StrReplace(window, "\", "\\"), '"', '\"') '`` not found!', 16711731, , , , id)


		case "minimise", "minimize":
			DetectHiddenWindows 0
			if (hwnd := WinExist(window := Trim(SubStr(command.content, InStr(command.content, name) + StrLen(name)))))
			{
				title := WinGetTitle("ahk_id " hwnd)
				try
				{
					WinMinimize "ahk_id " hwnd
					discord.SendEmbed('Minimized Window: ``' StrReplace(StrReplace(title, "\", "\\"), '"', '\"') '``', 5066239, , , , id)
				}
				catch as e
					discord.SendEmbed("Error:\n" e.Message " " e.What, 16711731, , , , id)
			}
			else
				discord.SendEmbed('Window ``' StrReplace(StrReplace(window, "\", "\\"), '"', '\"') '`` not found!', 16711731, , , , id)

		case "keep":
			try
				result := AmuletPrompt(1)
			catch Error as e
				result := e.Message
			switch result
			{
				case 2:
					discord.SendEmbed("No Roblox window found!", 16711731, , , , id)

				case 1:
					discord.SendEmbed("Kept Old Amulet", 5066239, , , , id)

				case 0:
					discord.SendEmbed("No Keep/Replace prompt found!", 16711731, , , , id)

				default:
					discord.SendEmbed("Error: " result "\nPlease report this to the BSS AI devs", 16711731, , , , id)
			}


		case "replace":
			try
				result := AmuletPrompt(2)
			catch
				result := -1
			switch result
			{
				case 2:
					discord.SendEmbed("No Roblox window found!", 16711731, , , , id)

				case 1:
					discord.SendEmbed("Replaced Amulet!", 5066239, , , , id)

				case 0:
					discord.SendEmbed("No Keep/Replace prompt found!", 16711731, , , , id)

				default:
					discord.SendEmbed("Error: SendMessage Timeout!", 16711731, , , , id)
			}


		case "planter", "planters":
			switch params[2], 0
			{
				case "clear":
					if ((params[3] = 1) || (params[3] = 2) || (params[3] = 3))
					{
						n := params[3]
						writeSettings("Planters", "PlanterName" n, "None", "settings\timers.ini", false)
						writeSettings("Planters", "PlanterField" n, "None", "settings\timers.ini", false)
						writeSettings("Planters", "PlanterNectar" n, "None", "settings\timers.ini", false)
						writeSettings("Planters", "PlanterHarvestNow" n, "", "settings\timers.ini", false)
						writeSettings("Planters", "PlanterHarvestTime" n, 0, "settings\timers.ini", false)
						writeSettings("Planters", "PlanterEstPercent" n, 0, "settings\timers.ini")
						discord.SendEmbed("Cleared planter in Slot " n "!", 5066239, , , , id)
					}
					else
						discord.SendEmbed((StrLen(params[3]) = 0) ? "You must specify a Planter Slot to clear!" : ("Planter Slot must be 1, 2, or 3!\nYou entered " params[3] "."), 16711731, , , , id)
			}

		case "prefix":
			if ((newPrefix := SubStr(params[2], 1, 3)) && (StrLen(newPrefix) > 0))
			{
				commandPrefix := newPrefix
				writeSettings("Settings", "commandprefix", commandPrefix)
				discord.SendEmbed("Set ``" newPrefix "`` as your command prefix!" ((StrLen(params[2]) > 3) ? "\nThe maximum prefix length is 3." : ""), 5066239, , , , id)
			}
			else
				discord.SendEmbed("``" ((StrLen(params[2]) > 0) ? params[2] : "<blank>") "`` is not a valid prefix!" ((StrLen(params[2]) = 0) ? "\nYou cannot have an empty prefix!" : ""), 16711731, , , , id)


		default:
			discord.SendEmbed("``" commandPrefix name "`` is not a valid command!\nMore commands coming next update!", 16711731, , , , id)
	}

	command_buffer.RemoveAt(1)
}

class discord
{
	static baseURL := "https://discord.com/api/v10/"

	static SendEmbed(message, color := 3223350, content := "", pBitmap := 0, channel := "", replyID := 0)
	{
		payload_json :=
		(
		'
		{
			"content": "' content '",
			"embeds": [{
				"description": "' message '",
				"color": "' color '"
				' (pBitmap ? (',"image": {"url": "attachment://ss.png"}') : '') '
			}]
			' (replyID ? (',"allowed_mentions": {"parse": []}, "message_reference": {"message_id": "' replyID '", "fail_if_not_exists": false}') : '') '
		}
		'
		)

		if pBitmap
			this.CreateFormData(&postdata, &contentType, [Map("name", "payload_json", "content-type", "application/json", "content", payload_json), Map("name", "files[0]", "filename", "ss.png", "content-type", "image/png", "pBitmap", pBitmap)])
		else
			postdata := payload_json, contentType := "application/json"

		return this.SendMessageAPI(postdata, contentType, channel)
	}

	static SendImage(pBitmap, imgname := "image.png", replyID := 0)
	{
		params := []
		(replyID > 0) && params.Push(Map("name", "payload_json", "content-type", "application/json", "content", '{"allowed_mentions": {"parse": []}, "message_reference": {"message_id": "' replyID '", "fail_if_not_exists": false}}'))
		params.Push(Map("name", "files[0]", "filename", imgname, "content-type", "image/png", "pBitmap", pBitmap))
		this.CreateFormData(&postdata, &contentType, params)
		this.SendMessageAPI(postdata, contentType)
	}

	static SendMessageAPI(postdata, contentType := "application/json", channel := "", url := "")
	{
		global webhook, bottoken, discordMode, MainChannelCheck, MainChannelID

		channel := MainChannelID

		if !url
			url := (discordMode = 0) ? (webhook "?wait=true") : (this.BaseURL "/channels/" channel "/messages")

		try
		{
			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Option[9] := 2720
			wr.Open("POST", url, 1)
			if (discordMode = 1)
			{
				wr.SetRequestHeader("User-Agent", "DiscordBot (AHK, " A_AhkVersion ")")
				wr.SetRequestHeader("Authorization", "Bot " bottoken)
			}
			wr.SetRequestHeader("Content-Type", contentType)
			wr.SetTimeouts(0, 60000, 120000, 30000)
			wr.Send(postdata)
			wr.WaitForResponse()
			return wr.ResponseText
		}
	}

	static GetCommands(channel)
	{
		global discordMode, commandPrefix

		if (discordMode = 0)
			return -1

		Loop (n := (messages := this.GetRecentMessages(channel)).Length)
		{
			i := n - A_Index + 1
			(SubStr(content := Trim(messages[i]["content"]), 1, StrLen(commandPrefix)) = commandPrefix) && command_buffer.Push({ content: content, id: messages[i]["id"], url: messages[i]["attachments"].Has(1) ? messages[i]["attachments"][1]["url"] : "" })
		}
	}

	static GetRecentMessages(channel)
	{
		global discordMode
		static lastmsg := Map()

		if (discordMode = 0)
			return -1

		try
			(messages := JSON.parse(text := this.GetMessageAPI(lastmsg.Has(channel) ? ("?after=" lastmsg[channel]) : "?limit=1", channel))).Length
		catch
			return []

		if (messages.Has(1))
			lastmsg[channel] := messages[1]["id"]

		return messages
	}

	static GetMessageAPI(params := "", channel := "")
	{
		global bottoken, discordMode, MainChannelID

		if (discordMode = 0)
			return -1

		if !channel
		{
			channel := MainChannelID
		}

		try
		{
			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Option[9] := 2720
			wr.Open("GET", this.BaseURL "/channels/" channel "/messages" params, 1)
			wr.SetRequestHeader("User-Agent", "DiscordBot (AHK, " A_AhkVersion ")")
			wr.SetRequestHeader("Authorization", "Bot " bottoken)
			wr.SetRequestHeader("Content-Type", "application/json")
			wr.Send()
			wr.WaitForResponse()
			return wr.ResponseText
		}
	}

	static EditMessageAPI(id, postdata, contentType := "application/json", channel := "")
	{
		if (!channel && (discordMode = 1))
		{
			channel := MainChannelID
		}

		url := (discordMode = 0) ? (webhook "/messages/" id) : (this.BaseURL "/channels/" channel "/messages/" id)

		try
		{
			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Option[9] := 2720
			wr.Open("PATCH", url, 1)
			if (discordMode = 1)
			{
				wr.SetRequestHeader("User-Agent", "DiscordBot (AHK, " A_AhkVersion ")")
				wr.SetRequestHeader("Authorization", "Bot " bottoken)
			}
			wr.SetRequestHeader("Content-Type", contentType)
			wr.SetTimeouts(0, 60000, 120000, 30000)
			wr.Send(postdata)
			wr.WaitForResponse()
			return wr.ResponseText
		}
	}

	static CreateFormData(&retData, &contentType, fields)
	{
		static chars := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"

		chars := Sort(chars, "D| Random")
		boundary := SubStr(StrReplace(chars, "|"), 1, 12)
		hData := DllCall("GlobalAlloc", "UInt", 0x2, "UPtr", 0, "Ptr")
		DllCall("ole32\CreateStreamOnHGlobal", "Ptr", hData, "Int", 0, "PtrP", &pStream := 0, "UInt")

		for field in fields
		{
			str :=
			(
			'

			------------------------------' boundary '
			Content-Disposition: form-data; name="' field["name"] '"' (field.Has("filename") ? ('; filename="' field["filename"] '"') : "") '
			Content-Type: ' field["content-type"] '

			' (field.Has("content") ? (field["content"] "`r`n") : "")
			)

			utf8 := Buffer(length := StrPut(str, "UTF-8") - 1), StrPut(str, utf8, length, "UTF-8")
			DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8.Ptr, "UInt", length, "UInt")

			if field.Has("pBitmap")
			{
				try
				{
					pFileStream := Gdip_SaveBitmapToStream(field["pBitmap"])
					DllCall("shlwapi\IStream_Size", "Ptr", pFileStream, "UInt64P", &size := 0, "UInt")
					DllCall("shlwapi\IStream_Reset", "Ptr", pFileStream, "UInt")
					DllCall("shlwapi\IStream_Copy", "Ptr", pFileStream, "Ptr", pStream, "UInt", size, "UInt")
					ObjRelease(pFileStream)
				}
			}

			if field.Has("file")
			{
				DllCall("shlwapi\SHCreateStreamOnFileEx", "WStr", field["file"], "Int", 0, "UInt", 0x80, "Int", 0, "Ptr", 0, "PtrP", &pFileStream := 0)
				DllCall("shlwapi\IStream_Size", "Ptr", pFileStream, "UInt64P", &size := 0, "UInt")
				DllCall("shlwapi\IStream_Copy", "Ptr", pFileStream, "Ptr", pStream, "UInt", size, "UInt")
				ObjRelease(pFileStream)
			}
		}

		str :=
		(
		'

		------------------------------' boundary '--
		'
		)

		utf8 := Buffer(length := StrPut(str, "UTF-8") - 1), StrPut(str, utf8, length, "UTF-8")
		DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8.Ptr, "UInt", length, "UInt")
		ObjRelease(pStream)

		pData := DllCall("GlobalLock", "Ptr", hData, "Ptr")
		size := DllCall("GlobalSize", "Ptr", pData, "UPtr")

		retData := ComObjArray(0x11, size)
		pvData := NumGet(ComObjValue(retData), 8 + A_PtrSize, "Ptr")
		DllCall("RtlMoveMemory", "Ptr", pvData, "Ptr", pData, "Ptr", size)

		DllCall("GlobalUnlock", "Ptr", hData)
		DllCall("GlobalFree", "Ptr", hData, "Ptr")
		contentType := "multipart/form-data; boundary=----------------------------" boundary
	}
}