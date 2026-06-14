#!/bin/bash

VERSION="1.2.0"

usage() {
    cat <<EOF
Usage: 2pdf [OPTIONS] <file>

Convert a file to PDF using pandoc and view it with zathura.

Options:
  -o, --output <file>   Save the PDF to a file instead of opening the viewer
  -f, --format <fmt>    Pandoc input format (skips interactive selection)
  -h, --help            Show this help message
  -v, --version         Show version information

Supported extensions:
  md, markdown, txt, html, htm, tex, rst, org, docx, odt, epub, rtf,
  csv, tsv, json, ipynb, xml, typ, man, mw, wiki, hs, djot, fb2, opml,
  muse, ris, t2t, textile, creole, csljson, bibtex, biblatex, adoc, asciidoc

Full pandoc format list: https://pandoc.org/MANUAL.html#general-options
EOF
}

output_file=""
input_file=""
forced_format=""

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
            if [[ $# -lt 2 || -z "$2" ]]; then
                echo "Error: --output requires a file path." >&2
                exit 1
            fi
            output_file="$2"
            shift 2
            ;;
        -f|--format)
            if [[ $# -lt 2 || -z "$2" ]]; then
                echo "Error: --format requires a format name." >&2
                exit 1
            fi
            forced_format="$2"
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

# Skip zathura check when writing to a file — it's never invoked in that path
deps=(pandoc)
[[ -z "$output_file" ]] && deps+=(zathura)
for cmd in "${deps[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' is not installed or not in PATH." >&2
        exit 1
    fi
done

# Require at least one PDF engine
pdf_engines=(pdflatex xelatex lualatex wkhtmltopdf weasyprint pagedjs-cli tectonic)
found_engine=0
for engine in "${pdf_engines[@]}"; do
    if command -v "$engine" &>/dev/null; then
        found_engine=1
        break
    fi
done
if [[ $found_engine -eq 0 ]]; then
    echo "Error: No PDF engine found. Install one of:" >&2
    echo "  pdflatex / xelatex / lualatex  — via TeX Live (full quality)" >&2
    echo "  wkhtmltopdf                    — lightweight, HTML-based" >&2
    echo "  weasyprint                     — lightweight, Python-based" >&2
    echo "  pagedjs-cli                    — lightweight, Node.js-based" >&2
    echo "  tectonic                       — self-contained LaTeX engine" >&2
    exit 1
fi

if [[ ! -f "$input_file" ]]; then
    echo "Error: File '$input_file' not found." >&2
    exit 1
fi

if [[ -n "$forced_format" ]]; then
    pandoc_format="$forced_format"
else
    filename="$(basename "$input_file")"
    extension="${filename##*.}"
    if [[ "$extension" == "$filename" ]]; then
        echo "Error: File '$input_file' has no extension. Use --format to specify a pandoc format." >&2
        exit 1
    fi
    extension="${extension,,}"  # normalize to lowercase

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
        [adoc]="asciidoc"
        [asciidoc]="asciidoc"
    )

    # Use +set to distinguish "key absent" from "key present with empty value"
    if [[ -z "${format_map[$extension]+set}" ]]; then
        echo "Error: Unsupported file extension '.$extension'." >&2
        echo "Use --format to specify a pandoc format manually, or run '2pdf --help'." >&2
        exit 1
    fi

    IFS=',' read -ra formats <<< "${format_map[$extension]}"

    if [[ ${#formats[@]} -gt 1 ]]; then
        if [[ ! -t 0 ]]; then
            # Non-interactive: default to first format rather than hanging
            pandoc_format="${formats[0]}"
            echo "Non-interactive: using format '$pandoc_format'. Use --format to override." >&2
        else
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
            if [[ -z "$pandoc_format" ]]; then
                echo "Aborted." >&2
                exit 1
            fi
        fi
    else
        pandoc_format="${formats[0]}"
    fi
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
