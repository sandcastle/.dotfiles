#!/usr/bin/env bash
# Install kubectx - Kubernetes context and namespace switching tool
# https://github.com/ahmetb/kubectx
# Installs both kubectx and kubens binaries

set -e
# Redirect output if SILENT mode is enabled
if [[ "${SILENT:-false}" == true ]]; then
    exec > /dev/null 2>&1
fi

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="kubectx"
BINARY="kubectx"
OS_NAME="Omarchy"

info "Installing $APP_NAME on $OS_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(kubectx --version 2>/dev/null || echo 'installed')"
    exit 0
fi

info "$APP_NAME - Kubernetes context and namespace switcher"
info "Website: https://github.com/ahmetb/kubectx"

# Install via AUR (kubectx is in AUR)
info "Installing from AUR..."
install_yay "kubectx" || {
    # Fallback: Install manually from GitHub release
    info "Installing from GitHub release..."
    
    LATEST_VERSION=$(curl -fsSL https://api.github.com/repos/ahmetb/kubectx/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [[ -z "$LATEST_VERSION" ]]; then
        error "Could not determine latest version"
        exit 1
    fi
    
    info "Downloading kubectx $LATEST_VERSION..."
    TEMP_DIR=$(mktemp -d)
    curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${LATEST_VERSION}/kubectx_${LATEST_VERSION#v}_linux_x86_64.tar.gz" -o "$TEMP_DIR/kubectx.tar.gz"
    curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${LATEST_VERSION}/kubens_${LATEST_VERSION#v}_linux_x86_64.tar.gz" -o "$TEMP_DIR/kubens.tar.gz"
    
    tar -xzf "$TEMP_DIR/kubectx.tar.gz" -C "$TEMP_DIR"
    tar -xzf "$TEMP_DIR/kubens.tar.gz" -C "$TEMP_DIR"
    
    sudo install -m 755 "$TEMP_DIR/kubectx" /usr/local/bin/kubectx
    sudo install -m 755 "$TEMP_DIR/kubens" /usr/local/bin/kubens
    
    rm -rf "$TEMP_DIR"
}

# Verify installations
if command -v kubectx &> /dev/null && command -v kubens &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Installed tools:"
    info "  kubectx - switch between Kubernetes contexts"
    info "  kubens - switch between Kubernetes namespaces"
    info ""
    info "Usage:"
    info "  kubectx <context>        # Switch context"
    info "  kubectx -                # Switch to previous context"
    info "  kubens <namespace>       # Switch namespace"
    info "  kubens -                 # Switch to previous namespace"
else
    error "$APP_NAME installation failed"
    exit 1
fi

# Install bash completions
info "Installing bash completions..."
mkdir -p "$USER_HOME/.bash_completion.d"

# kubectx completions
if [[ -f "/usr/share/bash-completion/completions/kubectx" ]]; then
    success "kubectx completions already available system-wide"
else
    # Try to get completions from the installed binary
    if kubectx --help 2>/dev/null | grep -q "completion"; then
        kubectx completion bash > "$USER_HOME/.bash_completion.d/kubectx" 2>/dev/null || true
    fi
fi

# kubens completions
if [[ -f "/usr/share/bash-completion/completions/kubens" ]]; then
    success "kubens completions already available system-wide"
else
    if kubens --help 2>/dev/null | grep -q "completion"; then
        kubens completion bash > "$USER_HOME/.bash_completion.d/kubens" 2>/dev/null || true
    fi
fi

success "Completions installed"

exit 0
