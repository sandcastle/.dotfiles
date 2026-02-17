#!/usr/bin/env bash
# Install kubectx - Kubernetes context and namespace switching tool
# https://github.com/ahmetb/kubectx
# Installs both kubectx and kubens binaries

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="kubectx"
BINARY="kubectx"
OS_NAME="Windows"

info "Installing $APP_NAME on $OS_NAME..."

# Detect Windows environment
ENV=$(detect_windows_shell)
info "Detected Windows environment: $ENV"

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(kubectx --version 2>/dev/null || echo 'installed')"
    exit 0
fi

info "$APP_NAME - Kubernetes context and namespace switcher"
info "Website: https://github.com/ahmetb/kubectx"

case "$ENV" in
    git-bash)
        info "Installing kubectx and kubens for Git Bash..."
        
        LATEST_VERSION=$(curl -fsSL https://api.github.com/repos/ahmetb/kubectx/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        if [[ -z "$LATEST_VERSION" ]]; then
            error "Could not determine latest version"
            exit 1
        fi
        
        info "Downloading kubectx $LATEST_VERSION..."
        TEMP_DIR=$(mktemp -d)
        curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${LATEST_VERSION}/kubectx_${LATEST_VERSION#v}_windows_x86_64.zip" -o "$TEMP_DIR/kubectx.zip"
        curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${LATEST_VERSION}/kubens_${LATEST_VERSION#v}_windows_x86_64.zip" -o "$TEMP_DIR/kubens.zip"
        
        # Extract using unzip
        unzip -q "$TEMP_DIR/kubectx.zip" -d "$TEMP_DIR"
        unzip -q "$TEMP_DIR/kubens.zip" -d "$TEMP_DIR"
        
        # Install to ~/bin or /usr/local/bin
        if [[ -d "$HOME/bin" ]]; then
            install -m 755 "$TEMP_DIR/kubectx.exe" "$HOME/bin/kubectx.exe"
            install -m 755 "$TEMP_DIR/kubens.exe" "$HOME/bin/kubens.exe"
        else
            mkdir -p "$HOME/bin"
            install -m 755 "$TEMP_DIR/kubectx.exe" "$HOME/bin/kubectx.exe"
            install -m 755 "$TEMP_DIR/kubens.exe" "$HOME/bin/kubens.exe"
        fi
        
        rm -rf "$TEMP_DIR"
        ;;
    wsl)
        info "Installing kubectx and kubens in WSL..."
        
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
        
        # Install bash completions for WSL
        info "Installing bash completions..."
        mkdir -p "$HOME/.bash_completion.d"
        
        if kubectx --help 2>/dev/null | grep -q "completion"; then
            kubectx completion bash > "$HOME/.bash_completion.d/kubectx" 2>/dev/null || true
        fi
        
        if kubens --help 2>/dev/null | grep -q "completion"; then
            kubens completion bash > "$HOME/.bash_completion.d/kubens" 2>/dev/null || true
        fi
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

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
    
    if [ "$ENV" = "git-bash" ]; then
        info ""
        info "Note: Ensure ~/bin is in your PATH"
        if [[ -f "$HOME/.bashrc" ]] && ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
            echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
            info "Added ~/bin to PATH in ~/.bashrc"
        fi
    fi
else
    error "$APP_NAME installation failed"
    exit 1
fi
