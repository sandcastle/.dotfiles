#!/usr/bin/env bash
# Install Moor - A pager designed to do the right thing
# https://github.com/walles/moor
#
# Features: Syntax highlighting, incremental search, filtering, ANSI color support

set -e
# Redirect output if SILENT mode is enabled
if [[ "${SILENT:-false}" == true ]]; then
    exec > /dev/null 2>&1
fi

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="Moor"
BINARY="moor"

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(${BINARY} --version 2>/dev/null || echo 'unknown')"
    exit 0
fi

info "$APP_NAME - A pager that just does the right thing"
info "Website: https://github.com/walles/moor"
info "Features: Syntax highlighting, incremental search, filtering, ANSI color support"

# Detect Windows environment
ENV=$(detect_windows_shell)
info "Detected environment: $ENV"

# Install based on environment
case "$ENV" in
    git-bash)
        # Git Bash: Use winget
        if command -v winget &> /dev/null; then
            install_winget "walles.moor"
        else
            error "winget not found. Please install winget or use WSL."
            exit 1
        fi
        ;;
    wsl)
        # WSL: Download and install .deb
        info "Installing from GitHub releases for WSL..."
        
        ARCH=$(uname -m)
        case "$ARCH" in
            x86_64)
                DOWNLOAD_ARCH="amd64"
                ;;
            aarch64|arm64)
                DOWNLOAD_ARCH="arm64"
                ;;
            *)
                error "Unsupported architecture: $ARCH"
                exit 1
                ;;
        esac
        
        # Get latest release URL
        LATEST_URL=$(curl -s https://api.github.com/repos/walles/moor/releases/latest | grep "browser_download_url.*linux_${DOWNLOAD_ARCH}.deb" | cut -d '"' -f 4)
        
        if [ -z "$LATEST_URL" ]; then
            error "Could not find download URL for Moor"
            exit 1
        fi
        
        # Download and install
        cd /tmp
        info "Downloading Moor..."
        curl -L -o moor.deb "$LATEST_URL"
        
        info "Installing Moor..."
        sudo dpkg -i moor.deb || sudo apt-get install -f -y
        
        rm -f moor.deb
        ;;
    *)
        error "Unknown Windows environment: $ENV"
        exit 1
        ;;
esac

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(${BINARY} --version)"
    info ""
    info "Usage examples:"
    info "  moor file.txt              # View file with syntax highlighting"
    info "  git diff | moor            # View git diff with colors"
    info "  command | moor             # Pipe any command output"
    info ""
    info "Key bindings:"
    info "  /pattern    - Search (incremental)"
    info "  &pattern    - Filter lines"
    info "  q           - Quit"
else
    error "$APP_NAME installation failed"
    info "For manual installation: https://github.com/walles/moor/releases"
    exit 1
fi

exit 0
