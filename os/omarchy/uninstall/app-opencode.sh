#!/usr/bin/env bash
# Uninstall OpenCode CLI

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="OpenCode"
BINARY="opencode"

info "Uninstalling $APP_NAME..."

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

info "Uninstalling OpenCode..."

# Remove binary
if [ -f "$HOME/.local/bin/opencode" ]; then
    rm -f "$HOME/.local/bin/opencode"
fi

# Remove via pacman if installed that way
if pacman -Q opencode &>/dev/null 2>&1; then
    uninstall_pacman "opencode"
fi

# Remove mise entry if installed via mise
if command -v mise &> /dev/null; then
    info "Removing from mise..."
    mise uninstall opencode 2>/dev/null || true
fi

# Remove configuration directory if requested
if [ "$1" = "--purge" ]; then
    if [ -d "$HOME/.config/opencode" ]; then
        info "Removing opencode configuration..."
        rm -rf "$HOME/.config/opencode"
    fi
    
    if [ -d "$HOME/.opencode" ]; then
        info "Removing opencode data directory..."
        rm -rf "$HOME/.opencode"
    fi
fi

# Remove completions
if [[ -f "$HOME/.bash_completion.d/opencode" ]]; then
    rm -f "$HOME/.bash_completion.d/opencode"
fi

# Remove from PATH in .bashrc (but keep the .local/bin entry as it may be used by other tools)
# Just remove the specific opencode comments if any
if [[ -f "$HOME/.bashrc" ]]; then
    sed -i '/# OpenCode/d' "$HOME/.bashrc" 2>/dev/null || true
fi

success "$APP_NAME uninstalled successfully!"
