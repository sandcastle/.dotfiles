---
name: dotfiles-os-manager
description: >
  REQUIRED when managing operating system configurations in the dotfiles repository.
  Use when creating new OS folders, managing OS-specific init scripts, or understanding the dotfiles OS structure.
  Triggers: new OS setup, OS configuration, init scripts, OS folder management, multi-OS support.
---

# Dotfiles OS Manager Skill

Manage operating system configurations and initialization in the dotfiles repository.

## When This Skill MUST Be Used

**ALWAYS invoke this skill when the user's request involves ANY of these:**

- Creating a new OS folder in `~/.dotfiles/os/`
- Modifying OS-specific `init.sh` scripts
- Adding/modifying OS-specific init apps (`os/{platform}/init/app-*.sh`)
- Understanding how the OS structure works
- Setting up a new operating system in the dotfiles repo
- Managing OS-specific dotfiles (`.aliases.os`, `.exports.os`, `.functions.os`)
- Configuring OS-specific package managers or tools

## Directory Structure

```
~/.dotfiles/os/
├── install.sh                 # Main entry point (detects OS, runs init + install)
├── _shared/                   # Cross-OS shared files
│   └── home/
│       ├── .aliases           # Shared aliases (symlinked to each OS)
│       ├── .exports           # Shared environment variables
│       ├── .functions         # Shared functions
│       └── .gitconfig         # Shared git configuration
│
├── omarchy/                   # Arch Linux / Omarchy
│   ├── init.sh               # Mandatory init orchestrator
│   ├── init/                 # Mandatory prerequisites (run once)
│   │   ├── app-git.sh        # Required: Git
│   │   ├── app-gum.sh        # Required: Pretty terminal output
│   │   └── app-mise.sh       # Required: Dev environment manager
│   ├── home/                 # Dotfiles to symlink
│   │   ├── .aliases → ../../../_shared/home/.aliases
│   │   ├── .aliases.os       # Omarchy-specific aliases
│   │   ├── .exports → ../../../_shared/home/.exports
│   │   ├── .exports.os       # Omarchy-specific exports
│   │   ├── .functions → ../../../_shared/home/.functions
│   │   ├── .functions.os     # Omarchy-specific functions
│   │   ├── .bashrc           # OS-specific bashrc
│   │   ├── .bash_profile     # OS-specific bash_profile
│   │   └── .gitconfig → ../../../_shared/home/.gitconfig
│   ├── install.sh            # OS-specific dotfiles installer
│   ├── install/              # Optional app installers
│   │   └── app-*.sh
│   ├── uninstall/            # App uninstallers
│   │   └── app-*.sh
│   └── configs/              # OS-specific app configs
│
├── mac/                       # macOS
│   ├── init.sh
│   ├── init/
│   │   ├── app-xcode-tools.sh  # First: Xcode CLT (required for compiling)
│   │   ├── app-homebrew.sh     # Second: Homebrew (package manager)
│   │   ├── app-git.sh          # Required: Git
│   │   ├── app-gum.sh          # Required: Pretty terminal output
│   │   └── app-mise.sh         # Required: Dev environment manager (via brew)
│   ├── home/
│   └── ... (same structure as omarchy)
│
├── cloud-shell/               # GCP Cloud Shell
│   ├── init.sh
│   ├── init/
│   │   ├── app-basic-tools.sh  # Ensure neovim, curl, wget, etc.
│   │   ├── app-git.sh          # Required: Git
│   │   ├── app-gum.sh          # Required: Pretty terminal output
│   │   └── app-mise.sh         # Required: Dev environment manager
│   └── ... (same structure)
│
└── windows/                   # Windows (Git Bash & WSL)
    ├── init.sh
    ├── init/
    │   ├── app-git.sh          # Verify Git for Windows
    │   ├── app-gum.sh          # Required: Pretty terminal output
    │   └── app-mise.sh         # Required: Dev environment manager
    └── ... (same structure)
```

## Critical OS Components

### 1. init.sh - The Orchestrator

