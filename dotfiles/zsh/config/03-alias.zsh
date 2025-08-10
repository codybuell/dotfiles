################################################################################
##                                                                            ##
##  Alias                                                                     ##
##                                                                            ##
##  Common command shortcuts and platform-specific aliases for navigation     ##
##  and system utilities. Includes macOS-specific finder and DNS commands.    ##
##                                                                            ##
##  Dependencies: none                                                        ##
##                                                                            ##
################################################################################

###############
#  Overrides  #
###############

# history with timestamps
alias history="fc -lt '%Y-%m-%d %H:%M:%S' 1"

# vi -> vim -> nvim
if [[ `which nvim | wc -l` -gt 0 ]]; then
  alias vi="nvim"
  alias vim="nvim"
  alias vix="nvim -i NONE --noplugin --cmd 'set noswapfile' --cmd 'set nobackup' --cmd 'set nowritebackup'"
  alias vimin="nvim --clean -u ~/.config/nvim/minimal.lua"
  alias vimdiff="nvim -d"
elif [[ `which vim | wc -l` -gt 0 ]]; then
  alias vi="vim"
  alias vix="vim -i NONE --noplugin --cmd 'set noswapfile' --cmd 'set nobackup' --cmd 'set nowritebackup'"
fi

###########
#  Shell  #
###########

# clear the completions cache (if you add a new completion or data is missing)
alias reload_completions="autoload -U compinit && compinit"

################
#  Navigation  #
################

alias dt='cd ~/Desktop'
alias dl='cd ~/Downloads'

##################
#  Git Workflow  #
##################

alias gd="git diff"
alias gi="git init && touch .gitignore && touch README.md && git add .gitignore README.md && git commit -m 'Initial commit'"
alias gl="git lg"
alias gp="git push"
alias gs="git status"
alias gc="git commit"
alias gca="git commit -a"
alias gbv="git branch -v"
alias gba="git branch -a"
alias gco="git checkout"
alias log="git log --pretty=oneline"
alias gsa="clear && git status && git branch -v"
alias gbc="git branch --merged | grep -Ev '^ *(^\*|main|master|support-*|release-[0-9]+)' | xargs git branch -d"

###################
#  MacOS Aliases  #
###################

if [[ "$OSTYPE" == "darwin"* ]]; then
	alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
	alias showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
	alias hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
	alias finder='open .'
fi
