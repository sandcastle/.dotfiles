#!/usr/bin/env bash
# Omarchy dotfiles installer
# Note: This script runs as regular user. sudo is only used for specific system operations.
#
# Usage: ./install.sh [--all] [--debug]
#   --all    Install all available apps after dotfiles setup
#   --debug  Show verbose output with paths and details

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$DOTFILES_ROOT"

# Source common functions and shared install utilities
source "$DOTFILES_ROOT/lib/common.sh"
source "$DOTFILES_ROOT/os/_shared/_install.sh"

OS_NAME="Omarchy"
os_name="omarchy"
BACKUP_DIR=$(get_backup_dir "$os_name")
INSTALL_ALL=false
DEBUG=${DEBUG:-false}

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --all)
            INSTALL_ALL=true
            ;;
        --debug)
            DEBUG=true
            export DEBUG
            ;;
        --help|-h)
            echo "Usage: $(basename "$0") [--all] [--debug]"
            echo "  --all    Install all available apps after dotfiles setup"
            echo "  --debug  Show verbose output with paths and details"
            exit 0
            ;;
    esac
done

info "Installing dotfiles for $OS_NAME..."
$DEBUG && info "Backup location: $BACKUP_DIR"
$DEBUG && info "Running as user: $(whoami)"

DOTFILES_HOME="$DOTFILES_ROOT/os/$os_name/home"

# Create backup directory (user directory, no sudo needed)
mkdir -p "$BACKUP_DIR"

# Symlink all dotfiles (user directory, no sudo needed)
symlink_all_dotfiles "$DOTFILES_HOME" "$HOME" "$BACKUP_DIR"

$DEBUG && info "Setting up git configuration..."
setup_git_user_config || warn "Git user config setup skipped or failed"

success "$OS_NAME dotfiles installed!"
$DEBUG && info "Backups stored in: $BACKUP_DIR"

# Install apps (handles both --all and interactive selection)
install_os_apps "$os_name" "$DOTFILES_ROOT" "$INSTALL_ALL"

info ""
info "Note: System-wide changes may require sudo and will prompt when needed."
