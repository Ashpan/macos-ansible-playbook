#!/bin/bash
# Script to export your current Karabiner-Elements configuration

# Create the directory structure
echo "Creating directory structure..."
mkdir -p mac-setup/files/complex_modifications

# Copy main configuration file
echo "Copying karabiner.json..."
cp ~/.config/karabiner/karabiner.json mac-setup/files/

# Check if complex modifications exist and copy them
if [ -d ~/.config/karabiner/assets/complex_modifications ]; then
  echo "Copying complex modifications..."
  cp ~/.config/karabiner/assets/complex_modifications/*.json mac-setup/files/complex_modifications/ 2>/dev/null || echo "No complex modifications found."
else
  echo "No complex modifications directory found."
fi

echo "Karabiner configuration migration complete."
echo "Files are stored in mac-setup/files/ directory."