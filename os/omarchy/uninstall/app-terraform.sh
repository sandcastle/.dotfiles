#!/usr/bin/env bash
# Uninstall Terraform - Infrastructure as Code tool

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

info "Uninstalling Terraform..."

# Remove via pacman
if pacman -Q terraform &>/dev/null; then
    uninstall_pacman "terraform"
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
    
    # Remove local state files
    info "Note: State files in project directories were not removed."
    info "      Delete .terraform directories in your projects manually if needed."
fi

# Remove completions
if [[ -L "/usr/share/bash-completion/completions/terraform" ]]; then
    sudo rm -f /usr/share/bash-completion/completions/terraform
fi

if [[ -f "/etc/bash_completion.d/terraform" ]]; then
    sudo rm -f /etc/bash_completion.d/terraform
fi

if [[ -f "$USER_HOME/.bash_completion.d/terraform" ]]; then
    rm -f "$USER_HOME/.bash_completion.d/terraform"
fi

success "$APP_NAME uninstalled successfully!"
