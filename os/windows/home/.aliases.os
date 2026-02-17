#!/usr/bin/env bash
# Windows-specific aliases
# This file is sourced after .aliases (shared) and before .aliases.local
# Place Windows-specific command shortcuts here

# Windows path helpers
# alias winhome="cd /c/Users/$USER"
# alias winprog="cd /c/Program\ Files"

# Windows tool aliases (when available)
# alias code="/c/Program\ Files/Microsoft\ VS\ Code/bin/code"

# WSL-specific
if grep -q Microsoft /proc/version 2>/dev/null; then
  # alias explorer="explorer.exe ."
  :
fi

# Example: Windows package manager
# alias winget="winget.exe"
