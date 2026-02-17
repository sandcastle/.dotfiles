#!/usr/bin/env bash
# Cloud Shell initialization script
# Installs mandatory prerequisites for using dotfiles on GCP Cloud Shell

set -e

DOTFILES_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# Source common functions
source "$DOTFILES_ROOT/lib/common.sh"

info "Initializing GCP Cloud Shell dotfiles..."

# Define initialization order (apps will be installed in this order)
# Order matters: dependencies first!
INIT_APPS=(
    "app-basic-tools.sh"  # Ensure basic tools are available
    "app-git.sh"          # Required for dotfiles
    "app-gum.sh"          # Required for pretty output
    "app-mise.sh"         # Required for dev environment management
)

INIT_DIR="$DOTFILES_ROOT/os/cloud-shell/init"

# Run each init app in order
for app_script in "${INIT_APPS[@]}"; do
    script_path="$INIT_DIR/$app_script"
    if [ -f "$script_path" ]; then
        bash "$script_path"
    fi
done

info "Cloud Shell has many tools pre-installed"
info "Additional tools can be installed via: sudo apt-get install <package>"
info "Your dotfiles will persist across Cloud Shell sessions"

success "GCP Cloud Shell initialized!"
