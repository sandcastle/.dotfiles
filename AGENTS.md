# AGENTS.md

Guidelines for AI agents working on this dotfiles repository.

## Build / Lint / Test Commands

This repository uses shell scripts. The primary linting tool is **shellcheck**.

### Linting (Required)

```bash
# Lint a single script
shellcheck os/install.sh

# Lint all scripts
find . -name "*.sh" -type f ! -path "./.opencode/*" -exec shellcheck {} \;

# Quick syntax check for bash
bash -n os/install.sh
```

### Testing

```bash
# Test a specific install script (safe to run, backs up existing files)
bash os/omarchy/install.sh

# Test with --all flag (installs dotfiles + all apps)
bash os/omarchy/install.sh --all

# Test a specific init script
bash os/omarchy/init.sh

# Test app installation
apps install gh
```

### Full Validation

```bash
# Check all scripts are executable
find os -name "*.sh" -type f ! -executable

# Verify symlinks are valid
find os -type l -exec test ! -e {} \; -print
```

## Code Style Guidelines

### Bash Scripts

**Shebang (REQUIRED):**
```bash
#!/usr/bin/env bash
```
- NEVER use `#!/bin/bash` - not portable to macOS

**Strict Mode (REQUIRED):**
```bash
set -euo pipefail
```

**Formatting (from .editorconfig):**
- 2-space indentation
- UTF-8 encoding
- LF line endings
- Trim trailing whitespace
- Final newline required

**Variable Naming:**
- `ALL_CAPS` for constants/exports
- `lowercase` for local variables
- `snake_case` preferred
- Always quote variables: `"$variable"` not `$variable`

**Code Patterns:**
```bash
# Use [[ ]] for conditionals
if [[ -f "$file" ]] && [[ ! -L "$file" ]]; then
  # ...
fi

# Use $() not backticks
result=$(command)

# Use local in functions
my_func() {
  local var="$1"
  # ...
}
```

**Error Handling:**
- All scripts must use `set -euo pipefail`
- Use `|| true` when you want to ignore errors
- Error messages to stderr: `>&2`

**Function Documentation:**
```bash
# Brief description
# Arguments:
#   $1 - description of arg 1
# Returns:
#   0 on success, 1 on failure
my_function() {
  # ...
}
```

### File Organization

**Script Structure:**
```bash
#!/usr/bin/env bash
#
# Brief description
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

# ============================================================================
# Functions
# ============================================================================

# ============================================================================
# Main
# ============================================================================
```

### Symlinks

When creating symlinks in the repo:
- Relative paths preferred: `../../_shared/home/.gitconfig`
- NOT: `../../../_shared/home/.gitconfig`

## Skills Reference

This repository has opencode skills defined in `/.opencode/skills/`:

### When to Use Each Skill

| Skill | Use When | Triggers |
|-------|----------|----------|
| **bash-scripting** | Writing/editing ANY shell script | `.sh` files, shebang, script logic |
| **dotfiles-app-manager** | Creating/modifying app install scripts | `app-*.sh`, `apps install`, `apps uninstall` |
| **dotfiles-os-manager** | OS configuration, init scripts, adding new OS | `init.sh`, `install.sh`, OS setup |

### Shared Utilities

**`os/_shared/_install.sh`** - Reusable install/uninstall functions:
- `install_os_apps()` - Interactive or batch app installation with multi-select
- `uninstall_os_apps()` - Batch app uninstallation  
- `remove_dotfile_symlinks()` - Clean up dotfile links

All OS install scripts source this file to avoid code duplication.

### Critical Rules

- **Always install bash completions** for CLI tools
- **Never use `#!/bin/bash`** - always `#!/usr/bin/env bash`
- **Always run shellcheck** before committing
- **Use `set -euo pipefail`** in every script
- **Quote all variables**: `"$var"` not `$var`

## Pre-commit Checklist

- [ ] `shellcheck` passes with no warnings
- [ ] Shebang is `#!/usr/bin/env bash`
- [ ] `set -euo pipefail` present
- [ ] Variables properly quoted
- [ ] Bash completions installed (for CLI apps)
- [ ] Script is executable (`chmod +x`)
- [ ] Tested the script (if possible)
