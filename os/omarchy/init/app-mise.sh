#!/usr/bin/env bash
# Init: Install Mise (development environment manager)
# https://mise.jdx.dev/
# 
# Installation method: curl https://mise.run | sh
# This is the official recommended method for all platforms

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Mise"
BINARY="mise"

# Check if Mise is already installed
if command -v "$BINARY" &> /dev/null; then
    info "✓ Mise is already installed ($(${BINARY} --version 2>/dev/null))"
    exit 0
fi

info "Installing mise..."

# Install Mise using the official installer
curl https://mise.run | sh

# Add to PATH for current session
export PATH="$HOME/.local/bin:$PATH"

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "Mise installed ($(${BINARY} --version))"
else
    error "Mise installation failed"
    exit 1
fi

# Add activation to shell rc file if not already present
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "mise activate" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$USER_HOME/.bashrc"
    echo '# Activate mise (development environment manager)' >> "$USER_HOME/.bashrc"
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> "$USER_HOME/.bashrc"
fi

# Install bash completions
mkdir -p "$USER_HOME/.bash_completion.d"
if [[ ! -f "$USER_HOME/.bash_completion.d/mise" ]]; then
    $BINARY completion bash > "$USER_HOME/.bash_completion.d/mise"
fi
