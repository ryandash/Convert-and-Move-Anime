# Convert-and-Move-Anime
Upscale anime to 4k using ffmpeg with anime4k shaders, 48fps using rife in vapoursynth, and moving the anime into proper subfolders to allow Plex or Jellyfin to auto add the anime.

## Script autoconvert.bat
(Given an anime video, upscale and convert the anime to 4k 48fps)
- use python script to extract anime title using anitopy
- make a full path directory and create the necessary folders for Jellyfin or Plex using python
- use ffmpeg with vapoursynth script to upscale to 4k and interpolate to 48fps outputting as an mp4 file
- clean up downloads by deleting all empty folders
-----------------------------------------------

#### Final result:
    [Anime Folder]
	    [Season]
	        [anime mp4 file]
		[anime subtitle files]
-----------------------------------------------

### Scripts can be simplified and improved but should work as is for common downloaded anime episodes **WITH** changes to directory information.
### The variable `%UserDirectory%` can be changed to the `%UserProfile%` path on windows which is the common location for documents and downloads.
### Suggestions on how to improve the scripts are welcome and appreciated, but I rarely visit this repository so do not expect any quick responses.
-----------------------------------------------

## Dependencies:
  - [VapourSynth](https://www.vapoursynth.com/doc/installation.html)
    VapourSynth Plugins to put in vs-plugins (script is made for NVIDIA gpu) (already included in repo)
      - [LSMASHSource](https://github.com/HomeOfAviSynthPlusEvolution/L-SMASH-Works/releases/)
      - [libvs_placebol](https://github.com/Lypheo/vs-placebo/releases)
      - [vs-miscfilter](https://github.com/vapoursynth/vs-miscfilters-obsolete/releases)
  - [FFmpeg](https://ffmpeg.org/download.html)
  - [Python](https://www.python.org/downloads/)
  - Anime4k shaders can be downloaded from repository or directly from [Anime4k](https://github.com/bloc97/Anime4K) (Shaders in repository are the original anime4k shaders merged together into 1 file for each mode for simplicity)

## Instructions:
1. Clone Repository
2. Move autoconvert.bat and new_anime_name_directory.py into Documents folder
3. Get vapoursynth portable into Documents folder
4. Get and extract vsmlrt-windows-x64-tensorrt into vs-plugins folder
4. If using basic Rife instead of drba_rife, get and extract vsmlrt-windows-x64-tensorrt into vs-plugins folder
5. Get and extract dll files for LSMASHSource, libvs_placebol, and vs-miscfilter into vs-plugins folder (already found in repo)
6. Download ffmpeg and extract bin folder contents to vapoursynth-portable folder
7. Download and install python (or use the python included with VapourSynth using `set "pythonPath=path to VapourSynth python"`)
8. Run `python -m pip install anitopy` in command line or navigate to VapourSynth python and run it there if pythonPath=path to VapourSynth python
9. In command line navigate to VapourSynth python and run `python -m pip install -U packaging setuptools wheel torch torchvision torch_tensorrt cupy-cuda12x vsdrba` to install the necessary packages
10. Navigate to Lib\site-packages\vsdrba in vapoursynth-portable and add a folder named models if it does not exist
11. Run `python -m vsdrba` in the vapoursynth-portable folder
12. Download an anime into your downloads folder
13. Add environment path variable UserDirectory=%UserProfile%
14. Run autoconvert.bat
