#!/usr/bin/env bash
#
# Common functions for dotfiles app management across all OSes
# Source this file in OS-specific install/uninstall scripts
#
# Features:
# - Pretty terminal output with gum (falls back to colored text)
# - OS detection and package manager wrappers
# - Consistent logging and error handling
# - Theme integration with omarchy
#

set -e

# ============================================================================
# Configuration
# ============================================================================

# Detect the correct home directory (handle sudo case)
get_user_home() {
    if [[ -n "${SUDO_USER:-}" ]]; then
        # Running with sudo - use the original user's home
        eval echo "~$SUDO_USER"
    else
        # Normal case - use current user's home
        echo "$HOME"
    fi
}

USER_HOME=$(get_user_home)
DOTFILES_ROOT="${DOTFILES_ROOT:-$USER_HOME/.dotfiles}"
DEBUG=${DEBUG:-false}
SILENT=${SILENT:-false}

# Load theme configuration
if [ -f "$DOTFILES_ROOT/lib/theme.sh" ]; then
    source "$DOTFILES_ROOT/lib/theme.sh"
fi

# Disable gum in SILENT mode to avoid terminal control issues
if [[ "$SILENT" == true ]]; then
    # Override has_gum to return false
    has_gum() { return 1; }
fi

# Check if gum is available (disabled in SILENT mode)
has_gum() {
    # Disable gum in SILENT mode to avoid terminal control issues
    if [[ "${SILENT:-false}" == true ]]; then
        return 1
    fi
    command -v gum &> /dev/null
}

# ============================================================================
# Pretty Output Functions
# ============================================================================

# Print a styled header
header() {
    local text="$1"
    if has_gum; then
        gum style --border double --margin "1 0" --padding "1 2" --foreground ${THEME_PRIMARY:-212} "$text"
    else
        echo ""
        echo -e "\033[1m\033[38;5;${THEME_PRIMARY:-212}m══════════════════════════════════════════════════════════════\033[0m"
        echo -e "\033[1m\033[38;5;${THEME_PRIMARY:-212}m  ${text}\033[0m"
        echo -e "\033[1m\033[38;5;${THEME_PRIMARY:-212}m══════════════════════════════════════════════════════════════\033[0m"
        echo ""
    fi
}

# Print a section title
section() {
    local text="$1"
    if has_gum; then
        gum style --border normal --margin "1 0" --padding "0 2" --foreground ${THEME_SECONDARY:-99} "▸ $text"
    else
        echo ""
        echo -e "\033[1m\033[38;5;${THEME_SECONDARY:-99}m▸\033[0m \033[1m${text}\033[0m"
        echo ""
    fi
}

# Info message
info() {
    local text="$1"
    if has_gum; then
        gum style --foreground ${THEME_INFO:-240} "• $text"
    else
        echo -e "\033[38;5;${THEME_INFO:-240}m• ${text}\033[0m"
    fi
}

# Success message with checkmark
success() {
    local text="$1"
    if has_gum; then
        gum style --foreground ${THEME_SUCCESS:-46} "✓ $text"
    else
        echo -e "\033[38;5;${THEME_SUCCESS:-46}m✓ ${text}\033[0m"
    fi
}

# Warning message
warn() {
    local text="$1"
    if has_gum; then
        gum style --foreground ${THEME_WARNING:-208} "⚠ $text"
    else
        echo -e "\033[38;5;${THEME_WARNING:-208}m⚠ ${text}\033[0m"
    fi
}

# Error message
error() {
    local text="$1"
    if has_gum; then
        gum style --foreground ${THEME_ERROR:-196} "✗ $text"
    else
        echo -e "\033[38;5;${THEME_ERROR:-196}m✗ ${text}\033[0m" >&2
    fi
}

# Status spinner (for long operations)
spin() {
    local title="$1"
    shift
    if has_gum; then
        gum spin --spinner dot --title "$title" -- "$@"
    else
        info "$title..."
        "$@"
    fi
}

# Confirmation prompt
confirm() {
    local text="$1"
    local default="${2:-true}"
    if has_gum; then
        if [ "$default" = "true" ]; then
            gum confirm "$text" --default=true
        else
            gum confirm "$text" --default=false
        fi
    else
        if [ "$default" = "true" ]; then
            read -p "$text [Y/n]: " response
            response=${response:-Y}
        else
            read -p "$text [y/N]: " response
            response=${response:-N}
        fi
        [[ "$response" =~ ^[Yy]$ ]]
    fi
}

