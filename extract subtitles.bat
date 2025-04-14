@echo off

for /f "delims=" %%a in ('where python') do set "pythonPath=%%a"
for /f "delims=" %%a in ('where powershell') do set "powershell=%%a"

cd /d "%UserDirectory%\Documents\ffmpeg\bin"
for /r "%UserDirectory%\Downloads\" %%f in (*.mkv) do (
	set "counter=0"
	set "file=%%~pdnf"

	setlocal EnableDelayedExpansion
	for /f "tokens=1,2 delims=|" %%a in ('%pythonPath% "%UserDirectory%\Documents\new_anime_name_directory.py" "%file%"') do (
		endlocal
		set "newDirectory=%%a"
		set "newFileName=%%b"
		setlocal EnableDelayedExpansion
	set "filename_ps=!newFileName:[=`[!"
	set "filename_ps=!filename_ps:]=`]!"
	set "filename_ps=!filename_ps:'=''!"

	set "counter=0"
	for /f "tokens=1,2 delims=," %%a in ('ffprobe -loglevel error -select_streams s -show_entries stream^=index:stream_tags^=language -of csv^=p^=0 "!file!"') do (
		set "lang=%%b"
		set "sub_index=%%a"

		set "suffix=!lang!"
		if "%%b"=="eng" (
			set "suffix=default.%%b"
		) else (
			set "suffix=%%b"
		)

		set "tempFile=!newDirectory!\!newFileName!.!suffix!.!counter!.utf8.ass"
		set "finalFile=!newDirectory!\!newFileName!.!suffix!.!counter!.ass"

		ffmpeg -y -i "!file!" -map 0:!sub_index! -c:s ass "!tempFile!"
		!powershell! -Command "Get-Content -Path '!tempFile!' -Encoding UTF8 | Set-Content -Path '!finalFile!' -Encoding utf8"
		del "!tempFile!" /f /q /s

		set /a "counter+=1"
	)

	move "!file!.mkv" "%UserDirectory%\Music\"
	"!pythonPath!" "%UserDirectory%\Documents\move_anime.py" "!file!.mkv"
	endlocal
)
pause