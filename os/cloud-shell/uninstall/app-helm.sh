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

# Remove binary
HELM_PATH=$(command -v helm)
if [ -n "$HELM_PATH" ] && [ -f "$HELM_PATH" ]; then
    info "Removing Helm binary..."
    sudo rm -f "$HELM_PATH"
fi

# Remove cache and config if --purge
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
