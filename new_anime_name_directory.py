import anitopy
import argparse
import os
import re

def anime_files(anime_video):
    path, old_file_name = os.path.dirname(anime_video), os.path.basename(anime_video)
    parsed_data = anitopy.parse(old_file_name)

    file_extension, episode_number = parsed_data.get('file_extension'), parsed_data.get('episode_number')
    anime_title = str(parsed_data.get('anime_title')).replace(" - ", " ")
    # Handle case for movies
    if episode_number is None:
        new_file_name = anime_title
        new_directory = os.path.join("D:\\Movies", new_file_name)
    else:
        anime_season = f"{int(parsed_data.get('anime_season', 1)):02}"
        new_file_name = f"{anime_title} - S{anime_season}E{episode_number}"
        new_directory = os.path.join("D:\\Anime", anime_title, f"Season {anime_season}")
    
    os.makedirs(new_directory, exist_ok=True)
    return new_directory, new_file_name

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate new directory and file names for anime video files and their subtitles.")
    parser.add_argument("anime_video", type=str, help="Path to the anime video")
    args = parser.parse_args()

    new_directory, new_file_name = anime_files(args.anime_video)
    print(f"{new_directory}|{new_file_name}")
