;@Ahk2Exe-SetMainIcon DownloadHelper.ico
;@Ahk2Exe-SetCopyright Nick768/Nico3110
;@Ahk2Exe-SetDescription Batch Downloadhelper mit Curl
;@Ahk2Exe-SetFileVersion 1.0
;@Ahk2Exe-SetInternalName DownloadHelper
;@Ahk2Exe-SetLanguage 0x0407
;@Ahk2Exe-SetName DownloadHelper
;@Ahk2Exe-SetOrigFileName DownloadHelper.exe
;@Ahk2Exe-SetProductName DownloadHelper
;@Ahk2Exe-SetProductVersion 1.0
;@Ahk2Exe-SetVersion 1.0

/*@Ahk2Exe-Keep
#NoTrayIcon
if !DirExist("bin")
	DirCreate("bin")
if !FileExist("bin\curl.exe")
	FileInstall("curl.exe", "bin\curl.exe")
*/

#Requires AutoHotkey v2.0-

SetWorkingDir A_ScriptDir


downloadDir := IniRead("DownloadHelper.ini", "Settings", "DownloadDirectory", EnvGet("USERPROFILE") . "\Downloads")
retry := IniRead("DownloadHelper.ini", "Settings", "Retry", false)
retryDelay := IniRead("DownloadHelper.ini", "Settings", "RetryDelay", 30)
links := "", link := ""
While link := IniRead("DownloadHelper.ini", "Links", "Link" . A_Index, False)
	links .= link . "`n"

forceStopped := true

AddLinkWindowOpen := false


DownloadHelperGui := Gui.New(, A_ScriptName) ; ToDo: Resizable ("+Resize +MinSize346x322")
											 ; DownloadHelperGui.GetPos(,, DhwW, DhwH)
DownloadHelperGui.OnEvent("Close", "CleanUpExit")
DownloadHelperTabs := DownloadHelperGui.Add("Tab3", "Choose2", ["Datei", "Downloader", "Curl", "Log", "Über"])


; Define Datei Tab
DownloadHelperTabs.UseTab(1)
DownloadHelperGui.Add("Text",, "Liste mit Links laden:")
DownloadHelperLoadButton := DownloadHelperGui.Add("Button", "w100", "Datei auswählen")
DownloadHelperLoadButton.OnEvent("Click", "SelectLoadFile")
DownloadHelperGui.Add("Text","Y+15", "Liste mit Links speichern:")
DownloadHelperSaveButton := DownloadHelperGui.Add("Button", "w100", "Datei auswählen")
DownloadHelperSaveButton.OnEvent("Click", "SelectSaveFile")
DownloadHelperGui.Add("Text","Y+50", "Downloadordner ändern:")
DownloadHelperDLDirButton := DownloadHelperGui.Add("Button", "w100", "Ordner auswählen")
DownloadHelperDLDirButton.OnEvent("Click", "SelectDLDir")
DownloadHelperGui.Add("Text", "Y+15", "Aktueller Downloadordner:")
DownloadHelperDLDir := DownloadHelperGui.Add("Edit", "ReadOnly -Wrap -VScroll w550")
DownloadHelperDLDirButton := DownloadHelperGui.Add("Button", "w100", "Ordner öffnen")
DownloadHelperDLDirButton.OnEvent("Click", "OpenDLDir")
try
	Trim(downloadDir, "`t`n ") != "" and DirExist(downloadDir) ? DownloadHelperDLDir.Value := downloadDir : DownloadHelperDLDir.Value := EnvGet("USERPROFILE") . "\Downloads"
catch
	DownloadHelperDLDir.Value := EnvGet("USERPROFILE") . "\Downloads"


