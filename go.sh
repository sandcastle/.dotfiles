#!/usr/bin/env bash
# go.sh - One-liner installer for dotfiles
# Usage: curl -fsSL https://raw.githubusercontent.com/sandcastle/.dotfiles/main/go.sh | bash
#
# Options:
#   --install    Skip cloning, just run installer (for existing repos)
#   --all        Install all apps after dotfiles
#   --debug      Show verbose output with paths and details

set -e

DOTFILES_REPO="https://github.com/sandcastle/.dotfiles.git"

# Detect the correct home directory (handle sudo case)
if [[ -n "${SUDO_USER:-}" ]]; then
    # Running with sudo - use the original user's home
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    # Normal case - use current user's home
    USER_HOME="$HOME"
fi

DOTFILES_DIR="${DOTFILES_DIR:-$USER_HOME/.dotfiles}"

# Parse arguments
INSTALL_ONLY=false
INSTALL_ARGS=""
DEBUG=false

for arg in "$@"; do
    case "$arg" in
        --install)
            INSTALL_ONLY=true
            ;;
        --debug)
            DEBUG=true
            INSTALL_ARGS="$INSTALL_ARGS --debug"
            ;;
        --all|--help|-h)
            INSTALL_ARGS="$INSTALL_ARGS $arg"
            ;;
    esac
done

# ANSI color codes
C_PRIMARY='\033[38;5;212m'
C_SUCCESS='\033[38;5;46m'
C_ERROR='\033[38;5;196m'
C_INFO='\033[38;5;240m'
C_RESET='\033[0m'
C_BOLD='\033[1m'

header() {
    echo ""
    echo -e "${C_PRIMARY}${C_BOLD}  ═════════════════════════════════════════════════${C_RESET}"
    echo -e "${C_PRIMARY}${C_BOLD}       Dotfiles Quick Installer${C_RESET}"
    echo -e "${C_PRIMARY}${C_BOLD}  ═════════════════════════════════════════════════${C_RESET}"
    echo ""
}

run_installer() {
    $DEBUG && echo -e "${C_INFO}  • Running installer...${C_RESET}"
    bash "$DOTFILES_DIR/os/install.sh" $INSTALL_ARGS
}

header

# --install mode: just run installer, skip cloning
if [[ "$INSTALL_ONLY" == true ]]; then
    if [[ -d "$DOTFILES_DIR" ]]; then
        run_installer
    else
        echo -e "${C_ERROR}  ✗ Dotfiles not found at $DOTFILES_DIR${C_RESET}"
        $DEBUG && echo -e "${C_INFO}  • Run without --install to clone first${C_RESET}"
        exit 1
    fi
    exit 0
fi

# Full install mode: clone or update, then install
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    $DEBUG && echo -e "${C_INFO}  • Updating dotfiles...${C_RESET}"
    cd "$DOTFILES_DIR"
    git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true
else
    $DEBUG && echo -e "${C_INFO}  • Cloning dotfiles...${C_RESET}"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR" 2>/dev/null || true
fi

run_installer

echo ""
echo -e "${C_SUCCESS}  ✓ Done!${C_RESET}"
echo ""
