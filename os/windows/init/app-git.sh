#!/usr/bin/env bash
# Windows init: Verify Git installation
# Git Bash comes with Git, but this ensures it's properly configured

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Git"

info "Verifying $APP_NAME..."

# Check if Git is installed
if ! command -v git &> /dev/null; then
    error "Git is not installed!"
    warn "Please install Git for Windows from: https://git-scm.com/download/win"
    warn "Git Bash is included with Git for Windows"
    exit 1
fi

info "Git is installed"
info "Version: $(git --version)"

# Check Git configuration
if [ -z "$(git config --global user.name 2>/dev/null)" ]; then
    warn "Git user.name is not set"
    info "Run: git config --global user.name 'Your Name'"
fi

if [ -z "$(git config --global user.email 2>/dev/null)" ]; then
    warn "Git user.email is not set"
    info "Run: git config --global user.email 'your.email@example.com'"
fi

success "Git verification complete!"