; Define Downloader Tab
DownloadHelperTabs.UseTab(2)
DownloadHelperGui.Add("Text",, "Bitte Links hier einfügen (ein Link pro Zeile):")
DownloadHelperLinksInputField := DownloadHelperGui.Add("Edit", "-Wrap +HScroll w550 h200")
DownloadHelperLinksInputField.Value := links
DownloadHelperStartButton := DownloadHelperGui.Add("Button","w75", "Start")
DownloadHelperStartButton.OnEvent("Click", "startDownloadProcess")
DownloadHelperStartButton := DownloadHelperGui.Add("Button", "x+5 w75", "Stop")
DownloadHelperStartButton.OnEvent("Click", "stopDownloadProcess")
DownloadHelperStartButton := DownloadHelperGui.Add("Button", "x+320 w75", "Leeren")
DownloadHelperStartButton.OnEvent("Click", "clearLinksInputField")
DownloadHelperRetry := DownloadHelperGui.Add("Checkbox", "x20 y+15", "Bei Fehler: Neustart nach")
DownloadHelperRetryDelay := DownloadHelperGui.Add("Edit", "x+0 y295 w50")
DownloadHelperGui.Add("UpDown", "Range1-60", "30")
DownloadHelperGui.Add("Text", "x+5 y297", "Sekunden")
DownloadHelperStatusBar := DownloadHelperGui.Add("StatusBar",, "Status: Fertig!")
try
	DownloadHelperRetry.Value := retry
catch
	DownloadHelperRetry.Value := false
try
	DownloadHelperRetryDelay.Value := retryDelay
catch
	DownloadHelperRetryDelay.Value := 30



; Define Curl Tab
DownloadHelperTabs.UseTab(3)
DownloadHelperCurlField := DownloadHelperGui.Add("Edit", "ReadOnly -Wrap +HScroll w550 h275")
DownloadHelperCurlField.SetFont(, "Consolas")


; Define Log Tab
DownloadHelperTabs.UseTab(4)
DownloadHelperLogField := DownloadHelperGui.Add("Edit", "ReadOnly -Wrap +HScroll w550 h275")
DownloadHelperLogField.SetFont(, "Consolas")


