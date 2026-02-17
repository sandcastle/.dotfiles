#!/usr/bin/env bash
# Uninstall Glow CLI on macOS

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Glow"
BINARY="glow"

info "Uninstalling $APP_NAME..."

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

info "Uninstalling Glow..."

# Remove via Homebrew
if brew list glow &>/dev/null; then
    brew uninstall glow
fi

# Remove configuration directory if requested
if [ "$1" = "--purge" ]; then
    if [ -d "$HOME/.config/glow" ]; then
        info "Removing glow configuration..."
        rm -rf "$HOME/.config/glow"
    fi
fi

# Remove completions
if [[ -L "$HOME/.bash_completion.d/glow" ]]; then
    rm -f "$HOME/.bash_completion.d/glow"
fi

success "$APP_NAME uninstalled successfully!"
