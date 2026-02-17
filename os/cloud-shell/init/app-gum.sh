#!/usr/bin/env bash
# Cloud Shell init: Install Gum for pretty terminal output
# https://github.com/charmbracelet/gum

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

info "$APP_NAME is required for pretty terminal output"
info "Setting up Charm repository and installing..."

# Install Gum via official Charm repo
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt-get update
sudo apt-get install -y gum

# Verify installation
if command -v gum &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(gum --version 2>/dev/null || echo 'unknown')"
    info "Your dotfiles will now have pretty, colorful output!"
else
    error "$APP_NAME installation failed"
    exit 1
fi
