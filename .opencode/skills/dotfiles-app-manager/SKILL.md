---
name: dotfiles-app-manager
description: >
  REQUIRED when adding new apps to the dotfiles repository or managing app install/uninstall scripts.
  Use when creating app-{name}.sh files in ~/.dotfiles/os/{platform}/install/ or uninstall/ folders.
  Triggers: apps install, apps uninstall, new app setup, multi-OS package installation scripts.
---

# Dotfiles App Manager Skill

Manage application installation and uninstallation scripts across multiple operating systems using a common library for code reuse.

## When This Skill MUST Be Used

**ALWAYS invoke this skill when the user's request involves ANY of these:**

- Creating a new app installation script in `~/.dotfiles/os/{platform}/install/`
- Creating a new app uninstallation script in `~/.dotfiles/os/{platform}/uninstall/`
- Modifying existing app-{name}.sh scripts
- Setting up package installation automation across multiple OSes
- Creating install/uninstall pairs for applications
- Adding apps that need to work on Omarchy, macOS, Cloud Shell, or Windows

## Architecture Overview

The dotfiles repository uses a **common library** (`lib/common.sh`) and **theme system** (`lib/theme.sh`) to avoid code duplication and maintain consistent visual styling:

```
~/.dotfiles/
├── go.sh                      # One-liner installer (root only)
├── lib/
│   ├── common.sh              # Shared functions for all OSes
│   └── theme.sh               # Color theme configuration
└── os/
    ├── install.sh             # Main entry point (detects OS)
    ├── _shared/                 # Cross-OS shared files
    │   └── home/
    │       └── .gitconfig       # Shared git config (symlinked to each OS)
    └── {platform}/
        ├── init.sh              # Initialize mandatory prerequisites
        ├── init/                # Init scripts (run in specific order)
        │   ├── app-homebrew.sh
        │   └── app-gum.sh
        ├── home/                # Dotfiles to symlink
        │   └── .gitconfig -> ../../_shared/home/.gitconfig
        ├── install.sh           # OS-specific dotfiles setup
        ├── install/             # App install scripts (optional)
        │   └── app-{name}.sh
        └── uninstall/           # App uninstall scripts
            └── app-{name}.sh
```

### Init vs Install

**Init (`init/`):**
- **Mandatory** prerequisites required before using dotfiles
- Run **once** during first setup (before `install.sh`)
- Examples: Homebrew (macOS), Git verification (Windows)
- Scripts named: `app-{name}.sh`
- Executed in specific order defined in `init.sh`

**Install (`install/`):**
- **Optional** apps users can install anytime via `apps install`
- Run on-demand via `apps install <name>`
- Examples: Docker, Node.js, Python, etc.
- Scripts named: `app-{name}.sh`

### Shared Files (`_shared/`)

Files that are identical across all OSes go in `os/_shared/`:

```
os/_shared/
└── home/
    └── .gitconfig          # Same git config for all OSes
```

**When to use _shared:**
- Configuration files that don't vary by OS (e.g., `.gitconfig`, `.bashrc` basics)
- Files that would otherwise be duplicated in each `os/{platform}/home/`

**Implementation:**
1. Place the file in `os/_shared/home/`
2. Create symlinks in each OS home folder: `ln -s ../../../_shared/home/.gitconfig`
3. The `symlink_all_dotfiles()` function will follow symlinks and create proper links in `~/`

**Example:** `.gitconfig` is stored in `os/_shared/home/.gitconfig` and symlinked from all OS home directories because git configuration is the same regardless of operating system.

### OS-Specific Variants (`.os` files)

When you need OS-specific additions to shared files, use the `.os` variant convention:

```
~/
├── .aliases          ← Symlinked from os/_shared/home/.aliases (shared)
├── .aliases.os       ← OS-specific additions (e.g., macOS shortcuts)
├── .aliases.local    ← Machine-specific (not tracked)
├── .exports          ← Symlinked from os/_shared/home/.exports (shared)
├── .exports.os       ← OS-specific environment variables
├── .functions        ← Symlinked from os/_shared/home/.functions (shared)
└── .functions.os     ← OS-specific functions
```

