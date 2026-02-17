#!/usr/bin/env bash
# GCP Cloud Shell-specific exports
# This file is sourced after .exports (shared) and before .exports.local
# Place Cloud Shell-specific environment variables here

# Cloud Shell project configuration
# export DEVSHELL_PROJECT_ID="your-project-id"

# Google Cloud SDK path (usually pre-configured)
# export PATH="$HOME/google-cloud-sdk/bin:$PATH"

# Example: Set default region
# export CLOUDSDK_COMPUTE_REGION=us-central1

# ---------------------------- PATHS ----------------------------

# Extra paths
# Add to the list below when required
paths=(
)

# Join paths with colon separator
joined_paths=$(IFS=:; echo "${paths[*]}")
export PATH="${joined_paths}:$PATH"
