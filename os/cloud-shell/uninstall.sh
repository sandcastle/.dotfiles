#!/usr/bin/env bash
# GCP Cloud Shell dotfiles uninstaller
#
# Usage: ./uninstall.sh [--all]
#   --all  Uninstall all apps (excluding init apps) before removing dotfiles
#   --purge  Also remove configuration files

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Source common functions
source "$DOTFILES_ROOT/lib/common.sh"

OS_NAME="GCP Cloud Shell"
os_name="cloud-shell"
UNINSTALL_ALL=false
PURGE=false

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --all)
            UNINSTALL_ALL=true
            ;;
        --purge)
            PURGE=true
            ;;
        --help|-h)
            echo "Usage: $(basename "$0") [--all] [--purge]"
            echo "  --all    Uninstall all apps before removing dotfiles"
            echo "  --purge  Also remove configuration files"
            exit 0
            ;;
    esac
done

info "Uninstalling dotfiles for $OS_NAME..."
warn "Note: This removes dotfiles but Cloud Shell retains system packages"

# Uninstall all apps if --all flag was passed
if [[ "$UNINSTALL_ALL" == true ]]; then
    info "Uninstalling all apps..."
    
    UNINSTALL_DIR="$DOTFILES_ROOT/os/$os_name/uninstall"
    if [[ -d "$UNINSTALL_DIR" ]]; then
        for app_script in "$UNINSTALL_DIR"/app-*.sh; do
            if [[ -f "$app_script" ]]; then
                app_name=$(basename "$app_script" | sed 's/app-//;s/\.sh$//')
                info "Uninstalling $app_name..."
                if [[ "$PURGE" == true ]]; then
                    bash "$app_script" --purge || warn "Failed to uninstall $app_name"
                else
                    bash "$app_script" || warn "Failed to uninstall $app_name"
                fi
            fi
        done
        success "All apps uninstalled!"
    else
        warn "No uninstall directory found at $UNINSTALL_DIR"
    fi
fi

# Remove dotfile symlinks
info "Removing dotfile symlinks..."
DOTFILES_HOME="$DOTFILES_ROOT/os/$os_name/home"

# Find all files in dotfiles home and remove their symlinks from $HOME
if [[ -d "$DOTFILES_HOME" ]]; then
    find "$DOTFILES_HOME" -type f -o -type l | while read -r file; do
        # Get relative path from DOTFILES_HOME
        rel_path="${file#$DOTFILES_HOME/}"
        symlink_path="$HOME/$rel_path"
        
        # Remove if it's a symlink
        if [[ -L "$symlink_path" ]]; then
            rm -f "$symlink_path"
            info "Removed: $symlink_path"
        fi
    done
fi

# Remove completion directory
if [[ -d "$HOME/.bash_completion.d" ]]; then
    info "Removing bash completions..."
    rm -rf "$HOME/.bash_completion.d"
fi

success "$OS_NAME dotfiles uninstalled!"
info "Note: Cloud Shell system packages maintained by Google remain installed"

if [[ "$PURGE" == true ]]; then
    info "Configuration files have been removed (--purge was used)"
else
    info "To also remove configuration files, run with --purge flag"
fi
