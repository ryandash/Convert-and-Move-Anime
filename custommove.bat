@echo off
@timeout /t 2 /nobreak
:loop
For /r "%UserDirectory%\ConvertedVideos\" %%f IN (*.mp4, *.mkv, *.webm) do (
	Set "Dir=%%f"
	Set "thename=%%~nf"
	Set "subASS=%%~dpnf.default.eng.ass"
	set "name="
	setlocal EnableDelayedExpansion
        echo moving !thename!
	del "%UserDirectory%\Videos\convert\!thename!.mkv" /f /q /s
	
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
	
	set "season="
	for /f "delims=SE, tokens=1" %%d in ("!seasonEpisode!") do (
		set "season=%%d"
	)
	set "Dir2=D:\Anime\!newName!\Season !season!"
	echo !Dir2!
	mkdir "!Dir2!"
	move /Y "!subASS!"  "!Dir2!"
	move /Y "!Dir!" "!Dir2!"
	endlocal
	goto loop
)
echo finished moving videos
@timeout /t 5 /nobreak
start cmd.exe /c "D:\Ryan\Documents\cleanup subtitles and folders.bat"
start cmd.exe /c "D:\Ryan\Documents\autoconvert.bat"
echo finished calling other batch files
exit