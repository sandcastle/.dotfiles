#!/usr/bin/env bash
# Uninstall Moor pager

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Moor"
BINARY="moor"

info "Uninstalling $APP_NAME..."

# Detect Windows environment
ENV=$(detect_windows_shell)
info "Detected environment: $ENV"

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

# Uninstall based on environment
case "$ENV" in
    git-bash)
        # Git Bash: Use winget
        if command -v winget &> /dev/null; then
            uninstall_winget "walles.moor"
        fi
        ;;
    wsl)
        # WSL: Use apt
        if dpkg -l | grep -q "^ii  moor"; then
            uninstall_apt "moor"
        fi
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

# Remove config directory if --purge
if [ "$1" = "--purge" ]; then
    if [ -d "$HOME/.config/moor" ]; then
        info "Removing Moor configuration..."
        rm -rf "$HOME/.config/moor"
    fi
fi

success "$APP_NAME uninstalled successfully!"
