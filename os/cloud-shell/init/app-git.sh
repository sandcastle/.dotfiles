#!/usr/bin/env bash
# Cloud Shell init: Install Git
# Git should already be present in Cloud Shell, but verify

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Git"

info "Verifying $APP_NAME..."

# Cloud Shell should already have git
if command -v git &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(git --version)"
    exit 0
fi

# Edge case: if git is somehow missing
info "$APP_NAME is required but not found"
info "Attempting to install via apt..."
install_apt "git"

# Verify
if command -v git &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(git --version)"
else
    error "$APP_NAME installation failed"
    exit 1
fi
