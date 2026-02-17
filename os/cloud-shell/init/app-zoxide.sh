#!/usr/bin/env bash
# Install Zoxide - smarter cd command
# https://github.com/ajeetdsouza/zoxide

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Zoxide"
BINARY="zoxide"

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $($BINARY --version 2>/dev/null | head -1 || echo 'unknown')"
    exit 0
fi

info "$APP_NAME - A smarter cd command"
info "Website: https://github.com/ajeetdsouza/zoxide"

# Install via official install script
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $($BINARY --version 2>/dev/null | head -1)"
else
    error "$APP_NAME installation failed"
    exit 1
fi
