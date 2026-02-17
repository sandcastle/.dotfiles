#!/usr/bin/env bash
# macOS-specific exports
# This file is sourced after .exports (shared) and before .exports.local
# Place macOS-specific environment variables here

# Homebrew paths (will be set by Homebrew itself, but can be overridden here)
# export HOMEBREW_NO_ANALYTICS=1

# macOS-specific PATH additions
# export PATH="/usr/local/bin:$PATH"

# Example: Set default editor for macOS
# export EDITOR="cursor"

# ---------------------------- PATHS ----------------------------

# Extra paths
# Add to the list below when required
paths=(
  "$HOME/google-cloud-sdk/bin"
)

# Join paths with colon separator
joined_paths=$(IFS=:; echo "${paths[*]}")
export PATH="${joined_paths}:$PATH"
