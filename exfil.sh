#!/bin/bash



#Determining Windows partition
echo "Preparing quick file Exfiltration... Stand by."
windows_partition=""
for partition in /media/kali/*; do
  if [ -d "$partition/Windows" ]; then
    windows_partition="$partition"
    break
  fi
done

#Determining destination partition.
destination_partition=""
for partition in /media/kali/*; do
  if [ "$partition" != "$windows_partition" ]; then
    destination_partition="$partition"
    break
  fi
done

#Checking if Windows partition was found
if [ -z "$windows_partition" ]; then
   echo "Error: Windows partition not found"
   exit 1
fi

#Checking if destination partition was found
if [ -z "$destination_partition" ]; then
   echo "Error: Destination partition not found"
   exit 1
fi

echo "Defining source and destination directories..."
source_dir="$windows_partition"
destination_dir="$destination_partition"
mkdir "$destination_dir/docs"
mkdir "$destination_dir/photos"

# Exfil document files
document_files=$(find "$source_dir" -type f \( -iname "*.doc" -o -iname "*.docx" -o -iname "*.pdf" -iname "*.xls" -o -iname "*.xlsx" \))

if [ -n "$document_files" ]; then
   echo "Copying document files..."
   IFS=$'\n' # Set the internal field separator to handle filenames with spaces correctly
   for file in $document_files; do
      cp --parents -r "$file" "$destination_dir/docs/"
   done
   echo "Document files exfiltrated. Proceeding to photos..."
else
   echo "No documents found"
fi

# Exfil photo files excluding images less than 15 KiB
picture_files=$(find "$source_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -size +100k)

if [ -n "$picture_files" ]; then
   echo "Copying photos..."
   IFS=$'\n' # Set the internal field separator to handle filenames with spaces correctly
   for file in $picture_files; do
      cp --parents -r "$file" "$destination_dir/photos/"
   done
   echo "Photos copied successfully. Exfil complete."
else
   echo "No eligible photos found. Exiting."
fi

exit 0"
