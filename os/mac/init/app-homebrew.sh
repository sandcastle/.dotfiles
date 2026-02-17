#!/usr/bin/env bash
# macOS init: Install Homebrew
# This is a mandatory prerequisite for macOS dotfiles

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Homebrew"

info "Installing $APP_NAME..."

# Check if Homebrew is already installed
if command -v brew &> /dev/null; then
    info "Homebrew is already installed"
    info "Version: $(brew --version | head -n1)"
    exit 0
fi

info "Homebrew is required for installing packages on macOS"
info "Downloading and installing Homebrew..."

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH for the current session
if [[ "$(uname -m)" == "arm64" ]]; then
    # Apple Silicon Mac
    eval "$(/opt/homebrew/bin/brew shellenv)"
    info "Added Homebrew to PATH for Apple Silicon"
else
    # Intel Mac
    eval "$(/usr/local/bin/brew shellenv)"
    info "Added Homebrew to PATH for Intel Mac"
fi

# Verify installation
if command -v brew &> /dev/null; then
    success "Homebrew installed successfully!"
    info "Version: $(brew --version | head -n1)"
    
    # Run brew doctor to check for any issues
    info "Running brew doctor to check system..."
    brew doctor || true
else
    error "Homebrew installation failed"
    exit 1
fi
