#!/bin/bash

# Check if a file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: 2pdf <file>"
    exit 1
fi

# Input file
file="$1"

# Ensure the file exists
if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found."
    exit 1
fi

# Extract the file extension
extension="${file##*.}"

# Set the input format
if [ "$extension" == "md" ]; then
    input_format="markdown"
else
    input_format="$extension"
fi

# Execute pandoc with the determined format
cat "$file" | pandoc -f "$input_format" -t pdf | zathura -

