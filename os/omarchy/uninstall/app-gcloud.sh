#!/usr/bin/env bash
# Uninstall Google Cloud CLI (gcloud) and kubectl

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

# Remove via pacman
if pacman -Q google-cloud-cli &>/dev/null; then
    uninstall_pacman "google-cloud-cli"
fi

# Remove kubectl if installed separately
if command -v kubectl &> /dev/null; then
    if pacman -Q kubectl &>/dev/null; then
        info "Removing kubectl..."
        uninstall_pacman "kubectl"
    fi
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
if [[ -L "/usr/share/bash-completion/completions/gcloud" ]]; then
    sudo rm -f /usr/share/bash-completion/completions/gcloud
fi

if [[ -f "$HOME/.bash_completion.d/gcloud" ]]; then
    rm -f "$HOME/.bash_completion.d/gcloud"
fi

if [[ -L "/usr/share/bash-completion/completions/kubectl" ]]; then
    sudo rm -f /usr/share/bash-completion/completions/kubectl
fi

if [[ -f "$HOME/.bash_completion.d/kubectl" ]]; then
    rm -f "$HOME/.bash_completion.d/kubectl"
fi

# Remove PATH entries from .bashrc
if [[ -f "$HOME/.bashrc" ]]; then
    sed -i '/# Google Cloud SDK/d' "$HOME/.bashrc"
    sed -i '/google-cloud-cli\/bin/d' "$HOME/.bashrc"
fi

success "$APP_NAME uninstalled successfully!"