**How it works:**

The `.bashrc` sources files in this order:
1. **Base file** (from `_shared/`) - shared across all OSes
2. **`.os` variant** (from `os/{platform}/home/`) - OS-specific additions
3. **`.local` variant** (in `~/`) - machine-specific, not tracked

```bash
# From .bashrc
for file in ~/.{exports,aliases,functions}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"      # Base (shared)
  [ -r "$file.os" ] && [ -f "$file.os" ] && source "$file.os"  # OS-specific
  [ -r "$file.local" ] && [ -f "$file.local" ] && source "$file.local"  # Local
done
```

**When to use `.os` variants:**
- OS-specific aliases (e.g., `brew` commands on macOS)
- OS-specific environment variables (e.g., `HOMEBREW_*` on macOS)
- OS-specific functions (e.g., `gcloud` helpers on Cloud Shell)
- Platform-specific tool configurations

**Implementation:**
1. Shared base file goes in `os/_shared/home/.{aliases,exports,functions}`
2. OS-specific additions go in `os/{platform}/home/.{aliases,exports,functions}.os`
3. Files are sourced in order: base → .os → .local

### Common Library Functions

The `lib/common.sh` provides standardized functions:

- **Pretty Output:** `header()`, `section()`, `info()`, `success()`, `warn()`, `error()`, `spin()`
- **Interactive:** `confirm()`, `input()`, `choose()`, `filter()`
- **OS Detection:** `detect_os()`, `detect_windows_shell()`
- **Installation Checks:** `check_installed()`, `check_file_exists()`
- **Package Managers:** `install_pacman()`, `install_apt()`, `install_brew()`, `install_winget()`, etc.
- **Configuration:** `link_app_config()`, `remove_app_config()`
- **Backups:** `get_backup_dir()`, `backup_file()`, `symlink_all_dotfiles()`
- **Gum Integration:** `has_gum()`, `ensure_gum()`

### Theme System

Colors are defined in `lib/theme.sh` and automatically detected from the Omarchy theme:

**Default Colors:**
- `THEME_PRIMARY` (212) - Hot pink for headers
- `THEME_SECONDARY` (99) - Purple for sections
- `THEME_SUCCESS` (46) - Green for success
- `THEME_ERROR` (196) - Red for errors
- `THEME_WARNING` (208) - Orange for warnings
- `THEME_INFO` (240) - Gray for info

**Auto-detection:** If using Omarchy, the script reads your current theme (catppuccin, tokyo-night, nord, dracula) and adjusts colors automatically.

**Customization:** Create `~/.dotfiles-theme.sh` to override any color:
```bash
THEME_PRIMARY="117"  # Cyan
THEME_SUCCESS="120"  # Bright green
```

## Creating a New App

### Step 1: Check if app already exists

```bash
# Check all OS folders
for os in omarchy mac cloud-shell windows; do
    if [ -f "$HOME/.dotfiles/os/$os/install/app-{name}.sh" ]; then
        echo "Found in $os"
    fi
done
```

### Step 2: Create OS-specific install scripts

All scripts should source the common library and use its functions.

#### Omarchy (Arch Linux)

Path: `~/.dotfiles/os/omarchy/install/app-{name}.sh`

```bash
#!/bin/bash
set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="{AppName}"
PACKAGES="{package-name}"
BINARY="{binary-name}"
OS_NAME="Omarchy"

info "Installing $APP_NAME on $OS_NAME..."

# Check if already installed
if check_installed "$BINARY" "$APP_NAME"; then
    exit 0
fi

# Install: prefer pacman, fallback to yay
if check_pacman_package "$PACKAGES"; then
    install_pacman "$PACKAGES"
else
    install_yay "$PACKAGES"
fi

# Link configs if they exist
link_app_config "{app-name}" "omarchy"

success "$APP_NAME installed successfully on $OS_NAME!"
```

#### macOS

Path: `~/.dotfiles/os/mac/install/app-{name}.sh`

