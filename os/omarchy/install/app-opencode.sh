#!/usr/bin/env bash
# Install OpenCode CLI
# https://github.com/opencode-ai/opencode
#
# OpenCode - AI-powered coding assistant CLI

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="OpenCode"
BINARY="opencode"

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(${BINARY} --version 2>/dev/null || echo 'unknown')"
    exit 0
fi

info "$APP_NAME - AI-powered coding assistant CLI"
info "GitHub: https://github.com/opencode-ai/opencode"
info "Features: AI code generation, refactoring, explanation, and more"

# Try to install via mise first (recommended)
if command -v mise &> /dev/null; then
    info "Installing via mise..."
    mise use --global opencode@latest
elif check_pacman_package "opencode"; then
    # Try pacman
    install_pacman "opencode"
else
    # Fallback to manual install
    info "Installing from GitHub releases..."
    
    # Detect architecture
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)
            ARCH="x86_64"
            ;;
        aarch64|arm64)
            ARCH="arm64"
            ;;
        *)
            error "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac
    
    # Download latest release
    LATEST_URL="https://github.com/opencode-ai/opencode/releases/latest/download/opencode-linux-${ARCH}.tar.gz"
    curl -fsSL "$LATEST_URL" -o /tmp/opencode.tar.gz
    
    # Extract to ~/.local/bin
    mkdir -p "$HOME/.local/bin"
    tar -xzf /tmp/opencode.tar.gz -C "$HOME/.local/bin"
    rm -f /tmp/opencode.tar.gz
    
    # Ensure ~/.local/bin is in PATH
    export PATH="$HOME/.local/bin:$PATH"
fi

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(${BINARY} --version 2>/dev/null || echo 'unknown')"
    info ""
    info "Next steps:"
    info "  1. Set your API key: export OPENAI_API_KEY=your_key"
    info "  2. Run 'opencode --help' to see available commands"
    info ""
    info "Common commands:"
    info "  opencode ask \"How do I refactor this?\""
    info "  opencode explain main.py"
    info "  opencode generate test.py"
else
    error "$APP_NAME installation failed"
    info "For manual installation: https://github.com/opencode-ai/opencode#installation"
    exit 1
fi

# Install bash completions if available
info "Installing bash completions for opencode..."
mkdir -p "$HOME/.bash_completion.d"
if $BINARY completion bash &>/dev/null; then
    $BINARY completion bash > "$HOME/.bash_completion.d/opencode"
    success "Completions installed to ~/.bash_completion.d/opencode"
fi

# Ensure completion loader is in .bashrc
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo '# Source bash completions' >> "$HOME/.bashrc"
    echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$HOME/.bashrc"
fi

# Ensure ~/.local/bin is in PATH
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "\.local/bin" "$HOME/.bashrc" 2>/dev/null; then
    info "Adding ~/.local/bin to PATH..."
    echo '' >> "$HOME/.bashrc"
    echo '# User local bin' >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi
