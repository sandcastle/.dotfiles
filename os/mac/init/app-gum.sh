#!/usr/bin/env bash
# macOS init: Install Gum for pretty terminal output
# This enhances the visual experience of all dotfiles scripts

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Gum"

info "Installing $APP_NAME..."

# Check if Gum is already installed
if command -v gum &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(gum --version 2>/dev/null || echo 'unknown')"
    exit 0
fi

info "Installing Gum via Homebrew..."
install_brew "gum"

# Verify installation
if command -v gum &> /dev/null; then
    success "Gum installed successfully!"
    info "Version: $(gum --version 2>/dev/null || echo 'unknown')"
    info "Your dotfiles will now have pretty, colorful output!"
else
    error "Gum installation failed"
    exit 1
fi
