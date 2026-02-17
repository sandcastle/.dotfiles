#!/usr/bin/env bash
# Uninstall GitHub CLI (gh) on Windows

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="GitHub CLI"
BINARY="gh"

info "Uninstalling $APP_NAME..."

# Check if installed
if ! command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is not installed"
    exit 0
fi

# Detect Windows environment
ENV=$(detect_windows_shell)

case "$ENV" in
    git-bash)
        info "Detected Git Bash environment"
        warn "To uninstall GitHub CLI on Windows:"
        warn "Run: winget uninstall GitHub.cli"
        
        # Remove completions
        if [[ -L "$HOME/.bash_completion.d/gh" ]]; then
            rm -f "$HOME/.bash_completion.d/gh"
        fi
        ;;
    wsl)
        info "Detected WSL environment"
        info "Uninstalling via apt..."
        
        if dpkg -l gh &>/dev/null; then
            sudo apt-get remove -y gh
        fi
        
        # Remove the apt source
        if [[ -f "/etc/apt/sources.list.d/github-cli.list" ]]; then
            sudo rm -f /etc/apt/sources.list.d/github-cli.list
            sudo apt-get update
        fi
        
        # Remove extensions
        if [ -d "$HOME/.local/share/gh" ]; then
            info "Removing gh extensions..."
            rm -rf "$HOME/.local/share/gh"
        fi
        
        # Remove configuration if requested
        if [ "$1" = "--purge" ]; then
            if [ -d "$HOME/.config/gh" ]; then
                info "Removing gh configuration..."
                rm -rf "$HOME/.config/gh"
            fi
        fi
        
        # Remove completions
        if [[ -f "$HOME/.bash_completion.d/gh" ]]; then
            rm -f "$HOME/.bash_completion.d/gh"
        fi
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

success "$APP_NAME uninstallation complete!"
