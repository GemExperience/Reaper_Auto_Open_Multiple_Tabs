#!/bin/bash

# Set the correct directory
cd "/Volumes/Mojave/Users/torbenscharling/Music/Jamtaba"

# Create the error log file if it doesn't exist
error_log_file="./error_log.txt"
touch "$error_log_file"

# Set up paths and filenames
log_file="./reaper_log.txt"
error_log_file="./error_log.txt"
processed_files_file="./processed_files.txt"
archive_zip_file="./Archive.zip"
skip_files_file="./skip_files.txt"

# Function to handle errors and log them to the error log file
function handle_error() {
  local error_message="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S'): Error: $error_message" >> "$error_log_file"
}

# Function to log messages to the log file
function log_message() {
  local message="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S'): $message" >> "$log_file"
}

# Check if the archive.zip file exists, create it if not
if [ ! -f "$archive_zip_file" ]; then
  touch "$archive_zip_file"
fi

# Set the maximum number of projects to process in one run
max_projects=15

# Initialize a counter for the number of projects processed in the current batch
num_projects_processed=0

# Loop through the files using find to match all .rpp files
find . -type f -name "*.rpp" | while read -r file; do
  # Check if the file should be skipped
  grep -qFx "$file" "$skip_files_file" && continue

  # Process the file
  log_message "Processing file: $file"

  # Check if the file exists before attempting to open it
  if [ -f "$file" ]; then
    # Check if the file is already in the list of processed files
    if ! grep -qFx "$file" "$processed_files_file"; then
      open -a "Reaper" "$file" || handle_error "Error opening the project file: $file"
      sleep 5 # Wait for 5 seconds before processing the next project
      echo "$file" >> "$processed_files_file"
      echo "$file" >> "$archive_zip_file"
      num_projects_processed=$((num_projects_processed + 1))

      # Check if the maximum number of projects has been processed in this batch
      if [ "$num_projects_processed" -ge "$max_projects" ]; then
        read -p "Processed 15 projects. Do you want to continue with the next batch? (y/n): " continue_processing
        if [ "$continue_processing" != "y" ]; then
          break
        fi
        num_projects_processed=0
      fi
    else
      handle_error "File already processed: $file"
    fi
  else
    handle_error "File not found: $file"
  fi

done

# Notify completion
log_message "Processing completed."
