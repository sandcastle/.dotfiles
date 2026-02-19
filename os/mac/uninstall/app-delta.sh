#!/usr/bin/env bash
# Uninstall Delta (git-delta)

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Delta"
BINARY="delta"

info "Uninstalling $APP_NAME..."

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

# Remove via Homebrew
if brew list git-delta &>/dev/null 2>&1; then
    uninstall_brew "git-delta"
fi

# Remove completions
if [[ -f "$USER_HOME/.bash_completion.d/delta" ]]; then
    rm -f "$USER_HOME/.bash_completion.d/delta"
fi

success "$APP_NAME uninstalled successfully!"
