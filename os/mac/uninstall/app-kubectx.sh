#!/usr/bin/env bash
# Uninstall kubectx - Kubernetes context and namespace switching tool

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="kubectx"
BINARY="kubectx"
OS_NAME="macOS"

info "Uninstalling $APP_NAME from $OS_NAME..."

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

# Uninstall via Homebrew
uninstall_brew "kubectx"

# Remove completions symlinks
info "Removing bash completions..."
rm -f "$USER_HOME/.bash_completion.d/kubectx"
rm -f "$USER_HOME/.bash_completion.d/kubens"

success "$APP_NAME uninstalled successfully from $OS_NAME!"
