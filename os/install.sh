#!/usr/bin/env bash
# Main dotfiles installer - detects OS and runs appropriate installer
# Located in os/install.sh - called by go.sh from root
#
# Usage: ./install.sh [--all] [--help]
#   --all  Install all available apps after dotfiles setup

set -e

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source common functions
source "$DOTFILES_ROOT/lib/common.sh"

# Parse arguments to pass through to OS installer
INSTALL_ARGS=""
for arg in "$@"; do
    case "$arg" in
        --all)
            INSTALL_ARGS="$INSTALL_ARGS --all"
            ;;
        --help|-h)
            echo "Usage: $(basename "$0") [--all] [--help]"
            echo "  --all  Install all available apps after dotfiles setup"
            echo "  --help Show this help message"
            exit 0
            ;;
    esac
done

# Try to install gum for pretty output (optional)
ensure_gum 2>/dev/null || true

OS=$(detect_os)
WINDOWS_SHELL=$(detect_windows_shell)

info "Installing dotfiles for $OS"
info "Location: $DOTFILES_ROOT"

# Function to run OS-specific init
case "$OS" in
    omarchy|arch)
        INIT_SCRIPT="$DOTFILES_ROOT/os/omarchy/init.sh"
        INSTALLER="$DOTFILES_ROOT/os/omarchy/install.sh"
        ;;
    mac)
        INIT_SCRIPT="$DOTFILES_ROOT/os/mac/init.sh"
        INSTALLER="$DOTFILES_ROOT/os/mac/install.sh"
        ;;
    cloud-shell)
        INIT_SCRIPT="$DOTFILES_ROOT/os/cloud-shell/init.sh"
        INSTALLER="$DOTFILES_ROOT/os/cloud-shell/install.sh"
        ;;
    windows|wsl)
        INIT_SCRIPT="$DOTFILES_ROOT/os/windows/init.sh"
        INSTALLER="$DOTFILES_ROOT/os/windows/install.sh"
        ;;
    unknown)
        error "Unable to detect operating system."
        info "OSTYPE: $OSTYPE"
        warn "Please run the OS-specific installer manually from $DOTFILES_ROOT/os/"
        exit 1
        ;;
esac

# Run initialization first (if init script exists)
if [ -f "$INIT_SCRIPT" ]; then
    bash "$INIT_SCRIPT"
fi

# Run main installation (passing through arguments)
if [ -f "$INSTALLER" ]; then
    bash "$INSTALLER" $INSTALL_ARGS
else
    error "Installer not found at $INSTALLER"
    exit 1
fi

success "Installation complete! Restart your terminal or run: source ~/.bashrc"
