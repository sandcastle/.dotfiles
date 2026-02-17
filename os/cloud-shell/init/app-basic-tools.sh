#!/usr/bin/env bash
# Cloud Shell init: Install basic development tools
# These are common tools that may not be pre-installed

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

info "Installing basic development tools..."

# List of tools to ensure are installed
# Note: neovim installs as 'nvim' binary
TOOLS="curl wget git neovim nano tree"

info "Checking and installing basic tools: $TOOLS"

# Update package list
sudo apt-get update

# Install any missing tools
for tool in $TOOLS; do
    if ! command -v "$tool" &> /dev/null; then
        info "Installing $tool..."
        sudo apt-get install -y "$tool" || warn "Failed to install $tool"
    else
        info "$tool is already installed"
    fi
done

success "Basic development tools check complete!"
