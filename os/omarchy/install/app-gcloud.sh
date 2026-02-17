#!/usr/bin/env bash
#
# Install Google Cloud CLI (gcloud) with kubectl
# https://cloud.google.com/sdk/docs/install
#
# Uses the official Google Cloud SDK installer to enable gcloud components management
#

set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Google Cloud CLI"
BINARY="gcloud"
DEBUG=${DEBUG:-false}
SILENT=${SILENT:-false}

# Redirect output if SILENT mode is enabled
# Note: Only redirect stdout, keep stderr for errors
if [[ "$SILENT" == true ]]; then
    exec > /dev/null
fi

# Install location
INSTALL_PARENT="$USER_HOME/.local/share"
GCLOUD_HOME="$INSTALL_PARENT/google-cloud-sdk"
GCLOUD_BIN="$GCLOUD_HOME/bin/gcloud"

# ============================================================================
# Resolve gcloud path (install if needed)
# ============================================================================

GCLOUD_CMD=""

# Check if gcloud is in PATH
if command -v "$BINARY" &> /dev/null; then
    GCLOUD_CMD="$BINARY"
    info "Found $APP_NAME in PATH"
    
# Check if installed but not in PATH
elif [[ -f "$GCLOUD_BIN" ]]; then
    GCLOUD_CMD="$GCLOUD_BIN"
    info "Found $APP_NAME at $GCLOUD_HOME"
    export PATH="$GCLOUD_HOME/bin:$PATH"
    
# Need to install
else
    info "$APP_NAME - Google Cloud SDK"
    info "Website: https://cloud.google.com/sdk"
    info "Installing via official Google Cloud SDK installer..."
    
    # Remove incomplete installation if exists
    if [[ -d "$GCLOUD_HOME" ]]; then
        info "Removing incomplete installation..."
        rm -rf "$GCLOUD_HOME"
    fi
    
    # Download and run installer
    if [[ "$SILENT" == true ]]; then
        curl -fsSL https://sdk.cloud.google.com | bash -s -- \
            --disable-prompts \
            --install-dir="$INSTALL_PARENT" \
            --path-update=false \
            --command-completion=false \
            --usage-reporting=false > /dev/null 2>&1
    else
        curl -fsSL https://sdk.cloud.google.com | bash -s -- \
            --disable-prompts \
            --install-dir="$INSTALL_PARENT"
    fi
    
    # Verify installation
    if [[ ! -f "$GCLOUD_BIN" ]]; then
        error "Installation failed - gcloud not found at $GCLOUD_BIN"
        exit 1
    fi
    
    export PATH="$GCLOUD_HOME/bin:$PATH"
    GCLOUD_CMD="$GCLOUD_BIN"
fi

# ============================================================================
# Install/Update components
# ============================================================================

info "Installing gcloud components..."

# Update first
if [[ "$DEBUG" == true ]]; then
    "$GCLOUD_CMD" components update --quiet
else
    "$GCLOUD_CMD" components update --quiet 2>&1 | grep -E '(ERROR|WARNING|Installing|Updating)' || true
fi

# Install components
for component in kubectl cloud_sql_proxy gke-gcloud-auth-plugin docker-credential-gcr; do
    if [[ "$DEBUG" == true ]]; then
        "$GCLOUD_CMD" components install "$component" --quiet || warn "Failed to install $component"
    else
        # Filter output but ensure the pipeline always succeeds
        "$GCLOUD_CMD" components install "$component" --quiet 2>&1 | 
            { grep -vE '^\s*$|All components are up to date' || true; }
    fi
done

# ============================================================================
# Verify and report
# ============================================================================

success "$APP_NAME installed successfully!"
info "Version: $("$GCLOUD_CMD" --version 2>/dev/null | head -1)"
info "Location: $GCLOUD_HOME"

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
info "To update: gcloud components update"
info "To add more: gcloud components install <component>"

# ============================================================================
# Install completions
# ============================================================================

info "Installing bash completions..."
mkdir -p "$USER_HOME/.bash_completion.d" || true

# gcloud completions
if [[ -f "$GCLOUD_HOME/completion.bash.inc" ]]; then
    ln -sf "$GCLOUD_HOME/completion.bash.inc" "$USER_HOME/.bash_completion.d/gcloud" || true
    success "gcloud completions installed"
fi

# kubectl completions - check both PATH and GCLOUD_HOME/bin
KUBECTL_BIN=""
if command -v kubectl &> /dev/null; then
    KUBECTL_BIN="kubectl"
elif [[ -f "$GCLOUD_HOME/bin/kubectl" ]]; then
    KUBECTL_BIN="$GCLOUD_HOME/bin/kubectl"
fi

if [[ -n "$KUBECTL_BIN" ]]; then
    "$KUBECTL_BIN" completion bash > "$USER_HOME/.bash_completion.d/kubectl" 2>/dev/null || true
    if [[ -f "$USER_HOME/.bash_completion.d/kubectl" ]]; then
        success "kubectl completions installed"
    fi
fi

# Note: PATH is configured in ~/.exports.os

exit 0
