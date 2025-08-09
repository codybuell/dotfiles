################################################################################
##                                                                            ##
##  Node Version Manager (NVM)                                                ##
##                                                                            ##
##  NVM integration with automatic version switching based on .nvmrc files.   ##
##  Provides seamless Node.js version management across projects.             ##
##                                                                            ##
##  Dependencies: nvm installation                                            ##
##                                                                            ##
################################################################################

# Skip if NVM is not installed
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  return 0
fi

####################
#  Initialization  #
####################

# Load NVM
source "$NVM_DIR/nvm.sh"

# Load NVM bash completion (optional)
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

#################################
#  Automatic Version Switching  #
#################################

# Auto-switch Node versions based on .nvmrc files
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [[ -n "$nvmrc_path" ]]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [[ "$nvmrc_node_version" = "N/A" ]]; then
      echo "Installing Node version specified in .nvmrc..."
      nvm install
    elif [[ "$nvmrc_node_version" != "$node_version" ]]; then
      echo "Switching to Node $(cat "${nvmrc_path}")..."
      nvm use
    fi
  elif [[ "$node_version" != "$(nvm version default)" ]]; then
    echo "Reverting to default Node version..."
    nvm use default
  fi
}

# Register the function to run on directory changes
autoload -Uz add-zsh-hook
add-zsh-hook chpwd load-nvmrc

# Run on initial load
load-nvmrc

#############
#  Aliases  #
#############

# Convenient aliases for common NVM operations
alias nvmi='nvm install'
alias nvmu='nvm use'
alias nvml='nvm list'
alias nvmr='nvm run'
alias nvmw='nvm which'
