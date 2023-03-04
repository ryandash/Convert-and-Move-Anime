@echo off
@timeout /t 10 /nobreak

tasklist /fi "imagename eq Hybrid.exe" | find ":" > nul
if "%ERRORLEVEL%"=="0" (
    if not exist "%UserDirectory%\Documents\runningFFmpeg.txt" (
    break>"%UserDirectory%\Documents\runningFFmpeg.txt"
        for /r "%UserDirectory%\Downloads\" %%f in (*.mkv) do (
            if not exist "%UserDirectory%\Videos\convert\%%~nf.mkv" (
                cd /d "%UserDirectory%\Documents\ffmpeg\bin"
                call ffmpeg -y -vsync 0 -i "%%f" -init_hw_device vulkan -vf format=yuv420p10,hwupload,libplacebo=w=3840:h=2160:upscaler=ewa_lanczos:custom_shader_path=shaders/Anime4K_ModeA.glsl,hwdownload,format=yuv420p10 -c:v hevc_nvenc -cq 24 -bf 5 -refs 5 -preset p7 "%UserDirectory%\Videos\convert\%%~nf.mkv"
            )
        )
        cd /d "%UserDirectory%\Downloads\"
        for /f "delims=" %%d in ('dir /s /b /ad ^| sort /r') do rd "%%d"
        del /f /q "%UserDirectory%\Documents\runningFFmpeg.txt"
    
        @timeout /t 1 /nobreak

        for /r "%UserDirectory%\Videos\convert" %%d in (*.mkv) do call set "Name="%%d" %%Name%%"
        
        setlocal EnableDelayedExpansion
        cd /d "C:\Program Files\Hybrid"
        echo !Name!
        if not "!Name!"=="" (
            start Hybrid -global anime -autoAdd addAndStart !Name:~0,-2!
        )
        endlocal
    )
)
pause