```bash
#!/bin/bash
set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="{AppName}"
BREW_FORMULA="{formula-name}"
BINARY="{binary-name}"
OS_NAME="macOS"

info "Installing $APP_NAME on $OS_NAME..."

# Check if already installed
if check_installed "$BINARY" "$APP_NAME"; then
    exit 0
fi

# Install via Homebrew
install_brew "$BREW_FORMULA"

# Link configs
link_app_config "{app-name}" "mac"

success "$APP_NAME installed successfully on $OS_NAME!"
```

#### GCP Cloud Shell

Path: `~/.dotfiles/os/cloud-shell/install/app-{name}.sh`

```bash
#!/bin/bash
set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="{AppName}"
APT_PACKAGES="{package-name}"
BINARY="{binary-name}"
OS_NAME="GCP Cloud Shell"

info "Installing $APP_NAME on $OS_NAME..."

# Check if already installed
if check_installed "$BINARY" "$APP_NAME"; then
    exit 0
fi

# Install via apt
install_apt "$APT_PACKAGES"

# Link configs
link_app_config "{app-name}" "cloud-shell"

success "$APP_NAME installed successfully on $OS_NAME!"
```

#### Windows (Git Bash / WSL)

Path: `~/.dotfiles/os/windows/install/app-{name}.sh`

```bash
#!/bin/bash
set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="{AppName}"
BINARY="{binary-name}"
OS_NAME="Windows"

info "Installing $APP_NAME on $OS_NAME..."

# Detect Windows environment
ENV=$(detect_windows_shell)
info "Detected environment: $ENV"

# Check if already installed
if check_installed "$BINARY" "$APP_NAME"; then
    exit 0
fi

# Install based on environment
case "$ENV" in
    git-bash)
        # Git Bash: Use winget or chocolatey
        WINGET_ID="{PackagePublisher.PackageName}"
        
        if command -v winget &> /dev/null; then
            install_winget "$WINGET_ID"
        elif command -v choco &> /dev/null; then
            install_choco "{choco-package-name}"
        else
            error "No package manager found (winget or chocolatey)"
            exit 1
        fi
        ;;
    wsl)
        # WSL: Use Linux package manager (apt or pacman)
        if command -v apt-get &> /dev/null; then
            install_apt "{apt-package-name}"
        elif command -v pacman &> /dev/null; then
            install_pacman "{pacman-package-name}"
        else
            error "No package manager found in WSL"
            exit 1
        fi
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

# Link configs
link_app_config "{app-name}" "windows"

success "$APP_NAME installed successfully on $OS_NAME ($ENV)!"
```

### Step 3: Install Bash Completions (Required)

**ALWAYS install bash completions** for tools that support them. This is a **mandatory** step for all app installations.

#### Why Completions Matter

- Tab-completion for commands, flags, and arguments
- Better user experience and discoverability
- Faster command-line workflow

#### How to Install Completions

Add this to the **end of every install script** after the tool is installed:

```bash
# Install bash completions (REQUIRED for all apps that support them)
info "Installing bash completions for $APP_NAME..."

# Check if tool supports completion generation
if $BINARY completion bash &>/dev/null; then
    # System-wide (preferred on Linux)
    if [[ -d "/usr/share/bash-completion/completions" ]]; then
        $BINARY completion bash | sudo tee /usr/share/bash-completion/completions/$BINARY > /dev/null
        success "Completions installed to /usr/share/bash-completion/completions/$BINARY"
    elif [[ -d "/etc/bash_completion.d" ]]; then
        $BINARY completion bash | sudo tee /etc/bash_completion.d/$BINARY > /dev/null
        success "Completions installed to /etc/bash_completion.d/$BINARY"
    else
        # User-local (preferred on macOS and restricted environments)
        mkdir -p "$HOME/.bash_completion.d"
        $BINARY completion bash > "$HOME/.bash_completion.d/$BINARY"
        success "Completions installed to ~/.bash_completion.d/$BINARY"
    fi
    
    # Ensure completion loader is in .bashrc
    if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
        echo '' >> "$HOME/.bashrc"
        echo '# Source bash completions' >> "$HOME/.bashrc"
        echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$HOME/.bashrc"
    fi
else
    # Tool doesn't support completion generation
    # Check if package installed completions automatically
    info "Checking for system completions..."
    if [[ ! -f "/usr/share/bash-completion/completions/$BINARY" ]] && \
       [[ ! -f "/etc/bash_completion.d/$BINARY" ]] && \
       [[ ! -f "$HOME/.bash_completion.d/$BINARY" ]]; then
        warn "No completion support found for $APP_NAME"
        warn "This is acceptable if the tool doesn't support bash completions"
    fi
fi
```

