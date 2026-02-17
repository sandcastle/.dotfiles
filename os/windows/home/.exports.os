#!/usr/bin/env bash
# Windows-specific exports
# This file is sourced after .exports (shared) and before .exports.local
# Place Windows-specific environment variables here

# Windows-specific PATH handling
# Note: In Git Bash, Windows paths are translated (e.g., C:\ -> /c/)
# export PATH="/c/Program Files/MyApp/bin:$PATH"

# WSL-specific settings
if grep -q Microsoft /proc/version 2>/dev/null; then
  # WSL-specific exports
  # export WSL_HOST=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
  :
fi

# Example: Set Windows-compatible editor
# export EDITOR="code"  # VS Code
