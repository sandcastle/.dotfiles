#!/usr/bin/env bash
# Install Glow CLI - Markdown reader for the terminal
# https://github.com/charmbracelet/glow
#
# Render markdown in the terminal with style

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Glow"
BINARY="glow"

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(${BINARY} --version 2>/dev/null || echo 'unknown')"
    exit 0
fi

info "$APP_NAME - A markdown renderer for the terminal"
info "GitHub: https://github.com/charmbracelet/glow"
info "Features: Render markdown files, GitHub/GitLab READMEs, and more"

# Install via Homebrew
info "Installing via Homebrew..."
install_brew "glow"

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(${BINARY} --version)"
    info ""
    info "Usage examples:"
    info "  glow README.md              # Render a local file"
    info "  glow github.com/charmbracelet/glow  # Render a GitHub README"
    info "  glow -p README.md           # Render with paging"
    info "  glow -s dark.json README.md # Use a custom style"
else
    error "$APP_NAME installation failed"
    info "For manual installation: https://github.com/charmbracelet/glow#installation"
    exit 1
fi

# Install bash completions
info "Installing bash completions for glow..."
mkdir -p "$HOME/.bash_completion.d"
if $BINARY completion bash &>/dev/null; then
    $BINARY completion bash > "$HOME/.bash_completion.d/glow"
    success "Completions installed to ~/.bash_completion.d/glow"
fi

# Ensure completion loader is in .bashrc
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo '# Source bash completions' >> "$HOME/.bashrc"
    echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$HOME/.bashrc"
fi
