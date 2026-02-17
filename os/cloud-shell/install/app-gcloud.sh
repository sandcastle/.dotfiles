#!/usr/bin/env bash
# Install Google Cloud CLI (gcloud) with kubectl and additional components
# https://cloud.google.com/sdk/docs/install-sdk#deb
#
# Also installs: kubectl, cloud_sql_proxy, gke-gcloud-auth-plugin, docker-credential-gcr (via gcloud components)

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Google Cloud CLI"
BINARY="gcloud"

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(${BINARY} --version 2>/dev/null | head -1 || echo 'unknown')"
    
    # Ensure components are installed
    info "Ensuring all gcloud components are installed..."
    $BINARY components install kubectl --quiet 2>/dev/null || true
    $BINARY components install cloud_sql_proxy --quiet 2>/dev/null || true
    $BINARY components install gke-gcloud-auth-plugin --quiet 2>/dev/null || true
    $BINARY components install docker-credential-gcr --quiet 2>/dev/null || true
    exit 0
fi

info "$APP_NAME - Google Cloud SDK with kubectl"
info "Website: https://cloud.google.com/sdk"

# Install via Google Cloud APT repository
info "Adding Google Cloud SDK APT repository..."

# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null

# Import the Google Cloud public key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# Update and install
info "Updating package lists..."
sudo apt-get update

info "Installing Google Cloud CLI packages..."
sudo apt-get install -y google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin

# Install additional components via gcloud
info "Installing gcloud components..."
$BINARY components install kubectl --quiet 2>/dev/null || warn "kubectl component install may require additional setup"
$BINARY components install cloud_sql_proxy --quiet 2>/dev/null || warn "cloud_sql_proxy component install may require additional setup"
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
info "Installing bash completions..."
mkdir -p "$USER_HOME/.bash_completion.d"

# gcloud completions
if [[ -f "/usr/share/google-cloud-sdk/completion.bash.inc" ]]; then
    ln -sf /usr/share/google-cloud-sdk/completion.bash.inc "$USER_HOME/.bash_completion.d/gcloud"
    success "gcloud completions installed"
fi

# kubectl completion
if command -v kubectl &> /dev/null; then
    kubectl completion bash > "$USER_HOME/.bash_completion.d/kubectl"
    success "kubectl completions installed"
fi

# Ensure completion loader is in .bashrc
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$USER_HOME/.bashrc"
    echo '# Source bash completions' >> "$USER_HOME/.bashrc"
    echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$USER_HOME/.bashrc"
fi
