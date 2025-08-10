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
    __BUELL[SYNTAX_HIGHLIGHTING_LOADED]=1
  else
    echo "Warning: zsh-syntax-highlighting not found at $syntax_highlighting_script" >&2
  fi
fi
