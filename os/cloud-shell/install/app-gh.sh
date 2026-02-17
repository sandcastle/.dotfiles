#!/usr/bin/env bash
# Install GitHub CLI (gh) - GitHub's official command-line tool
# https://cli.github.com/

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="GitHub CLI"
BINARY="gh"

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(gh --version 2>/dev/null | head -1 || echo 'unknown')"
    exit 0
fi

info "$APP_NAME - GitHub's official command-line tool"
info "Website: https://cli.github.com"

# Install via GitHub's APT repository
info "Adding GitHub CLI APT repository..."

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

info "Updating package lists..."
sudo apt-get update

info "Installing GitHub CLI..."
sudo apt-get install -y gh

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(gh --version 2>/dev/null | head -1)"
    info ""
    info "Next steps:"
    info "  1. Run 'gh auth login' to authenticate with GitHub"
    info "  2. Run 'gh --help' to see available commands"
else
    error "$APP_NAME installation failed"
    exit 1
fi

# Install bash completions
info "Installing bash completions..."
mkdir -p "$USER_HOME/.bash_completion.d"

if gh --help 2>/dev/null | grep -q "completion"; then
    gh completion -s bash > "$USER_HOME/.bash_completion.d/gh" 2>/dev/null || warn "Could not generate completions"
fi

# Ensure completion loader is in .bashrc
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$USER_HOME/.bashrc"
    echo '# Source bash completions' >> "$USER_HOME/.bashrc"
    echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$USER_HOME/.bashrc"
fi

success "Completions installed"
