# Convert-and-Move-Anime
Upscale anime to 4k using ffmpeg and anime4k filters, convert to 48fps using [hybrid from selur](https://www.selur.de/downloads), and moving the anime into proper subfolders to allow plex to auto add the anime with proper seasons

### If you would like to replicate my scripts, links to all the downloads necessary are below in [Things to Download](https://github.com/ryandash/Convert-and-Move-Anime?tab=readme-ov-file#things-to-download) section and run `pip install anitopy` before trying any batch files. [Anitopy python](https://github.com/igorcmoura/anitopy) is used to get the title name, season, and episode.

## Script autoconvert.bat + rename_anime.py
(Given an anime video, upscale and convert the anime to 4k 48fps)
#### First half (use ffmpeg for 4k upscale)
- Use timeouts to avoid trying to convert partially copied anime from another script.
- Rename anime to a consistent naming scheme
#### Get Anime file information using Antimony Python:
- Format to: ([anime name] - S[season]E[episode number])
- Use ffmpeg to upscale anime with anime4k shaders and copy over all subtitles, audio streams, and attachements
- clean up by deleting all unnecessary empty folders left in downloads
#### Second half (to use hybrid to convert to 48fps)
- clean up downloads by deleting all empty folders
- create a variable with 1 string containing all anime full directories
- use hybrid script to convert anime from 23.976 fps (~24 fps) to 47.952 fps (~48 fps)
-----------------------------------------------

## Script custommove.bat + move_anime.py
(Given a filename with a lot of unnecessary information and potentially season information, clean up the filename, extract season number, create season folder, and move file into either anime folder or season folder in the anime folder)
#### Final result:
    [Anime Folder]
	    [Season]
	        [anime mkv file]
		    [anime subtitle files]
#### Extract:
  - anime's name without season number for folder name
  - season number for season subfolder
  - subtitles
-----------------------------------------------
  
## Scripts can be simplified and improved but should work as is for common downloaded anime episodes **WITH** changes to directory information.
The variable `%UserDirectory%` can be changed to the `%UserProfile%` path on windows which is the common location for documents and downloads.
Suggestions on how to improve the scripts are welcome and appreciated but I rarely visit this repository so do not expect any quick responses.
-----------------------------------------------

## Things to Download:
  - [Hybrid from selur](https://www.selur.de/downloads)
  - [FFmpeg](https://ffmpeg.org/download.html)
  - [Python](https://www.python.org/downloads/)
  - Anime4k shaders can be downloaded from repository or directly from [Anime4k](https://github.com/bloc97/Anime4K) (Shaders in respository are the original anime4k shaders merged together into 1 file for each mode for simplicity)
