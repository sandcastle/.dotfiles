#!/usr/bin/env bash
# go.sh - One-liner installer for dotfiles
# Usage: curl -fsSL https://raw.githubusercontent.com/sandcastle/.dotfiles/main/go.sh | bash
#
# Options:
#   --install    Skip cloning, just run installer (for existing repos)
#   --all        Install all apps after dotfiles (passed through to os/install.sh)

set -e

DOTFILES_REPO="https://github.com/sandcastle/.dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Parse arguments
INSTALL_ONLY=false
INSTALL_ARGS=""
for arg in "$@"; do
    case "$arg" in
        --install)
            INSTALL_ONLY=true
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
    echo -e "${C_INFO}  • Running installer...${C_RESET}"
    bash "$DOTFILES_DIR/os/install.sh" $INSTALL_ARGS
}

header

# --install mode: just run installer, skip cloning
if [[ "$INSTALL_ONLY" == true ]]; then
    if [[ -d "$DOTFILES_DIR" ]]; then
        run_installer
    else
        echo -e "${C_ERROR}  ✗ Dotfiles not found at $DOTFILES_DIR${C_RESET}"
        echo -e "${C_INFO}  • Run without --install to clone first${C_RESET}"
        exit 1
    fi
    exit 0
fi

# Full install mode: clone or update, then install
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    echo -e "${C_INFO}  • Dotfiles already exist at $DOTFILES_DIR${C_RESET}"
    echo -e "${C_INFO}  • Updating to latest version...${C_RESET}"
    cd "$DOTFILES_DIR"
    git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true
else
    echo -e "${C_INFO}  • Cloning dotfiles to $DOTFILES_DIR...${C_RESET}"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

echo ""
run_installer

echo ""
echo -e "${C_SUCCESS}  ✓ Installation complete!${C_RESET}"
echo ""
echo -e "${C_INFO}  Your dotfiles are located at: $DOTFILES_DIR${C_RESET}"
echo ""
echo -e "${C_PRIMARY}${C_BOLD}  Quick Commands:${C_RESET}"
echo -e "${C_INFO}    apps install <app-name>      Install an app${C_RESET}"
echo -e "${C_INFO}    apps uninstall <app-name>    Uninstall an app${C_RESET}"
echo -e "${C_INFO}    apps install                 List available apps${C_RESET}"
echo ""
