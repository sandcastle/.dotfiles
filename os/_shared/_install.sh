#!/usr/bin/env bash
#
# Shared install utility functions for all OS installers
#

DEBUG=${DEBUG:-false}

# Install all apps from the OS install directory
# Arguments: $1=OS name, $2=dotfiles root, $3=install_all flag
install_os_apps() {
    local os_name="$1" dotfiles_root="$2" install_all="$3"
    local install_dir="$dotfiles_root/os/$os_name/install"
    
    [[ "$install_all" == "true" ]] || return
    [[ -d "$install_dir" ]] || { warn "No install directory: $install_dir"; return; }
    
    # Disable gum for app installations to prevent terminal control issues
    # Export SILENT so child scripts (which source common.sh) will disable gum
    export SILENT=true
    
    info "Installing apps..."
    local installed_count=0
    
    for app_script in "$install_dir"/app-*.sh; do
        [[ -f "$app_script" ]] || continue
        local app_name=$(basename "$app_script" | sed 's/app-//;s/\.sh$//')
        info "Processing: $app_name"
        
        # Run app script: debug shows output, normal suppresses it
        # Run in background then wait to avoid terminal state issues from gcloud
        if [[ "$DEBUG" == true ]]; then
            bash "$app_script" &
            wait $!
        else
            bash "$app_script" >/dev/null 2>&1 &
            wait $! 2>/dev/null || true
        fi
        
        # Use increment without arithmetic context to avoid hang
        installed_count=$((installed_count + 1))
        success "$app_name installed"
    done
    
    [[ $installed_count -gt 0 ]] && success "$installed_count app(s) installed" || warn "No apps installed"
}

# Remove dotfile symlinks
# Arguments: $1=OS name, $2=dotfiles root
remove_dotfile_symlinks() {
    local os_name="$1" dotfiles_root="$2"
    local dotfiles_home="$dotfiles_root/os/$os_name/home"
    
    [[ -d "$dotfiles_home" ]] || return
    info "Removing dotfile symlinks..."
    
    local removed_count=0
    while read -r file; do
        local symlink_path="$HOME/${file#$dotfiles_home/}"
        [[ -L "$symlink_path" ]] && rm -f "$symlink_path" && ((removed_count++))
    done < <(find "$dotfiles_home" -type f -o -type l)
    
    (( removed_count > 0 )) && success "Removed $removed_count symlink(s)"
}

# Uninstall all apps
# Arguments: $1=OS name, $2=dotfiles root, $3=purge flag
uninstall_os_apps() {
    local os_name="$1" dotfiles_root="$2" purge="$3"
    local uninstall_dir="$dotfiles_root/os/$os_name/uninstall"
    
    [[ -d "$uninstall_dir" ]] || { warn "No uninstall directory: $uninstall_dir"; return; }
    info "Uninstalling apps..."
    
    local uninstalled_count=0
    for app_script in "$uninstall_dir"/app-*.sh; do
        [[ -f "$app_script" ]] || continue
        local app_name=$(basename "$app_script" | sed 's/app-//;s/\.sh$//')
        info "Uninstalling $app_name..."
        [[ "$purge" == "true" ]] && bash "$app_script" --purge || bash "$app_script"
        ((uninstalled_count++))
    done
    
    (( uninstalled_count > 0 )) && success "$uninstalled_count app(s) uninstalled"
}
