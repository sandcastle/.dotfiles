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

# Detect Windows environment
ENV=$(detect_windows_shell)
info "Detected Windows environment: $ENV"

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(${BINARY} --version 2>/dev/null || echo 'unknown')"
    exit 0
fi

case "$ENV" in
    git-bash)
        info "$APP_NAME - AI-powered coding assistant CLI"
        info "GitHub: https://github.com/opencode-ai/opencode"
        info "Installing for Windows..."
        
        # Download Windows binary
        LATEST_URL="https://github.com/opencode-ai/opencode/releases/latest/download/opencode-windows-x86_64.zip"
        curl -fsSL "$LATEST_URL" -o /tmp/opencode.zip
        
        # Extract to ~/.local/bin
        mkdir -p "$HOME/.local/bin"
        unzip -o /tmp/opencode.zip -d "$HOME/.local/bin"
        rm -f /tmp/opencode.zip
        
        # Ensure PATH
        export PATH="$HOME/.local/bin:$PATH"
        ;;
    wsl)
        info "$APP_NAME - AI-powered coding assistant CLI"
        info "Installing in WSL..."
        
        # Try mise first
        if command -v mise &> /dev/null; then
            mise use --global opencode@latest
        else
            # Download Linux binary
            LATEST_URL="https://github.com/opencode-ai/opencode/releases/latest/download/opencode-linux-x86_64.tar.gz"
            curl -fsSL "$LATEST_URL" -o /tmp/opencode.tar.gz
            
            # Extract to ~/.local/bin
            mkdir -p "$HOME/.local/bin"
            tar -xzf /tmp/opencode.tar.gz -C "$HOME/.local/bin"
            rm -f /tmp/opencode.tar.gz
            
            # Ensure PATH
            export PATH="$HOME/.local/bin:$PATH"
        fi
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

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

# Install bash completions (for WSL)
if [ "$ENV" = "wsl" ]; then
    info "Installing bash completions for opencode..."
    mkdir -p "$USER_HOME/.bash_completion.d"
    if $BINARY completion bash &>/dev/null; then
        $BINARY completion bash > "$USER_HOME/.bash_completion.d/opencode"
        success "Completions installed to ~/.bash_completion.d/opencode"
    fi
    
    # Ensure completion loader is in .bashrc
    if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
        echo '' >> "$USER_HOME/.bashrc"
        echo '# Source bash completions' >> "$USER_HOME/.bashrc"
        echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$USER_HOME/.bashrc"
    fi
fi

# Ensure ~/.local/bin is in PATH
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "\.local/bin" "$HOME/.bashrc" 2>/dev/null; then
    info "Adding ~/.local/bin to PATH..."
    echo '' >> "$USER_HOME/.bashrc"
    echo '# User local bin' >> "$USER_HOME/.bashrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$USER_HOME/.bashrc"
fi
