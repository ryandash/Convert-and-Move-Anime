@echo off

for /f "delims=" %%a in ('where python') do set "pythonPath=%%a"

for /r "%UserDirectory%\Downloads\" %%f in (*.mkv) do (
	Set "path=%%~dpf" 

	:: Rename anime
	for /f "delims=" %%a in ('%pythonPath% "%UserDirectory%\Documents\rename_anime.py" "%%f"') do (set "thename=%%a")
	if !thename!=="" (
		echo failed to set thename
		exit
	)

	setlocal EnableDelayedExpansion

    cd /d "%UserDirectory%\Documents\ffmpeg\bin"
	set "counter=0"
	for /f "tokens=1 delims=," %%a in ('ffprobe -loglevel error -select_streams s -show_entries stream^=index:stream_tags^=language -of csv^=p^=0 "!path!!thename!.mkv" ^| C:\Windows\System32\findstr.exe "eng"') do (
		ffmpeg -y -i "!path!!thename!.mkv" -map 0:%%a -c:s ass "!path!!thename!.default.eng.!counter!.utf8.ass"
		"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Command "Get-Content -Path '!path!!thename!.default.eng.!counter!.utf8.ass' -Encoding UTF8 | Set-Content -Path '!path!!thename!.default.eng.!counter!.ass' -Encoding utf8"
		del "!path!!thename!.default.eng.!counter!.utf8.ass" /f /q /s
		set /a "counter+=1"
	)

	"!pythonPath!" "%UserDirectory%\Documents\move_anime.py" "!path!!thename!.mkv"
	
	move "!path!!thename!.mkv" "%UserDirectory%\Music\"
	
	endlocal
)
pause