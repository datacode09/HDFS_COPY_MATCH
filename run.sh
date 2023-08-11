#!/bin/bash

# Source and destination directories
src_dir="/dev/etl"
dest_dir="/qa/etl"

# Function to check if the source directory exists and has contents
check_source_directory() {
    if hdfs dfs -test -d "$src_dir" && [ "$(hdfs dfs -count -q "$src_dir" | awk '{print $2}')" -gt 0 ]; then
        return 0
    else
        echo "Source directory is empty or doesn't exist: $src_dir"
        return 1
    fi
}

# Function to create the destination directory if it doesn't exist
create_dest_directory() {
    if ! hdfs dfs -test -d "$dest_dir"; then
        hdfs dfs -mkdir -p "$dest_dir"
        echo "Created destination directory: $dest_dir"
    fi
}

# Function to compare contents of source and destination directories
compare_contents() {
    src_count=$(hdfs dfs -count -q "$src_dir" | awk '{print $2}')
    dest_count=$(hdfs dfs -count -q "$dest_dir" | awk '{print $2}')

    if [ "$src_count" -eq "$dest_count" ]; then
        echo "Contents in source and destination directories match."
    else
        echo "WARNING: Contents in source and destination directories do not match!"
    fi
}

# Main script
if check_source_directory; then
    create_dest_directory
    # Copy contents from source to destination
    hdfs dfs -cp "$src_dir"/* "$dest_dir"
    echo "Contents copied from $src_dir to $dest_dir"
    compare_contents
else
    echo "Aborted."
fi
