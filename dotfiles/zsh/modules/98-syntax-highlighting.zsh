################################################################################
##                                                                            ##
##  Syntax Highlighting                                                       ##
##                                                                            ##
##  Provides real-time syntax highlighting for command line input.            ##
##  Must be loaded last to work properly with other zsh configurations.       ##
##                                                                            ##
##  Dependencies: zsh-syntax-highlighting (git submodule)                     ##
##                                                                            ##
################################################################################

# Only load once
if [[ -z "${__BUELL[SYNTAX_HIGHLIGHTING_LOADED]:-}" ]]; then
  # Adjust this path to match where your submodule is located
  local syntax_highlighting_script="$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  if [[ -r "$syntax_highlighting_script" ]]; then
    source "$syntax_highlighting_script"

    # Remove all path highlighting
    ZSH_HIGHLIGHT_STYLES[path]='none'
    ZSH_HIGHLIGHT_STYLES[path_prefix]='none'
    ZSH_HIGHLIGHT_STYLES[path_approx]='none'

    # Or set custom colors without formatting
    ZSH_HIGHLIGHT_STYLES[path]='fg=blue'                    # Blue paths, no underline
    ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=cyan'             # Cyan partial paths
    ZSH_HIGHLIGHT_STYLES[path_approx]='fg=yellow'           # Yellow approximate paths

    # Other common customizations
    ZSH_HIGHLIGHT_STYLES[command]='fg=green'                # Commands in green
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'           # Built-ins in bold green
    ZSH_HIGHLIGHT_STYLES[function]='fg=blue'                # Functions in blue
    ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta'                # Aliases in magenta
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'       # Errors in bold red
    ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=yellow'         # Keywords in yellow
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=cyan'  # Single quotes in cyan
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=cyan'  # Double quotes in cyan
    ZSH_HIGHLIGHT_STYLES[comment]='fg=59'                   # Comments in dim gray

    __BUELL[SYNTAX_HIGHLIGHTING_LOADED]=1
  else
    echo "Warning: zsh-syntax-highlighting not found at $syntax_highlighting_script" >&2
  fi
fi
