#!/usr/bin/env bash
# Install Helm - The Kubernetes Package Manager
# https://helm.sh/
#
# Features: Package management for Kubernetes, chart repositories, release management

set -e
# Redirect output if SILENT mode is enabled
if [[ "${SILENT:-false}" == true ]]; then
    exec > /dev/null 2>&1
fi

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Helm"
BINARY="helm"

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(${BINARY} version --short 2>/dev/null || echo 'unknown')"
    exit 0
fi

info "$APP_NAME - The Kubernetes Package Manager"
info "Website: https://helm.sh/"
info "Features: Package management for Kubernetes, chart repositories, release management"

# Install via pacman (helm is in official repos)
info "Installing from Arch repositories..."
install_pacman "helm"

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(helm version --short)"
    info ""
    info "Common commands:"
    info "  helm repo add stable https://charts.helm.sh/stable"
    info "  helm search repo nginx"
    info "  helm install my-release stable/nginx"
    info "  helm list"
    info "  helm uninstall my-release"
else
    error "$APP_NAME installation failed"
    info "For manual installation: https://helm.sh/docs/intro/install/"
    exit 1
fi

# Install bash completions
info "Installing bash completions for helm..."

if [[ -d "/usr/share/bash-completion/completions" ]]; then
    if $BINARY completion bash &>/dev/null; then
        $BINARY completion bash | sudo tee /usr/share/bash-completion/completions/helm > /dev/null
        success "Completions installed to /usr/share/bash-completion/completions/helm"
    fi
elif [[ -d "/etc/bash_completion.d" ]]; then
    if $BINARY completion bash &>/dev/null; then
        $BINARY completion bash | sudo tee /etc/bash_completion.d/helm > /dev/null
        success "Completions installed to /etc/bash_completion.d/helm"
    fi
else
    mkdir -p "$USER_HOME/.bash_completion.d"
    if $BINARY completion bash &>/dev/null; then
        $BINARY completion bash > "$USER_HOME/.bash_completion.d/helm"
        success "Completions installed to ~/.bash_completion.d/helm"
    fi
fi

exit 0
