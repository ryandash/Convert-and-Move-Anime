@echo off

for /f "delims=" %%a in ('where powershell') do set "powershell=%%a"
for /f "delims=" %%a in ('where python') do set "pythonPath=%%a"

timeout /t 5 /nobreak
setlocal EnableDelayedExpansion
tasklist /fi "ImageName eq VSPipe.exe" /fo csv 2>NUL | find /I "VSPipe.exe">NUL
echo error level !ERRORLEVEL! for hybrid
IF !ERRORLEVEL! NEQ 0 (
	tasklist /fi "ImageName eq ffmpeg.exe" /fo csv 2>NUL | find /I "ffmpeg.exe">NUL
	echo error level !ERRORLEVEL! for ffmpeg
	IF !ERRORLEVEL! NEQ 0 (
		endlocal

		:start
		cd /d "%UserDirectory%\Documents\vapoursynth-portable"
		for /r "%UserDirectory%\Downloads\" %%f in (*.mkv) do (
			set "file=%%f"
			set "filename=%%~nf"

			setlocal EnableDelayedExpansion
			for /f "tokens=1,2 delims=|" %%a in ('!pythonPath! "%UserDirectory%\Documents\new_anime_name_directory.py" "!file!"') do (
				endlocal
				set "newDirectory=%%a"
				set "newFileName=%%b"
				setlocal EnableDelayedExpansion
			)
			echo !newDirectory!
			echo !newFileName!

			REM Upscale 4k
			call vspipe --arg source="!file!" -c y4m "encode 4k 48fps.vpy" - | ffmpeg -y -f yuv4mpegpipe -i pipe:0 -hwaccel cuvid -i "!file!" -c:v hevc_nvenc -cq 26 -bf 5 -refs 3 -preset p5 -map 0:v -map 1:a -c:a copy -sn "!newDirectory!\!newFileName!.mp4"
			REM Extract english subtitles
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
				!powershell! -Command Get-Content -Path "!tempFile!" -Encoding UTF8 ^| Set-Content -Path "!finalFile!" -Encoding utf8
				del "!tempFile!" /f /q /s

				set /a "counter+=1"
			)
			del "!file!" /q /s
			endlocal
		)
		
		REM Cleanup empty folders
		cd /d "%UserDirectory%\Downloads\"
		for /d %%d in (*) do rd "%%d" 2>NUL

		if exist "%UserDirectory%\Downloads\*.mkv" (
			goto start
		)
	)
)
endlocal