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

# Detect Windows environment
ENV=$(detect_windows_shell)
info "Detected environment: $ENV"

# Install based on environment
case "$ENV" in
    git-bash)
        # Git Bash: Use winget
        if command -v winget &> /dev/null; then
            install_winget "Helm.Helm"
        else
            error "winget not found. Please install winget or use WSL."
            exit 1
        fi
        ;;
    wsl)
        # WSL: Use official Helm install script
        info "Installing Helm using official script..."
        curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

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

exit 0
