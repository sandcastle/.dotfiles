#!/usr/bin/env bash
# Windows initialization script
# Installs mandatory prerequisites for using dotfiles on Windows

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Source common functions
source "$DOTFILES_ROOT/lib/common.sh"

SHELL_TYPE=$(detect_windows_shell)

info "Initializing Windows dotfiles..."
info "Shell type: $SHELL_TYPE"

# Define initialization order (apps will be installed in this order)
# Different lists for different Windows environments

case "$SHELL_TYPE" in
    git-bash)
        # Git Bash environment
        INIT_APPS=(
            "app-git.sh"      # Required - included with Git for Windows
            "app-gum.sh"      # Required for pretty output
            "app-mise.sh"     # Required for dev environment management
        )
        ;;
    wsl)
        # WSL environment - uses Linux package management
        INIT_APPS=(
            "app-git.sh"      # Required for dotfiles
            "app-gum.sh"      # Required for pretty output
            "app-mise.sh"     # Required for dev environment management
        )
        ;;
    cygwin)
        # Cygwin environment
        INIT_APPS=(
            "app-git.sh"      # Required for dotfiles
            "app-gum.sh"      # Required for pretty output
            "app-mise.sh"     # Required for dev environment management
        )
        ;;
    *)
        warn "Unknown Windows environment"
        INIT_APPS=()
        ;;
esac

INIT_DIR="$DOTFILES_ROOT/os/windows/init"

# Run each init app in order
for app_script in "${INIT_APPS[@]}"; do
    script_path="$INIT_DIR/$app_script"
    if [ -f "$script_path" ]; then
        bash "$script_path"
    fi
done

case "$SHELL_TYPE" in
    git-bash)
        info "Git Bash is included with Git for Windows"
        info "Recommended package managers:"
        info "  - winget (Windows 10/11 built-in)"
        info "  - Chocolatey (https://chocolatey.org/install)"
        ;;
    wsl)
        info "WSL detected - standard Linux package management available"
        ;;
esac

success "Windows ($SHELL_TYPE) initialized!"
