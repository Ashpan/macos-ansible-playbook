#!/bin/bash
# Script to export your current zshrc to the Ansible files directory

# Create directories if they don't exist
mkdir -p "files"

# Copy zshrc file
echo "Copying your current .zshrc file..."
cp "$HOME/.zshrc" "files/zshrc"

echo "Done! Your current .zshrc file has been exported to files/zshrc"
echo "This file will be used by the Ansible playbook to set up your shell environment."