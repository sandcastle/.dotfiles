#!/usr/bin/env bash
# Uninstall Helm (Kubernetes Package Manager)

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Helm"
BINARY="helm"

info "Uninstalling $APP_NAME..."

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

# Remove via pacman
if pacman -Q helm &>/dev/null; then
    uninstall_pacman "helm"
fi

# Remove completions
if [[ -L "/usr/share/bash-completion/completions/helm" ]]; then
    sudo rm -f /usr/share/bash-completion/completions/helm
fi

if [[ -f "/etc/bash_completion.d/helm" ]]; then
    sudo rm -f /etc/bash_completion.d/helm
fi

if [[ -f "$USER_HOME/.bash_completion.d/helm" ]]; then
    rm -f "$USER_HOME/.bash_completion.d/helm"
fi

# Remove cache directory if --purge
if [ "$1" = "--purge" ]; then
    if [ -d "$HOME/.cache/helm" ]; then
        info "Removing Helm cache..."
        rm -rf "$HOME/.cache/helm"
    fi
    
    if [ -d "$HOME/.config/helm" ]; then
        info "Removing Helm configuration..."
        rm -rf "$HOME/.config/helm"
    fi
fi

success "$APP_NAME uninstalled successfully!"
