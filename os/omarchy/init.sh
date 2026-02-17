#!/usr/bin/env bash
# Omarchy initialization script
# Installs mandatory prerequisites for using dotfiles on Omarchy

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Source common functions
source "$DOTFILES_ROOT/lib/common.sh"

info "Installing prerequisites..."

# Define initialization order (apps will be installed in this order)
# Order matters: dependencies first!
INIT_APPS=(
    "app-git.sh"      # Required for dotfiles
    "app-gum.sh"      # Required for pretty output
    "app-mise.sh"     # Required for dev environment management
    "app-starship.sh" # Required for shell prompt
    "app-zoxide.sh"   # Required for smarter cd
)

INIT_DIR="$DOTFILES_ROOT/os/omarchy/init"

# Run each init app in order
for app_script in "${INIT_APPS[@]}"; do
    bash "$INIT_DIR/$app_script"
done

success "Prerequisites installed"