Every OS **MUST** have an `init.sh` script that:
- Defines the `INIT_APPS` array (installation order matters!)
- Sources `lib/common.sh` for helper functions
- Runs each init app in sequence
- Displays completion message

**Template:**
```bash
#!/usr/bin/env bash
# {OS} initialization script
# Installs mandatory prerequisites for using dotfiles on {OS}

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

header "Initializing {OS} Dotfiles"

# Define initialization order (apps will be installed in this order)
# Order matters: dependencies first!
INIT_APPS=(
    "app-dependency.sh"     # Install this first
    "app-main.sh"          # This depends on above
    "app-git.sh"           # Required for all OSes
    "app-gum.sh"           # Required for pretty output
    "app-mise.sh"          # Required for dev environments
)

INIT_DIR="$DOTFILES_ROOT/os/{os}/init"

# Run each init app in order
for app_script in "${INIT_APPS[@]}"; do
    script_path="$INIT_DIR/$app_script"
    if [ -f "$script_path" ]; then
        section "Running: $app_script"
        bash "$script_path"
    fi
done

success "{OS} initialization complete!"
```

### 2. Init Apps (os/{platform}/init/)

**Mandatory for ALL OSes:**

| App | Purpose | Install Method |
|-----|---------|----------------|
| `app-git.sh` | Version control | pacman/brew/apt |
| `app-gum.sh` | Pretty terminal UI | pacman/brew/apt/winget |
| `app-mise.sh` | Dev env manager | curl \| sh / brew |

**OS-Specific Additional Apps:**

| OS | Additional Init Apps |
|----|---------------------|
| **macOS** | `app-xcode-tools.sh`, `app-homebrew.sh` |
| **Omarchy** | (none - uses pacman) |
| **Cloud Shell** | `app-basic-tools.sh` (neovim, curl, wget, tree) |
| **Windows** | `app-git.sh` (verify Git for Windows) |

### 3. Init App Template

Every init app **MUST** follow this structure:

```bash
#!/usr/bin/env bash
# {OS} init: Install {Tool}
# {Official URL}
#
# Official install: {command}

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="{Tool}"
BINARY="{binary}"

section "Installing $APP_NAME"

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $($BINARY --version 2>/dev/null || echo 'unknown')"
    exit 0
fi

info "$APP_NAME - {brief description}"
info "Website: {official URL}"

# Install using OS-appropriate method
# (see specific examples below)

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $($BINARY --version)"
else
    error "$APP_NAME installation failed"
    exit 1
fi

# Add to .bashrc if needed
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "$BINARY activate" "$HOME/.bashrc" 2>/dev/null; then
    info "Adding $BINARY to ~/.bashrc..."
    echo '' >> "$HOME/.bashrc"
    echo "# Activate $BINARY" >> "$HOME/.bashrc"
    echo 'eval "$('$BINARY' activate bash)"' >> "$HOME/.bashrc"
fi

# Install bash completions (REQUIRED)
info "Installing bash completions for $APP_NAME..."
if $BINARY completion bash &>/dev/null; then
    mkdir -p "$HOME/.bash_completion.d"
    if [[ ! -f "$HOME/.bash_completion.d/$BINARY" ]]; then
        $BINARY completion bash > "$HOME/.bash_completion.d/$BINARY"
        success "Completions installed to ~/.bash_completion.d/$BINARY"
    fi
    
    # Ensure completion sourcing is in .bashrc
    if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
        echo '' >> "$HOME/.bashrc"
        echo '# Source bash completions' >> "$HOME/.bashrc"
        echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$HOME/.bashrc"
    fi
fi
```

## OS-Specific Installation Methods

### Arch Linux (Omarchy)

```bash
# Try official repos first, fallback to AUR
if check_pacman_package "$PACKAGE"; then
    install_pacman "$PACKAGE"
else
    install_yay "$PACKAGE"
fi
```

### macOS

```bash
# Homebrew is the standard
install_brew "$FORMULA"
```

### Debian/Ubuntu (Cloud Shell)

