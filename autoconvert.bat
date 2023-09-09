@echo off
@timeout /t 10 /nobreak
SETLOCAL ENABLEDELAYEDEXPANSION

tasklist /fi "ImageName eq Hybrid.exe" /fo csv 2>NUL | find /I "Hybrid.exe">NUL
IF !ERRORLEVEL! NEQ 0 (
	tasklist /fi "ImageName eq ffmpeg.exe" /fo csv 2>NUL | find /I "ffmpeg.exe">NUL
	IF !ERRORLEVEL! NEQ 0 (
		endlocal
		del /q/f/s %TEMP%\*
		cd /d "%UserDirectory%\Documents\ffmpeg\bin"
		for /r "%UserDirectory%\Downloads\" %%f in (*.mkv) do (
			if not exist "%UserDirectory%\Videos\convert\%%~nf.mkv" (
				call ffmpeg -y -i "%%f" -init_hw_device "vulkan=vk:0" -vf libplacebo=w=3840:h=2160:upscaler=ewa_lanczos:force_original_aspect_ratio=decrease:custom_shader_path=shaders/Anime4K_ModeA.glsl,format=yuv420p10 -map 0 -c:v hevc_nvenc -cq 24 -bf 5 -refs 5 -preset p7 -c:a copy -c:s copy "%UserDirectory%\Videos\convert\%%~nf.mkv"
				del "%%f" /f /q /s
			)
		)
		cd /d "%UserDirectory%\Downloads\"
		for /f "delims=" %%d in ('dir /s /b /ad ^| sort /r') do rd "%%d"

		set "Name="

		for /r "%UserDirectory%\Videos\convert" %%d in (*.mkv) do (
			if exist %%d (
				call set "Name=%%Name%% "%%d""
			)
		)

		setlocal EnableDelayedExpansion
		cd /d "C:\Program Files\Hybrid"
		if not "!Name!"=="" (
			start Hybrid -global anime -autoAdd addAndStart !Name!
		)
	)
)
endlocal
exit