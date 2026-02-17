---
name: bash-scripting
description: >
  REQUIRED when writing, editing, or reviewing bash/shell scripts in the dotfiles repository.
  Use for any shell script modifications, new script creation, or best practice enforcement.
  Triggers: bash scripts, shell scripts, .sh files, shebang, script development.
---

# Bash Scripting Skill

Best practices and conventions for writing portable, maintainable bash scripts.

## When This Skill MUST Be Used

**ALWAYS invoke this skill when the user's request involves ANY of these:**

- Creating new `.sh` scripts
- Editing existing bash/shell scripts
- Writing install scripts, init scripts, or utility functions
- Setting up shebang lines
- Working with shell variables, conditionals, or loops
- Scripting automation or tooling

## Critical: Shebang Convention

**ALWAYS use `#!/usr/bin/env bash` instead of `#!/bin/bash`**

### Why?

`#!/usr/bin/env bash` is preferred because:
- **Portability**: Works on systems where bash isn't in `/bin/` (macOS, *BSD, some Linux distros)
- **Flexibility**: Respects user's PATH and finds bash wherever it's installed
- **Compatibility**: Better cross-platform support (WSL, Git Bash, various Unix systems)

### Examples

**✅ CORRECT:**
```bash
#!/usr/bin/env bash
```

**❌ INCORRECT:**
```bash
#!/bin/bash
```

### Enforcement

When editing any `.sh` file:
1. Check the first line (shebang)
2. If it says `#!/bin/bash`, **MUST change to `#!/usr/bin/env bash`**
3. If it's missing, **MUST add `#!/usr/bin/env bash` as the first line**

## Script Structure Template

Always structure scripts in this order:

```bash
#!/usr/bin/env bash
#
# Brief description of what this script does
#
# Usage: ./script-name.sh [arguments]
# Example: ./script-name.sh --help
#

set -euo pipefail

# ============================================================================
# Configuration / Variables
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

# ============================================================================
# Functions
# ============================================================================

main() {
    # Main entry point
    echo "Starting $SCRIPT_NAME..."
}

# ============================================================================
# Main
# ============================================================================

main "$@"
```

## Best Practices

### 1. Use Strict Mode

```bash
set -euo pipefail
```

- `set -e`: Exit on error
- `set -u`: Exit on undefined variable
- `set -o pipefail`: Exit if any command in pipeline fails

### 2. Always Quote Variables

```bash
# ✅ CORRECT:
file="$HOME/.bashrc"
cp "$file" "$backup_dir/"

# ❌ INCORRECT:
cp $file $backup_dir/  # Fails if paths contain spaces
```

### 3. Use [[ ]] for Conditionals

```bash
# ✅ CORRECT:
if [[ -f "$file" ]]; then
    echo "File exists"
fi

# ❌ INCORRECT:
if [ -f $file ]; then
    echo "File exists"
fi
```

### 4. Prefer $() over Backticks

```bash
# ✅ CORRECT:
files=$(ls -la)

# ❌ INCORRECT:
files=`ls -la`
```

### 5. Use Local Variables in Functions

```bash
my_function() {
    local var1="$1"
    local var2="$2"
    
    # Function logic here
}
```

### 6. Handle Missing Arguments

```bash
my_function() {
    local required_arg="${1:-}"
    
    if [[ -z "$required_arg" ]]; then
        echo "Error: Required argument missing" >&2
        return 1
    fi
    
    # Continue with logic
}
```

### 7. Use Meaningful Variable Names

```bash
# ✅ CORRECT:
readonly backup_dir="$HOME/.backup"
readonly timestamp=$(date +%Y%m%d_%H%M%S)

# ❌ INCORRECT:
d="$HOME/.backup"
t=$(date +%Y%m%d_%H%M%S)
```

### 8. Comment Complex Logic

```bash
# Check if the file is a symlink pointing to our dotfiles
# and if the source file exists in the _shared directory
if [[ -L "$target" ]] && [[ "$(readlink "$target")" == *"_shared"* ]]; then
    rm "$target"
fi
```

## Common Patterns

### Pattern 1: Detect OS

```bash
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    else
        echo "unknown"
    fi
}
```

