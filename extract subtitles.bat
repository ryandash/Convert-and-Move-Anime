@echo off
:loop
for /r "%UserDirectory%\Downloads\" %%f in (*.mkv) do (
	Set "Dir=%%f"
	Set "thename=%%~nf"
	Set "newFileName=%%~nf"
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
	set "newFileName=!thename!"
	echo !thename!
	set "seasonEpisode="


	if not "!thename: -=0!"=="!thename!" (
		:again
		set "seasonEpisode=!thename:~-1!!seasonEpisode!"
		set "thename=!thename:~0,-1!"
		if not "!thename: -=0!"=="!thename!" (
			goto again
		)
		set "seasonEpisode=!seasonEpisode:~2!"
		set newName= !thename:episode= !
		echo !newName! main path
		goto recheck

	) else (
		:again2
		set /a varCheck = !thename:~0,1!
		if !varCheck!==0 (
			if not "!thename:~0,1!" =="0" (
				if not "!thename:~0,1!" =="" (
						set newName=!newName!!thename:~0,1!
						echo !newName! 2nd path
					set thename=!thename:~1!
					goto again2
				) else (
					goto recheck
				)
			) else (
				goto recheck
			)
		)
	)

	:recheck
	if "!newName:~0,1!"==" " (
		set newName=!newName:~1!
		goto recheck	
	)

	:recheck2
	if "!newName:~-1!"==" " (
		set newName=!newName:~0,-1!
		goto :recheck2
	)
	echo !newName!
	
	set "season="
	for /f "delims=SE, tokens=1" %%d in ("!seasonEpisode!") do (
		set "season=%%d"
	)
	set "Dir2=D:\Anime\!newName!\Season !season!\"
	mkdir "!Dir2!"
	cd /d "%UserDirectory%\Documents\ffmpeg\bin\"
	set "counter=0"
	for /f "tokens=1 delims=," %%a in ('ffprobe -loglevel error -select_streams s -show_entries stream^=index:stream_tags^=language -of csv^=p^=0 "!path!!newFileName!.mkv" ^| C:\Windows\System32\findstr.exe "eng"') do (
		ffmpeg -y -i "!path!!newFileName!.mkv" -map 0:%%a -c:s ass "!Dir2!!newFileName!.default.eng.!counter!.utf8.ass"
		"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Command "Get-Content -Path '!Dir2!!newFileName!.default.eng.!counter!.utf8.ass' -Encoding UTF8 | Set-Content -Path '!Dir2!!newFileName!.default.eng.!counter!.ass' -Encoding utf8"
		del "!Dir2!!newFileName!.default.eng.!counter!.utf8.ass" /f /q /s
		set /a "counter+=1"
	)
	
	move "!path!!newFileName!.mkv" "%UserDirectory%\Music\"
	
	endlocal
	goto loop
)
pause