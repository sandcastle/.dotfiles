#!/usr/bin/env bash
# Windows init: Install Gum for pretty terminal output
# https://github.com/charmbracelet/gum
#
# Official install for Windows:
#   winget install charmbracelet.gum
#   or
#   scoop install charm-gum

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Gum"

info "Installing $APP_NAME..."

# Check if Gum is already installed
if command -v gum &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(gum --version 2>/dev/null || echo 'unknown')"
    exit 0
fi

info "$APP_NAME provides pretty terminal UI components"
info "GitHub: https://github.com/charmbracelet/gum"
info ""

# Detect Windows environment
ENV=$(detect_windows_shell)

case "$ENV" in
    git-bash)
        info "Installing via winget..."
        if command -v winget &> /dev/null; then
            install_winget "charmbracelet.gum"
        else
            warn "winget not found. Please install winget or download Gum manually"
            info "Download from: https://github.com/charmbracelet/gum/releases"
            exit 1
        fi
        ;;
    wsl)
        info "Installing in WSL (using apt repository)..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt-get update
        sudo apt-get install -y gum
        ;;
    *)
        error "Unknown Windows environment"
        exit 1
        ;;
esac

# Verify installation
if command -v gum &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(gum --version 2>/dev/null || echo 'unknown')"
    info "Your dotfiles will now have pretty, colorful output!"
else
    error "$APP_NAME installation failed"
    info "For manual installation, see: https://github.com/charmbracelet/gum#installation"
    exit 1
fi
