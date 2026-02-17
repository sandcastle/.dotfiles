#!/usr/bin/env bash
# GCP Cloud Shell dotfiles installer
#
# Usage: ./install.sh [--all] [--debug]
#   --all    Install all available apps after dotfiles setup
#   --debug  Show verbose output with paths and details

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Source common functions and shared install utilities
source "$DOTFILES_ROOT/lib/common.sh"
source "$DOTFILES_ROOT/os/_shared/_install.sh"

OS_NAME="GCP Cloud Shell"
os_name="cloud-shell"
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
$DEBUG && info "Backup: $BACKUP_DIR"

DOTFILES_HOME="$DOTFILES_ROOT/os/$os_name/home"

# Symlink all dotfiles (sudo available on Cloud Shell)
symlink_all_dotfiles "$DOTFILES_HOME" "$USER_HOME" "$BACKUP_DIR"

$DEBUG && info "Setting up git configuration..."
setup_git_user_config || warn "Git user config setup skipped or failed"

success "$OS_NAME dotfiles installed!"
$DEBUG && info "Backups in: $BACKUP_DIR"

# Install apps (handles both --all and interactive selection)
install_os_apps "$os_name" "$DOTFILES_ROOT" "$INSTALL_ALL"

info "Additional packages can be installed via: sudo apt-get install <package>"
