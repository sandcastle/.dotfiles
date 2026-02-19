#!/usr/bin/env bash
# Uninstall Delta (git-delta)

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Delta"
BINARY="delta"

info "Uninstalling $APP_NAME..."

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

# Remove via pacman
if pacman -Q git-delta &>/dev/null; then
    uninstall_pacman "git-delta"
fi

# Remove completions
if [[ -L "/usr/share/bash-completion/completions/delta" ]]; then
    sudo rm -f /usr/share/bash-completion/completions/delta
fi

if [[ -f "/etc/bash_completion.d/delta" ]]; then
    sudo rm -f /etc/bash_completion.d/delta
fi

if [[ -f "$USER_HOME/.bash_completion.d/delta" ]]; then
    rm -f "$USER_HOME/.bash_completion.d/delta"
fi

success "$APP_NAME uninstalled successfully!"
