#!/usr/bin/env bash
# macOS init: Install Git
# Git is required for dotfiles to function

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Git"

info "Installing $APP_NAME..."

# Check if Git is already installed
if command -v git &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(git --version)"
    exit 0
fi

# macOS usually comes with an older git via Xcode CLT
# But we want a recent version via Homebrew
info "$APP_NAME is required for dotfiles to function"
info "Installing via Homebrew..."

install_brew "git"

# Verify installation
if command -v git &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(git --version)"
else
    error "$APP_NAME installation failed"
    exit 1
fi
