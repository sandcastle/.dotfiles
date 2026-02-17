#!/usr/bin/env bash
# Windows-specific functions
# This file is sourced after .functions (shared) and before .functions.local
# Place Windows-specific functions here

# Windows path conversion helper
winpath() {
    # Convert Unix path to Windows path
    echo "$1" | sed 's|^/c/|C:\\|; s|/|\\|g'
}

# Open file/URL in default Windows app
winopen() {
    if command -v cmd.exe &> /dev/null; then
        cmd.exe /c start "" "$1"
    else
        xdg-open "$1" 2>/dev/null || open "$1"
    fi
}

# Kill Windows process by name
winkill() {
    taskkill.exe /F /IM "$1"
}

# ---------------------------- PATHS ----------------------------

# Extra paths
# Add to the list below when required
paths=(
)

# Join paths with colon separator
joined_paths=$(IFS=:; echo "${paths[*]}")
export PATH="${joined_paths}:$PATH"
