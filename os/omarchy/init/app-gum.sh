#!/usr/bin/env bash
# Omarchy init: Install Gum for pretty terminal output
# https://github.com/charmbracelet/gum
#
# Official install: pacman -S gum (Arch Linux) or yay -S gum (AUR)

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

# Check if Gum is already installed
if command -v gum &> /dev/null; then
    info "✓ Gum is already installed ($(gum --version 2>/dev/null | awk '{print $3}'))"
    exit 0
fi

info "Installing gum..."

# Try official Arch repos first, then AUR
if check_pacman_package "gum"; then
    install_pacman "gum"
else
    install_yay "gum"
fi

# Verify installation
if command -v gum &> /dev/null; then
    success "Gum installed ($(gum --version 2>/dev/null | awk '{print $3}'))"
else
    error "Gum installation failed"
    exit 1
fi
