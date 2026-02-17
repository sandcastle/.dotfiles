#!/usr/bin/env bash
# Uninstall kubectx - Kubernetes context and namespace switching tool

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="kubectx"
BINARY="kubectx"
OS_NAME="Omarchy"

info "Uninstalling $APP_NAME from $OS_NAME..."

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

# Uninstall via pacman/yay
if pacman -Qi kubectx &>/dev/null; then
    uninstall_pacman "kubectx"
else
    # Manually installed, remove binaries
    info "Removing manually installed binaries..."
    sudo rm -f /usr/local/bin/kubectx /usr/local/bin/kubens
fi

# Remove completions
info "Removing bash completions..."
rm -f "$USER_HOME/.bash_completion.d/kubectx"
rm -f "$USER_HOME/.bash_completion.d/kubens"

success "$APP_NAME uninstalled successfully from $OS_NAME!"
