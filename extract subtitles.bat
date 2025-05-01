@echo off

for /f "delims=" %%a in ('where python') do set "pythonPath=%%a"
for /f "delims=" %%a in ('where powershell') do set "powershell=%%a"

cd /d "%UserDirectory%\Documents\ffmpeg\bin"
for /r "%UserDirectory%\Downloads\" %%f in (*.mkv) do (
	set "file=%%f"

	setlocal EnableDelayedExpansion
	for /f "tokens=1,2 delims=|" %%a in ('!pythonPath! "!UserDirectory!\Documents\new_anime_name_directory.py" "!file!"') do (
		endlocal
		set "newDirectory=%%a"
		set "newFileName=%%b"
		setlocal EnableDelayedExpansion
	)
	echo !newDirectory!
	echo !newFileName!
	
	set "filename_ps=!newFileName:[=`[!"
	set "filename_ps=!filename_ps:]=`]!"
	set "filename_ps=!filename_ps:'=''!"
	set "directory_ps=!newDirectory:[=`[!"
	set "directory_ps=!directory_ps:]=`]!"
	set "directory_ps=!directory_ps:'=''!"

	set "counter=0"
	for /f "tokens=1,2,3 delims=," %%a in ('ffprobe -loglevel error -select_streams s -show_entries stream^=index^,codec_name:stream_tags^=language -of csv^=p^=0 "!file!"') do (
		set "sub_index=%%a"
		set "codec=%%b"
		set "lang=%%c"
		echo !codec!

		if /I "!lang!"=="eng" (
			set "lang=default.eng"
		)

		REM Set extension and codec option
		set "codec_arg=-c:s copy"
		if /I "!codec!"=="hdmv_pgs_subtitle" (
			set "ext=sup"
		) else if /I "!codec!"=="dvd_subtitle" (
			set "ext=sub"
		) else if /I "!codec!"=="dvb_subtitle" (
			set "ext=sub"
		) else if /I "!codec!"=="xsub" (
			set "ext=sub"
		) else (
			set "ext=ass"
			set "codec_arg=-c:s ass"
		)

		set "outfile=!newDirectory!\!newFileName!.!lang!.!counter!.!ext!"

		REM Extract subtitle
		if /I "!ext!"=="ass" (
			set "utf8file=!outfile:.ass=.utf8.ass!"
			ffmpeg -y -i "!file!" -map 0:!sub_index! !codec_arg! "!utf8file!"
			!powershell! -Command "Get-Content -Path '!directory_ps!\!filename_ps!.!lang!.!counter!.utf8.ass' -Encoding UTF8 ^| Set-Content -Path '!directory_ps!\!filename_ps!.!lang!.!counter!.ass' -Encoding utf8"
			del "!utf8file!"
		) else (
			ffmpeg -y -i "!file!" -map 0:!sub_index! !codec_arg! "!outfile!"
		)

		set /a "counter+=1"
	)

	move "!file!" "%UserDirectory%\Music\"
	endlocal
)
pause