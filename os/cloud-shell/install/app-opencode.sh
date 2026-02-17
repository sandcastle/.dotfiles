#!/usr/bin/env bash
# Install Opencode - CLI tool for OpenCode
# https://opencode.ai

set -e
# Redirect output if SILENT mode is enabled
if [[ "${SILENT:-false}" == true ]]; then
    exec > /dev/null 2>&1
fi

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Opencode"
BINARY="opencode"

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(opencode --version 2>/dev/null || echo 'unknown')"
    exit 0
fi

info "$APP_NAME - CLI tool for OpenCode"
info "Website: https://opencode.ai"

# Install via npm (recommended method for opencode)
if command -v npm &> /dev/null; then
    info "Installing via npm..."
    sudo npm install -g opencode
else
    warn "npm is not installed. Installing npm first..."
    sudo apt-get update
    sudo apt-get install -y npm
    sudo npm install -g opencode
fi

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Run 'opencode --help' to get started"
else
    error "$APP_NAME installation failed"
    exit 1
fi

# Install bash completions
info "Installing bash completions..."
mkdir -p "$USER_HOME/.bash_completion.d"

if opencode --help 2>/dev/null | grep -q "completion"; then
    opencode completion bash > "$USER_HOME/.bash_completion.d/opencode" 2>/dev/null || warn "Could not generate completions"
fi

# Ensure completion loader is in .bashrc
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$USER_HOME/.bashrc"
    echo '# Source bash completions' >> "$USER_HOME/.bashrc"
    echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$USER_HOME/.bashrc"
fi

success "Completions installed"

exit 0
