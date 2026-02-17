# Dotfiles

Personal dotfiles repository supporting multiple operating systems: Omarchy (Arch Linux), macOS, GCP Cloud Shell, and Windows (Git Bash/WSL).

## Quick Install

Install everything with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/sandcastle/.dotfiles/main/go.sh | bash
```

Or manually clone and install:

```bash
git clone https://github.com/sandcastle/.dotfiles.git ~/.dotfiles
bash ~/.dotfiles/os/install.sh
```

## Supported Operating Systems

| OS | Package Manager | Status |
|----|----------------|--------|
| **Omarchy** (Arch Linux) | `pacman` / `yay` | ✅ Fully supported |
| **macOS** | `brew` (Homebrew) | ✅ Fully supported |
| **GCP Cloud Shell** | `apt` | ✅ Fully supported |
| **Windows (Git Bash)** | `winget` / `choco` | ✅ Fully supported |
| **Windows (WSL)** | `apt` / `pacman` | ✅ Fully supported |

The installer automatically detects your OS and runs the appropriate setup.

## Architecture

```
.dotfiles/
├── go.sh                   # One-liner installer (curl | bash) - only file in root
├── lib/
│   ├── common.sh           # Shared functions for all OS scripts
│   └── theme.sh            # Color theme configuration
├── os/
│   ├── install.sh          # Main installer (detects OS, runs init + install)
│   ├── _shared/            # Cross-OS shared files
│   │   └── home/
│   │       └── .gitconfig  # Shared git config (symlinked to each OS)
│   ├── omarchy/            # Arch Linux / Omarchy
│   ├── mac/                # macOS
│   ├── cloud-shell/        # GCP Cloud Shell
│   └── windows/            # Windows (Git Bash & WSL)
└── configs/                # Shared app configurations
```

### Common Library (`lib/common.sh`)

All OS-specific scripts source this library for consistent:
- Logging functions (`info`, `success`, `error`, `warn`)
- Package manager wrappers (`install_pacman`, `install_brew`, `install_apt`, `install_winget`, etc.)
- OS detection (`detect_os`, `detect_windows_shell`)
- Configuration management (`link_app_config`, `symlink_all_dotfiles`)
- Backup utilities (`get_backup_dir`, `backup_file`)
- Interactive prompts (`confirm`, `input`, `has_gum`)
- Git user config setup (`setup_git_user_config`) - keeps PII out of repo

### Shared Install Utilities (`os/_shared/_install.sh`)

Reusable functions for install/uninstall scripts:
- `install_os_apps()` - Interactive or batch app installation
- `uninstall_os_apps()` - Batch app uninstallation
- `remove_dotfile_symlinks()` - Clean up dotfile links

## Usage

### Install Dotfiles

```bash
# Automatic (detects OS, runs init + install)
bash ~/.dotfiles/os/install.sh

# Install dotfiles + all apps automatically
bash ~/.dotfiles/os/install.sh --all

# Or run components separately
bash ~/.dotfiles/os/mac/init.sh      # Install prerequisites
bash ~/.dotfiles/os/mac/install.sh   # Install dotfiles
```

### Init System (Prerequisites)

Each OS has an `init.sh` script that installs **mandatory** prerequisites before the dotfiles can be used:

```
os/{platform}/
├── init.sh              # Runs init apps in order
└── init/
    ├── app-homebrew.sh  # macOS: Install Homebrew
    ├── app-gum.sh       # Install Gum for pretty output
    └── app-git.sh       # Windows: Verify Git
```

**Examples:**

| OS | Init Apps | Purpose |
|----|-----------|---------|
| **macOS** | `app-homebrew.sh` | Install Homebrew (required for packages) |
| **Omarchy** | `app-gum.sh` | Install Gum for pretty output |
| **Cloud Shell** | (none) | Most tools pre-installed |
| **Windows** | `app-git.sh` | Verify Git for Windows |

The init scripts run **automatically** during `install.sh` before dotfiles are installed.

### Uninstall Dotfiles

```bash
# Remove dotfile symlinks
bash ~/.dotfiles/os/omarchy/uninstall.sh

# Uninstall all apps + remove dotfiles
bash ~/.dotfiles/os/omarchy/uninstall.sh --all

# Uninstall everything including configs
bash ~/.dotfiles/os/omarchy/uninstall.sh --all --purge
```

### Manage Apps

```bash
# Install an app
apps install docker
apps i docker          # shorthand

# Uninstall an app
apps uninstall docker

