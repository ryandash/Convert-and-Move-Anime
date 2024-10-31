@echo off

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
			set "file=%%f"
			set "filename=%%~nf"

			:: Upscale 4k
			echo upscaling %%~nxf > "%UserDirectory%\Documents\autoconvertlog.txt"
			call ffmpeg -y -i "%%f" -init_hw_device "vulkan=vk:0" -vf libplacebo=w=3840:h=2160:upscaler=ewa_lanczos:force_original_aspect_ratio=decrease:custom_shader_path='shaders/Anime4K_ModeA.glsl',format=yuv420p -map 0 -c:v hevc_nvenc -cq 10 -bf 5 -refs 5 -preset p7 -c:a copy -sn "%UserDirectory%\Videos\convert\%%~nxf"
			
			:: Extract english subtitles
			setlocal EnableDelayedExpansion
			set "filename_ps=!filename:[=`[!"
			set "filename_ps=!filename_ps:]=`]!"
			set "filename=!filename:'=''!"
			set "counter=0"
			for /f "tokens=1 delims=," %%a in ('ffprobe -loglevel error -select_streams s -show_entries stream^=index:stream_tags^=language -of csv^=p^=0 "!file!" ^| C:\Windows\System32\findstr.exe "eng"') do (
				ffmpeg -y -i "!file!" -map 0:%%a -c:s ass "%UserDirectory%\ConvertedVideos\!filename!.default.eng.!counter!.utf8.ass"
				:: Fix for broken characters in subtitles when playing back in browser or simular player
				!powershell! -Command "Get-Content -Path '%UserDirectory%\ConvertedVideos\!filename_ps!.default.eng.!counter!.utf8.ass' -Encoding UTF8 | Set-Content -Path '%UserDirectory%\ConvertedVideos\!filename_ps!.default.eng.!counter!.ass' -Encoding utf8"
				del "%UserDirectory%\ConvertedVideos\!filename!.default.eng.!counter!.utf8.ass" /f /q /s
				set /a "counter+=1"
			)
			del "!file!" /q /s
			endlocal
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
		)
		endlocal
	)
)
endlocal