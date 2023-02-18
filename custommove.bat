@echo off

For /r "%UserDirectory%\ConvertedVideos\" %%f IN (*.mkv) do (
	Set Dir=%%f
	Set thename=%%~nf
	setlocal EnableDelayedExpansion
	"%UserDirectory%\Documents\Recycle.exe" "%UserDirectory%\Videos\convert\!thename!.mkv"
	endlocal
	GOTO endloop
)
:endloop
setlocal EnableDelayedExpansion
Set thename=!thename:_= !
Set "newName="
Set remove=f
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
Set thename=!var!

:check
if "!thename:~0,1!"==" " (
	set thename=!thename:~1!
	goto :check
)
:check2
if "!thename:~-1!"==" " (
	set thename=!thename:~0,-1!
	goto :check2
)
ren "!Dir!" "!thename!.mkv"
set "Dir=%UserDirectory%\ConvertedVideos\!thename!.mkv"
set "name="

if not "!thename:- =0!"=="!thename!" (
	:again
	set thename=!thename:~0,-1!
	if not "!thename: -=0!"=="!thename!" (
		goto again
	)
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

if not "!newName!"=="~0,-1" (
	set "season="
	for %%d in (!newName!) do (echo %%d | findstr /r "S[0-9]">nul && (
		set "fullseason=%%d"
		set "season=\Season !fullseason:S=!"
		)
	)
	set Dir2=D:\Anime\!newName!!season!
	mkdir "!Dir2!"
	move /Y "!Dir!" "!Dir2!"
)

endlocal

cd /d D:/

if exist "%UserDirectory%\Downloads\*.mkv" (
	"%UserDirectory%\Documents\autoconvert.bat"
)

if exist "%UserDirectory%\ConvertedVideos\*.mkv" (
	"%UserDirectory%\Documents\custommove.bat"
)

exit