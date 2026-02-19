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

# Remove via apt
if dpkg -l | grep -q "^ii  git-delta"; then
    uninstall_apt "git-delta"
fi

success "$APP_NAME uninstalled successfully!"