```bash
# Standard apt or custom repos
install_apt "$PACKAGE"

# For custom repos (like Charm for gum):
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt-get update
sudo apt-get install -y "$PACKAGE"
```

### Windows (Git Bash)

```bash
# Use winget when available
if command -v winget &> /dev/null; then
    install_winget "$WINGET_ID"
fi

# Or Chocolatey
if command -v choco &> /dev/null; then
    install_choco "$PACKAGE"
fi
```

### Windows (WSL)

```bash
# Same as Debian/Ubuntu - use apt
install_apt "$PACKAGE"
```

## Adding a New Operating System

### Step 1: Create the OS folder structure

```bash
mkdir -p ~/.dotfiles/os/{new-os}/{init,home,install,uninstall,configs}
```

### Step 2: Create init.sh

Use the template above, customize `INIT_APPS` for the OS.

### Step 3: Create mandatory init apps

**Required for all OSes:**
- `app-git.sh`
- `app-gum.sh`
- `app-mise.sh`

**OS-specific:**
- Package manager setup (homebrew, etc.)
- Development tools (xcode-tools, etc.)
- Basic utilities

### Step 4: Create home directory structure

```bash
# Symlink shared files
ln -s ../../../_shared/home/.aliases ~/.dotfiles/os/{new-os}/home/.aliases
ln -s ../../../_shared/home/.exports ~/.dotfiles/os/{new-os}/home/.exports
ln -s ../../../_shared/home/.functions ~/.dotfiles/os/{new-os}/home/.functions
ln -s ../../../_shared/home/.gitconfig ~/.dotfiles/os/{new-os}/home/.gitconfig

# Create OS-specific variants
touch ~/.dotfiles/os/{new-os}/home/.aliases.os
touch ~/.dotfiles/os/{new-os}/home/.exports.os
touch ~/.dotfiles/os/{new-os}/home/.functions.os

# Create OS-specific bash configs
cp ~/.dotfiles/os/omarchy/home/.bashrc ~/.dotfiles/os/{new-os}/home/.bashrc
cp ~/.dotfiles/os/omarchy/home/.bash_profile ~/.dotfiles/os/{new-os}/home/.bash_profile
```

### Step 5: Create install.sh

```bash
#!/usr/bin/env bash
# {New OS} dotfiles installer

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

OS_NAME="{New OS}"
os_name="{new-os}"
BACKUP_DIR=$(get_backup_dir "$os_name")

header "Installing Dotfiles for $OS_NAME"

section "Pre-Installation"
info "Backup Location: $BACKUP_DIR"

DOTFILES_HOME="$DOTFILES_ROOT/os/$os_name/home"

# Symlink all dotfiles
symlink_all_dotfiles "$DOTFILES_HOME" "$HOME" "$BACKUP_DIR"

section "Git Configuration"
setup_git_user_config || warn "Git user config setup skipped or failed"

section "Post-Installation"
success "$OS_NAME dotfiles installed successfully!"
info "Backups stored in: $BACKUP_DIR"
info "To install apps: apps install <app-name>"
```

### Step 6: Add OS detection to main install.sh

Edit `~/.dotfiles/os/install.sh` and add a new case:

```bash
{new-os})
    INIT_SCRIPT="$DOTFILES_ROOT/os/{new-os}/init.sh"
    INSTALLER="$DOTFILES_ROOT/os/{new-os}/install.sh"
    OS_NAME="{New OS Name}"
    ;;
```

### Step 7: Update detect_os() in lib/common.sh

Add detection logic:

```bash
# In detect_os() function
if [ -f /etc/{new-os}-release ]; then
    echo "{new-os}"
    return
fi
```

## OS-Specific Dotfiles (`.os` variants)

### Purpose

Files with `.os` extension contain OS-specific additions that are sourced after the shared files.

### Loading Order

From `.bashrc`:
```bash
for file in ~/.{exports,aliases,functions}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"      # Base (shared)
  [ -r "$file.os" ] && [ -f "$file.os" ] && source "$file.os"  # OS-specific
  [ -r "$file.local" ] && [ -f "$file.local" ] && source "$file.local"  # Local
done
```

