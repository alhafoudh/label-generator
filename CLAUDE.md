# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Setup
- `bundle install` - Install Ruby dependencies

### Generate Labels
- `bundle exec thor label_generator:generate "QR_CONTENT" "LINE1" "LINE2" "LINE3"` - Generate a PDF label with QR code and 3 lines of text
- Output: Creates `label.pdf` and `label.html` (for debugging) in the project root
- Optional flags: `--width=57 --height=32 --padding=2.5` (dimensions in millimeters)

### Development
- Use `bundle exec` prefix for all Thor commands to avoid gem version conflicts
- `thor list` (without bundle exec) may fail due to Thor version mismatches

## Architecture

This is a Ruby CLI tool built with Thor that generates PDF labels with QR codes and text using Ferrum (headless Chrome) for PDF rendering.

### Key Components
- **label_generator.thor**: Main Thor CLI class containing the label generation logic
- **lib/html_label.rb**: Core label generation class that creates HTML templates and converts them to PDF
- **lib/label.html.erb**: ERB template for the HTML label layout
- **Gemfile**: Dependencies including Thor, Ferrum, RQRCode, ERB, and Zeitwerk

### Label Generation Process
1. Creates an HtmlLabel instance with QR content and 3 lines of text
2. Generates QR code as SVG using RQRCode gem
3. Renders HTML from ERB template with QR code and text
4. Uses Ferrum (headless Chrome) to convert HTML to PDF
5. Outputs to `label.pdf` (also saves `label.html` for debugging)

### Technical Details
- Uses Zeitwerk for auto-loading Ruby modules from lib/ directory
- QR codes are generated as SVG for crisp rendering at any size
- HTML layout uses CSS Grid for positioning QR code and text
- Label dimensions are customizable (default: 57x32mm with 2.5mm padding)
- PDF generation uses CSS page size for accurate dimensions
- Text is HTML-escaped for security using CGI.escapeHTML

### Command Usage
The updated command syntax requires 4 arguments:
- `bundle exec thor label_generator:generate "QR_CONTENT" "LINE1" "LINE2" "LINE3"`
- Optional flags: `--width=57 --height=32 --padding=2.5` (in millimeters)