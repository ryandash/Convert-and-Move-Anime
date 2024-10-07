@echo off

for /f "delims=" %%a in ('where python') do set "pythonPath=%%a"
for /f "delims=" %%a in ('where powershell') do set "powershell=%%a"

timeout /t 10 /nobreak
setlocal EnableDelayedExpansion
tasklist /fi "ImageName eq VSPipe.exe" /fo csv 2>NUL | find /I "VSPipe.exe">NUL
echo error level !ERRORLEVEL! for hybrid > "%UserDirectory%\Documents\autoconvertlog.txt"
IF !ERRORLEVEL! NEQ 0 (
	tasklist /fi "ImageName eq ffmpeg.exe" /fo csv 2>NUL | find /I "ffmpeg.exe">NUL
	echo error level !ERRORLEVEL! for ffmpeg >> "%UserDirectory%\Documents\autoconvertlog.txt"
	IF !ERRORLEVEL! NEQ 0 (
		endlocal
		cd /d "%UserDirectory%\Documents\ffmpeg\bin\"
		for /r "%UserDirectory%\Downloads\" %%f in (*.mkv) do (
			if not exist "%UserDirectory%\Videos\convert\%%~nf.mkv" (
				Set "Dir=%%f"
				Set "path=%%~dpf"

				:: Rename anime and return filename
				set "thename="
				for /f "delims=" %%a in ('%pythonPath% "%UserDirectory%\Documents\rename_anime.py" "%%f"') do (
					set "thename=%%a"
				)

				setlocal EnableDelayedExpansion				
				if "!thename!"=="" (
					echo failed to get filename >> "%UserDirectory%\Documents\autoconvertlog.txt"
					exit
				)
				
				:: Upscale 4k
				echo upscaling !thename! > "%UserDirectory%\Documents\autoconvertlog.txt"
				call ffmpeg -y -i "!path!!thename!.mkv" -init_hw_device "vulkan=vk:0" -vf libplacebo=w=3840:h=2160:upscaler=ewa_lanczos:force_original_aspect_ratio=decrease:custom_shader_path='shaders/Anime4K_ModeA.glsl',format=yuv420p -map 0 -c:v hevc_nvenc -cq 10 -bf 5 -refs 5 -preset p7 -c:a copy -sn "%UserDirectory%\Videos\convert\!thename!.mkv"
				set "counter=0"

				for /f "tokens=1 delims=," %%a in ('ffprobe -loglevel error -select_streams s -show_entries stream^=index:stream_tags^=language -of csv^=p^=0 "!path!!thename!.mkv" ^| C:\Windows\System32\findstr.exe "eng"') do (
					ffmpeg -y -i "!path!!thename!.mkv" -map 0:%%a -c:s ass "%UserDirectory%\ConvertedVideos\!thename!.default.eng.!counter!.utf8.ass"
					:: Fix for broken characters in subtitles when playing back in browser or simular player
					!powershell! -Command "Get-Content -Path '%UserDirectory%\ConvertedVideos\!thename!.default.eng.!counter!.utf8.ass' -Encoding UTF8 | Set-Content -Path '%UserDirectory%\ConvertedVideos\!thename!.default.eng.!counter!.ass' -Encoding utf8"
					del "%UserDirectory%\ConvertedVideos\!thename!.default.eng.!counter!.utf8.ass" /f /q /s
					set /a "counter+=1"
				)
				del "!path!!thename!.mkv" /q /s
				endlocal
			)
		)
		
		:: Cleanup empty folders
		cd /d "%UserDirectory%\Downloads\"
		for /f "delims=" %%d in ('dir /s /b /ad') do rd "%%d"
		echo deleted empty folders >> "%UserDirectory%\Documents\autoconvertlog.txt"

		set "Name="
		for /r "%UserDirectory%\Videos\convert" %%d in (*.mkv) do (
			if exist "%%d" (
				call set "Name=%%Name%% "%%d""
			)
		)

		setlocal EnableDelayedExpansion
		:: Hybrid Selur to interpolate to 2x
		cd /d "C:\Program Files\Hybrid\"
		if not "!Name!"=="" (
			echo starting Hybrid with !Name! >> "%UserDirectory%\Documents\autoconvertlog.txt"
			start Hybrid -global anime -autoAdd addAndStart !Name!
		) else (
			echo No files for Hybrid to interpolate >> "%UserDirectory%\Documents\autoconvertlog.txt"
		)
		endlocal
	)
)
endlocal
exit