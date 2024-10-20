@echo off
For /r "D:\Anime" %%f IN (*.ass, *.srt) do (
	set "subtitle=%%f"
	set "delete=true"
	set "string=%%~pdnf"
	set "foundDefault=false"
	set "video="

	call :innerloop
	
	setlocal EnableDelayedExpansion
	if "!foundDefault!"=="true" (
		set "video=!video:~1!"
		if exist "!video!.mp4" set "delete=false"
		if exist "!video!.mkv" set "delete=false"
		if exist "!video!.webm" set "delete=false"
		if "!delete!"=="true" (
			del "!subtitle!" /f /q /s
			echo deleted !subtitle!
			echo deleted "!subtitle!" >> "%UserDirectory%\Documents\deleted_subtitles.txt"
		)
	)
	endlocal
)
for /f "delims=" %%d in ('dir "D:\Anime" /s /b /ad ^| sort /r') do rd "%%d" 2>nul
goto :end

:innerloop
for /f "tokens=1,* delims=." %%a in ("%string%") do (
	if "%%a"=="default" (
		set "foundDefault=true"
		goto :end
	) else (
		set "video=%video%.%%a"
		set "string=%%b"
		goto :innerloop
	)
)
:end