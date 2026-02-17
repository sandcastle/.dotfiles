#!/usr/bin/env bash
# Install GitHub CLI (gh)
# https://cli.github.com/
#
# Also installs: gh-sub-issue extension for sub-issue management

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
    
    # Check if extension is installed
    if ! $BINARY extension list | grep -q "gh-sub-issue"; then
        info "Installing gh-sub-issue extension..."
        $BINARY extension install yahsan2/gh-sub-issue || warn "Extension install failed"
    fi
    exit 0
fi

info "$APP_NAME - GitHub's official command line tool"
info "Website: https://cli.github.com/"
info "Features: repo creation, PRs, issues, releases, workflows, and more"

# Install via Homebrew
info "Installing via Homebrew..."
install_brew "gh"

# Verify installation
if command -v "$BINARY" &> /dev/null; then
    success "$APP_NAME installed successfully!"
    info "Version: $(${BINARY} --version)"
    
    # Install gh-sub-issue extension
    info "Installing gh-sub-issue extension for sub-issue management..."
    $BINARY extension install yahsan2/gh-sub-issue || warn "Extension install failed (optional)"
    
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
    info "  gh sub-issue list           # List sub-issues (extension)"
else
    error "$APP_NAME installation failed"
    info "For manual installation: https://github.com/cli/cli#installation"
    exit 1
fi

# Install bash completions
info "Installing bash completions for gh..."
mkdir -p "$USER_HOME/.bash_completion.d"
if $BINARY completion bash &>/dev/null; then
    $BINARY completion bash > "$USER_HOME/.bash_completion.d/gh"
    success "Completions installed to ~/.bash_completion.d/gh"
fi

# Ensure completion loader is in .bashrc
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "bash_completion.d" "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$USER_HOME/.bashrc"
    echo '# Source bash completions' >> "$USER_HOME/.bashrc"
    echo 'for f in ~/.bash_completion.d/*; do [[ -f "$f" ]] && source "$f"; done' >> "$USER_HOME/.bashrc"
fi
