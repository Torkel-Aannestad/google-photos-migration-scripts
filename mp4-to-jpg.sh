#! /bin/bash

search_dir="./date_unknown_copy/date-unknown"

temp_work_dir="./date_unknown_copy/temp"
destination_dir="./after-format-convertion/from-mp4-renamed"
unprocessable_dir="./date_unknown_copy/no_mp4_date"

# Create the destination directory if it doesn't exist
mkdir -p "$temp_work_dir"
mkdir -p "$destination_dir"
mkdir -p "$unprocessable_dir"

# Delete files in destination_dir, temp_work_dir & unprocessable_dir
echo "Deleting files in temp_work_dir"
find $temp_work_dir -mindepth 1 -delete

echo "Deleting files in destination_dir"
find $destination_dir -mindepth 1 -delete

echo "Deleting files in unprocessable_dir"
find $unprocessable_dir -mindepth 1 -delete

echo "" 

process-mp4-to-jpg() {
  file=$1
  echo $file

  temp_work_dir="./date_unknown_copy/temp"
  destination_dir="./after-format-convertion/from-mp4-renamed"
  unprocessable_dir="./date_unknown_copy/no_mp4_date"

  #echo "Extracting: creation_time"
  creation_time=$(ffprobe -v quiet -print_format json -show_entries format_tags=creation_time ./date_unknown_copy/date-unknown/IMG_0085.MP4 | jq -r '.format.tags.creation_time')

  #echo "creation_time: ${creation_time}"

  if [ -z "$creation_time" ] || [ "$creation_time" = "null" ]; then
    echo "no creation_time: ${creation_time}"
    basename=$(basename "${file}")
    
    new_file=$(echo "${unprocessable_dir}/${basename}")
    
    cp "${file}" "${new_file}"
    exit 1
  fi


  # Converting to jpg
  #echo "Converting to jpg"
  basename=$(basename "${file}")
  basename_without_extension="${basename%.*}"
  formatted_time=$(echo "$creation_time" | awk -F'T' '{print $1}')
  new_file_name=$(echo "${formatted_time}_${basename_without_extension}.jpg")
  temp_file_path=$(echo "${temp_work_dir}/${new_file_name}")

  ffmpeg -loglevel quiet -i $file -vf "select=eq(n\,0)" -q:v 1 -frames:v 1 $temp_file_path -y

  if [ $? -ne 0 ]; then
    echo "ffmpeg failed for $new_file_name"
    exit 1
  fi

  # Adding -DateTimeOriginal to jpg
  #echo "Adding -DateTimeOriginal to jpg"
  exiftool -quiet -overwrite_original -DateTimeOriginal="${creation_time}" $temp_file_path

  if [ $? -ne 0 ]; then
    echo "find with -exec exiftool failed for $new_file_name"
    exit 1
  fi

  # Copy to destination_dir
  #echo "Copying to destination_dir"
  jpg_with_metadata="$destination_dir/$new_file_name"
  
  cp "$temp_work_dir/$new_file_name" "$jpg_with_metadata"
  rm $temp_file_path
  
   if [ $? -ne 0 ]; then
    echo "Copy failed"
    exit 1
  fi
}

# need to export function to give access to subprocess (parallel)
export -f process-mp4-to-jpg

# Find all mp4 files and process them
# files=$(find "$search_dir" -type f -iname '*.MP4')
# for file in $files; do #this works fine, but runs slowly
find "$search_dir" -type f -iname '*.MP4' | parallel -j 10 'process-mp4-to-jpg {}'