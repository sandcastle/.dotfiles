#!/usr/bin/env bash
# Install Terraform - Infrastructure as Code tool
# https://www.terraform.io/
#
# Terraform enables you to safely and predictably create, change, and
# improve infrastructure using code.

set -e
# Redirect output if SILENT mode is enabled
if [[ "${SILENT:-false}" == true ]]; then
    exec > /dev/null 2>&1
fi

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Terraform"
BINARY="terraform"

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(${BINARY} version 2>/dev/null | head -1 || echo 'unknown')"
    exit 0
fi

info "$APP_NAME - Infrastructure as Code tool"
info "Website: https://www.terraform.io/"
info "Features: Multi-cloud provisioning, state management, plan/apply workflow"

# Install via Homebrew
info "Installing via Homebrew..."
install_brew "terraform"

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(${BINARY} version | head -1)"
    info ""
    info "Next steps:"
    info "  1. Run 'terraform init' to initialize a new project"
    info "  2. Run 'terraform plan' to preview changes"
    info ""
    info "Common commands:"
    info "  terraform init              # Initialize working directory"
    info "  terraform plan              # Show execution plan"
    info "  terraform apply             # Apply changes"
    info "  terraform destroy           # Destroy infrastructure"
    info "  terraform validate          # Validate configuration"
else
    error "$APP_NAME installation failed"
    info "For manual installation: https://developer.hashicorp.com/terraform/install"
    exit 1
fi

# Install bash completions
info "Installing bash completions for terraform..."
mkdir -p "$USER_HOME/.bash_completion.d"
# terraform has built-in autocomplete support
if $BINARY -help 2>/dev/null | grep -q "autocomplete"; then
    $BINARY -install-autocomplete 2>/dev/null || true
    # Move completions to user-local if created in system location
    if [[ -f "/etc/bash_completion.d/terraform" ]]; then
        mv /etc/bash_completion.d/terraform "$USER_HOME/.bash_completion.d/terraform" 2>/dev/null || true
        success "Completions installed to ~/.bash_completion.d/terraform"
    elif [[ -f "$USER_HOME/.bash_completion.d/terraform" ]]; then
        success "Completions installed to ~/.bash_completion.d/terraform"
    fi
fi

# Ensure completion loader is in .bashrc
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$USER_HOME/.bashrc"
    echo '# Source bash completions' >> "$USER_HOME/.bashrc"
    echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$USER_HOME/.bashrc"
fi

exit 0
