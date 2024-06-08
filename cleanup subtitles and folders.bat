@echo off
For /r "D:\Anime" %%f IN (*.ass, *.srt) do (
	set "subtitle=%%f"
	set "delete=true"
	set "video=%%~pdnf"
	setlocal EnableDelayedExpansion
	set "newVideo="
	for /f "delims=." %%a in ("!video!") do (
        if "%%a"=="default" (
            goto :FoundDefault
        )
        set "newVideo=!newVideo!.%%a"
    )
	:FoundDefault
	set "video=!newVideo:~1!"
	if exist "!video!.mp4" set "delete=false"
	if exist "!video!.mkv" set "delete=false"
	if exist "!video!.webm" set "delete=false"
	if "!delete!"=="true" (
		del "!subtitle!" /f /q /s
		echo deleted "!subtitle!"
	)
	endlocal
)
cd /d "D:\Anime\"
for /f "delims=" %%d in ('dir /s /b /ad ^| sort /r') do rd "%%d" 2>nul