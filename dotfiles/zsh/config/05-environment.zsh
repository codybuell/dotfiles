################################################################################
##                                                                            ##
##  Environment                                                               ##
##                                                                            ##
################################################################################

##################
#  Core Tools    #
##################

# Editor (prioritize nvim, fallback to custom vim, then system vim)
if (( ${+commands[nvim]} )); then
  export EDITOR="nvim"
elif (( ${+commands[vim]} )); then
  export EDITOR="vim"
else
  export EDITOR="vi"
fi

# Default pager
export PAGER="less"

##########
#  Less  #
##########

#  i = Case-insensitive searches, unless uppercase characters in search string
#  F = Exit immediately if output fits on one screen
#  M = Verbose prompt
#  R = ANSI color support
#  S = Chop long lines (rather than wrap them onto next line)
#  X = Suppress alternate screen
export LESS="iFMRSX"

# Filename (if known)
# Line number if known
# Falling back to percent if known
# Falling back to byte offset
# Falling back to dash
export LESSPROMPT='?f%f .?ltLine %lt:?pt%pt\%:?btByte %bt:-...'

# Colored man pages
export LESS_TERMCAP_mb=$'\E[01;31m'         # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;208m'   # begin bold
export LESS_TERMCAP_me=$'\E[0m'             # end mode
export LESS_TERMCAP_se=$'\E[0m'             # end standout-mode
export LESS_TERMCAP_ue=$'\E[0m'             # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;111m'   # begin underline

###########
#  Vault  #
###########

#export VAULT_CAPATH={{ VaultCAPath }}
export VAULT_TOKEN={{ VaultToken }}
export VAULT_ADDR={{ VaultAddress }}
export VAULT_TLS_SERVER_NAME={{ VaultServer }}

############
#  Docker  #
############

# Enable Docker build kit
export DOCKER_BUILDKIT=1

#############
#  Ripgrep  #
#############

export RIPGREP_CONFIG_PATH="$HOME/.rgrc"

##############
#  Homebrew  #
##############

export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_GITHUB_API_TOKEN='{{ GitHubHomebrewAPIToken }}'

##############
#  API Keys  #
##############

export OPENAI_API_KEY='{{ OpenAIAPIKey }}'
export ANTHROPIC_API_KEY='{{ AnthropicAPIKey }}'

##################
#  Miscellaneous #
##################

export CLICOLOR=true           # Enable color output for many cli tools
export GPG_TTY="$(tty)"        # Set tty for GPG, needed for password prompts
export FTP_PASSIVE=1           # Use passive mode by default with ftp
export PROMPT_EOL_MARK=""      # What to show when a line ends w/o newline
