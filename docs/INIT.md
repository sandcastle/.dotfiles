# Dotfiles Init System

## Overview

The init system handles **mandatory prerequisites** that must be installed before the dotfiles can be used. This runs automatically during the main installation.

## Structure

```
os/{platform}/
├── init.sh              # Runs all init apps in specific order
└── init/
    ├── app-homebrew.sh  # macOS: Install Homebrew
    ├── app-gum.sh       # Install Gum for pretty output
    └── app-git.sh       # Windows: Verify Git
```

## How It Works

1. **Main installer** (`install.sh`) detects OS
2. **Runs init.sh** (if it exists) before the main installation
3. **Init.sh** runs each `app-*.sh` script in a specific order
4. **Order matters** - dependencies must be installed first!

## Current Init Scripts

### macOS (`os/mac/init/`)

| Script | Purpose | Order |
|--------|---------|-------|
| `app-xcode-tools.sh` | Install Xcode Command Line Tools | 1st |
| `app-homebrew.sh` | Install Homebrew package manager | 2nd |

**Why this order:** Xcode tools are required to compile software, and Homebrew needs them.

### Omarchy (`os/omarchy/init/`)

| Script | Purpose |
|--------|---------|
| `app-gum.sh` | Install Gum for pretty terminal output |

### GCP Cloud Shell (`os/cloud-shell/init/`)

| Script | Purpose |
|--------|---------|
| `app-basic-tools.sh` | Ensure common tools (curl, wget, git, vim, tree) are installed |

### Windows (`os/windows/init/`)

| Script | Purpose |
|--------|---------|
| `app-git.sh` | Verify Git for Windows is properly installed |

**Note:** Windows init is environment-specific (Git Bash vs WSL)

## Creating New Init Scripts

### Template

```bash
#!/bin/bash
# {OS} init: {Description}

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="{App Name}"

section "Installing $APP_NAME"

# Check if already installed
if command -v {binary} &> /dev/null; then
    info "$APP_NAME is already installed"
    exit 0
fi

# Installation logic here
install_{package_manager} "{package}"

success "$APP_NAME installed successfully!"
```

### Adding to Init Order

Edit `os/{platform}/init.sh`:

```bash
# Define initialization order (apps will be installed in this order)
INIT_APPS=(
    "app-dependency.sh"    # Install this first!
    "app-main.sh"          # This depends on the above
)
```

## Init vs Install Apps

| | Init (`init/`) | Install (`install/`) |
|--|----------------|----------------------|
| **Required?** | Yes, mandatory | No, optional |
| **When?** | During first setup | On-demand via `apps install` |
| **Purpose** | Prerequisites | Additional tools |
| **Examples** | Homebrew, Xcode tools, Git | Docker, Node.js, Python |
| **Ran by** | `install.sh` automatically | `apps install <name>` manually |

## Running Init Manually

```bash
# Run all init scripts for current OS
bash ~/.dotfiles/os/$(detect_os)/init.sh

# Or specific OS
bash ~/.dotfiles/os/mac/init.sh
bash ~/.dotfiles/os/omarchy/init.sh
```
