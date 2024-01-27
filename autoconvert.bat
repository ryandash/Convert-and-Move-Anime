@echo off
@timeout /t 10 /nobreak

setlocal EnableDelayedExpansion
tasklist /fi "ImageName eq Hybrid.exe" /fo csv 2>NUL | find /I "Hybrid.exe">NUL
IF !ERRORLEVEL! NEQ 0 (
	tasklist /fi "ImageName eq ffmpeg.exe" /fo csv 2>NUL | find /I "ffmpeg.exe">NUL
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
						for %%d in (!thename!) do (echo %%d | %SystemRoot%\System32\findstr.exe /r /c:"S[0-9]">nul && (
								set "season=%%d"
								if "!season:~0,-1!"=="S" (
									set "season=0!season:S=!"
								)
								set "name=!thename: %%d=!"
							)
						)
					
						
						:again
						set "episode=!name:~-1!!episode!"
						set "name=!name:~0,-1!"
						
						if not "!name:- =0!"=="!name!" (
							goto again
						)
						set "episode=!episode:~1!"
						echo !thename!
						set "thename=!name: -=! - S!season:S=!E!episode!"
						echo !thename!
					)
				)
				ren "!Dir!" "!thename!.mkv"
				
				:: Upscale 4k
				cd /d "%UserDirectory%\Documents\ffmpeg\bin"
				call ffmpeg -y -i "!path!!thename!.mkv" -init_hw_device "vulkan=vk:0" -vf libplacebo=w=3840:h=2160:upscaler=ewa_lanczos:force_original_aspect_ratio=decrease:custom_shader_path=shaders/Anime4K_ModeA.glsl,format=yuv420p -map 0 -c:v hevc_nvenc -cq 10 -bf 5 -refs 5 -preset p7 -c:a copy -sn "%UserDirectory%\Videos\convert\!thename!.mkv"
				call ffmpeg -y -i "!path!!thename!.mkv" -c:s ass "%UserDirectory%\ConvertedVideos\!thename!.default.eng.ass"
				del "!path!!thename!.mkv" /f /q /s
				endlocal
				goto loop
			)
		)
		:: Cleanup empty folders
		cd /d "%UserDirectory%\Downloads\"
		for /f "delims=" %%d in ('dir /s /b /ad ^| sort /r') do rd "%%d"

		:: Hybrid Selur to interpolate to 2x
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
		endlocal
	)
)
endlocal