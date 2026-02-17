#!/usr/bin/env bash
# GCP Cloud Shell dotfiles installer
#
# Usage: ./install.sh [--all]
#   --all  Install all available apps after dotfiles setup

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Source common functions and shared install utilities
source "$DOTFILES_ROOT/lib/common.sh"
source "$DOTFILES_ROOT/os/_shared/_install.sh"

OS_NAME="GCP Cloud Shell"
os_name="cloud-shell"
BACKUP_DIR=$(get_backup_dir "$os_name")
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
info "Backup location: $BACKUP_DIR"
warn "Cloud Shell has pre-installed packages maintained by Google"

DOTFILES_HOME="$DOTFILES_ROOT/os/$os_name/home"

# Symlink all dotfiles (sudo available on Cloud Shell)
symlink_all_dotfiles "$DOTFILES_HOME" "$HOME" "$BACKUP_DIR"

info "Setting up git configuration..."
setup_git_user_config || warn "Git user config setup skipped or failed"

success "$OS_NAME dotfiles installed!"
info "Backups stored in: $BACKUP_DIR"

# Install apps (handles both --all and interactive selection)
install_os_apps "$os_name" "$DOTFILES_ROOT" "$INSTALL_ALL"

info "Additional packages can be installed via: sudo apt-get install <package>"
info "Note: Configs persist across Cloud Shell sessions"
