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
    shutil.move(anime_video, new_directory)

    # Move subtitle files
    converted_videos_dir = os.path.join(os.getenv('UserDirectory'), 'ConvertedVideos')
    print(converted_videos_dir)
    for root, _, files in os.walk(converted_videos_dir):
        for file in files:
            if file.endswith('.ass') and os.path.splitext(file_name)[0] in file:
                sub_file_path = os.path.join(root, file)
                shutil.move(sub_file_path, new_directory)
                print(f"Moved subtitle: {sub_file_path}")

    print(f"Moved video: {os.path.join(new_directory, file_name)}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Move anime video files and their subtitles to organized directories.")
    parser.add_argument("anime_video", type=str, help="Path to the anime video")
    args = parser.parse_args()

    move_anime_files(args.anime_video)
