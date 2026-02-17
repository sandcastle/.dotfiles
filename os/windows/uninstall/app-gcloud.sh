#!/usr/bin/env bash
# Uninstall Google Cloud CLI (gcloud) and kubectl on Windows

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Google Cloud CLI"
BINARY="gcloud"

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
        warn "To uninstall Google Cloud SDK on Windows:"
        warn "1. Go to Windows Settings > Apps > Google Cloud SDK"
        warn "2. Click Uninstall"
        warn ""
        warn "Or use Windows Control Panel to uninstall"
        
        # Remove completions
        if [[ -L "$USER_HOME/.bash_completion.d/gcloud" ]]; then
            rm -f "$USER_HOME/.bash_completion.d/gcloud"
        fi
        
        if [[ -f "$USER_HOME/.bash_completion.d/kubectl" ]]; then
            rm -f "$USER_HOME/.bash_completion.d/kubectl"
        fi
        
        # Remove PATH entries from .bashrc
        if [[ -f "$HOME/.bashrc" ]]; then
            sed -i '/# Google Cloud SDK/d' "$HOME/.bashrc"
            sed -i '/google-cloud-sdk\/bin/d' "$HOME/.bashrc"
        fi
        ;;
    wsl)
        info "Detected WSL environment"
        info "Uninstalling via apt..."
        
        # Remove via apt
        if dpkg -l google-cloud-cli &>/dev/null; then
            sudo apt-get remove -y google-cloud-cli kubectl google-cloud-sdk-gke-gcloud-auth-plugin
        fi
        
        # Remove the apt source
        if [[ -f "/etc/apt/sources.list.d/google-cloud-sdk.list" ]]; then
            sudo rm -f /etc/apt/sources.list.d/google-cloud-sdk.list
            sudo apt-get update
        fi
        
        # Remove configuration directory if requested
        if [ "$1" = "--purge" ]; then
            if [ -d "$HOME/.config/gcloud" ]; then
                info "Removing gcloud configuration..."
                rm -rf "$HOME/.config/gcloud"
            fi
            
            if [ -d "$HOME/.kube" ]; then
                info "Removing kubectl configuration..."
                rm -rf "$HOME/.kube"
            fi
        fi
        
        # Remove completions
        if [[ -L "/usr/share/google-cloud-sdk/completion.bash.inc" ]]; then
            sudo rm -f /usr/share/google-cloud-sdk/completion.bash.inc
        fi
        
        if [[ -L "$USER_HOME/.bash_completion.d/gcloud" ]]; then
            rm -f "$USER_HOME/.bash_completion.d/gcloud"
        fi
        
        if [[ -f "$USER_HOME/.bash_completion.d/kubectl" ]]; then
            rm -f "$USER_HOME/.bash_completion.d/kubectl"
        fi
        
        # Remove PATH entries from .bashrc
        if [[ -f "$HOME/.bashrc" ]]; then
            sed -i '/# Google Cloud SDK/d' "$HOME/.bashrc"
            sed -i '/google-cloud-cli\/bin/d' "$HOME/.bashrc"
        fi
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

success "$APP_NAME uninstallation complete!"