#### Completion Installation Priority

1. **System-wide** (Linux): `/usr/share/bash-completion/completions/` or `/etc/bash_completion.d/`
   - Available to all users
   - Loaded automatically by bash-completion
   - Requires sudo

2. **User-local** (macOS, restricted environments): `~/.bash_completion.d/`
   - Only for current user
   - Requires sourcing loop in `~/.bashrc`
   - No sudo required

#### Tools That Need Completions

Common tools that support `completion bash`:
- `mise completion bash`
- `gum completion bash`
- `kubectl completion bash`
- `docker completion bash`
- `helm completion bash`
- `aws completion bash` (via aws-cli)
- `gcloud completion bash`

**Check if a tool supports completions:**
```bash
$BINARY completion bash --help 2>/dev/null && echo "Supports completions" || echo "No completion support"
```

### Step 4: Create OS-specific uninstall scripts

#### Omarchy

Path: `~/.dotfiles/os/omarchy/uninstall/app-{name}.sh`

```bash
#!/bin/bash
set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="{AppName}"
PACKAGES="{package-name}"
BINARY="{binary-name}"
OS_NAME="Omarchy"

info "Uninstalling $APP_NAME from $OS_NAME..."

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

# Uninstall
uninstall_pacman "$PACKAGES"

# Optional: Remove configs with --purge flag
if [ "$1" = "--purge" ]; then
    info "Removing $APP_NAME configuration files..."
    remove_app_config "{app-name}"
fi

success "$APP_NAME uninstalled successfully from $OS_NAME!"
```

#### macOS

Path: `~/.dotfiles/os/mac/uninstall/app-{name}.sh`

```bash
#!/bin/bash
set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="{AppName}"
BREW_FORMULA="{formula-name}"
BINARY="{binary-name}"
OS_NAME="macOS"

info "Uninstalling $APP_NAME from $OS_NAME..."

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

# Uninstall via Homebrew
uninstall_brew "$BREW_FORMULA"

# Optional: Remove configs with --purge flag
if [ "$1" = "--purge" ]; then
    info "Removing $APP_NAME configuration files..."
    remove_app_config "{app-name}" "${HOME}/Library/Application Support/{app-name}"
fi

success "$APP_NAME uninstalled successfully from $OS_NAME!"
```

#### GCP Cloud Shell

Path: `~/.dotfiles/os/cloud-shell/uninstall/app-{name}.sh`

```bash
#!/bin/bash
set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="{AppName}"
APT_PACKAGES="{package-name}"
BINARY="{binary-name}"
OS_NAME="GCP Cloud Shell"

info "Uninstalling $APP_NAME from $OS_NAME..."

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

# Uninstall via apt
uninstall_apt "$APT_PACKAGES"

# Optional: Remove configs with --purge flag
if [ "$1" = "--purge" ]; then
    info "Removing $APP_NAME configuration files..."
    remove_app_config "{app-name}"
fi

success "$APP_NAME uninstalled successfully from $OS_NAME!"
```

#### Windows (Git Bash / WSL)

Path: `~/.dotfiles/os/windows/uninstall/app-{name}.sh`