### Pattern 2: Check Command Exists

```bash
if command -v gum &> /dev/null; then
    echo "Gum is installed"
else
    echo "Gum is not installed"
fi
```

### Pattern 3: Create Backup

```bash
backup_file() {
    local file="$1"
    local backup_dir="$2"
    local filename=$(basename "$file")
    
    if [[ -f "$file" ]] && [[ ! -L "$file" ]]; then
        mkdir -p "$backup_dir"
        cp "$file" "$backup_dir/${filename}.bak.$(date +%s)"
    fi
}
```

### Pattern 4: Source Common Library

```bash
#!/usr/bin/env bash

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$DOTFILES_ROOT/lib/common.sh"
```

## Error Handling

### Exit Codes

- `0`: Success
- `1`: General error
- Use custom codes (2-125) for specific errors

```bash
my_function() {
    if [[ ! -f "$1" ]]; then
        echo "Error: File not found: $1" >&2
        return 1
    fi
    
    return 0
}
```

### Trap Errors

```bash
cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/tempfile
}

trap cleanup EXIT
```

## Portability Tips

### Avoid bash-isms for POSIX Compliance

If you need POSIX compliance, use `/bin/sh` and avoid:
- Arrays (`myarray=(1 2 3)`)
- `[[ ]]` (use `[ ]` instead)
- `$()` (use backticks or avoid)

But for dotfiles, we assume bash is available, so bash features are fine.

### Handle Different macOS/BSD Tools

macOS uses BSD versions of tools which have different flags:

```bash
# Portable way to get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# macOS date vs GNU date
if date --version &> /dev/null; then
    # GNU date
    date +%s
else
    # BSD date (macOS)
    date +%s
fi
```

## Code Review Checklist

Before submitting bash scripts:

- [ ] Shebang is `#!/usr/bin/env bash`
- [ ] `set -euo pipefail` is present
- [ ] Variables are quoted: `"$var"` not `$var`
- [ ] `[[ ]]` used for conditionals
- [ ] `$()` used for command substitution
- [ ] Functions use `local` for variables
- [ ] Arguments are validated
- [ ] Error messages go to stderr (`>&2`)
- [ ] Script is executable (`chmod +x`)

## Common Mistakes to Avoid

### 1. Forgetting to Quote

```bash
# ❌ BAD:
cp $source $dest

# ✅ GOOD:
cp "$source" "$dest"
```

### 2. Wrong Shebang

```bash
# ❌ BAD:
#!/bin/bash

# ✅ GOOD:
#!/usr/bin/env bash
```

### 3. Not Checking if File Exists

```bash
# ❌ BAD:
rm "$file"

# ✅ GOOD:
[[ -f "$file" ]] && rm "$file"
```

### 4. Using External Variables Without Defaults

```bash
# ❌ BAD:
echo "$HOME"

# ✅ GOOD:
echo "${HOME:-/tmp}"
```

### 5. Not Handling Pipe Failures

```bash
# ❌ BAD:
cat file.txt | grep pattern | head -n 1

# ✅ GOOD (with set -o pipefail):
set -o pipefail
cat file.txt | grep pattern | head -n 1
```

## Examples

### Good Script Example

```bash
#!/usr/bin/env bash
#
# Backup dotfiles before making changes
#

set -euo pipefail

readonly BACKUP_DIR="${HOME}/.backup/$(date +%Y%m%d_%H%M%S)"

backup_file() {
    local source_file="$1"
    local filename=$(basename "$source_file")
    
    if [[ -f "$source_file" ]] && [[ ! -L "$source_file" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp "$source_file" "$BACKUP_DIR/$filename"
        echo "Backed up: $filename"
    fi
}

main() {
    for file in ~/.{bashrc,bash_profile}; do
        if [[ -f "$file" ]]; then
            backup_file "$file"
        fi
    done
    
    echo "Backup complete: $BACKUP_DIR"
}

main "$@"
```

## Tools for Shell Scripting

- **shellcheck**: Linting tool for bash scripts (`brew install shellcheck`)
- **shfmt**: Shell script formatter
- **explainshell.com**: Understand complex commands

Run `shellcheck` on your scripts before committing!
