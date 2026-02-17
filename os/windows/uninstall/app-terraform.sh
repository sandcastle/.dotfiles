#!/usr/bin/env bash
# Uninstall Terraform - Infrastructure as Code tool on Windows

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Terraform"
BINARY="terraform"

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
        warn "To uninstall Terraform on Windows:"
        warn "Run: winget uninstall Hashicorp.Terraform"
        
        # Remove completions
        if [[ -L "$USER_HOME/.bash_completion.d/terraform" ]]; then
            rm -f "$USER_HOME/.bash_completion.d/terraform"
        fi
        ;;
    wsl)
        info "Detected WSL environment"
        info "Uninstalling via apt..."
        
        if dpkg -l terraform &>/dev/null; then
            sudo apt-get remove -y terraform
        fi
        
        # Remove the apt source
        if [[ -f "/etc/apt/sources.list.d/hashicorp.list" ]]; then
            info "Removing HashiCorp APT repository..."
            sudo rm -f /etc/apt/sources.list.d/hashicorp.list
            sudo apt-get update
        fi
        
        # Remove configuration directory if requested
        if [ "$1" = "--purge" ]; then
            if [ -d "$HOME/.terraform.d" ]; then
                info "Removing Terraform configuration..."
                rm -rf "$HOME/.terraform.d"
            fi
            
            # Remove terraform plugin cache
            if [ -d "$HOME/.terraform.plugin-cache" ]; then
                info "Removing Terraform plugin cache..."
                rm -rf "$HOME/.terraform.plugin-cache"
            fi
            
            info "Note: State files in project directories were not removed."
            info "      Delete .terraform directories in your projects manually if needed."
        fi
        
        # Remove completions
        if [[ -f "$USER_HOME/.bash_completion.d/terraform" ]]; then
            rm -f "$USER_HOME/.bash_completion.d/terraform"
        fi
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

success "$APP_NAME uninstallation complete!"
