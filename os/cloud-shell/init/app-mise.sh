#!/usr/bin/env bash
# Cloud Shell init: Install Mise (development environment manager)
# https://mise.jdx.dev/

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Mise"
BINARY="mise"

info "Installing $APP_NAME..."

# Check if Mise is already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(${BINARY} --version 2>/dev/null || echo 'unknown')"
    exit 0
fi

info "$APP_NAME is a development environment manager"
info "It manages language versions: Node.js, Python, Ruby, etc."

# Install Mise using the official installer
info "Installing via official installer..."
curl https://mise.run | sh

# Add to PATH for current session
export PATH="$HOME/.local/bin:$PATH"

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(${BINARY} --version)"
    info "Run 'mise --help' to get started"
else
    error "$APP_NAME installation may have failed"
    info "Please check https://mise.jdx.dev/getting-started.html for manual installation"
    exit 1
fi

# Add activation to shell rc file if not already present
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "mise activate" "$HOME/.bashrc" 2>/dev/null; then
    info "Adding mise activation to ~/.bashrc..."
    echo '' >> "$HOME/.bashrc"
    echo '# Activate mise (development environment manager)' >> "$HOME/.bashrc"
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> "$HOME/.bashrc"
fi

# Install bash completions
info "Installing bash completions for mise..."
mkdir -p "$HOME/.bash_completion.d"
if [[ ! -f "$HOME/.bash_completion.d/mise" ]]; then
    $BINARY completion bash > "$HOME/.bash_completion.d/mise"
    success "Completions installed to ~/.bash_completion.d/mise"
fi

# Add completion sourcing to .bashrc if not present
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo '# Source bash completions' >> "$HOME/.bashrc"
    echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$HOME/.bashrc"
fi
