@echo off

for /f "delims=" %%a in ('where python') do set "pythonPath=%%a"
for /f "delims=" %%a in ('where powershell') do set "powershell=%%a"
cd /d "%UserDirectory%\Documents\ffmpeg\bin"
for /r "%UserDirectory%\Downloads\" %%f in (*.mkv) do (
	set "counter=0"
	set "file=%%~pdnf"

	setlocal EnableDelayedExpansion
	set "filename=!file:[=`[!"
	set "filename=!filename:]=`]!"
	set "filename=!filename:'=''!"
	for /f "tokens=1 delims=," %%a in ('ffprobe -loglevel error -select_streams s -show_entries stream^=index:stream_tags^=language -of csv^=p^=0 "!file!.mkv" ^| C:\Windows\System32\findstr.exe "eng"') do (
		ffmpeg -y -i "!file!.mkv" -map 0:%%a -c:s ass "!file!.default.eng.!counter!.utf8.ass"
		!powershell! -Command "Get-Content -Path '!filename!.default.eng.!counter!.utf8.ass' -Encoding UTF8 | Set-Content -Path '!filename!.default.eng.!counter!.ass' -Encoding utf8"
		del "!file!.default.eng.!counter!.utf8.ass" /f /q /s
		set /a "counter+=1"
	)

	move "!file!.mkv" "%UserDirectory%\Music\"
	"!pythonPath!" "%UserDirectory%\Documents\move_anime.py" "!file!.mkv"
	endlocal
)
pause