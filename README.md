# Mac Setup Automation with Ansible

This repository contains Ansible playbooks and roles to automate the setup of a new Mac with applications, system preferences, shell configuration, and more.

## Features

This automation handles:

- **Homebrew**: Installation and package management
- **Mac App Store**: App installation via the `mas` CLI
- **macOS Settings**: System preferences and defaults
- **Karabiner-Elements**: Custom keyboard configuration
- **Oh My Zsh**: Shell setup with plugins and configuration
- **Rust**: Installation of Rust programming language and Cargo
- **Java Environment**: Setup with jEnv for managing multiple Java versions
- **Directory Structure**: Organized by role for easy maintenance

## Prerequisites

- macOS (tested on macOS Sonoma)
- Git (to clone this repository)
- Basic command line knowledge

## Zero to Configured

If you want to run this all in 1 go, you can run
```bash
curl -fsSL https://gist.githubusercontent.com/Ashpan/8d8dab5122d905d6a055a4eb6d214b8e/raw/aeda95195617fd6c72f42bc73cf3a2e61424e26a/script.sh | bash
```

## Getting Started

### 1. Clone this repository

```bash
git clone git@github.com:Ashpan/macos-ansible-playbook.git mac-setup
cd mac-setup
```

### 2. Export your current configurations (optional)

If you want to use your current settings:

```bash
# Export macOS settings
./export-macos-settings.sh

# Export your zshrc
./export-zshrc.sh

# Export Karabiner configuration
./migrate-karabiner-config.sh
```

### 3. Review and customize

- Edit `group_vars/all.yml` to customize which packages to install
- Modify any of the exported settings if needed

### 4. Run the playbook

```bash
# Full setup
ansible-playbook -i inventory.yml playbook.yml -K

# Or run specific tags
ansible-playbook -i inventory.yml playbook.yml -K --tags homebrew,zsh
```

The `-K` flag will prompt for your sudo password, which is required for some operations.

## Available Tags

Run specific parts of the setup using tags:

- `homebrew`: Install Homebrew and packages
- `mas`: Install Mac App Store applications
- `macos`: Configure macOS settings
- `karabiner`: Set up Karabiner-Elements configuration
- `zsh`: Configure Oh My Zsh and shell environment
- `rust`: Install Rust and Cargo
- `jenv`: Install jEnv and configure Java environments



Example:
```bash
ansible-playbook -i inventory.yml playbook.yml -K --tags macos
```

## Project Structure

```
mac-setup/
├── bootstrap.sh                 # Bootstrap script for new Macs
├── playbook.yml                 # Main playbook file
├── inventory.yml                # Inventory file
├── group_vars/
│   └── all.yml                  # Variables for all groups
├── files/                       # Static files to be copied
│   ├── zshrc                    # Your zsh configuration
│   └── karabiner.json           # Your Karabiner configuration
├── roles/
│   ├── homebrew/                # Homebrew installation and packages
│   ├── mas/                     # Mac App Store applications
│   ├── macos/                   # macOS settings
│   ├── karabiner/               # Karabiner-Elements configuration
│   ├── zsh/                     # Oh My Zsh setup
│   ├── rust/                    # Rust programming language setup
│   └── jenv/                    # Java environment manager setup
├── export-macos-settings.sh     # Script to export macOS settings
├── export-zshrc.sh              # Script to export zshrc
└── migrate-karabiner-config.sh  # Script to export Karabiner config
```

## Customization

### Homebrew Packages

Edit `group_vars/all.yml` to modify the lists of packages to install:

```yaml
brew_packages:
  - git
  - jq
  # Add more packages here

brew_cask_packages:
  - brave-browser
  - visual-studio-code
  # Add more cask packages here
```

### Mac App Store Applications

Edit the `mas_packages` section in `group_vars/all.yml`:

```yaml
mas_packages:
  - { id: 1352778147, name: "Bitwarden" }
  # Add more App Store apps with their IDs
```

### macOS Settings

Either use the exported settings from `export-macos-settings.sh` or modify the direct settings in `roles/macos/tasks/direct_commands.yml`.

### Shell Configuration

Modify `files/zshrc` to customize your shell environment.

## Transferring Settings Between Macs

1. **Export settings** from your source Mac:
   ```bash
   ./export-macos-settings.sh
   ./export-zshrc.sh
   ./migrate-karabiner-config.sh
   ```

2. **Copy the exported files** to your target Mac's repository:
   ```
   roles/macos/vars/exported_settings.yml
   files/zshrc
   files/karabiner.json
   ```

3. **Run the playbook** on your target Mac.

## Troubleshooting

### Homebrew
- If Homebrew fails to install, try installing it manually first
- For package installation failures, try installing the problematic package manually

### macOS Settings
- Some settings may require logging out and back in
- If a setting doesn't apply, try running the command manually in Terminal

### Oh My Zsh
- If plugins aren't loading, check that they're properly installed in the Oh My Zsh plugins directory
- For NVM issues, try sourcing your `.zshrc` manually

### Java/jEnv Issues
- If Java versions aren't detected, try running `jenv add $(/usr/libexec/java_home)` manually
- Make sure to run `jenv enable-plugin export` to properly set JAVA_HOME

### Rust Issues
- If Rust doesn't install correctly, try running the rustup script manually:
  ```bash
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  ```
- Ensure `~/.cargo/bin` is in your PATH

## License

MIT

## Credits

Created by Ashpan Raskar
