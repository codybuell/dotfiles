################################################################################
##                                                                            ##
##  Auto Suggestions                                                          ##
##                                                                            ##
##  Fish-like autosuggestions based on command history.                       ##
##                                                                            ##
##  Dependencies: zsh-autosuggestions (git submodule)                         ##
##                                                                            ##
################################################################################

# Only load once
if [[ -z "${__BUELL[AUTOSUGGESTIONS_LOADED]:-}" ]]; then
  # Adjust this path to match where your submodule is located
  local autosuggestions_script="$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

  if [[ -r "$autosuggestions_script" ]]; then
    source "$autosuggestions_script"

    # Configuration
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=59'  # Dim gray suggestions

    # Key bindings (note: ^o is already used in 04-bindings.zsh for forward-word)
    bindkey '^y' autosuggest-accept          # Ctrl+Y to accept suggestion

    __BUELL[AUTOSUGGESTIONS_LOADED]=1
  else
    echo "Warning: zsh-autosuggestions not found at $autosuggestions_script" >&2
  fi
fi
