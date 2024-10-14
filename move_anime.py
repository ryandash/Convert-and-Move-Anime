import anitopy
import argparse
import os
import shutil
import re

def anime_files(anime_video):
    path, old_file_name = os.path.dirname(anime_video), os.path.basename(anime_video)
    parsed_data = anitopy.parse(old_file_name)

    file_extension = parsed_data.get('file_extension')
    anime_title = parsed_data.get('anime_title')
    episode_number = parsed_data.get('episode_number')
    
    # Handle case for movies
    if episode_number is None:
        new_file_name = anime_title
        new_directory = os.path.join("D:\\Movies", anime_title)
    else:
        anime_season = f"{int(parsed_data.get('anime_season', 1)):02}"
        new_file_name = f"{anime_title} - S{anime_season}E{episode_number}"
        new_directory = os.path.join("D:\\Anime", anime_title, f"Season {anime_season}")
    
    # Create the new directory if it doesn't exist
    os.makedirs(new_directory, exist_ok=True)

    if os.path.exists(anime_video):
        # Rename and move the video file
        new_file = os.path.join(new_directory, f"{new_file_name}.{file_extension}")
        shutil.move(anime_video, new_file)
        print(f"Moved: {new_file_name} to {new_file}")

    # Regular expression to capture subtitle number (e.g., "0.ass", "1.ass")
    subtitle_number_regex = re.compile(r'(\d+)\.ass$')

    # Move and rename subtitle files
    for root, _, files in os.walk(path):
        for file in files:
            file_path = os.path.join(root, file)

            print(file + " ends with ass " + str(file.endswith(".ass")))

            # Check if it's a subtitle file with extension ".ass"
            if file.endswith(".ass"):
                print(file + " has match " + str(subtitle_number_regex.search(file)))
                # Match subtitle number
                match = subtitle_number_regex.search(file)
                if match:
                    subtitle_number = match.group(1)  # Extract subtitle number (e.g., "0" or "1")
                    
                    # Create the new subtitle file name, preserving subtitle number
                    new_subtitle_name = f"{new_file_name}.default.eng.{subtitle_number}.ass"
                    new_subtitle_path = os.path.join(new_directory, new_subtitle_name)

                    # Rename and move subtitle file
                    shutil.move(file_path, new_subtitle_path)  # Use shutil.move for both rename and move
                    print(f"Moved: {file_path} to {new_subtitle_path}")
                    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Move anime video files and their subtitles to organized directories.")
    parser.add_argument("anime_video", type=str, help="Path to the anime video")
    args = parser.parse_args()

    anime_files(args.anime_video)
