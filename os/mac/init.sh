#!/usr/bin/env bash
# macOS initialization script
# Installs mandatory prerequisites for using dotfiles on macOS

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Source common functions
source "$DOTFILES_ROOT/lib/common.sh"

info "Initializing macOS dotfiles..."

# Define initialization order (apps will be installed in this order)
# Order matters: install dependencies first!
INIT_APPS=(
    "app-xcode-tools.sh"  # Required first for compiling
    "app-homebrew.sh"     # Package manager for macOS
    "app-git.sh"          # Required for dotfiles
    "app-gum.sh"          # Required for pretty output
    "app-mise.sh"         # Required for dev environment management
)

INIT_DIR="$DOTFILES_ROOT/os/mac/init"

# Run each init app in order
for app_script in "${INIT_APPS[@]}"; do
    script_path="$INIT_DIR/$app_script"
    if [ -f "$script_path" ]; then
        bash "$script_path"
    fi
done

success "macOS initialized!"
