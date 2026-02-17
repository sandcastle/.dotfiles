#!/usr/bin/env bash
# Install Starship - minimal, fast, and customizable prompt
# https://starship.rs

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Starship"
BINARY="starship"
ENV=$(detect_windows_shell)

info "Installing $APP_NAME on Windows ($ENV)..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $($BINARY --version 2>/dev/null | head -1 || echo 'unknown')"
    exit 0
fi

info "$APP_NAME - Minimal, fast, and customizable prompt"
info "Website: https://starship.rs"

case "$ENV" in
    git-bash)
        # Install via official install script
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        ;;
    wsl)
        # Install via official install script in WSL
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully on Windows ($ENV)!"
    info "Version: $($BINARY --version 2>/dev/null | head -1)"
else
    error "$APP_NAME installation failed on Windows ($ENV)"
    exit 1
fi
