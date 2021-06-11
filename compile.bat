@echo off

"C:\Program Files\AutoHotkey\ahkdll\v2\Compiler\ahk2Exe.exe" "C:\Program Files\AutoHotkey\ahkdll\v2\Compiler\ahk2Exe.ahk" /in "DownloadHelper.ahk" /bin "C:\Program Files\AutoHotkey\ahkdll\v2\x64w_MT\AutoHotkey.bin" || goto Error
bin\AddResource.exe bin\curl.exe DownloadHelper.exe || goto Error
Exit

:Error
pause
