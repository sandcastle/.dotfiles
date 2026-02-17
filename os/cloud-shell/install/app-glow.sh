#!/usr/bin/env bash
# Install Glow - Markdown reader for the terminal
# https://github.com/charmbracelet/glow

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Glow"
BINARY="glow"

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(glow --version 2>/dev/null | head -1 || echo 'unknown')"
    exit 0
fi

info "$APP_NAME - Markdown reader for the terminal"
info "Website: https://github.com/charmbracelet/glow"

# Install via GitHub release (not in standard apt repos)
info "Installing from GitHub release..."

LATEST_VERSION=$(curl -fsSL https://api.github.com/repos/charmbracelet/glow/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [[ -z "$LATEST_VERSION" ]]; then
    error "Could not determine latest version"
    exit 1
fi

info "Downloading Glow $LATEST_VERSION..."
TEMP_DIR=$(mktemp -d)
curl -fsSL "https://github.com/charmbracelet/glow/releases/download/${LATEST_VERSION}/glow_${LATEST_VERSION#v}_linux_x86_64.tar.gz" -o "$TEMP_DIR/glow.tar.gz"

tar -xzf "$TEMP_DIR/glow.tar.gz" -C "$TEMP_DIR"

sudo install -m 755 "$TEMP_DIR/glow" /usr/local/bin/glow

rm -rf "$TEMP_DIR"

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(glow --version 2>/dev/null | head -1)"
    info ""
    info "Usage: glow <file.md> or just 'glow' for interactive UI"
else
    error "$APP_NAME installation failed"
    exit 1
fi

# Install bash completions
info "Installing bash completions..."
mkdir -p "$USER_HOME/.bash_completion.d"

if glow --help 2>/dev/null | grep -q "completion"; then
    glow completion bash > "$USER_HOME/.bash_completion.d/glow" 2>/dev/null || warn "Could not generate completions"
fi

# Ensure completion loader is in .bashrc
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$USER_HOME/.bashrc"
    echo '# Source bash completions' >> "$USER_HOME/.bashrc"
    echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$USER_HOME/.bashrc"
fi

success "Completions installed"
