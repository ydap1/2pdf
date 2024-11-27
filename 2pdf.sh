#!/bin/bash

# Check if a file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: 2pdf <file>"
    exit 1
fi

# Extract the file extension
file="$1"
extension="${file##*.}"

# Ensure the file exists
if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found."
    exit 1
fi

# Map file extensions 
declare -A format_map=(
    [bibtex]="bibtex"
    [biblatex]="biblatex"
    [xml]="bits"
    [md]="commonmark,commonmark_x,markdown,markdown_mmd,markdown_phpextra,markdown_strict"
    [creole]="creole"
    [csljson]="csljson"
    [csv]="csv"
    [tsv]="tsv"
    [djot]="djot"
    [docx]="docx"
    [txt]="dokuwiki,tikiwiki,twiki,jira,vimwiki"
    [epub]="epub"
    [fb2]="fb2"
    [html]="html"
    [ipynb]="ipynb"
    [json]="json"
    [tex]="latex"
    [muse]="muse"
    [odt]="odt"
    [opml]="opml"
    [org]="org"
    [ris]="ris"
    [rtf]="rtf"
    [rst]="rst"
    [t2t]="t2t"
    [textile]="textile"
    [typ]="typst"
    [man]="man"
    [mw]="mediawiki"
    [hs]="native"
)

# Check if the file extension has a corresponding Pandoc format
if [[ -z "${format_map[$extension]}" ]]; then
    echo "Error: Unsupported file extension '$extension'."
    exit 1
fi

# Get the possible formats for the file extension
formats=(${format_map[$extension]//,/ })

# If there are multiple formats, prompt the user to choose
if [ ${#formats[@]} -gt 1 ]; then
    echo "Multiple formats are available for '$extension'. Please choose one:"
    PS3="Select format: "
    select format in "${formats[@]}"; do
        if [[ -n "$format" ]]; then
            pandoc_format="$format"
            break
        else
            echo "Invalid choice"
        fi
    done
else
    # If there's only one format, use it
    pandoc_format="${formats[0]}"
fi

# Execute the Pandoc command
cat "$file" | pandoc -f "$pandoc_format" -t pdf | zathura -