# Text input prompt
input() {
    local placeholder="$1"
    if has_gum; then
        gum input --placeholder "$placeholder"
    else
        read -p "$placeholder: " value
        echo "$value"
    fi
}

# Choose from a list
choose() {
    if has_gum; then
        gum choose "$@"
    else
        select choice in "$@"; do
            echo "$choice"
            break
        done
    fi
}

# Filter/search through a list
filter() {
    if has_gum; then
        gum filter "$@"
    else
        cat
    fi
}

# Join items with separator
join() {
    local separator="$1"
    shift
    local result=""
    local first=true
    for item in "$@"; do
        if [ "$first" = true ]; then
            result="$item"
            first=false
        else
            result="${result}${separator}${item}"
        fi
    done
    echo "$result"
}

# ============================================================================
# Legacy Logging Functions (deprecated, use new functions above)
# ============================================================================

log_info() {
    info "$1"
}

log_error() {
    error "$1"
}

log_success() {
    success "$1"
}

# ============================================================================
# Check Functions
# ============================================================================

# Check if a command/binary is already installed
check_installed() {
    local binary="$1"
    local display_name="${2:-$binary}"
    
    if command -v "$binary" &> /dev/null; then
        info "$display_name is already installed"
        return 0
    fi
    return 1
}

# Check if a file exists (for Windows/Git Bash where binaries might not be in PATH)
check_file_exists() {
    local file_path="$1"
    local display_name="$2"
    
    if [ -f "$file_path" ]; then
        info "$display_name is already installed (found at $file_path)"
        return 0
    fi
    return 1
}

# ============================================================================
# Backup Functions
# ============================================================================

# Create timestamped backup directory
get_backup_dir() {
    local os_name="$1"
    echo "$USER_HOME/.backup/$(date +%Y%m%d_%H%M%S)_${os_name}"
}

# Backup a file before overwriting
backup_file() {
    local file="$1"
    local backup_dir="$2"
    
    if [ -f "$file" ] && [ ! -L "$file" ]; then
        mkdir -p "$backup_dir"
        local filename=$(basename "$file")
        mv "$file" "$backup_dir/$filename"
        $DEBUG && info "Backed up $filename"
        return 0
    fi
    
    # Also backup existing symlinks
    if [ -L "$file" ]; then
        mkdir -p "$backup_dir"
        local filename=$(basename "$file")
        cp -a "$file" "$backup_dir/$filename"
        rm "$file"
        $DEBUG && info "Backed up symlink $filename"
        return 0
    fi
    
    return 1
}

# ============================================================================
# Symlink Functions
# ============================================================================

# Create a symlink, backing up existing files first
symlink_dotfile() {
    local source="$1"
    local target="$2"
    local backup_dir="$3"
    
    local filename=$(basename "$source")
    
    # Backup existing file/symlink if it exists (ignore return value)
    backup_file "$target" "$backup_dir" || true
    
    # If source is a symlink, resolve it to the absolute path
    # This ensures the link works from the target directory
    if [ -L "$source" ]; then
        # Get the directory containing the source symlink
        local source_dir=$(dirname "$source")
        # Get the relative target of the symlink
        local rel_target=$(readlink "$source")
        # Change to source directory and resolve to absolute path
        local resolved_source=$(cd "$source_dir" && realpath "$rel_target" 2>/dev/null || echo "$source")
        if [ -e "$resolved_source" ]; then
            source="$resolved_source"
        fi
    fi
    
    # Create the symlink
    ln -sf "$source" "$target"
    success "Linked $filename"
    $DEBUG && info "  → $source"
    return 0
}

# Symlink all dotfiles from a directory with progress
symlink_all_dotfiles() {
    local source_dir="$1"
    local target_dir="$2"
    local backup_dir="$3"
    
    if [[ "$DEBUG" == true ]]; then
        section "Installing dotfiles"
        info "Source: $source_dir"
        info "Backup: $backup_dir"
    else
        info "Installing dotfiles..."
    fi
    
    mkdir -p "$backup_dir"
    
    local count=0
    # Find all files and symlinks recursively, including hidden files
    while IFS= read -r -d '' file; do
        # Get relative path from source_dir
        local rel_path="${file#$source_dir/}"
        local target="$target_dir/$rel_path"
        local target_parent=$(dirname "$target")
        
        # Create parent directory if needed
        if [[ "$target_parent" != "$target_dir" ]]; then
            mkdir -p "$target_parent"
        fi
        
        # If source is a symlink, resolve it to the absolute path
        local source="$file"
        if [ -L "$file" ]; then
            local source_parent=$(dirname "$file")
            local rel_target=$(readlink "$file")
            local resolved_source=$(cd "$source_parent" && realpath "$rel_target" 2>/dev/null || echo "$file")
            if [ -e "$resolved_source" ]; then
                source="$resolved_source"
            fi
        fi
        
        # Backup existing file/symlink if it exists
        backup_file "$target" "$backup_dir" || true
        
        # Create the symlink (force overwrite)
        ln -sf "$source" "$target"
        success "Linked $rel_path"
        $DEBUG && info "  → $source"
        count=$((count + 1))
    done < <(find "$source_dir" -type f -print0 -o -type l -print0 2>/dev/null)
    
    success "Installed $count dotfiles"
    $DEBUG && info "Backups in: $backup_dir"
    return 0
}

