#Requires AutoHotkey v2.0-
#NoTrayIcon
#Warn All, Off
;@Ahk2Exe-ConsoleApp

startDir := A_InitialWorkingDir

DllCall("AttachConsole", "int", -1)
FileAppend("`n", "*")

if (A_Args.Length != 2) {
	FileAppend("    Usage:`n        " . A_ScriptName . " <Resource-to-add> <Destination-binary>`n", "**")
	ExitApp(-1)
}

; Check if A_Args is relative
args := A_Args
isRelative := [true, true]
rounds := 0

while ((isRelative[1] or isRelative[2]) and rounds < 3) {
	rounds++
	relativeCheck()
}

if (isRelative[1] or isRelative[2]) {
	FileAppend("    Something went wrong. Check your input!`n", "**")
	ExitApp(-1)
}

res2add := args[1]
destbin := args[2]
SplitPath(res2add, resname)

FileAppend("    Adding:`t`"" . res2add . "`"`n    To:`t`t`"" . destbin . "`"`n    With bame:`t`"" . resname . "`"`n`n", "*")

ResPut(FileRead(res2add, "RAW"), FileGetSize(res2add), destbin, resname)

try succ := ResExist(destbin, StrUpper(resname))
if succ
	FileAppend("    Success!`n", "*")
else
	FileAppend("    Something went wrong!`n", "*")

DllCall("FreeConsole")
return

relativeCheck() {
	global args, isRelative, startDir
	for index, arg in args {
		if (!FileExist(arg) and !FileExist(".\" . arg) and !FileExist(startDir . "\" . arg)) {
			FileAppend("    `"" . arg . "`" doesn't exist!`n", "**")
			ExitApp(-1)
		}

		; better check twice!
		SetWorkingDir(A_WinDir)
		if FileExist(arg)
			isRelative[index] := false
		SetWorkingDir(A_MyDocuments)
		if FileExist(arg)
			isRelative[index] := false

		; fix relative path
		SetWorkingDir(startDir)
		if isRelative[index] {
			SplitPath(arg, filename)
			try SetWorkingDir(StrReplace(arg, filename, ""))
			args[index] := A_WorkingDir . "\" . filename
			SetWorkingDir(startDir)
		}
	}
	return
}
