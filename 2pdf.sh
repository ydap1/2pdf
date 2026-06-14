#!/bin/bash

VERSION="1.1.0"

usage() {
    cat <<EOF
Usage: 2pdf [OPTIONS] <file>

Convert a file to PDF using pandoc and view it with zathura.

Options:
  -o, --output <file>  Save the PDF to a file instead of opening the viewer
  -h, --help           Show this help message
  -v, --version        Show version information

Supported extensions:
  md, markdown, txt, html, htm, tex, rst, org, docx, odt, epub, rtf,
  csv, tsv, json, ipynb, xml, typ, man, mw, wiki, hs, djot, fb2, opml,
  muse, ris, t2t, textile, creole, csljson, bibtex, biblatex

Full pandoc format list: https://pandoc.org/MANUAL.html#general-options
EOF
}

output_file=""
input_file=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--version)
            echo "2pdf $VERSION"
            exit 0
            ;;
        -o|--output)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "Error: --output requires a file path." >&2
                exit 1
            fi
            output_file="$2"
            shift 2
            ;;
        -*)
            echo "Error: Unknown option '$1'. Run '2pdf --help' for usage." >&2
            exit 1
            ;;
        *)
            if [[ -n "$input_file" ]]; then
                echo "Error: Multiple input files provided. Only one file is supported." >&2
                exit 1
            fi
            input_file="$1"
            shift
            ;;
    esac
done

if [[ -z "$input_file" ]]; then
    usage
    exit 1
fi

# Dependency check
for cmd in pandoc zathura; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' is not installed or not in PATH." >&2
        exit 1
    fi
done

if [[ ! -f "$input_file" ]]; then
    echo "Error: File '$input_file' not found." >&2
    exit 1
fi

# Extract the file extension
filename="$(basename "$input_file")"
extension="${filename##*.}"
if [[ "$extension" == "$filename" ]]; then
    echo "Error: File '$input_file' has no extension." >&2
    exit 1
fi

declare -A format_map=(
    [bibtex]="bibtex"
    [biblatex]="biblatex"
    [xml]="bits"
    [md]="commonmark,commonmark_x,markdown,markdown_mmd,markdown_phpextra,markdown_strict"
    [markdown]="commonmark,commonmark_x,markdown,markdown_mmd,markdown_phpextra,markdown_strict"
    [creole]="creole"
    [csljson]="csljson"
    [csv]="csv"
    [tsv]="tsv"
    [djot]="djot"
    [docx]="docx"
    [txt]="plain,dokuwiki,tikiwiki,twiki,jira,vimwiki"
    [epub]="epub"
    [fb2]="fb2"
    [html]="html"
    [htm]="html"
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
    [wiki]="mediawiki"
    [hs]="native"
)

if [[ -z "${format_map[$extension]}" ]]; then
    echo "Error: Unsupported file extension '.$extension'." >&2
    echo "Run '2pdf --help' to see supported extensions." >&2
    exit 1
fi

IFS=',' read -ra formats <<< "${format_map[$extension]}"

if [[ ${#formats[@]} -gt 1 ]]; then
    echo "Multiple formats available for '.$extension'. Please choose one:"
    PS3="Select format: "
    select format in "${formats[@]}"; do
        if [[ -n "$format" ]]; then
            pandoc_format="$format"
            break
        else
            echo "Invalid choice. Try again."
        fi
    done
else
    pandoc_format="${formats[0]}"
fi

if [[ -n "$output_file" ]]; then
    pandoc "$input_file" -f "$pandoc_format" -t pdf -o "$output_file"
    status=$?
    if [[ $status -ne 0 ]]; then
        echo "Error: Conversion failed." >&2
        exit $status
    fi
    echo "PDF saved to '$output_file'."
else
    pandoc "$input_file" -f "$pandoc_format" -t pdf -o - | zathura -
    pandoc_status=${PIPESTATUS[0]}
    if [[ $pandoc_status -ne 0 ]]; then
        echo "Error: Conversion failed." >&2
        exit $pandoc_status
    fi
fi
