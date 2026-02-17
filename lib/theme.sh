#!/usr/bin/env bash
#
# Theme configuration for dotfiles output
# Source this file to override default colors used by common.sh
#
# Usage: source "$DOTFILES_ROOT/lib/theme.sh"
#
# Theme loading order (later overrides earlier):
# 1. Built-in defaults (this file)
# 2. /etc/dotfiles.theme (system-wide config)
# 3. Omarchy theme auto-detection
# 4. ~/.dotfiles-theme.sh (user override)
#

# ============================================================================
# Step 1: Built-in Default Theme Colors
# ============================================================================

# Primary accent color (used for headers, borders)
THEME_PRIMARY="${THEME_PRIMARY:-212}"        # Hot pink

# Secondary accent color (used for sections)
THEME_SECONDARY="${THEME_SECONDARY:-99}"     # Purple

# Success color (checkmarks, success messages)
THEME_SUCCESS="${THEME_SUCCESS:-46}"          # Green

# Error color (error messages, failures)
THEME_ERROR="${THEME_ERROR:-196}"             # Red

# Warning color (warnings, cautions)
THEME_WARNING="${THEME_WARNING:-208}"         # Orange

# Info color (informational messages)
THEME_INFO="${THEME_INFO:-240}"               # Gray

# Background/border colors
THEME_BG_PRIMARY="${THEME_BG_PRIMARY:-}"      # Optional background
THEME_BORDER="${THEME_BORDER:-212}"           # Border color

# Text colors
THEME_TEXT_PRIMARY="${THEME_TEXT_PRIMARY:-255}"   # White
THEME_TEXT_SECONDARY="${THEME_TEXT_SECONDARY:-250}"  # Light gray
THEME_TEXT_DIM="${THEME_TEXT_DIM:-245}"           # Dim text

# ============================================================================
# Step 2: System-wide Theme Configuration (/etc/dotfiles.theme)
# ============================================================================

# Load system-wide theme if available
# Note: /etc is typically world-readable, so this should work for non-root users
if [ -r /etc/dotfiles.theme ]; then
    source /etc/dotfiles.theme
fi

# ============================================================================
# Step 3: Omarchy Theme Auto-Detection
# ============================================================================

# Check if Omarchy is installed and try to detect current theme colors
# This allows automatic matching with the current omarchy theme
if [ -f /etc/arch-release ] && [ -d "$HOME/.local/share/omarchy" ]; then
    # Try to read current omarchy theme
    if [ -f "$HOME/.config/omarchy/theme/current" ]; then
        OMANCHY_THEME=$(cat "$HOME/.config/omarchy/theme/current" 2>/dev/null || echo "")
        
        # Apply omarchy theme colors if detected (only if not already set by system config)
        case "$OMANCHY_THEME" in
            catppuccin*)
                # Catppuccin colors
                THEME_PRIMARY="${THEME_PRIMARY:-212}"      # Pink
                THEME_SECONDARY="${THEME_SECONDARY:-117}"  # Blue
                THEME_SUCCESS="${THEME_SUCCESS:-120}"      # Green
                THEME_WARNING="${THEME_WARNING:-223}"    # Yellow
                ;;
            tokyo-night*)
                # Tokyo Night colors
                THEME_PRIMARY="${THEME_PRIMARY:-117}"      # Cyan
                THEME_SECONDARY="${THEME_SECONDARY:-170}"  # Purple
                THEME_SUCCESS="${THEME_SUCCESS:-120}"      # Green
                THEME_WARNING="${THEME_WARNING:-180}"    # Yellow
                ;;
            nord*)
                # Nord colors
                THEME_PRIMARY="${THEME_PRIMARY:-117}"      # Frost
                THEME_SECONDARY="${THEME_SECONDARY:-111}"  # Aurora
                THEME_SUCCESS="${THEME_SUCCESS:-114}"      # Green
                THEME_WARNING="${THEME_WARNING:-222}"    # Yellow
                ;;
            dracula*)
                # Dracula colors
                THEME_PRIMARY="${THEME_PRIMARY:-212}"      # Pink
                THEME_SECONDARY="${THEME_SECONDARY:-141}"  # Purple
                THEME_SUCCESS="${THEME_SUCCESS:-120}"      # Green
                THEME_WARNING="${THEME_WARNING:-229}"    # Yellow
                ;;
            *)
                # Default Omarchy colors
                ;;
        esac
    fi
fi

# ============================================================================
# Step 4: User Override Support (~/.dotfiles-theme.sh)
# ============================================================================

# Allow user to override everything with ~/.dotfiles-theme.sh
if [ -f "$HOME/.dotfiles-theme.sh" ]; then
    source "$HOME/.dotfiles-theme.sh"
fi

# ============================================================================
# Export All Theme Variables
# ============================================================================

export THEME_PRIMARY THEME_SECONDARY THEME_SUCCESS THEME_ERROR THEME_WARNING
export THEME_INFO THEME_BG_PRIMARY THEME_BORDER
export THEME_TEXT_PRIMARY THEME_TEXT_SECONDARY THEME_TEXT_DIM
