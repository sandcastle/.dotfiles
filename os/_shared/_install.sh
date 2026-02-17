#!/usr/bin/env bash
#
# Shared install utility functions for all OS installers
# Source this file in OS-specific install.sh scripts
#

DEBUG=${DEBUG:-false}

# Install all apps from the OS install directory
# Arguments:
#   $1 - OS name (e.g., "omarchy", "mac", "cloud-shell", "windows")
#   $2 - Dotfiles root path
#   $3 - Install_all flag (true/false)
install_os_apps() {
    local os_name="$1"
    local dotfiles_root="$2"
    local install_all="$3"
    local install_dir="$dotfiles_root/os/$os_name/install"
    
    # Skip if --all was already passed and handled
    if [[ "$install_all" == "true" ]]; then
        if [[ -d "$install_dir" ]]; then
            info "Installing apps..."
            
            local installed_count=0
            for app_script in "$install_dir"/app-*.sh; do
                if [[ -f "$app_script" ]]; then
                    local app_name=$(basename "$app_script" | sed 's/app-//;s/\.sh$//')
                    if [[ "$DEBUG" == true ]]; then
                        # Show full output when debugging
                        if bash "$app_script"; then
                            ((installed_count++))
                            success "$app_name installed"
                        else
                            error "Failed to install $app_name"
                        fi
                    else
                        # Suppress output normally using SILENT mode
                        if env SILENT=true bash "$app_script" > /dev/null 2>&1; then
                            ((installed_count++))
                            success "$app_name installed"
                        else
                            warn "Failed to install $app_name"
                        fi
                    fi
                fi
            done
            
            if (( installed_count > 0 )); then
                success "$installed_count app(s) installed"
            else
                warn "No apps were installed"
            fi
        else
            warn "No install directory found at $install_dir"
        fi
        return
    fi
    
    # Interactive mode: ask user what they want to install
    if [[ -d "$install_dir" ]] && [[ -n $(ls -A "$install_dir"/app-*.sh 2>/dev/null) ]]; then
        echo ""
        info "Available apps:"
        
        # Build array of available apps
        local available_apps=()
        for app_script in "$install_dir"/app-*.sh; do
            if [[ -f "$app_script" ]]; then
                local app_name=$(basename "$app_script" | sed 's/app-//;s/\.sh$//')
                available_apps+=("$app_name")
                info "  • $app_name"
            fi
        done
        echo ""
        
        if confirm "Would you like to install all apps now?" false; then
            # Install all apps
            info "Installing apps..."
            local installed_count=0
            for app_script in "$install_dir"/app-*.sh; do
                if [[ -f "$app_script" ]]; then
                    local app_name=$(basename "$app_script" | sed 's/app-//;s/\.sh$//')
                    if [[ "$DEBUG" == true ]]; then
                        # Show full output when debugging
                        if bash "$app_script"; then
                            ((installed_count++))
                            success "$app_name installed"
                        else
                            error "Failed to install $app_name"
                        fi
                    else
                        # Suppress output normally using SILENT mode
                        if env SILENT=true bash "$app_script" > /dev/null 2>&1; then
                            ((installed_count++))
                            success "$app_name installed"
                        else
                            warn "Failed to install $app_name"
                        fi
                    fi
                fi
            done
            
            if (( installed_count > 0 )); then
                success "$installed_count app(s) installed"
            fi
        else
            # Offer multi-select to pick specific apps
            echo ""
            info "Select which apps to install:"
            
            # Display numbered list
            local i=0
            for app_name in "${available_apps[@]}"; do
                echo "  $((i+1)). $app_name"
                ((i++))
            done
            echo "  0. Skip (install none)"
            echo ""
            
            local selected_apps=""
            
            if has_gum; then
                # Use gum choose for multi-select
                selected_apps=$(printf '%s\n' "${available_apps[@]}" | gum choose --no-limit --header "Select apps to install (space to select, enter to confirm):")
            else
                # Fallback to manual input
                read -p "Enter numbers (e.g., '1 3 4' or '0' to skip): " selection
                if [[ "$selection" != "0" && -n "$selection" ]]; then
                    for num in $selection; do
                        if [[ "$num" =~ ^[0-9]+$ ]] && (( num > 0 && num <= ${#available_apps[@]} )); then
                            local app_name="${available_apps[$((num-1))]}"
                            if [[ -z "$selected_apps" ]]; then
                                selected_apps="$app_name"
                            else
                                selected_apps="$selected_apps""$'\n'""$app_name"
                            fi
                        else
                            warn "Invalid selection: $num"
                        fi
                    done
                fi
            fi
            
            # Install selected apps
            if [[ -n "$selected_apps" ]]; then
                info "Installing apps..."
                local installed_count=0
                
                while IFS= read -r app_name; do
                    if [[ -n "$app_name" ]]; then
                        local app_script="$install_dir/app-${app_name}.sh"
                        if [[ -f "$app_script" ]]; then
                    if [[ "$DEBUG" == true ]]; then
                        # Show full output when debugging
                        if bash "$app_script"; then
                            ((installed_count++))
                            success "$app_name installed"
                        else
                            error "Failed to install $app_name"
                        fi
                    else
                        # Suppress output normally using SILENT mode
                        if env SILENT=true bash "$app_script" > /dev/null 2>&1; then
                            ((installed_count++))
                            success "$app_name installed"
                        else
                            warn "Failed to install $app_name"
                        fi
                    fi
                        fi
                    fi
                done <<< "$selected_apps"
                
                if (( installed_count > 0 )); then
                    success "$installed_count app(s) installed"
                fi
            else
                info "No apps selected for installation"
            fi
            
            info ""
            info "To install additional apps later, use: apps install <app-name>"
        fi
    fi
}

# Remove dotfile symlinks for an OS
# Arguments:
#   $1 - OS name
#   $2 - Dotfiles root path
remove_dotfile_symlinks() {
    local os_name="$1"
    local dotfiles_root="$2"
    local dotfiles_home="$dotfiles_root/os/$os_name/home"
    
    info "Removing dotfile symlinks..."
    
    # Find all files in dotfiles home and remove their symlinks from $HOME
    if [[ -d "$dotfiles_home" ]]; then
        local removed_count=0
        find "$dotfiles_home" -type f -o -type l | while read -r file; do
            # Get relative path from DOTFILES_HOME
            local rel_path="${file#$dotfiles_home/}"
            local symlink_path="$HOME/$rel_path"
            
            # Remove if it's a symlink
            if [[ -L "$symlink_path" ]]; then
                rm -f "$symlink_path"
                $DEBUG && info "Removed: $symlink_path"
                ((removed_count++))
            fi
        done
        
        if (( removed_count > 0 )); then
            success "Removed $removed_count symlink(s)"
        fi
    fi
}

# Uninstall all apps for an OS
# Arguments:
#   $1 - OS name
#   $2 - Dotfiles root path
#   $3 - Purge flag (true/false)
uninstall_os_apps() {
    local os_name="$1"
    local dotfiles_root="$2"
    local purge="$3"
    local uninstall_dir="$dotfiles_root/os/$os_name/uninstall"
    
    if [[ -d "$uninstall_dir" ]]; then
        info "Uninstalling all apps..."
        
        local uninstalled_count=0
        for app_script in "$uninstall_dir"/app-*.sh; do
            if [[ -f "$app_script" ]]; then
                local app_name=$(basename "$app_script" | sed 's/app-//;s/\.sh$//')
                info "Uninstalling $app_name..."
                if [[ "$purge" == "true" ]]; then
                    if bash "$app_script" --purge; then
                        ((uninstalled_count++))
                    else
                        warn "Failed to uninstall $app_name"
                    fi
                else
                    if bash "$app_script"; then
                        ((uninstalled_count++))
                    else
                        warn "Failed to uninstall $app_name"
                    fi
                fi
            fi
        done
        
        if (( uninstalled_count > 0 )); then
            success "$uninstalled_count app(s) uninstalled"
        fi
    else
        warn "No uninstall directory found at $uninstall_dir"
    fi
}