# ============================================================================
# OS Detection Functions
# ============================================================================

# Detect current OS
detect_os() {
    # Check for Omarchy (Arch Linux with Omarchy-specific files)
    if [ -f /etc/arch-release ] && [ -d "$HOME/.local/share/omarchy" ]; then
        echo "omarchy"
        return
    fi
    
    # Check for Arch Linux
    if [ -f /etc/arch-release ]; then
        echo "arch"
        return
    fi
    
    # Check for macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "mac"
        return
    fi
    
    # Check for GCP Cloud Shell
    if [ -n "$CLOUD_SHELL" ] || [ -n "$DEVSHELL_PROJECT_ID" ]; then
        echo "cloud-shell"
        return
    fi
    
    # Check for Windows (Git Bash, MSYS2, Cygwin)
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == mingw* ]]; then
        echo "windows"
        return
    fi
    
    # Check for WSL
    if [ -f /proc/version ] && grep -q Microsoft /proc/version; then
        echo "wsl"
        return
    fi
    
    echo "unknown"
}

# Detect Windows shell type (git-bash, wsl, cygwin)
detect_windows_shell() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == mingw* ]]; then
        echo "git-bash"
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        echo "cygwin"
    elif [ -f /proc/version ] && grep -q Microsoft /proc/version; then
        echo "wsl"
    else
        echo "unknown"
    fi
}

# ============================================================================
# Package Manager Functions with Pretty Output
# ============================================================================

# Check if a package is available in pacman repos
check_pacman_package() {
    local package="$1"
    pacman -Ss "^$package$" &> /dev/null
}

# Install package with pacman (Omarchy/Arch)
install_pacman() {
    local packages="$1"
    if has_gum; then
        spin "Installing packages via pacman: $packages" sudo pacman -S --needed --noconfirm $packages
    else
        info "Installing via pacman: $packages"
        sudo pacman -S --needed --noconfirm $packages
    fi
}

# Install package with yay (AUR)
install_yay() {
    local packages="$1"
    if has_gum; then
        spin "Installing packages via yay (AUR): $packages" yay -S --needed --noconfirm $packages
    else
        info "Installing via yay (AUR): $packages"
        yay -S --needed --noconfirm $packages
    fi
}

# Install package with apt (Debian/Ubuntu)
install_apt() {
    local packages="$1"
    if has_gum; then
        spin "Installing packages via apt: $packages" bash -c "sudo apt-get update && sudo apt-get install -y $packages"
    else
        info "Installing via apt: $packages"
        sudo apt-get update
        sudo apt-get install -y $packages
    fi
}

# Install package with Homebrew (macOS)
install_brew() {
    local formula="$1"
    
    # Ensure Homebrew is installed
    if ! command -v brew &> /dev/null; then
        section "Installing Homebrew"
        if has_gum; then
            spin "Installing Homebrew..." bash -c '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        else
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    fi
    
    if has_gum; then
        spin "Installing via Homebrew: $formula" brew install $formula
    else
        info "Installing via Homebrew: $formula"
        brew install $formula
    fi
}

# Install package with winget (Windows Git Bash)
install_winget() {
    local package_id="$1"
    if has_gum; then
        spin "Installing via winget: $package_id" winget install --id "$package_id" --accept-package-agreements --accept-source-agreements
    else
        info "Installing via winget: $package_id"
        winget install --id "$package_id" --accept-package-agreements --accept-source-agreements
    fi
}

# Install package with Chocolatey (Windows)
install_choco() {
    local package="$1"
    if has_gum; then
        spin "Installing via Chocolatey: $package" choco install "$package" -y
    else
        info "Installing via Chocolatey: $package"
        choco install "$package" -y
    fi
}

