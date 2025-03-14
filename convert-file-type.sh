#move files
mv /mnt/c/Users/TorkelAannestad/Photos/torkel.aannestad@gmail.com/Torkel.aannestad@after-exif $HO
ME/projects/google-takeout-exif/photos-input

#Check if same number of files
find . -mindepth 1 -maxdepth 1 -type f | wc -l
(Get-ChildItems -File).count


# open image in windows
explorer.exe "$(wslpath -w after-format-convertion/from-mp4/IMG_0743.jpg)"


#HEIC

- find ./photos-input/Torkel.aannestad@after-exif/ALL_PHOTOS -type f -iname '\*.HEIC' | parallel -j 10 heif-convert {} after-format-convertion/from-heic/{/.}.jpg
  #- Note: -name "\*.HEIC" må være UTEN \ vs code legger denne til
  #- test: find . -type f -name 'IMG_3010.HEIC' #./IMG_3010.HEIC
  #- test2: heif-convert photos-input/Torkel.aannestad@after-exif/ALL_PHOTOS/IMG_3010.HEIC after-format-convertion/from-heic/IMG_3010.jpg
  #- Test3: find ./photos-input/Torkel.aannestad@after-exif/ALL_PHOTOS -type f -name 'IMG_3010.HEIC' | parallel -j 10 heif-convert {} after-format-convertion/from-heic/{/.}.jpg
  -Test4: find ./photos-input/Torkel.aannestad@after-exif/ALL_PHOTOS -type f -name '\*.HEIC' | wc -l # - gir 3035 resultater
## remove
find . -type f -name '*:apple:*' -exec rm {} \;

#PNG

- find ./photos-input/Torkel.aannestad@after-exif/ALL_PHOTOS -type f -iname '*.PNG' | parallel -j 20 ffmpeg -i {} -q:v 1 after-format-convertion/from-png/{/.}.jpg
  - test1: ffmpeg -i photos-input/Torkel.aannestad@after-exif/ALL_PHOTOS/IMG_3023.PNG -q:v 1 after-format-convertion/from-png/IMG_3023.jpg
# 192 PNG

# REMOVE HEIC & PNG from ALL_PHOTOS
# 5111 items i all_photos
find . -type f -iname '*.HEIC' -exec rm {} \;



#mp4
## Først hent ut dato og rename mp4 -> deretter converter
## Vi lager et script. Hent ut dato og converter og deretter bruk exif til å legge metadata tilbake. 
- Anta at alt i date_unknown er bilder og hent ut.
find ./photos-input/Torkel.aannestad@after-exif/ALL_PHOTOS/date-unknown -type f -iname '*.mp4' | parallel -j 10 'ffmpeg -i {} -vf "select=eq(n\,0)" -q:v 1 -frames:v 1 after-format-convertion/from-mp4/{/.}.jpg'

# filmer

- finn .MOV og .MP4 og flytt dem til egen mappe
