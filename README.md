# Convert-and-Move-Anime
Upscale anime to 4k using mpv and anime4k filters, convert to 48fps using [hybrid from selur](https://www.selur.de/downloads), and move anime into proper subfolders to allow plex to auto add the anime with proper seasons

### To convert anime to 4k a custom version of mpv is used which can be found here: [ryandash mpv github](https://github.com/ryandash/mpv)
### Script contains the code I use to run mpv and upscale anime to 4k
### For more info on why I create a custom version of mpv [github discussion](https://github.com/mpv-player/mpv/issues/9589)
### If you would like to replicate my scripts, links to all the downloads necessary are below in [Downloads](https://github.com/ryandash/Convert-and-Move-Anime/blob/main/README.md#downloads) section

## Script autoconvert.bat
(Given an anime video, upscale and convert the anime to 4k 48fps)
#### First half (use mpv for 4k upscale)
- Use ffmpeg to extract width and height of anime
- use ffprobe to get first subtitle's codec type
- use ffmpeg to extract subtitle to file
- use mpv to upscale anime with anime4k shaders
- use mkvmerge to recombine 4k video with subtitles
- clean up by deleting all unnecessary files used in the process
- repeat for all anime in downloads
#### Second half (to use hybrid to convert to 48fps)
- clean up downloads by deleting all empty folders
- create a variable with 1 string containing all anime full directories
- use hybrid script to convert anime from 23.976 fps (~24 fps) to 47.952 fps (~48 fps)
-----------------------------------------------

## Script custommove.bat
(Given a filename with a lot of extra unnessary information and potentially season information, clean up the filename and extract season info)
#### Remove:
  - underlines between words
  - everything between round and square brackets (stuff to remove) and [stuff to remove]
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
  - To compile my version of mpv can be found here [ryandash mpv github](https://github.com/ryandash/mpv) (to compile mpv on windows I used these [instructions](https://github.com/mpv-player/mpv/blob/master/DOCS/compile-windows.md)
  - To download the pre-compiled mpv that I use you can [download from google drive](https://drive.google.com/file/d/17PnfYLlaqyvZ_UUko_riPqisM5gXHgRG/view?usp=share_link)
  - [Anime4k shaders](https://github.com/bloc97/Anime4K) (I used a command line that I put in the github discussion mentioned above to combine then, the combined versions can be found in the google drive download of mpv or in the discussion)
  - [Mkvmerge](https://mkvtoolnix.download/downloads.html#windows:~:text=repository%20directory%20yourself.-,Windows,-Download)
  - [Recycle](http://www.maddogsw.com/cmdutils/cmdutils.zip) (it is not necessary to send files to the recycle bin instead of deleting them permanently but I use it to avoid loosing files when I am making changes to the script. This is also an easy to use file that requires no install)
  
  
