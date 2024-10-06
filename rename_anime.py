import anitopy
import argparse
import os

def rename_anime_video(anime_video):
    directory, file_name = os.path.dirname(anime_video), os.path.basename(anime_video)
    parsed_data = anitopy.parse(file_name)

    file_extension = parsed_data.get('file_extension')
    anime_title = parsed_data.get('anime_title')
    episode_number = parsed_data.get('episode_number')
    
    # Handle case for movies
    if episode_number is None:
        new_file_name = anime_title
    else:
        anime_season = f"{int(parsed_data.get('anime_season', 1)):02}"
        new_file_name = f"{anime_title} - S{anime_season}E{episode_number}"
    print(new_file_name)

    # Rename the file
    os.rename(anime_video, os.path.join(directory, f"{new_file_name}.{file_extension}"))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Rename anime video files based on their titles.")
    parser.add_argument("anime_video", type=str, help="Path to the anime video")
    args = parser.parse_args()

    rename_anime_video(args.anime_video)
