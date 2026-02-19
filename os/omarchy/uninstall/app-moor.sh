#!/usr/bin/env bash
# Uninstall Moor pager

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Moor"
BINARY="moor"

info "Uninstalling $APP_NAME..."

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

# Remove via yay (AUR)
if yay -Q moor &>/dev/null 2>&1 || pacman -Q moor &>/dev/null 2>&1; then
    info "Removing Moor package..."
    uninstall_pacman "moor" || yay -R --noconfirm moor || true
fi

# Remove config directory if --purge
if [ "$1" = "--purge" ]; then
    if [ -d "$HOME/.config/moor" ]; then
        info "Removing Moor configuration..."
        rm -rf "$HOME/.config/moor"
    fi
fi

success "$APP_NAME uninstalled successfully!"
