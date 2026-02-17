#!/usr/bin/env bash
# Uninstall kubectx - Kubernetes context and namespace switching tool

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="kubectx"
BINARY="kubectx"
OS_NAME="Windows"

info "Uninstalling $APP_NAME from $OS_NAME..."

# Detect Windows environment
ENV=$(detect_windows_shell)
info "Detected Windows environment: $ENV"

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

case "$ENV" in
    git-bash)
        info "Removing kubectx and kubens..."
        rm -f "$HOME/bin/kubectx.exe"
        rm -f "$HOME/bin/kubens.exe"
        ;;
    wsl)
        info "Removing kubectx and kubens..."
        sudo rm -f /usr/local/bin/kubectx /usr/local/bin/kubens
        
        # Remove completions
        rm -f "$USER_HOME/.bash_completion.d/kubectx"
        rm -f "$USER_HOME/.bash_completion.d/kubens"
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

success "$APP_NAME uninstalled successfully from $OS_NAME ($ENV)!"