# Uninstall package with pacman
uninstall_pacman() {
    local packages="$1"
    if has_gum; then
        spin "Removing packages via pacman: $packages" sudo pacman -R --noconfirm $packages
    else
        info "Uninstalling via pacman: $packages"
        sudo pacman -R --noconfirm $packages || true
    fi
}

# Uninstall package with apt
uninstall_apt() {
    local packages="$1"
    if has_gum; then
        spin "Removing packages via apt: $packages" sudo apt-get remove -y $packages
    else
        info "Uninstalling via apt: $packages"
        sudo apt-get remove -y $packages
    fi
}

# Uninstall package with Homebrew
uninstall_brew() {
    local formula="$1"
    if has_gum; then
        spin "Removing via Homebrew: $formula" brew uninstall "$formula"
    else
        info "Uninstalling via Homebrew: $formula"
        brew uninstall "$formula"
    fi
}

# Uninstall package with winget
uninstall_winget() {
    local package_id="$1"
    if has_gum; then
        spin "Removing via winget: $package_id" winget uninstall --id "$package_id"
    else
        info "Uninstalling via winget: $package_id"
        winget uninstall --id "$package_id"
    fi
}

# Uninstall package with Chocolatey
uninstall_choco() {
    local package="$1"
    if has_gum; then
        spin "Removing via Chocolatey: $package" choco uninstall "$package" -y
    else
        info "Uninstalling via Chocolatey: $package"
        choco uninstall "$package" -y
    fi
}

# ============================================================================
# Configuration Functions
# ============================================================================

