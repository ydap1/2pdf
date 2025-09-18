
---

# 2pdf 

Simple bash script that allows you to easily convert a file into a PDF format using `pandoc` and view it with `zathura`.

## Features

- Converts files from all [formats](https://pandoc.org/MANUAL.html#general-options) supported by pandoc to PDF to be viewed in zathura.
- Uses `pandoc` for document conversion and `zathura` for viewing the output PDF.

## Installation

### Prerequisites

Make sure you have the following installed on your system:

- **pandoc**  
- **zathura**  
- **zathura-pdf-mupdf**
- [texlive](https://www.tug.org/texlive/quickinstall.html)
- (optional) [shc](https://github.com/neurobin/shc) 

### Installing the Script

1. Clone the repo:

   ```bash
   git clone https://github.com/ydap1/2pdf.git
   cd 2pdf
   ```

2. Make the script executable:

   ```bash
   chmod +x 2pdf.sh
   ```

3. Copy the script to `/usr/local/bin` to make it globally accessible:

   ```bash
   sudo cp 2pdf.sh /usr/local/bin/2pdf
   ```

Now you can run the script by simply typing `2pdf <file>` in your terminal.
