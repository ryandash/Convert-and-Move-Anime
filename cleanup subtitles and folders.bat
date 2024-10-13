@echo off
For /r "D:\Anime" %%f IN (*.ass, *.srt) do (
	set "subtitle=%%f"
	set "delete=true"
	set "string=%%~pdnf"
	:loop
	for /f "tokens=1* delims=." %%a in ("%string%") do (
		if "%%a"=="default" (
            goto :FoundDefault
        )
		set "video=%video%.%%a"
		set "string=%%b"
	)
	if defined string goto loop

	:FoundDefault
	setlocal EnableDelayedExpansion
	set "video=!video:~1!"

	if exist "!video!.mp4" set "delete=false"
	if exist "!video!.mkv" set "delete=false"
	if exist "!video!.webm" set "delete=false"
	if "!delete!"=="true" (
		del "!subtitle!" /f /q /s
		echo deleted "!subtitle!" >> "%UserDirectory%\Documents\move_anime.txt"
	)
	endlocal
)
cd /d "D:\Anime\"
for /f "delims=" %%d in ('dir /s /b /ad ^| sort /r') do rd "%%d" 2>nul
exit