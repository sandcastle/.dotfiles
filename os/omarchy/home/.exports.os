#!/usr/bin/env bash
# Omarchy-specific exports
# This file is sourced after .exports (shared) and before .exports.local
# Place Omarchy-specific environment variables here

# Example: Omarchy-specific environment
# export OMANCHY_THEME="catppuccin"

# ---------------------------- PATHS ----------------------------

# Extra paths
# Add to the list below when required
paths=(
  "$HOME/.local/share/google-cloud-sdk/bin"
  "$HOME/.local/share/google-cloud-sdk/google-cloud-sdk/bin"
  "$HOME/.local/share/JetBrains/Toolbox/scripts"
)

# Join paths with colon separator
joined_paths=$(IFS=:; echo "${paths[*]}")
export PATH="${joined_paths}:$PATH"