;Define Über Tab
DownloadHelperTabs.UseTab(5)
DownloadHelperGui.Add("Text",, "Dieses Programm wurde entwickelt und getestet von:")
DownloadHelperGui.Add("Link", "X245 Y+30", "<a href=`"https://github.com/Nick768`">Nico3110/Nick768.</a>")
DownloadHelperGui.Add("Text", "X450 Y+215", "Version: 1.0 (01.06.2021)")


DownloadHelperGui.Show("AutoSize")

OnClipboardChange("UpdateLinkList")
OnError("CleanUpError")
OnExit("CleanUpExit")

return



SelectSaveFile(*) {
	global DownloadHelperLinksInputField, DownloadHelperTabs

	selectedFile := FileSelect("S 16",, "Datei zum speichern der Links auswählen...", "*.txt")

	if selectedFile != "" {
		saveFile := FileOpen(selectedFile, "w")
		saveFile.Write(DownloadHelperLinksInputField.Value)
		saveFile.Close()
		DownloadHelperTabs.Value := 2
	}

	return
}

SelectLoadFile(*) {
	global DownloadHelperLinksInputField, DownloadHelperTabs

	selectedFile := FileSelect(,, "Datei zum laden der Links auswählen...", "*.txt")

	if selectedFile != "" {
		saveFile := FileOpen(selectedFile, "r")
		DownloadHelperLinksInputField.Value := saveFile.Read()
		saveFile.Close()
		DownloadHelperTabs.Value := 2
	}

	return
}

SelectDLDir(*) {
	global DownloadHelperDLDir

	newDownloadDir := FileSelect("D",, "Downloadordner auswählen...")
	if newDownloadDir != ""
		DownloadHelperDLDir.Value := newDownloadDir

	return
}

OpenDLDir(*) {
	global DownloadHelperDLDir

	Run(A_WinDir . "\explorer.exe `"" . DownloadHelperDLDir.Value . "`"")
}

writeLog(msg, eL := 0) {
	; errorLevel 0 := Info
	; errorLevel 1 := Warning
	; errorLevel 2 := Error

	global DownloadHelperLogField
	eLText := ["Info: ", "WARNUNG: ", "FEHLER: "]

	DownloadHelperLogField.Value .= A_Hour . ":" . A_Min . ":" . A_Sec . ": " . eLText[eL + 1] . msg . "`n"
}

startDownloadProcess(*) {
	global DownloadHelperStatusBar, DownloadHelperLinksInputField, DownloadHelperDLDir, DownloadHelperRetry, DownloadHelperTabs, DownloadHelperCurlField, DownloadHelperRetryDelay, forceStopped

	forceStopped := false
	if DownloadHelperLinksInputField.Value = "" {
		DownloadHelperStatusBar.SetText("WARNUNG: Bitte überprüfe deine Eingabe im Log-Tab!")
		writeLog("Keine Links eingegeben!", 1)
	} else {
		links := StrSplit(DownloadHelperLinksInputField.Value, "`n")
		for index, link in links {
			if link != "" {
				if !RegExMatch(link, "(http://|https://|ftp://)(www.)?.*[.].*") {
					DownloadHelperStatusBar.SetText("WARNUNG: Bitte überprüfe deine Eingabe im Log-Tab!")
					writeLog("Ungültiger Link: " . link, 1)
				} else if !forceStopped {
					curlBox := CriticalObject(DownloadHelperCurlField)
					pipename := "\\.\pipe\DownloadHelper" . Random()
					ProgressThreadCode := Format("
					(
						#NoTrayIcon
						curlfield := ""
						pipename := ""
						curlBox := CriticalObject({1})
						Alias(pipename, {2})
						if -1 = (Pipe := CreateNamedPipe(pipename, 3, 0, 255, 0, 0, 0, 0)) {
							pipename := Pipe
							MsgBox("Fehler beim Erstellen der Pipe!", "FEHLER:", 16)
							ExitApp()
						}
						size := 0
						;Run(A_ComSpec . " /C bin\curl.exe 2> " . pipename)
						while !DllCall("PeekNamedPipe", "Ptr", Pipe, "Ptr", 0, "UInt", 0, "Ptr", 0, "UIntP", size, "Ptr", 0)
							Sleep(0)
						output := ""
						errorOut := ""
						successcount := 3
						while DllCall("PeekNamedPipe", "Ptr", Pipe, "Ptr", 0, "UInt", 0, "Ptr", 0, "UIntP", size, "Ptr", 0) {
							out := ""
							VarSetStrCapacity(out, size)
							DllCall("ReadFile", "Ptr", Pipe, "Ptr", StrPtr(out), "UInt", size, "PtrP", 0, "Ptr", 0)
							out := StrGet(StrPtr(out), size, "CP0")
							if RegexMatch(out, "(curl:|warning:|error|Curl:|Warning:|Error:)") or successcount < 3 {
								outlines := StrSplit(out, "``n")
								for line in outlines
									if RegexMatch(line, "(curl:|warning:|error|Curl:|Warning:|Error:)")
										errorOut := line . "``n" . errorOut
								curlBox.Value := errorOut
								successcount := 0
							} else if !InStr(output, "% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current") {
								output := "  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current``n"
								output .= "                                 Dload  Upload   Total   Spent    Left  Speed  ``n" . StrReplace(out, "``n")
								curlBox.Value := output
								successcount++
								errorOut := ""
							} else {
								output := out
								curlBox.Value := output
								successcount++
								errorOut := ""
							}
						}
						DllCall("CloseHandle", "Ptr", Pipe)
					)", ObjPtr(curlBox), GetVar(pipename))
					ExeThread(ProgressThreadCode)
					retry := DownloadHelperRetry.Value ? "--retry-all-errors --retry 9999999 --retry-delay " . DownloadHelperRetryDelay.Value : ""
					if index = 1
						DownloadHelperTabs.Value := 3
					DownloadHelperStatusBar.SetText("Status: Lade herunter...")
					writeLog("Curl gestartet: " . A_ComSpec . ' /C ""' . A_ScriptDir . '\bin\curl.exe" -O --output-dir "' . DownloadHelperDLDir.Value . '" -J -L ' . retry . ' "' . link . '" > ' . pipename . '" 2>&1')
					Sleep(1000)
					RunWait(A_ComSpec . ' /C ""' . A_ScriptDir . '\bin\curl.exe" -O --output-dir "' . DownloadHelperDLDir.Value . '" -JLf ' . retry . ' "' . link . '" > ' . pipename . '" 2>&1',, "Hide")
					DownloadHelperStatusBar.SetText("Status: Fertig!")
				} else
					break
			}
		}
	}
	return
}

stopDownloadProcess(*) {
	global DownloadHelperStatusBar, forceStopped

	forceStopped := true
	Loop 10
		if (ProcessExist("curl.exe"))
			ProcessClose("curl.exe")
		else {
			DownloadHelperStatusBar.SetText("Status: Curl gestoppt!")
			writeLog("Download manuell abgebrochen")
			return
		}

	DownloadHelperStatusBar.SetText("WARNUNG: Bitte prüfe den Log-Tab!")
	writeLog("Curl wurde nicht gestoppt oder läuft nicht!", 1)

	return
}

clearLinksInputField(*) {
	global DownloadHelperLinksInputField

	DownloadHelperLinksInputField.Value := ""

	return
}

UpdateLinkList(*) {
	global AddLinkWindowOpen, DownloadHelperLinksInputField

	ClickOK(*) {
		DownloadHelperLinksInputField.Value := Trim(DownloadHelperLinksInputField.Value, "`n`t ") . "`n" . AddLinkGuiEdit.Value

		AddLinkGui.Submit()
		AddLinkWindowOpen := false

		return
	}

	ClickCancel(*) {
		AddLinkGui.Submit()
		AddLinkWindowOpen := false

		return
	}

		CBLines := StrSplit(A_Clipboard, "`n")
		if !AddLinkWindowOpen {
		AddLinkGui := Gui.New(, "Links hinzufügen:")
		AddLinkGui.OnEvent("Close", "ClickCancel")
		AddLinkGuiEdit := AddLinkGui.Add("Edit", "-Wrap +HScroll w350 h250")
		for linkCount, line in CBLines {
			lineToAdd := Trim(line, " `n`t")
			if RegExMatch(lineToAdd, "(http://|https://|ftp://)(www.)?.*[.].*") and !InStr(DownloadHelperLinksInputField.Value, lineToAdd) {
				AddLinkGuiEdit.Value .= lineToAdd . "`n"

				if linkCount = CBLines.Length and !AddLinkWindowOpen {
					OKButton := AddLinkGui.Add("Button", "w75 y+15", "OK")
					CancelButton := AddLinkGui.Add("Button", "w75 x+5", "Abbrechen")
					OKButton.OnEvent("Click", "ClickOK")
					CancelButton.OnEvent("Click", "ClickCancel")
					AddLinkGui.Show("AutoSize Minimize")
					AddLinkWindowOpen := true
					Loop 6 {
						AddLinkGui.Flash()
						Sleep(500)
					}
				}
			}
		}
	}

	return
}

CleanUpError(*) {
	global DownloadHelperLinksInputField, DownloadHelperDLDir, DownloadHelperRetry, DownloadHelperRetryDelay

	IniDelete("DownloadHelper.ini", "Settings")
	IniDelete("DownloadHelper.ini", "Links")

	links := StrSplit(DownloadHelperLinksInputField.Value, "`n")
	for index, link in links
		if link
			IniWrite(link, "DownloadHelper.ini", "Links", "Link" . index)

	IniWrite(DownloadHelperDLDir.Value, "DownloadHelper.ini", "Settings", "DownloadDirectory")
	IniWrite(DownloadHelperRetry.Value, "DownloadHelper.ini", "Settings", "Retry")
	IniWrite(DownloadHelperRetryDelay.Value, "DownloadHelper.ini", "Settings", "RetryDelay")

	stopDownloadProcess()

	if MsgBox("Es ist ein Fehler aufgetreten. Möchtest du ihn melden?", "FEHLER:", "20") = "yes"
		Run("https://github.com/Nick768")

	ExitApp()
}

CleanUpExit(*) {
	global DownloadHelperLinksInputField, DownloadHelperDLDir, DownloadHelperRetry, DownloadHelperRetryDelay

	IniDelete("DownloadHelper.ini", "Settings")
	IniDelete("DownloadHelper.ini", "Links")

	links := StrSplit(DownloadHelperLinksInputField.Value, "`n")
	for index, link in links
		if link
			IniWrite(link, "DownloadHelper.ini", "Links", "Link" . index)

	IniWrite(DownloadHelperDLDir.Value, "DownloadHelper.ini", "Settings", "DownloadDirectory")
	IniWrite(DownloadHelperRetry.Value, "DownloadHelper.ini", "Settings", "Retry")
	IniWrite(DownloadHelperRetryDelay.Value, "DownloadHelper.ini", "Settings", "RetryDelay")

	stopDownloadProcess()

	ExitApp()
}
