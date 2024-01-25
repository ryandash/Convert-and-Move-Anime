@echo off
For /r "D:\Anime" %%f IN (*.ass, *.srt) do (
	set "subtitle=%%f"
	set "delete=true"
	set "video=%%~pdnf"
	call set video=%%video:.default.eng=%%
	
	setlocal EnableDelayedExpansion
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
echo finished cleanup