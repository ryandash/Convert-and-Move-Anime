import anitopy
import argparse
import os
import shutil

def move_anime_files(anime_video):
    file_name = os.path.basename(anime_video)
    parsed_data = anitopy.parse(file_name)

    anime_title = parsed_data.get('anime_title')
    anime_season = parsed_data.get('anime_season')
    new_directory = os.path.join("D:\\Anime" if anime_season else "D:\\Movies", anime_title, f"Season {int(anime_season):02}" if anime_season else "")

    os.makedirs(new_directory, exist_ok=True)

    # Move files with anime videos name to new directory
    for root, _, files in os.walk(os.path.dirname(anime_video)):
        for file in files:
            # If anime video name without extension is in file name and the file does not exists in new directory
            if os.path.splitext(file_name)[0] in file and not os.path.exists(os.path.join(new_directory, file)):
                file_path = os.path.join(root, file)
                shutil.move(file_path, new_directory)
                print(f"Moved: {file_path} to {new_directory}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Move anime video files and their subtitles to organized directories.")
    parser.add_argument("anime_video", type=str, help="Path to the anime video")
    args = parser.parse_args()

    move_anime_files(args.anime_video)
