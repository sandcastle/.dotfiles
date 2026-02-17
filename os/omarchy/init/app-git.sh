#!/usr/bin/env bash
# Init: Install Git
# Git is required for dotfiles to function

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

# Check if Git is already installed
if command -v git &> /dev/null; then
    info "✓ Git is already installed ($(git --version | cut -d' ' -f3))"
    exit 0
fi

# Omarchy should already have git, but handle edge case
info "Installing git..."

# Try pacman first, then yay
if check_pacman_package "git"; then
    install_pacman "git"
else
    install_yay "git"
fi

# Verify installation
if command -v git &> /dev/null; then
    success "Git installed ($(git --version | cut -d' ' -f3))"
else
    error "Git installation failed"
    exit 1
fi

# Ensure bash completions are loaded in .bashrc
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash-completion/bash_completion" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo '# Load bash completions for git and other tools' >> "$HOME/.bashrc"
    echo 'if [ -f /usr/share/bash-completion/bash_completion ]; then' >> "$HOME/.bashrc"
    echo '    . /usr/share/bash-completion/bash_completion' >> "$HOME/.bashrc"
    echo 'elif [ -f /etc/bash_completion ]; then' >> "$HOME/.bashrc"
    echo '    . /etc/bash_completion' >> "$HOME/.bashrc"
    echo 'fi' >> "$HOME/.bashrc"
fi
