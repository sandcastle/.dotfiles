#!/usr/bin/env bash
# Uninstall Google Cloud CLI (gcloud) and kubectl on macOS

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Google Cloud CLI"
BINARY="gcloud"

info "Uninstalling $APP_NAME..."

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

info "Uninstalling Google Cloud SDK..."

# Remove via Homebrew
if brew list --cask google-cloud-sdk &>/dev/null; then
    brew uninstall --cask google-cloud-sdk
else
    brew uninstall google-cloud-sdk 2>/dev/null || true
fi

# Remove configuration directory if requested
if [ "$1" = "--purge" ]; then
    if [ -d "$HOME/.config/gcloud" ]; then
        info "Removing gcloud configuration..."
        rm -rf "$HOME/.config/gcloud"
    fi
    
    if [ -d "$HOME/.kube" ]; then
        info "Removing kubectl configuration..."
        rm -rf "$HOME/.kube"
    fi
fi

# Remove completions
if [[ -L "$USER_HOME/.bash_completion.d/gcloud" ]]; then
    rm -f "$USER_HOME/.bash_completion.d/gcloud"
fi

if [[ -f "$USER_HOME/.bash_completion.d/kubectl" ]]; then
    rm -f "$USER_HOME/.bash_completion.d/kubectl"
fi

# Remove PATH entries from .bashrc
if [[ -f "$HOME/.bashrc" ]]; then
    sed -i '' '/# Google Cloud SDK/d' "$HOME/.bashrc"
    sed -i '' '/google-cloud-sdk\/bin/d' "$HOME/.bashrc"
fi

success "$APP_NAME uninstalled successfully!"
