#!/usr/bin/env bash
# Install kubectx - Kubernetes context and namespace switching tool
# https://github.com/ahmetb/kubectx
# Installs both kubectx and kubens binaries

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="kubectx"
BINARY="kubectx"
OS_NAME="macOS"

info "Installing $APP_NAME on $OS_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(kubectx --version 2>/dev/null || echo 'installed')"
    exit 0
fi

info "$APP_NAME - Kubernetes context and namespace switcher"
info "Website: https://github.com/ahmetb/kubectx"

# Install via Homebrew
info "Installing via Homebrew..."
install_brew "kubectx"

# Verify installations
if command -v kubectx &> /dev/null && command -v kubens &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Installed tools:"
    info "  kubectx - switch between Kubernetes contexts"
    info "  kubens - switch between Kubernetes namespaces"
    info ""
    info "Usage:"
    info "  kubectx <context>        # Switch context"
    info "  kubectx -                # Switch to previous context"
    info "  kubens <namespace>       # Switch namespace"
    info "  kubens -                 # Switch to previous namespace"
else
    error "$APP_NAME installation failed"
    exit 1
fi

# Install bash completions
info "Installing bash completions..."
mkdir -p "$HOME/.bash_completion.d"

# Homebrew installs completions automatically, but link them if needed
if [[ -f "$(brew --prefix)/etc/bash_completion.d/kubectx" ]]; then
    ln -sf "$(brew --prefix)/etc/bash_completion.d/kubectx" "$HOME/.bash_completion.d/kubectx"
    success "kubectx completions linked"
fi

if [[ -f "$(brew --prefix)/etc/bash_completion.d/kubens" ]]; then
    ln -sf "$(brew --prefix)/etc/bash_completion.d/kubens" "$HOME/.bash_completion.d/kubens"
    success "kubens completions linked"
fi

# Ensure completion loader is in .bashrc
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo '# Source bash completions' >> "$HOME/.bashrc"
    echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$HOME/.bashrc"
fi

success "Completions installed"
