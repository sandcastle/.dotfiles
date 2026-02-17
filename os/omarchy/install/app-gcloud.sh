#!/usr/bin/env bash
# Install Google Cloud CLI (gcloud) with kubectl
# https://cloud.google.com/sdk/docs/install
#
# Uses the official Google Cloud SDK installer to enable gcloud components management

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Google Cloud CLI"
BINARY="gcloud"
DEBUG=${DEBUG:-false}
SILENT=${SILENT:-false}

# Redirect output if SILENT mode is enabled
if [[ "$SILENT" == true ]]; then
    exec > /dev/null 2>&1
fi

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(${BINARY} --version 2>/dev/null | head -1 || echo 'unknown')"
    
    # Update components
    info "Updating gcloud components..."
    $BINARY components update --quiet 2>/dev/null || true
    
    # Install kubectl component
    info "Installing kubectl component..."
    $BINARY components install kubectl --quiet 2>/dev/null || warn "kubectl component install may have failed"
    
    # Install other components
    $BINARY components install cloud_sql_proxy --quiet 2>/dev/null || true
    $BINARY components install gke-gcloud-auth-plugin --quiet 2>/dev/null || true
    $BINARY components install docker-credential-gcr --quiet 2>/dev/null || true
    
    exit 0
fi

info "$APP_NAME - Google Cloud SDK"
info "Website: https://cloud.google.com/sdk"

# Install via official installer (not system package manager)
# This allows us to use 'gcloud components install'
info "Installing via official Google Cloud SDK installer..."

INSTALL_DIR="$USER_HOME/.local/share/google-cloud-sdk"

# Download and run the installer
# In SILENT mode, redirect all output to suppress verbose download progress
if [[ "$SILENT" == true ]]; then
    curl -fsSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir="$INSTALL_DIR" --path-update=false --command-completion=false --usage-reporting=false > /dev/null 2>&1
else
    curl -fsSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir="$INSTALL_DIR"
fi

# The installer creates a nested google-cloud-sdk directory
# Check both possible paths and use whatever exists
if [[ -f "$INSTALL_DIR/bin/gcloud" ]]; then
    # Direct install (rare)
    export PATH="$INSTALL_DIR/bin:$PATH"
    FINAL_INSTALL_DIR="$INSTALL_DIR"
    $DEBUG && info "gcloud installed at: $INSTALL_DIR"
elif [[ -f "$INSTALL_DIR/google-cloud-sdk/bin/gcloud" ]]; then
    # Nested install (common) - use nested path without moving files
    # Moving files breaks gcloud's component management
    export PATH="$INSTALL_DIR/google-cloud-sdk/bin:$PATH"
    FINAL_INSTALL_DIR="$INSTALL_DIR/google-cloud-sdk"
    $DEBUG && info "gcloud installed at: $INSTALL_DIR/google-cloud-sdk"
fi

# Add to PATH for future sessions (use the actual install path)
if ! grep -q "google-cloud-sdk" "$USER_HOME/.exports.os" 2>/dev/null; then
    echo '' >> "$USER_HOME/.exports.os"
    echo '# Google Cloud SDK' >> "$USER_HOME/.exports.os"
    # Note: PATH may be nested depending on how installer extracted
    echo 'export PATH="$HOME/.local/share/google-cloud-sdk/bin:$HOME/.local/share/google-cloud-sdk/google-cloud-sdk/bin:$PATH"' >> "$USER_HOME/.exports.os"
fi

# Verify gcloud is available
if ! command -v "$BINARY" &> /dev/null; then
    error "gcloud installation failed - not found in PATH"
    info "Expected locations: $INSTALL_DIR/bin/gcloud or $INSTALL_DIR/google-cloud-sdk/bin/gcloud"
    exit 1
fi

# Install components via gcloud
info "Installing gcloud components..."
if [[ "$DEBUG" == true ]]; then
    # Show full output in debug mode
    $BINARY components install kubectl --quiet || error "kubectl component install failed"
    $BINARY components install cloud_sql_proxy --quiet || true
    $BINARY components install gke-gcloud-auth-plugin --quiet || true
    $BINARY components install docker-credential-gcr --quiet || true
else
    # Suppress output normally
    $BINARY components install kubectl --quiet 2>/dev/null || warn "kubectl component install may have failed"
    $BINARY components install cloud_sql_proxy --quiet 2>/dev/null || true
    $BINARY components install gke-gcloud-auth-plugin --quiet 2>/dev/null || true
    $BINARY components install docker-credential-gcr --quiet 2>/dev/null || true
fi

# Verify installations
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(${BINARY} --version 2>/dev/null | head -1)"
    info "Location: $INSTALL_DIR"
    
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
    info ""
    info "To update components: gcloud components update"
    info "To install more components: gcloud components install <component-name>"
else
    error "$APP_NAME installation failed"
    info "For manual installation: https://cloud.google.com/sdk/docs/install-sdk"
    exit 1
fi

# Install bash completions
info "Installing bash completions..."
mkdir -p "$USER_HOME/.bash_completion.d"

# gcloud completions
if [[ -f "$INSTALL_DIR/completion.bash.inc" ]]; then
    ln -sf "$INSTALL_DIR/completion.bash.inc" "$USER_HOME/.bash_completion.d/gcloud"
    success "gcloud completions installed"
fi

# kubectl completions
if command -v kubectl &> /dev/null; then
    kubectl completion bash > "$USER_HOME/.bash_completion.d/kubectl"
    success "kubectl completions installed"
fi

exit 0
