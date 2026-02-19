#!/usr/bin/env bash
# Uninstall Delta (git-delta)

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Delta"
BINARY="delta"

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
            uninstall_winget "dandavison.delta"
        fi
        ;;
    wsl)
        # WSL: Use apt
        if dpkg -l | grep -q "^ii  git-delta"; then
            uninstall_apt "git-delta"
        fi
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

success "$APP_NAME uninstalled successfully!"
