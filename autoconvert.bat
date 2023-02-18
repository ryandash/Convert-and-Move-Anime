@echo off
@timeout /t 10 /nobreak

tasklist /fi "imagename eq Hybrid.exe" | find ":" > nul
if "%ERRORLEVEL%"=="0" (
    if not exist "%UserDirectory%\Documents\runningMpv.txt" (
    break>"%UserDirectory%\Documents\runningMpv.txt"
        for /r "%UserDirectory%\Downloads\" %%f in (*.mkv) do (
		cd /d "%UserDirectory%\Videos\"
            if not exist "%UserDirectory%\Videos\convert\%%~nf.mkv" (
                for /f "tokens=5 delims==_" %%i in ('%UserDirectory%\Documents\ffmpeg\bin\ffprobe -v error -of flat^=s^=_ -select_streams v:0 -show_entries stream^=width "%%f"') do (set /a width=%%i*2)
                for /f "tokens=5 delims==_" %%i in ('%UserDirectory%\Documents\ffmpeg\bin\ffprobe -v error -of flat^=s^=_ -select_streams v:0 -show_entries stream^=height "%%f"') do (set /a height=%%i*2)
                for /F "delims=" %%I in ('%UserDirectory%\Documents\ffmpeg\bin\ffprobe -v error -select_streams s:0 -show_entries stream^=codec_name -of default^=noprint_wrappers^=1:nokey^=1 "%%f"') do (set "codec=%%I")
                set "file=%%f"
                set "shortfile=%%~nf"

                setlocal EnableDelayedExpansion
                if "!codec!"=="subrip" (
                    set codec=srt
                ) else (
                    set codec=ass
                )
                cd /d "%UserDirectory%\Videos"

                "%UserDirectory%\Documents\ffmpeg\bin\ffmpeg" -y -vn -an -dn -i "!file!" -c copy -map 0:s:0 "!shortfile!-subs.!codec!"
                call "%UserDirectory%\Documents\new mpv\mpv" "!file!" --no-config --glsl-shaders="%UserDirectory%\Documents\new mpv\Anime4K_ModeA.glsl" -vf=gpu="w=!width!:h=!height!" -scale=ewa_lanczossharp -cscale=ewa_lanczossharp --no-sub --gpu-shader-cache-dir="%UserDirectory%\Documents\mpv\cache" --o="!shortfile!-nosubs.mkv"

                @timeout /t 1 /nobreak
                "C:\Program Files\MKVToolNix\mkvmerge" -o "%UserDirectory%\Videos\convert\!shortfile!.mkv" "%UserDirectory%\Videos\!shortfile!-nosubs.mkv" "%UserDirectory%\Videos\!shortfile!-subs.!codec!"
                @timeout /t 1 /nobreak

                if exist "%UserDirectory%\Videos\convert\!shortfile!.mkv" (
                    "%UserDirectory%\Documents\Recycle.exe" "!shortfile!-subs.!codec!"
                    "%UserDirectory%\Documents\Recycle.exe" "!shortfile!-nosubs.mkv"
                    "%UserDirectory%\Documents\Recycle.exe" "!file!"
			  cd /d "%UserDirectory%\Videos\convert\"
                    ren "!shortfile!.mkv" "!shortfile!.mkv"
                )
                endlocal

                @timeout /t 1 /nobreak
            )
        )
        cd /d "%UserDirectory%\Downloads\"
        for /f "delims=" %%d in ('dir /s /b /ad ^| sort /r') do rd "%%d"
        del /F /Q "%UserDirectory%\Documents\runningMpv.txt"
    
        @timeout /t 1 /nobreak

        for /r "%UserDirectory%\Videos\convert\" %%d in (*.mkv) do call set "Name="%%d" %%Name%%"
        
        setlocal EnableDelayedExpansion
        cd /d "C:\Program Files\Hybrid"
        if NOT "!Name!"=="" (
            start Hybrid -global anime -autoAdd addAndStart !Name:~0,-2!
        )
        endlocal
    )
)
exit