```bash
#!/bin/bash
set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="{AppName}"
BINARY="{binary-name}"
OS_NAME="Windows"

info "Uninstalling $APP_NAME from $OS_NAME..."

# Detect Windows environment
ENV=$(detect_windows_shell)
info "Detected environment: $ENV"

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

# Uninstall based on environment
case "$ENV" in
    git-bash)
        WINGET_ID="{PackagePublisher.PackageName}"
        
        if command -v winget &> /dev/null; then
            uninstall_winget "$WINGET_ID"
        elif command -v choco &> /dev/null; then
            uninstall_choco "{choco-package-name}"
        else
            error "No package manager found"
            exit 1
        fi
        ;;
    wsl)
        if command -v apt-get &> /dev/null; then
            uninstall_apt "{apt-package-name}"
        elif command -v pacman &> /dev/null; then
            uninstall_pacman "{pacman-package-name}"
        else
            error "No package manager found in WSL"
            exit 1
        fi
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

# Optional: Remove configs with --purge flag
if [ "$1" = "--purge" ]; then
    info "Removing $APP_NAME configuration files..."
    remove_app_config "{app-name}"
fi

success "$APP_NAME uninstalled successfully from $OS_NAME ($ENV)!"
```

### Step 4: Make all scripts executable

```bash
#!/bin/bash

# Make all install/uninstall scripts executable
for os in omarchy mac cloud-shell windows; do
    for script in "$HOME/.dotfiles/os/$os/install/app-"*.sh; do
        [ -f "$script" ] && chmod +x "$script"
    done
    for script in "$HOME/.dotfiles/os/$os/uninstall/app-"*.sh; do
        [ -f "$script" ] && chmod +x "$script"
    done
done

echo "Made all app scripts executable!"
```

## Common Library Reference

### Logging Functions

```bash
info "Message"      # [INFO] Message
error "Message"     # [ERROR] Message (to stderr)
success "Message"   # [✓] Message
```

### Package Manager Functions

| Function | Purpose | Parameters |
|----------|---------|------------|
| `install_pacman()` | Install with pacman | `packages` |
| `install_yay()` | Install from AUR | `packages` |
| `install_apt()` | Install with apt-get | `packages` |
| `install_brew()` | Install with Homebrew | `formula` |
| `install_winget()` | Install with winget | `package_id` |
| `install_choco()` | Install with Chocolatey | `package` |
| `uninstall_pacman()` | Remove with pacman | `packages` |
| `uninstall_apt()` | Remove with apt | `packages` |
| `uninstall_brew()` | Remove with brew | `formula` |
| `uninstall_winget()` | Remove with winget | `package_id` |
| `uninstall_choco()` | Remove with choco | `package` |

### Check Functions

```bash
# Check if binary is in PATH
check_installed "$binary" "$display_name"

# Check specific file path (useful for Windows)
check_file_exists "/c/Program Files/App/app.exe" "App Name"

# Check if package is in pacman repos
check_pacman_package "package-name"
```

### Configuration Functions

```bash
# Link configs from dotfiles to app config dir
# Searches: os/{os}/configs/{app}/ first, then configs/{app}/
link_app_config "app-name" "os-name"

# Remove app config directory (for --purge)
remove_app_config "app-name" "${HOME}/.config/app-name"
```

### OS Detection

```bash
# Get OS name
OS=$(detect_os)  # Returns: omarchy, arch, mac, cloud-shell, windows, wsl, unknown

# Get Windows shell type (for Windows scripts)
ENV=$(detect_windows_shell)  # Returns: git-bash, cygwin, wsl, unknown
```

## Configuration Files

Many apps store configs in the same locations across OSes. Create these in the appropriate folders:

### Shared Config Locations

| App Type | Config Location | Action |
|----------|-----------------|--------|
| CLI tools | `~/.config/{app}/` | Symlink from `os/{platform}/configs/` |
| Shell configs | `~/.{file}` | Symlink from `os/{platform}/home/` |
| Git configs | `~/.gitconfig` | Symlink from `os/{platform}/home/` |
| Vim/Neovim | `~/.vimrc` or `~/.config/nvim/` | Symlink from `os/{platform}/home/` |

### Directory Structure

```
~/.dotfiles/
├── configs/              # OS-agnostic shared configs
│   └── {app-name}/
│       └── config
└── os/
    └── {platform}/
        └── configs/       # OS-specific overrides
            └── {app-name}/
                └── config
```

## Best Practices

### Always Source the Common Library

```bash
#!/bin/bash
set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"
```

