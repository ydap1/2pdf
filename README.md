# 2pdf

Simple bash script to convert files to PDF using `pandoc` and view them with `zathura`.

## Features

- Converts files from all [formats supported by pandoc](https://pandoc.org/MANUAL.html#general-options) to PDF.
- Interactively picks a pandoc format when a file extension maps to several (e.g. `.md`, `.txt`).
- Opens the result directly in `zathura`, or saves it to a file with `-o`.

## Installation

### Prerequisites

- [pandoc](https://pandoc.org/installing.html)
- [zathura](https://pwmt.org/projects/zathura/) + [zathura-pdf-mupdf](https://pwmt.org/projects/zathura-pdf-mupdf/)
- [TeX Live](https://www.tug.org/texlive/quickinstall.html) (required by pandoc for PDF output)

### Setup

```bash
git clone https://github.com/ydap1/2pdf.git
cd 2pdf
chmod +x 2pdf.sh
sudo cp 2pdf.sh /usr/local/bin/2pdf
```

## Usage

```
2pdf [OPTIONS] <file>

Options:
  -o, --output <file>   Save the PDF to a file instead of opening the viewer
  -f, --format <fmt>    Pandoc input format (skips interactive selection)
  -h, --help            Show help
  -v, --version         Show version
```

### Examples

```bash
# View a Markdown file
2pdf notes.md

# View an HTML file
2pdf report.html

# Save to PDF instead of opening zathura
2pdf thesis.tex -o thesis.pdf

# Skip the format menu — useful in scripts or makefiles
2pdf notes.md -f markdown

# Works on headless systems (zathura not needed with -o)
2pdf report.rst -o report.pdf
```

## Supported Extensions

| Extension | Pandoc formats |
|-----------|---------------|
| `md`, `markdown` | commonmark, commonmark_x, markdown, markdown_mmd, markdown_phpextra, markdown_strict |
| `txt` | plain, dokuwiki, tikiwiki, twiki, jira, vimwiki |
| `html`, `htm` | html |
| `tex` | latex |
| `rst` | rst |
| `org` | org |
| `docx` | docx |
| `odt` | odt |
| `epub` | epub |
| `rtf` | rtf |
| `csv` | csv |
| `tsv` | tsv |
| `json` | json |
| `ipynb` | ipynb |
| `xml` | bits |
| `typ` | typst |
| `fb2` | fb2 |
| `man` | man |
| `mw`, `wiki` | mediawiki |
| `adoc`, `asciidoc` | asciidoc |
| `hs` | native |
| `djot` | djot |
| `opml` | opml |
| `muse` | muse |
| `ris` | ris |
| `t2t` | t2t |
| `textile` | textile |
| `creole` | creole |
| `csljson` | csljson |
| `bibtex` | bibtex |
| `biblatex` | biblatex |

## License

[MIT](LICENSE)
