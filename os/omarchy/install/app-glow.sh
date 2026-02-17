#!/usr/bin/env bash
# Install Glow CLI - Markdown reader for the terminal
# https://github.com/charmbracelet/glow
#
# Render markdown in the terminal with style

set -e
# Redirect output if SILENT mode is enabled
if [[ "${SILENT:-false}" == true ]]; then
    exec > /dev/null 2>&1
fi

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

# Check if sudo is available for package installation
if ! sudo -n true 2>/dev/null; then
    warn "Package installation requires sudo privileges"
    warn "Please run: sudo -v  # To authenticate, then re-run this script"
    exit 1
fi

# Install via pacman (Charm packages are in official repos)
info "Installing from Arch repositories..."
if check_pacman_package "glow"; then
    install_pacman "glow"
else
    info "Installing from AUR..."
    install_yay "glow"
fi

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

if [[ -d "/usr/share/bash-completion/completions" ]]; then
    if $BINARY completion bash &>/dev/null; then
        $BINARY completion bash | sudo tee /usr/share/bash-completion/completions/glow > /dev/null
        success "Completions installed to /usr/share/bash-completion/completions/glow"
    fi
elif [[ -d "/etc/bash_completion.d" ]]; then
    if $BINARY completion bash &>/dev/null; then
        $BINARY completion bash | sudo tee /etc/bash_completion.d/glow > /dev/null
        success "Completions installed to /etc/bash_completion.d/glow"
    fi
else
    # User-local
    mkdir -p "$USER_HOME/.bash_completion.d"
    if $BINARY completion bash &>/dev/null; then
        $BINARY completion bash > "$USER_HOME/.bash_completion.d/glow"
        success "Completions installed to ~/.bash_completion.d/glow"
    fi
fi

# Ensure completion loader is in .bashrc
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$USER_HOME/.bashrc"
    echo '# Source bash completions' >> "$USER_HOME/.bashrc"
    echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$USER_HOME/.bashrc"
fi

exit 0
