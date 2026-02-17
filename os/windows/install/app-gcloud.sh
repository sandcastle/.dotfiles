#!/usr/bin/env bash
# Install Google Cloud CLI (gcloud) with kubectl
# https://cloud.google.com/sdk/docs/install-sdk#windows
#
# Also installs: kubectl (via gcloud components)

set -e
# Redirect output if SILENT mode is enabled
if [[ "${SILENT:-false}" == true ]]; then
    exec > /dev/null 2>&1
fi

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Google Cloud CLI"
BINARY="gcloud"

info "Installing $APP_NAME..."

# Detect Windows environment
ENV=$(detect_windows_shell)
info "Detected Windows environment: $ENV"

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

case "$ENV" in
    git-bash)
        info "$APP_NAME - Google Cloud SDK with kubectl"
        info "Website: https://cloud.google.com/sdk"
        info ""
        info "Installing via Windows installer..."
        info "Downloading GoogleCloudSDKInstaller.exe..."
        
        # Download and run Windows installer
        curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe
        ./GoogleCloudSDKInstaller.exe
        
        warn "Please complete the installation wizard"
        warn "After installation completes, run: gcloud components install kubectl"
        ;;
    wsl)
        info "$APP_NAME - Google Cloud SDK with kubectl"
        info "Website: https://cloud.google.com/sdk"
        info "Installing in WSL..."
        
        # For WSL, use the Linux installation method
        info "Adding Google Cloud SDK APT repository..."
        
        # Add the Cloud SDK distribution URI as a package source
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
        
        # Import the Google Cloud public key
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        
        # Update and install
        sudo apt-get update
        sudo apt-get install -y google-cloud-cli kubectl google-cloud-sdk-gke-gcloud-auth-plugin
        
        # Also install via gcloud components
        if command -v "$BINARY" &> /dev/null; then
            info "Installing gcloud components..."
            $BINARY components install kubectl --quiet 2>/dev/null || true
            $BINARY components install cloud_sql_proxy --quiet 2>/dev/null || true
            $BINARY components install gke-gcloud-auth-plugin --quiet 2>/dev/null || true
            $BINARY components install docker-credential-gcr --quiet 2>/dev/null || true
        fi
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

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
    if [ "$ENV" = "git-bash" ]; then
        warn "$APP_NAME requires manual completion of the installer"
        warn "Please finish the installation wizard and then run again"
        exit 0
    else
        error "$APP_NAME installation failed"
        info "For manual installation: https://cloud.google.com/sdk/docs/install-sdk"
        exit 1
    fi
fi

# Install bash completions (for WSL)
if [ "$ENV" = "wsl" ]; then
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
fi