### Use Common Functions

```bash
# Good - uses common function
info "Installing app..."
check_installed "$BINARY" "$APP_NAME"
install_pacman "$PACKAGES"
success "App installed!"

# Bad - duplicates logic
echo "Installing app..."
if command -v app &> /dev/null; then
    echo "Already installed"
    exit 0
fi
sudo pacman -S --needed --noconfirm app
echo "App installed!"
```

### Windows: Handle Both Git Bash and WSL

```bash
ENV=$(detect_windows_shell)

case "$ENV" in
    git-bash)
        install_winget "{PackageId}"
        ;;
    wsl)
        install_apt "{package-name}"
        ;;
esac
```

### Multi-OS Support Checklist

- [ ] Create install script for Omarchy (Arch/pacman)
- [ ] Create install script for macOS (brew)
- [ ] Create install script for Cloud Shell (apt)
- [ ] Create install script for Windows (winget/choco + WSL)
- [ ] Create matching uninstall scripts for all OSes
- [ ] Support `--purge` flag in all uninstall scripts
- [ ] Link appropriate configs with `link_app_config()`
- [ ] Test install/uninstall cycle (if possible)

## Safety Rules

**ALWAYS:**
- Source `lib/common.sh` at the start of every script
- Use `set -e` to exit on error
- Use common functions for logging, checking, and installing
- Create scripts for ALL supported OSes
- Check if app is already installed before installing
- Support `--purge` flag in uninstall scripts
- Make scripts executable with `chmod +x`

**NEVER:**
- Duplicate common logic (use the library functions instead)
- Delete user data without explicit `--purge` flag
- Assume package names are the same across OSes
- Skip the uninstall script when creating an install script
- Use `rm -rf` without checking paths first (use `remove_app_config()`)

**WINDOWS-SPECIFIC:**
- Use `sudo` in WSL, but NOT in Git Bash
- Always detect environment with `detect_windows_shell()`
- Handle both winget/choco for Git Bash and apt/pacman for WSL
- Test in vanilla Git Bash (bundled with Git for Windows)

## Troubleshooting

```bash
# Test install script for specific OS
bash ~/.dotfiles/os/omarchy/install/app-{name}.sh

# Test uninstall script
bash ~/.dotfiles/os/omarchy/uninstall/app-{name}.sh

# Check if script sources common library
grep -n "source.*common.sh" ~/.dotfiles/os/{platform}/install/app-{name}.sh

# View available apps for specific OS
ls ~/.dotfiles/os/{platform}/install/

# Run main installer to detect OS
bash ~/.dotfiles/install.sh

# Check common library functions
grep -n "^[a-z_]*()" ~/.dotfiles/lib/common.sh | head -20
```

## Examples

### Example: Adding Node.js

Create for each OS:

**Omarchy:**
```bash
#!/bin/bash
set -e
DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

info "Installing Node.js on Omarchy..."

if check_installed "node"; then
    exit 0
fi

install_pacman "nodejs npm"
link_app_config "nodejs" "omarchy"

success "Node.js installed successfully!"
```

**macOS:**
```bash
#!/bin/bash
set -e
DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

info "Installing Node.js on macOS..."

if check_installed "node"; then
    exit 0
fi

install_brew "node"
link_app_config "nodejs" "mac"

success "Node.js installed successfully!"
```

**Cloud Shell:**
```bash
#!/bin/bash
set -e
DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

info "Installing Node.js on Cloud Shell..."

if check_installed "node"; then
    exit 0
fi

install_apt "nodejs npm"
link_app_config "nodejs" "cloud-shell"

success "Node.js installed successfully!"
```

**Windows:**
```bash
#!/bin/bash
set -e
DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

ENV=$(detect_windows_shell)

info "Installing Node.js on Windows ($ENV)..."

if check_installed "node"; then
    exit 0
fi

case "$ENV" in
    git-bash)
        install_winget "OpenJS.NodeJS"
        ;;
    wsl)
        install_apt "nodejs npm"
        ;;
esac

link_app_config "nodejs" "windows"

success "Node.js installed successfully!"
```
