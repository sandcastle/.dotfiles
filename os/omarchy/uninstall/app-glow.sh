#!/usr/bin/env bash
# Uninstall Glow CLI

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

# Remove via pacman
if pacman -Q glow &>/dev/null; then
    uninstall_pacman "glow"
fi

# Remove configuration directory if requested
if [ "$1" = "--purge" ]; then
    if [ -d "$HOME/.config/glow" ]; then
        info "Removing glow configuration..."
        rm -rf "$HOME/.config/glow"
    fi
fi

# Remove completions
if [[ -L "/usr/share/bash-completion/completions/glow" ]]; then
    sudo rm -f /usr/share/bash-completion/completions/glow
fi

if [[ -f "/etc/bash_completion.d/glow" ]]; then
    sudo rm -f /etc/bash_completion.d/glow
fi

if [[ -f "$USER_HOME/.bash_completion.d/glow" ]]; then
    rm -f "$USER_HOME/.bash_completion.d/glow"
fi

success "$APP_NAME uninstalled successfully!"
