#!/usr/bin/env bash
# Uninstall GitHub CLI (gh) on macOS

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="GitHub CLI"
BINARY="gh"

info "Uninstalling $APP_NAME..."

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

info "Uninstalling GitHub CLI..."

# Remove via Homebrew
if brew list gh &>/dev/null; then
    brew uninstall gh
fi

# Remove extensions directory
if [ -d "$HOME/.local/share/gh" ]; then
    info "Removing gh extensions..."
    rm -rf "$HOME/.local/share/gh"
fi

# Remove configuration directory if requested
if [ "$1" = "--purge" ]; then
    if [ -d "$HOME/.config/gh" ]; then
        info "Removing gh configuration..."
        rm -rf "$HOME/.config/gh"
    fi
    
    if [ -d "$HOME/Library/Application Support/gh" ]; then
        info "Removing gh macOS app data..."
        rm -rf "$HOME/Library/Application Support/gh"
    fi
fi

# Remove completions
if [[ -L "$HOME/.bash_completion.d/gh" ]]; then
    rm -f "$HOME/.bash_completion.d/gh"
fi

success "$APP_NAME uninstalled successfully!"
