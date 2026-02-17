#!/usr/bin/env bash
# Main dotfiles installer - detects OS and runs appropriate installer
# Located in os/install.sh - called by go.sh from root
#
# Usage: ./install.sh [--all] [--debug] [--help]
#   --all    Install all available apps after dotfiles setup
#   --debug  Show verbose output with paths and details

set -e

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source common functions
source "$DOTFILES_ROOT/lib/common.sh"

# Parse arguments to pass through to OS installer
INSTALL_ARGS=""
DEBUG=false

for arg in "$@"; do
    case "$arg" in
        --all)
            INSTALL_ARGS="$INSTALL_ARGS --all"
            ;;
        --debug)
            DEBUG=true
            INSTALL_ARGS="$INSTALL_ARGS --debug"
            export DEBUG
            ;;
        --help|-h)
            echo "Usage: $(basename "$0") [--all] [--debug] [--help]"
            echo "  --all    Install all available apps after dotfiles setup"
            echo "  --debug  Show verbose output with paths and details"
            echo "  --help   Show this help message"
            exit 0
            ;;
    esac
done

# Try to install gum for pretty output (optional)
ensure_gum 2>/dev/null || true

OS=$(detect_os)
WINDOWS_SHELL=$(detect_windows_shell)

info "Installing dotfiles for $OS"
$DEBUG && info "Location: $DOTFILES_ROOT"

# Request sudo upfront for Linux systems (caches credentials for later use)
if [[ "$OS" == "omarchy" || "$OS" == "arch" || "$OS" == "cloud-shell" ]]; then
    if command -v sudo &> /dev/null; then
        if ! sudo -n true 2>/dev/null; then
            info "Some operations require sudo privileges"
            info "Please enter your password to continue..."
            if ! sudo -v; then
                error "sudo authentication failed"
                exit 1
            fi
            # Keep sudo alive in the background
            (while true; do sleep 60; sudo -n true 2>/dev/null || break; done) &
            SUDO_KEEPALIVE_PID=$!
        fi
    fi
fi

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

# Cleanup sudo keepalive process if it was started
if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
fi

success "Installation complete! Restart your terminal or run: source ~/.bashrc"
