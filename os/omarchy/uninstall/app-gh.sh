#!/usr/bin/env bash
# Uninstall GitHub CLI (gh)

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

# Remove via pacman
if pacman -Q github-cli &>/dev/null; then
    uninstall_pacman "github-cli"
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
    
    if [ -d "$HOME/.gh" ]; then
        info "Removing gh data directory..."
        rm -rf "$HOME/.gh"
    fi
fi

# Remove completions
if [[ -L "/usr/share/bash-completion/completions/gh" ]]; then
    sudo rm -f /usr/share/bash-completion/completions/gh
fi

if [[ -f "/etc/bash_completion.d/gh" ]]; then
    sudo rm -f /etc/bash_completion.d/gh
fi

if [[ -f "$USER_HOME/.bash_completion.d/gh" ]]; then
    rm -f "$USER_HOME/.bash_completion.d/gh"
fi

# Remove PATH entries from .bashrc (if any gh-specific entries)
# (gh typically doesn't need PATH modifications as it installs to /usr/bin)

success "$APP_NAME uninstalled successfully!"
