#!/usr/bin/env bash
# Install Starship - minimal, fast, and customizable prompt
# https://starship.rs

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Starship"
BINARY="starship"

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $($BINARY --version 2>/dev/null | head -1 || echo 'unknown')"
    exit 0
fi

info "$APP_NAME - Minimal, fast, and customizable prompt"
info "Website: https://starship.rs"

# Install via Homebrew
install_brew "starship"

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $($BINARY --version 2>/dev/null | head -1)"
else
    error "$APP_NAME installation failed"
    exit 1
fi
