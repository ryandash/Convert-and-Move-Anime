@echo off
@timeout /t 2 /nobreak
:loop
For /r "%UserDirectory%\ConvertedVideos\" %%f IN (*.mp4, *.mkv, *.webm) do (
	Set "Dir=%%f"
	Set "thename=%%~nf"
	Set "movieName=%%~dpnf"
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
		goto recheck

	) else (
		:again2
		set /a varCheck = !thename:~0,1!
		if !varCheck!==0 (
			if not "!thename:~0,1!" =="0" (
				if not "!thename:~0,1!" =="" (
					    set newName=!newName!!thename:~0,1!
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
	mkdir "!Dir2!"
	For /r "%UserDirectory%\ConvertedVideos\" %%f IN (*.ass) do (
		set "subFile=%%f"
		echo !subFile!
		if not "!subFile:%movieName%=!"=="!subFile!" (
		    move /Y "!subFile!"  "!Dir2!"
		)
	)
	move /Y "!Dir!" "!Dir2!"
	endlocal
	goto loop
)
echo finished moving videos
@timeout /t 10 /nobreak
cd /d "%UserDirectory%\Documents\"
start cmd.exe /c "cleanup subtitles and folders.bat"
start cmd.exe /c "autoconvert.bat"
exit