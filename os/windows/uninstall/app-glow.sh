#!/usr/bin/env bash
# Uninstall Glow CLI on Windows

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Glow"
BINARY="glow"

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
        warn "To uninstall Glow on Windows:"
        warn "Run: winget uninstall Charmbracelet.Glow"
        
        # Remove completions
        if [[ -L "$USER_HOME/.bash_completion.d/glow" ]]; then
            rm -f "$USER_HOME/.bash_completion.d/glow"
        fi
        ;;
    wsl)
        info "Detected WSL environment"
        info "Uninstalling via apt..."
        
        if dpkg -l glow &>/dev/null; then
            sudo apt-get remove -y glow
        fi
        
        # Remove the apt source if it was added by us
        if [[ -f "/etc/apt/sources.list.d/charm.list" ]]; then
            # Check if glow was the only charm package
            if ! dpkg -l | grep -q "gum\|glow" | grep -v "^rc"; then
                sudo rm -f /etc/apt/sources.list.d/charm.list
                sudo apt-get update
            fi
        fi
        
        # Remove configuration if requested
        if [ "$1" = "--purge" ]; then
            if [ -d "$HOME/.config/glow" ]; then
                info "Removing glow configuration..."
                rm -rf "$HOME/.config/glow"
            fi
        fi
        
        # Remove completions
        if [[ -L "/usr/share/glow/completion.bash.inc" ]]; then
            sudo rm -f /usr/share/glow/completion.bash.inc
        fi
        
        if [[ -L "$USER_HOME/.bash_completion.d/glow" ]]; then
            rm -f "$USER_HOME/.bash_completion.d/glow"
        fi
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

success "$APP_NAME uninstallation complete!"
