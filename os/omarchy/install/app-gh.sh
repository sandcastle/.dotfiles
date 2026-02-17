#!/usr/bin/env bash
# Install GitHub CLI (gh)
# https://cli.github.com/
#
# The official GitHub command-line tool

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="GitHub CLI"
BINARY="gh"

info "Installing $APP_NAME..."

# Check if already installed
if command -v "$BINARY" &> /dev/null; then
    info "$APP_NAME is already installed"
    info "Version: $(${BINARY} --version 2>/dev/null || echo 'unknown')"
    exit 0
fi

info "$APP_NAME - GitHub's official command line tool"
info "Website: https://cli.github.com/"
info "Features: repo creation, PRs, issues, releases, workflows, and more"

# Install via official Arch package
info "Installing from Arch repositories..."
if check_pacman_package "github-cli"; then
    install_pacman "github-cli"
else
    info "Installing from AUR..."
    install_yay "github-cli"
fi

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(${BINARY} --version)"
    info ""
    info "Next steps:"
    info "  1. Run 'gh auth login' to authenticate with GitHub"
    info "  2. Run 'gh repo create' to create a new repository"
    info ""
    info "Common commands:"
    info "  gh repo clone owner/repo    # Clone a repository"
    info "  gh pr create                # Create a pull request"
    info "  gh issue list               # List issues"
    info "  gh workflow run             # Run a GitHub Actions workflow"
else
    error "$APP_NAME installation failed"
    info "For manual installation: https://github.com/cli/cli#installation"
    exit 1
fi

# Install bash completions
info "Installing bash completions for gh..."

if [[ -d "/usr/share/bash-completion/completions" ]]; then
    # Try to generate completions
    if $BINARY completion bash &>/dev/null; then
        $BINARY completion bash | sudo tee /usr/share/bash-completion/completions/gh > /dev/null
        success "Completions installed to /usr/share/bash-completion/completions/gh"
    fi
elif [[ -d "/etc/bash_completion.d" ]]; then
    if $BINARY completion bash &>/dev/null; then
        $BINARY completion bash | sudo tee /etc/bash_completion.d/gh > /dev/null
        success "Completions installed to /etc/bash_completion.d/gh"
    fi
else
    # User-local
    mkdir -p "$HOME/.bash_completion.d"
    if $BINARY completion bash &>/dev/null; then
        $BINARY completion bash > "$HOME/.bash_completion.d/gh"
        success "Completions installed to ~/.bash_completion.d/gh"
    fi
fi

# Ensure completion loader is in .bashrc
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo '# Source bash completions' >> "$HOME/.bashrc"
    echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$HOME/.bashrc"
fi