# List available apps
apps install           # Shows all installable apps
apps uninstall         # Shows all uninstallable apps
```

Apps are stored in `~/.dotfiles/os/{platform}/install/` and `uninstall/`.

### Available Apps

| App | Description |
|-----|-------------|
| `gh` | GitHub CLI |
| `gcloud` | Google Cloud CLI (with kubectl, cloud_sql_proxy, gke-auth-plugin, docker-credential-gcr) |
| `glow` | Markdown reader for terminal |
| `kubectx` | Kubernetes context/namespace switcher (includes `kubens`) |
| `opencode` | CLI tool for OpenCode |

### Interactive App Selection

When running `./install.sh` (without `--all`), you'll be prompted:
1. List of available apps is displayed
2. Choose **Yes** to install all apps, or **No** to pick specific ones
3. If No: multi-select interface to choose which apps to install (uses Gum if available, falls back to numbered input)

## Managing Apps

### Adding a New App

Create install/uninstall scripts for each supported OS:

**Example:** `app-gh.sh` (GitHub CLI)
```bash
#!/usr/bin/env bash
set -e
DOTFILES_ROOT="$(cd "$(dirname "$0")/../../../" && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"

APP_NAME="GitHub CLI"
info "Installing $APP_NAME..."

command -v gh &>/dev/null && { info "Already installed"; exit 0; }
install_brew "gh"  # or install_pacman, install_apt, etc.
success "$APP_NAME installed!"
```

Make executable:
```bash
chmod +x ~/.dotfiles/os/*/install/app-<name>.sh
```

### App Configuration

Place common configs in:
- `~/.dotfiles/configs/{app-name}/` - Shared across all OSes
- `~/.dotfiles/os/{platform}/configs/{app-name}/` - OS-specific overrides

Install scripts automatically link configs using `link_app_config`.

## Windows Specifics

### Git Bash

- No `sudo` required (runs as Windows user)
- Uses `winget` or `choco` for package installation
- Configs stored in Unix-style paths: `~/.config/`
- Can also access Windows paths: `/c/Users/{user}/AppData/Roaming/`

### WSL (Windows Subsystem for Linux)

- Full Linux environment with `sudo` support
- Uses `apt` or `pacman` depending on WSL distro
- Access Windows files at `/mnt/c/`

## Backups

Before making changes, existing files are backed up to:
```
~/.backup/{YYYYMMDD_HHMMSS}_{os_name}/
```

This includes:
- Existing dotfiles (before symlinking)
- Existing symlinks (before replacing)
- App configuration files (when using `--purge`)

## Features

- ✅ **Multi-OS Support** - Works on Omarchy, macOS, Cloud Shell, Windows
- ✅ **Idempotent** - Safe to run multiple times
- ✅ **Automatic Backups** - Never lose your existing files
- ✅ **Common Library** - DRY code with shared functions
- ✅ **OS Detection** - Automatically detects environment
- ✅ **App Management** - Simple `apps install/uninstall` commands
- ✅ **Windows Support** - Handles both Git Bash and WSL
- ✅ **Shared Configs** - Common configurations across OSes

## Requirements

### Omarchy/Arch Linux
- `pacman` (for official repos)
- `yay` (for AUR packages)
- `git`

### macOS
- Homebrew (auto-installed if missing)
- `git`

### GCP Cloud Shell
- Pre-configured environment
- `apt`
- `git`

### Windows (Git Bash)
- Git for Windows (includes Git Bash)
- `winget` (Windows 10/11) or `choco`

### Windows (WSL)
- WSL2 with Ubuntu/Debian or Arch
- Standard Linux tools

## Development

### Testing Changes

```bash
# Test OS detection
bash ~/.dotfiles/os/install.sh

# Test specific OS installer
bash ~/.dotfiles/os/omarchy/install.sh

# Test app install
bash ~/.dotfiles/os/omarchy/install/app-docker.sh
```

### Project Structure

The repository is organized by OS, with a shared library for common functionality:

- Each OS has its own `home/` directory for dotfiles
- Apps have install/uninstall scripts in `install/` and `uninstall/` directories
- The `lib/common.sh` provides reusable functions for all scripts
- OS detection happens automatically in the root `install.sh`

### opencode Skill

This repository includes an opencode skill for AI assistance with app management:

```
~/.dotfiles/.opencode/skills/dotfiles-app-manager/SKILL.md
```

The skill helps with:
- Creating install/uninstall scripts for all OSes
- Using the common library functions
- Following best practices for multi-OS support
- Handling Windows (Git Bash vs WSL) differences

## Theme Customization

The dotfiles use a color theme system that automatically matches your Omarchy theme or can be customized at multiple levels:

### Default Theme Colors

| Variable | Color | Usage |
|----------|-------|-------|
| `THEME_PRIMARY` | Hot Pink (212) | Headers, borders |
| `THEME_SECONDARY` | Purple (99) | Section titles |
| `THEME_SUCCESS` | Green (46) | Success messages |
| `THEME_ERROR` | Red (196) | Error messages |
| `THEME_WARNING` | Orange (208) | Warnings |
| `THEME_INFO` | Gray (240) | Information |

Find color codes at: [256 Colors Cheat Sheet](https://jonasjacek.github.io/colors/)

### Theme Configuration Hierarchy

Themes are loaded in this order (later overrides earlier):

1. **Built-in defaults** (`lib/theme.sh`)
2. **System-wide config** (`/etc/dotfiles.theme`) - requires root to create, readable by all
3. **Omarchy auto-detection** (matches your current theme)
4. **User override** (`~/.dotfiles-theme.sh`)

### System-wide Configuration

For system-wide theme settings (affects all users):

```bash
sudo tee /etc/dotfiles.theme << 'EOF'
THEME_PRIMARY="117"
THEME_SECONDARY="141"
THEME_SUCCESS="120"
EOF
```

**Note:** `/etc` is typically world-readable, so this works fine for non-elevated processes.

### User Configuration

Create `~/.dotfiles-theme.sh` for personal theme overrides:

```bash
# ~/.dotfiles-theme.sh
THEME_PRIMARY="117"      # Cyan
THEME_SUCCESS="120"      # Bright green
THEME_ERROR="196"        # Red
```

### Auto-Detection

If you're using Omarchy, the theme automatically detects and matches:
- Catppuccin (pink/purple)
- Tokyo Night (cyan/blue)
- Nord (frost colors)
- Dracula (pink/purple)

### Gum Integration

For the best visual experience, install [Gum](https://github.com/charmbracelet/gum):

```bash
# Omarchy/Arch
sudo pacman -S gum

# macOS
brew install gum

# Debian/Ubuntu (including GCP Cloud Shell & WSL)
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update && sudo apt install gum

# Windows (Git Bash)
winget install CharmSoft.Gum
```

The dotfiles automatically use Gum when available for:
- Styled headers and sections
- Spinners for long operations
- Interactive prompts
- Progress indicators

Without Gum, the dotfiles fall back to pretty ANSI colors.

## Git Configuration & PII Handling

The dotfiles handle personal information (PII) like your git name and email carefully to keep it **out of the git repository** while still providing a seamless experience.

### How It Works

```
~/.gitconfig          ← Symlinked from dotfiles (shared settings, tracked)
   └─ os/_shared/home/.gitconfig  ← Shared across all OSes
~/.gitconfig.user     ← Generated during install (your PII, NOT tracked)
```

The main `.gitconfig` is stored in `os/_shared/home/` and symlinked to each OS folder since it doesn't change per operating system. It uses Git's `include` feature to load your personal settings:

```ini
[include]
  path = ~/.gitconfig.user  # Contains your name, email, github username
```

### During Installation

When you run the installer, you'll be prompted:
- **Your full name** (for git commits)
- **Your email address** (for git commits)
- **Your GitHub username** (optional, for URL shortcuts)

This creates `~/.gitconfig.user` with your PII, which is:
- **NOT tracked in git** (it's in `.gitignore`)
- **Not symlinked** (it's a generated local file)
- **Readable only by you** (permissions set to 600)

### Manual Setup

If you skip the setup during install, you can create it manually:

```bash
# Create the user config file
cat > ~/.gitconfig.user << 'EOF'
# Git user configuration
# This file is NOT tracked in dotfiles repo

[user]
  name = Your Name
  email = your.email@example.com

[github]
  user = yourusername
EOF

# Secure the file
chmod 600 ~/.gitconfig.user
```

### Updating Your Info

Simply edit `~/.gitconfig.user`:

```bash
# Edit with your preferred editor
cursor ~/.gitconfig.user
# or
nano ~/.gitconfig.user
# or
vim ~/.gitconfig.user
```

### Shared Git Settings

The `.gitconfig` in the dotfiles repo contains:
- Aliases (`git st`, `git up`, `git graph`, etc.)
- Colors and formatting
- Default behaviors (rebase on pull, etc.)
- URL shortcuts (`gh:username/repo`)
- Diff/merge tool configurations

These are the same across all your machines and are safely tracked in git.

## Troubleshooting

### Permission Denied

```bash
# Make scripts executable
chmod +x ~/.dotfiles/os/install.sh
chmod +x ~/.dotfiles/os/*/install.sh
chmod +x ~/.dotfiles/os/*/init.sh
chmod +x ~/.dotfiles/os/*/install/*.sh
chmod +x ~/.dotfiles/os/*/uninstall/*.sh
chmod +x ~/.dotfiles/os/*/init/*.sh
```

### OS Not Detected

Check what the installer sees:
```bash
echo "OSTYPE: $OSTYPE"
if [ -f /etc/arch-release ]; then echo "Arch detected"; fi
if [ -n "$CLOUD_SHELL" ]; then echo "Cloud Shell detected"; fi
```

### Windows: Git Bash vs WSL

```bash
# Check which Windows environment
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == mingw* ]]; then
    echo "Git Bash"
elif [ -f /proc/version ] && grep -q Microsoft /proc/version; then
    echo "WSL"
fi
```

### App Not Found

List available apps for your OS:
```bash
ls ~/.dotfiles/os/$(detect_os)/install/
```

## License

MIT - Feel free to use and modify for your own dotfiles!

## Contributing

To contribute new apps or improvements:

1. Create install/uninstall scripts for all supported OSes
2. Use the common library functions (`lib/common.sh`)
3. Follow the existing code patterns
4. Test on the target OS if possible
5. Update this README with any new features

---

**Note:** Remember to update `go.sh` with your actual GitHub username/repository URL before sharing the one-liner installer!
