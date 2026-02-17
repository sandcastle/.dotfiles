#!/usr/bin/env bash
# Windows dotfiles installer (Git Bash / WSL)
#
# Usage: ./install.sh [--all]
#   --all  Install all available apps after dotfiles setup

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Source common functions and shared install utilities
source "$DOTFILES_ROOT/lib/common.sh"
source "$DOTFILES_ROOT/os/_shared/_install.sh"

OS_NAME="Windows"
os_name="windows"
SHELL_TYPE=$(detect_windows_shell)
BACKUP_DIR=$(get_backup_dir "${os_name}_${SHELL_TYPE}")
INSTALL_ALL=false

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --all)
            INSTALL_ALL=true
            ;;
        --help|-h)
            echo "Usage: $(basename "$0") [--all]"
            echo "  --all  Install all available apps after dotfiles setup"
            exit 0
            ;;
    esac
done

info "Installing dotfiles for $OS_NAME..."
info "Shell type: $SHELL_TYPE"
info "Backup location: $BACKUP_DIR"

case "$SHELL_TYPE" in
    git-bash)
        info "Git Bash: No sudo required (run Git Bash as Administrator for system-wide changes)"
        info "Package managers: winget (Windows 10/11) or chocolatey"
        info "Home directory: $HOME"
        ;;
    cygwin)
        info "Running in Cygwin environment"
        ;;
    wsl)
        info "Running in WSL (Windows Subsystem for Linux)"
        if command -v apt-get &> /dev/null; then
            info "Detected: Debian/Ubuntu WSL"
        elif command -v pacman &> /dev/null; then
            info "Detected: Arch WSL"
        fi
        info "Access Windows files at: /mnt/c/"
        ;;
    *)
        warn "Unknown Windows environment detected"
        info "OSTYPE: $OSTYPE"
        ;;
esac

DOTFILES_HOME="$DOTFILES_ROOT/os/$os_name/home"

# Symlink all dotfiles
symlink_all_dotfiles "$DOTFILES_HOME" "$HOME" "$BACKUP_DIR"

info "Setting up git configuration..."
setup_git_user_config || warn "Git user config setup skipped or failed"

success "Windows ($SHELL_TYPE) dotfiles installed!"
info "Backups stored in: $BACKUP_DIR"

# Install apps (handles both --all and interactive selection)
install_os_apps "$os_name" "$DOTFILES_ROOT" "$INSTALL_ALL"

case "$SHELL_TYPE" in
    git-bash)
        info "To install apps with winget: apps install <app-name>"
        info "To install apps with Chocolatey: choco install <package>"
        ;;
    wsl)
        info "To install apps: apps install <app-name>"
        ;;
esac
