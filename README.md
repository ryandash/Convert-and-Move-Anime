# Convert-and-Move-Anime
Upscale anime to 4k using ffmpeg with anime4k shaders, 48fps using rife in vapoursynth, and moving the anime into proper subfolders to allow Plex or Jellyfin to auto add the anime.

Requires `pip install anitopy` for python script to work

## Script autoconvert.bat
(Given an anime video, upscale and convert the anime to 4k 48fps)
- use python script to extract anime title using anitopy
- make a full path directory and create the necessary folders for Jellyfin or Plex using python
- use ffmpeg with vapoursynth script to upscale to 4k and interpolate to 48fps outputting as an mp4 file
- clean up downloads by deleting all empty folders
-----------------------------------------------

## Script custommove.bat + move_anime.py
(Given a filename with a lot of unnecessary information and potentially season information, clean up the filename, extract season number, create season folder, rename videos, and move file into either anime folder or season folder in the anime folder)
#### Final result:
    [Anime Folder]
	    [Season]
	        [anime mkv file]
		[anime subtitle files]
#### Extract:
  - anime's name for directory path and filename in python
  - season number for season subfolder in python
  - subtitles
-----------------------------------------------

## Scripts can be simplified and improved but should work as is for common downloaded anime episodes **WITH** changes to directory information.
The variable `%UserDirectory%` can be changed to the `%UserProfile%` path on windows which is the common location for documents and downloads.
Suggestions on how to improve the scripts are welcome and appreciated, but I rarely visit this repository so do not expect any quick responses.
-----------------------------------------------

## Things to Download:
  - [Vapoursynth](https://www.vapoursynth.com/doc/installation.html)
    
    Vapoyrsynth Plugin for RIFE tensorrt (script is made for NVIDIA gpu)
      - [vsmlrt-windows-x64-tensorrt](https://github.com/AmusementClub/vs-mlrt/releases)
  - [FFmpeg](https://ffmpeg.org/download.html)
  - [Python](https://www.python.org/downloads/)
  - Anime4k shaders can be downloaded from repository or directly from [Anime4k](https://github.com/bloc97/Anime4K) (Shaders in repository are the original anime4k shaders merged together into 1 file for each mode for simplicity)
