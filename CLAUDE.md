# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Setup
- `bundle install` - Install Ruby dependencies

### Generate Labels
- `bundle exec thor label_generator:generate "TEXT"` - Generate a PDF label with the specified text
- Output: Creates `label.pdf` in the project root

### Development
- Use `bundle exec` prefix for all Thor commands to avoid gem version conflicts
- `thor list` (without bundle exec) may fail due to Thor version mismatches

## Architecture

This is a Ruby CLI tool built with Thor that generates PDF labels using HexaPDF.

### Key Components
- **label_generator.thor**: Main Thor CLI class containing the label generation logic
- **Gemfile**: Dependencies including Thor, Ferrum, Zeitwerk, and Pry
- **lib/**: Directory for additional Ruby modules (currently empty, loaded via Zeitwerk)

### Label Generation Process
1. Creates a new HTML document
2. Adds a page with specific dimensions (57x32mm)
3. Renders PDF using ferrum
4. Outputs to `label.pdf`

### Technical Details
- Uses Zeitwerk for auto-loading from lib/ directory
- PDF dimensions are converted from millimeters to points (72 DPI)
- Label size is fixed at 57x32mm (typical address label size)