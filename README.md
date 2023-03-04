# Convert-and-Move-Anime
<<<<<<< Updated upstream
Upscale anime to 4k using mpv and anime4k filters, convert to 48fps using [hybrid from selur](https://www.selur.de/downloads), and move anime into proper subfolders to allow plex to auto add the anime with proper seasons
=======
Upscale anime to 4k using ffmpeg and anime4k filters, convert to 48fps using [hybrid from selur](https://www.selur.de/downloads), and moving the anime into proper subfolders to allow plex to auto add the anime with proper seasons
>>>>>>> Stashed changes

### If you would like to replicate my scripts, links to all the downloads necessary are below in [Downloads](https://github.com/ryandash/Convert-and-Move-Anime/blob/main/README.md#downloads) section

## Script autoconvert.bat
(Given an anime video, upscale and convert the anime to 4k 48fps)
#### First half (use ffmpeg for 4k upscale)
- Use timeouts to avoid trying to convert partially copied anime from another script.
- Use ffmpeg to upscale anime with anime4k shaders
- clean up by deleting all unnecessary empty folders left in downloads
#### Second half (to use hybrid to convert to 48fps)
- clean up downloads by deleting all empty folders
- create a variable with 1 string containing all anime full directories
- use hybrid script to convert anime from 23.976 fps (~24 fps) to 47.952 fps (~48 fps)
-----------------------------------------------

## Script custommove.bat
(Given a filename with a lot of extra unnessary information and potentially season information, clean up the filename and extract season info)
#### Remove:
  - underlines between words
  - everything between round and square brackets e.g. (stuff to remove) and [stuff to remove]
  - dashes between words that are not between anime name and episode number
  - whitespaces at beginning and end of filename
     ##### goal is to have ([anime name] [season] - [episode number]) as the final result
 #### Extract:
  - filename without number for folder name
  - season number for subfolder season
-----------------------------------------------
  
## Scripts can be simplified and improved but should work as is for common downloaded anime episodes **WITH** changes to directory information. Suggestions on how to improve the scripts are welcome and appreciated but I will not be keeping an eye on this repository so do not expect any response to suggestions.
-----------------------------------------------

## Downloads:
  - [Hybrid from selur](https://www.selur.de/downloads)
  - [Ffmpeg](https://ffmpeg.org/download.html)
<<<<<<< Updated upstream
  - Custom mpv can be found here [ryandash mpv github](https://github.com/ryandash/mpv) ([instructions](https://github.com/mpv-player/mpv/blob/master/DOCS/compile-windows.md) I used to compile)
  - To download the pre-compiled mpv that I use you can [download from google drive](https://drive.google.com/file/d/17PnfYLlaqyvZ_UUko_riPqisM5gXHgRG/view?usp=share_link)
  - [Anime4k shaders](https://github.com/bloc97/Anime4K) (I used a command line that I put in the github discussion mentioned above to combine then, the combined versions can be found in the google drive download of mpv or in the discussion)
=======
  - Anime4k shaders can be downloaded from repository or directly from [Anime4k](https://github.com/bloc97/Anime4K) (Shaders in respository are the original anime4k shaders merged together into 1 file for simplicity)
>>>>>>> Stashed changes
  - [Mkvmerge](https://mkvtoolnix.download/downloads.html#windows:~:text=repository%20directory%20yourself.-,Windows,-Download)
  - [Recycle](http://www.maddogsw.com/cmdutils/cmdutils.zip) (it is not necessary to send files to the recycle bin instead of deleting them permanently but I use it to avoid loosing files when I am making changes to the script. This is also an easy to use file that requires no install)
  
  
