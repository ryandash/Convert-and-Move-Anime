@echo off
for /f "delims=" %%a in ('where python') do set "pythonPath=%%a"

For /r "%UserDirectory%\ConvertedVideos\" %%f IN (*.mp4, *.mkv, *.webm) do (
	Set "Dir=%%f"
	del "%UserDirectory%\Videos\convert\%%~nf.mkv" /f /q /s
	:: Use delayedexpansion to avoid removing exclamation marks from the path
	setlocal EnableDelayedExpansion
	echo "!Dir!" in custommove.bat >> "%UserDirectory%\Documents\move_anime.txt"
	"!pythonPath!" "%UserDirectory%\Documents\move_anime.py" "!Dir!" >> "%UserDirectory%\Documents\move_anime.txt"
	endlocal
)
echo finished moving videos
timeout /t 10 /nobreak
cd /d "%UserDirectory%\Documents\"
call cmd.exe /c "cleanup subtitles and folders.bat"
start cmd.exe /c "autoconvert.bat"