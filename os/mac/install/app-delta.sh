#!/usr/bin/env bash
# Install Delta - A syntax-highlighting pager for git and diff output
# https://github.com/dandavison/delta
#
# Features: Syntax highlighting, side-by-side view, line numbers, git integration

set -e
# Redirect output if SILENT mode is enabled
if [[ "${SILENT:-false}" == true ]]; then
    exec > /dev/null 2>&1
fi

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Delta"
BINARY="delta"

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(${BINARY} --version 2>/dev/null | head -1 || echo 'unknown')"
    exit 0
fi

info "$APP_NAME - A syntax-highlighting pager for git and diff output"
info "Website: https://github.com/dandavison/delta"
info "Features: Syntax highlighting, side-by-side view, line numbers, git integration"

# Install via Homebrew
info "Installing via Homebrew..."
install_brew "git-delta"

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(${BINARY} --version | head -1)"
    info ""
    info "To use Delta with Git, add to your ~/.gitconfig:"
    info "  [pager]"
    info "    diff = delta"
    info "    log = delta"
    info "    reflog = delta"
    info "    show = delta"
    info ""
    info "Or run: delta --setup"
else
    error "$APP_NAME installation failed"
    info "For manual installation: https://github.com/dandavison/delta/releases"
    exit 1
fi

# Install bash completions
info "Installing bash completions for delta..."
mkdir -p "$USER_HOME/.bash_completion.d"

if $BINARY --help 2>/dev/null | grep -q "completion"; then
    $BINARY --generate-bash-completions 2>/dev/null > "$USER_HOME/.bash_completion.d/delta" || warn "Could not generate completions"
fi

exit 0
