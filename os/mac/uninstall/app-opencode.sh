#!/usr/bin/env bash
# Uninstall OpenCode CLI on macOS

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

# Remove via Homebrew if installed that way
if brew list opencode &>/dev/null 2>&1; then
    brew uninstall opencode
fi

# Remove via mise if installed that way
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
    
    if [ -d "$HOME/Library/Application Support/opencode" ]; then
        info "Removing opencode macOS app data..."
        rm -rf "$HOME/Library/Application Support/opencode"
    fi
fi

# Remove completions
if [[ -f "$HOME/.bash_completion.d/opencode" ]]; then
    rm -f "$HOME/.bash_completion.d/opencode"
fi

success "$APP_NAME uninstalled successfully!"