### When to Use

- **`.aliases.os`**: OS-specific shortcuts (e.g., `brew` on macOS, `pacman` on Arch)
- **`.exports.os`**: OS-specific environment (e.g., `HOMEBREW_NO_ANALYTICS`, `GOPATH`)
- **`.functions.os`**: OS-specific helper functions (e.g., macOS notification center)

### Examples

**macOS `.aliases.os`:**
```bash
alias brewup="brew update && brew upgrade"
alias show-hidden="defaults write com.apple.finder AppleShowAllFiles YES"
```

**Omarchy `.exports.os`:**
```bash
export PATH="$HOME/.local/share/omarchy/bin:$PATH"
```

## Best Practices

### Always Use Official Installation Methods

- Check the tool's official documentation
- Use package managers when available (brew, pacman, apt)
- For universal installers (mise), use `curl | sh` approach

### Order Matters in INIT_APPS

```bash
INIT_APPS=(
    "app-xcode-tools.sh"  # Must be first (compiling)
    "app-homebrew.sh"     # Second (package manager)
    "app-git.sh"          # Now we can use git
    "app-gum.sh"          # Pretty output for rest
    "app-mise.sh"         # Dev environments
)
```

### Handle Already-Installed Tools Gracefully

```bash
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    exit 0
fi
```

### Always Include Error Handling

```bash
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
else
    error "$APP_NAME installation failed"
    info "For manual installation, see: {official-docs-url}"
    exit 1
fi
```

### Use Shebang `#!/usr/bin/env bash`

**NEVER** use `#!/bin/bash` - always use `#!/usr/bin/env bash` for portability.

## Common Mistakes to Avoid

### 1. Wrong INIT_APPS Order

**❌ BAD:** Installing mise before gum (no pretty output for mise install)
```bash
INIT_APPS=("app-mise.sh" "app-gum.sh")  # Wrong!
```

**✅ GOOD:**
```bash
INIT_APPS=("app-gum.sh" "app-mise.sh")  # Correct!
```

### 2. Forgetting System Completions on Linux

**❌ BAD:** Only installing user-local completions on Linux
```bash
mkdir -p "$HOME/.bash_completion.d"
$BINARY completion bash > "$HOME/.bash_completion.d/$BINARY"
```

**✅ GOOD:** Using system-wide when possible
```bash
if [[ -d "/usr/share/bash-completion/completions" ]]; then
    $BINARY completion bash | sudo tee /usr/share/bash-completion/completions/$BINARY > /dev/null
else
    mkdir -p "$HOME/.bash_completion.d"
    $BINARY completion bash > "$HOME/.bash_completion.d/$BINARY"
fi
```

### 3. Missing Bashrc Activation

**❌ BAD:** Not adding tool activation to .bashrc
```bash
# Install only, no activation
install_brew "mise"
```

**✅ GOOD:**
```bash
install_brew "mise"
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "mise activate" "$HOME/.bashrc" 2>/dev/null; then
    echo 'eval "$(mise activate bash)"' >> "$HOME/.bashrc"
fi
```

### 4. Using `#!/bin/bash`

**❌ BAD:**
```bash
#!/bin/bash
```

**✅ GOOD:**
```bash
#!/usr/bin/env bash
```

## Testing a New OS

After adding a new OS:

```bash
# Test OS detection
bash ~/.dotfiles/os/install.sh --help 2>&1 | head -5

# Test init
bash ~/.dotfiles/os/{new-os}/init.sh

# Test dotfiles installation
bash ~/.dotfiles/os/{new-os}/install.sh
```

## Documentation

When adding a new OS, update:
- This SKILL.md with OS-specific details
- README.md with OS support table
- Add OS-specific examples to init app templates

## Official Documentation Links

**Gum:** https://github.com/charmbracelet/gum#installation
**Mise:** https://mise.jdx.dev/getting-started.html
**Homebrew:** https://docs.brew.sh/Installation
**Git:** https://git-scm.com/download
