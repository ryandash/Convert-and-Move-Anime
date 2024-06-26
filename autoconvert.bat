@echo off
@timeout /t 10 /nobreak
setlocal EnableDelayedExpansion
tasklist /fi "ImageName eq VSPipe.exe" /fo csv 2>NUL | find /I "VSPipe.exe">NUL
echo error level !ERRORLEVEL! for hybrid > "%UserDirectory%\Documents\autoconvertlog.txt"
echo error level !ERRORLEVEL! for hybrid
IF !ERRORLEVEL! NEQ 0 (
	tasklist /fi "ImageName eq ffmpeg.exe" /fo csv 2>NUL | find /I "ffmpeg.exe">NUL
	echo error level !ERRORLEVEL! for ffmpeg >> "%UserDirectory%\Documents\autoconvertlog.txt"
	echo error level !ERRORLEVEL! for ffmpeg
	IF !ERRORLEVEL! NEQ 0 (
		endlocal
		:loop
		for /r "%UserDirectory%\Downloads\" %%f in (*.mkv) do (
			if not exist "%UserDirectory%\Videos\convert\%%~nf.mkv" (
				Set "Dir=%%f"
				Set "thename=%%~nf"
				Set "path=%%~dpf"

				:: Rename and cleanup name
				setlocal EnableDelayedExpansion
				Set "thename=!thename:_= !"
				Set "thename=!thename:.= !"
				Set "remove=f"
				Set "var="
				Set /a pos=0
				:NextChar
					Set tem=!thename:~%pos%,1!
					if "!tem!"=="[" (
						Set remove=t
					)
					if "!tem!"=="(" (
						Set remove=t
					)
					if "!remove!"=="f" (
						Set var=!var!!tem!
					)
					if "!tem!"==")" (
						Set remove=f
					)
					if "!tem!"=="]" (
						Set remove=f
					)
				set /a pos=pos+1
				if not "!thename:~%pos%,1!"=="" goto NextChar
				set /a pos=0
				set "thename=!var!"
				:check
				if "!thename:~0,1!"==" " (
					set "thename=!thename:~1!"
					goto :check
				)
				:check2
				if "!thename:~-1!"==" " (
					set "thename=!thename:~0,-1!"
					goto :check2
				)
		
				set "season=01"
				set "name=!thename!"
				for /f "delims=^" %%d in ("!thename!") do (echo %%d | %SystemRoot%\System32\findstr.exe /r /c:"S[0-9][0-9]*E[0-9][0-9]*">nul || (
						for %%d in (!thename!) do (set "episode=%%d" && echo %%d | %SystemRoot%\System32\findstr.exe /r /c:"S[0-9]">nul && (
								set "season=%%d"
								if "!season:~0,-1!"=="S" (
									set "season=0!season:S=!"
								)
								set "name=!thename: %%d=!"
							)
						)
						
						call set name=%%name:!episode!=%%

						echo !thename!
						set "thename=!name!S!season:S=!E!episode!"
						echo !thename!
					)
				)
				
				set "name="
				for %%a in (!thename!) do (
					set "name=!name! %%a"
					echo %%a | %SystemRoot%\System32\findstr.exe /r /c:"S[0-9][0-9]*E[0-9][0-9]">nul && (
						set "thename=!name:~1!"
						goto :done
					)
				)
				:done
				ren "!Dir!" "!thename!.mkv"
				
				:: Upscale 4k
				cd /d "%UserDirectory%\Documents\ffmpeg\bin"
				call ffmpeg -y -i "!path!!thename!.mkv" -init_hw_device "vulkan=vk:0" -vf libplacebo=w=3840:h=2160:upscaler=ewa_lanczos:force_original_aspect_ratio=decrease:custom_shader_path=shaders/Anime4K_ModeA.glsl,format=yuv420p -map 0 -c:v hevc_nvenc -cq 10 -bf 5 -refs 5 -preset p7 -c:a copy -sn "%UserDirectory%\Videos\convert\!thename!.mkv"
				set "counter=0"
				for /f "tokens=1 delims=," %%a in ('ffprobe -loglevel error -select_streams s -show_entries stream^=index:stream_tags^=language -of csv^=p^=0 "!path!!thename!.mkv" ^| C:\Windows\System32\findstr.exe "eng"') do (
					ffmpeg -y -i "!path!!thename!.mkv" -map 0:%%a -c:s ass "%UserDirectory%\ConvertedVideos\!thename!.default.eng.!counter!.utf8.ass"
					"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Command "Get-Content -Path '%UserDirectory%\ConvertedVideos\!thename!.default.eng.!counter!.utf8.ass' -Encoding UTF8 | Set-Content -Path '%UserDirectory%\ConvertedVideos\!thename!.default.eng.!counter!.ass' -Encoding utf8"
					del "%UserDirectory%\ConvertedVideos\!thename!.default.eng.!counter!.utf8.ass" /f /q /s
					set /a "counter+=1"
				)
				del "!path!!thename!.mkv" /f /q /s
				endlocal
				goto loop
			)
		)
		:: Cleanup empty folders
		cd /d "%UserDirectory%\Downloads\"
		for /f "delims=" %%d in ('dir /s /b /ad ^| sort /r') do rd "%%d"
		echo cleanup empty folders >> "%UserDirectory%\Documents\autoconvertlog.txt"
		echo cleanup empty folders

		:: Hybrid Selur to interpolate to 2x
		set "Name="
		for /r "%UserDirectory%\Videos\convert" %%d in (*.mkv) do (
			if exist %%d (
				call set "Name=%%Name%% "%%d""
			)
		)

		setlocal EnableDelayedExpansion
		echo starting Hybrid with !Name! >> "%UserDirectory%\Documents\autoconvertlog.txt"
		echo starting Hybrid with !Name!
		cd /d "C:\Program Files\Hybrid\"
		if not "!Name!"=="" (
			start Hybrid -global anime -autoAdd addAndStart !Name!
		)
		echo started Hybrid >> "%UserDirectory%\Documents\autoconvertlog.txt"
		echo started Hybrid 
		endlocal
		exit
	)
)
endlocal
exit