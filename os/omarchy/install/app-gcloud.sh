#!/usr/bin/env bash
# Install Google Cloud CLI (gcloud) with kubectl
# https://cloud.google.com/sdk/docs/install
#
# Also installs: kubectl (via gcloud components)

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Google Cloud CLI"
BINARY="gcloud"
DEBUG=${DEBUG:-false}

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(${BINARY} --version 2>/dev/null | head -1 || echo 'unknown')"
    
    # Ensure kubectl is also installed via gcloud
    if ! $BINARY components list 2>/dev/null | grep -q "kubectl.*Not Installed"; then
        info "kubectl component already installed"
    else
        info "Installing kubectl component..."
        $BINARY components install kubectl
    fi
    exit 0
fi

info "$APP_NAME - Google Cloud SDK with kubectl"
info "Website: https://cloud.google.com/sdk"

# Install via official Arch package
info "Installing from Arch repositories..."
if check_pacman_package "google-cloud-cli"; then
    install_pacman "google-cloud-cli"
else
    info "Installing from AUR..."
    if [[ "$DEBUG" == true ]]; then
        # Show full output when debugging
        install_yay "google-cloud-cli"
    else
        # Suppress output normally
        install_yay "google-cloud-cli" || {
            error "Failed to install google-cloud-cli via yay"
            info "Try installing manually: yay -S google-cloud-cli"
            exit 1
        }
    fi
fi

# Install gcloud components
info "Installing gcloud components..."
$BINARY components install kubectl --quiet 2>/dev/null || warn "kubectl component install may require additional setup"
$BINARY components install cloud_sql_proxy --quiet 2>/dev/null || warn "cloud_sql_proxy component install may require additional setup"
$BINARY components install gke-gcloud-auth-plugin --quiet 2>/dev/null || warn "gke-gcloud-auth-plugin component install may require additional setup"
$BINARY components install docker-credential-gcr --quiet 2>/dev/null || warn "docker-credential-gcr component install may require additional setup"

# Verify installations
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(${BINARY} --version 2>/dev/null | head -1)"
    
    # Check installed components
    if command -v kubectl &> /dev/null; then
        info "  kubectl: $(kubectl version --client 2>/dev/null | head -1 || echo 'installed')"
    fi
    if command -v cloud_sql_proxy &> /dev/null; then
        info "  cloud_sql_proxy: installed"
    fi
    if command -v docker-credential-gcr &> /dev/null; then
        info "  docker-credential-gcr: installed"
    fi
    if command -v gke-gcloud-auth-plugin &> /dev/null; then
        info "  gke-gcloud-auth-plugin: installed"
    fi
    
    info ""
    info "Next steps:"
    info "  1. Run 'gcloud init' to authenticate"
    info "  2. Run 'gcloud config set project YOUR_PROJECT_ID'"
else
    error "$APP_NAME installation failed"
    info "For manual installation: https://cloud.google.com/sdk/docs/install-sdk"
    exit 1
fi

# Install bash completions
info "Installing bash completions for gcloud and kubectl..."

# gcloud completions
if [[ -d "/usr/share/bash-completion/completions" ]]; then
    # gcloud provides a completion script
    if [[ -f "/opt/google-cloud-cli/completion.bash.inc" ]]; then
        sudo ln -sf /opt/google-cloud-cli/completion.bash.inc /usr/share/bash-completion/completions/gcloud
        success "gcloud completions installed"
    fi
    
    # kubectl completion
    if command -v kubectl &> /dev/null; then
        kubectl completion bash | sudo tee /usr/share/bash-completion/completions/kubectl > /dev/null
        success "kubectl completions installed"
    fi
else
    # User-local
    mkdir -p "$USER_HOME/.bash_completion.d"
    
    if [[ -f "/opt/google-cloud-cli/completion.bash.inc" ]]; then
        ln -sf /opt/google-cloud-cli/completion.bash.inc "$USER_HOME/.bash_completion.d/gcloud"
        success "gcloud completions installed to ~/.bash_completion.d"
    fi
    
    if command -v kubectl &> /dev/null; then
        kubectl completion bash > "$USER_HOME/.bash_completion.d/kubectl"
        success "kubectl completions installed to ~/.bash_completion.d"
    fi
fi

# Note: Google Cloud SDK PATH is already configured in ~/.exports.os (dotfiles template)