# Link app configuration files from dotfiles
link_app_config() {
    local app_name="$1"
    local os_name="$2"
    local config_dir="${3:-$HOME/.config/$app_name}"
    
    # Try OS-specific config first
    local os_config="$DOTFILES_ROOT/os/$os_name/configs/$app_name"
    
    # Fall back to common config
    local common_config="$DOTFILES_ROOT/configs/$app_name"
    
    local source_config=""
    
    if [ -d "$os_config" ]; then
        source_config="$os_config"
    elif [ -d "$common_config" ]; then
        source_config="$common_config"
    fi
    
    if [ -n "$source_config" ]; then
        info "Linking configs for $app_name from $source_config"
        mkdir -p "$config_dir"
        
        local count=0
        for config in "$source_config"/*; do
            if [ -f "$config" ]; then
                local target="$config_dir/$(basename "$config")"
                ln -sf "$config" "$target"
                ((count++)) || true
            fi
        done
        success "Linked $count config files for $app_name"
    fi
}

# Remove app configuration files (for --purge)
remove_app_config() {
    local app_name="$1"
    local config_dir="${2:-$HOME/.config/$app_name}"
    
    if [ -d "$config_dir" ]; then
        if has_gum; then
            if confirm "Remove $app_name configuration directory? ($config_dir)"; then
                rm -rf "$config_dir"
                success "Removed config directory: $config_dir"
            fi
        else
            info "Removing configuration directory: $config_dir"
            rm -rf "$config_dir"
        fi
    fi
}

# ============================================================================
# Git Configuration Helper
# ============================================================================

# Setup git user configuration (creates ~/.gitconfig.user)
# This keeps PII (name, email) out of the dotfiles repo
setup_git_user_config() {
    local gitconfig_user="$USER_HOME/.gitconfig.user"
    
    # Check if user config already exists
    if [ -f "$gitconfig_user" ]; then
        info "Git user config already exists at $gitconfig_user"
        return 0
    fi
    
    section "Git Configuration"
    info "Setting up git user information (stored in $gitconfig_user)"
    info "Note: This file is NOT tracked in your dotfiles repo for privacy"
    
    # Get user input
    local git_name=""
    local git_email=""
    local github_user=""
    
    if has_gum; then
        git_name=$(input "Your full name for git commits")
        git_email=$(input "Your email address for git commits")
        github_user=$(input "Your GitHub username (optional, press Enter to skip)")
    else
        echo ""
        read -p "Your full name for git commits: " git_name
        read -p "Your email address for git commits: " git_email
        read -p "Your GitHub username (optional): " github_user
    fi
    
    # Validate inputs
    if [ -z "$git_name" ] || [ -z "$git_email" ]; then
        warn "Git user name or email not provided"
        warn "You can configure this later by editing $gitconfig_user"
        return 1
    fi
    
    # Create the user config file
    cat > "$gitconfig_user" << EOF
# Git user configuration
# This file is NOT tracked in dotfiles repo - contains personal info
# Generated by dotfiles installer on $(date)

[user]
  name = $git_name
  email = $git_email
EOF
    
    # Add GitHub user if provided
    if [ -n "$github_user" ]; then
        cat >> "$gitconfig_user" << EOF

[github]
  user = $github_user
EOF
    fi
    
    # Secure the file (readable only by user)
    chmod 600 "$gitconfig_user"
    
    success "Git user configuration created!"
    info "Location: $gitconfig_user"
    info "This file contains your PII and is NOT tracked in git"
    
    return 0
}

# ============================================================================
# Main Install/Uninstall Helpers
# ============================================================================

# Generic install function that OS scripts can call
install_app() {
    local app_name="$1"
    local os_name="$2"
    local binary_name="$3"
    local install_func="$4"
    shift 4
    
    section "Installing $app_name on $os_name"
    
    # Check if already installed
    if check_installed "$binary_name" "$app_name"; then
        exit 0
    fi
    
    # Run the install function
    $install_func "$@"
    
    success "$app_name installed successfully on $os_name!"
}

# Generic uninstall function that OS scripts can call
uninstall_app() {
    local app_name="$1"
    local os_name="$2"
    local binary_name="$3"
    local uninstall_func="$4"
    local purge="${5:-false}"
    shift 4
    
    section "Uninstalling $app_name from $os_name"
    
    # Check if installed
    if ! command -v "$binary_name" &> /dev/null; then
        info "$app_name is not installed"
        exit 0
    fi
    
    # Run the uninstall function
    $uninstall_func "$@"
    
    success "$app_name uninstalled successfully from $os_name!"
}

# ============================================================================
# Script Utilities
# ============================================================================

# Ensure script is executable
ensure_executable() {
    local script="$1"
    if [ -f "$script" ] && [ ! -x "$script" ]; then
        chmod +x "$script"
        info "Made $script executable"
    fi
}

# Get available app scripts for an OS
list_available_apps() {
    local os_name="$1"
    local action="$2"  # install or uninstall
    
    local dir="$DOTFILES_ROOT/os/$os_name/$action"
    
    if [ -d "$dir" ]; then
        ls "$dir"/app-*.sh 2>/dev/null | xargs -n1 basename | sed 's/app-//;s/\.sh$//' || echo ""
    fi
}

# ============================================================================
# Gum Installation Helper
# ============================================================================

# Install gum if not present
ensure_gum() {
    if ! has_gum; then
        section "Installing Gum (for pretty output)"
        
        local os=$(detect_os)
        case "$os" in
            omarchy|arch)
                if check_pacman_package "gum"; then
                    install_pacman "gum"
                else
                    install_yay "gum"
                fi
                ;;
            mac)
                install_brew "gum"
                ;;
            cloud-shell)
                # Debian/Ubuntu based (GCP Cloud Shell) - use official Charm repo
                if command -v apt-get &> /dev/null; then
                    info "Setting up Charm repository for Gum..."
                    sudo mkdir -p /etc/apt/keyrings
                    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
                    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
                    sudo apt-get update
                    sudo apt-get install -y gum
                else
                    warn "No package manager found for Gum, using plain text output"
                    return 1
                fi
                ;;
            windows)
                local shell=$(detect_windows_shell)
                case "$shell" in
                    git-bash)
                        # Try winget first, then choco
                        if command -v winget &> /dev/null; then
                            install_winget "CharmSoft.Gum"
                        elif command -v choco &> /dev/null; then
                            install_choco "gum"
                        else
                            warn "No package manager found for Gum, using plain text output"
                            return 1
                        fi
                        ;;
                    wsl)
                        # WSL - check if Debian/Ubuntu or Arch based
                        if command -v apt-get &> /dev/null; then
                            # Debian/Ubuntu WSL - use official Charm repo
                            info "Setting up Charm repository for Gum..."
                            sudo mkdir -p /etc/apt/keyrings
                            curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
                            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
                            sudo apt-get update
                            sudo apt-get install -y gum
                        elif command -v pacman &> /dev/null; then
                            # Arch WSL
                            install_pacman "gum"
                        else
                            warn "No package manager found for Gum, using plain text output"
                            return 1
                        fi
                        ;;
                esac
                ;;
            *)
                warn "Cannot install Gum on this system, using plain text output"
                return 1
                ;;
        esac
        
        if has_gum; then
            success "Gum installed successfully!"
        fi
    fi
}
