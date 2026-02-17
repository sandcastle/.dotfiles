#!/usr/bin/env bash
# macOS init: Install Xcode Command Line Tools
# Required for many development tools on macOS

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Xcode Command Line Tools"

info "Installing $APP_NAME..."

# Check if already installed
if xcode-select -p &> /dev/null; then
    info "$APP_NAME are already installed"
    info "Path: $(xcode-select -p)"
    exit 0
fi

info "$APP_NAME are required for compiling software on macOS"
info "Starting installation (this may take several minutes)..."

# Trigger installation
xcode-select --install

# Wait for user to complete installation
warn "A dialog should appear asking you to install Command Line Tools"
warn "Please complete the installation and press Enter to continue..."
read -r

# Verify installation
if xcode-select -p &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Path: $(xcode-select -p)"
else
    error "$APP_NAME installation incomplete"
    info "Please run: xcode-select --install"
    exit 1
fi
