# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# ---------------------------- OMARCHY ----------------------------

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# ---------------------------- INIT ----------------------------

# Load the shell dotfiles, and then some:
# Order: base file -> .os variant (OS-specific) -> .local variant (machine-specific)
for file in ~/.{exports,aliases,functions}; do
  # Load the base file (symlinked from _shared)
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
  # Load OS-specific variant (e.g., .aliases.os) if available
  [ -r "$file.os" ] && [ -f "$file.os" ] && source "$file.os"
  # Load local variant (non-committed) if available
  [ -r "$file.local" ] && [ -f "$file.local" ] && source "$file.local"
done
unset file

# ---------------------------- SHELL ----------------------------

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Automatically cd into a directory if you type just the path
shopt -s autocd

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# --------------------------- ACTIVATION ----------------------------

# Interactive-only settings
if [[ "$TERM" != "dumb" ]]; then


  if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
      . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
    fi
  fi

  # Modern prompt
  if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
  fi

  # Smarter cd command
  if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
  fi
fi

# Mise environments
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi
