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

# use gsed for consistent development
alias sed=gsed

# change term when ssh'ing
alias ssh="TERM=xterm-256color ssh"

# ssh without trying to use any keys
alias sshn="TERM=xterm-256color ssh -o PreferredAuthentications=keyboard-interactive,password -o PubkeyAuthentication=no"

#######################
#  Vim Muscle Memory  #
#######################

alias :e="vim"
alias :q="exit"
alias :qa="exit"
alias :wq="exit"
alias :sp='test -n "$TMUX" && tmux split-window'
alias :vs='test -n "$TMUX" && tmux split-window -h'

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

##########
#  TMUX  #
##########

# Only if we are running in a tmux session
if [ ! -z $TMUX ]; then
  # fix ssh-agent issues
  if [ `uname` == Linux ]; then
    alias ssh="TERM=xterm-256color ssh"
    alias scp="TERM=xterm-256color scp"
  else
    alias ssh="TERM=xterm-256color reattach-to-user-namespace ssh"
    alias scp="TERM=xterm-256color reattach-to-user-namespace scp"
    alias terminal-notifier="reattach-to-user-namespace terminal-notifier"
  fi
fi

###################
#  MacOS Aliases  #
###################

if [[ "$OSTYPE" == "darwin"* ]]; then
	alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
	alias showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
	alias hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
	alias finder='open .'
fi

####################
#  Global Aliases  #
####################

# work at any position within the command line
[ `echo $0` == '-zsh' ] && {
  # mnemonic: "[G]rep"
  alias -g G="|grep"
  # mnemonic: "[H]ead"
  alias -g H="|head"
  # mnemonic: "[J]SON"
  alias -g J="|jq"
  # mnemonic: "[L]ess"
  alias -g L="|less"
}

###################
#  Miscellaneous  #
###################

alias serve='python -m SimpleHTTPServer 8080'
alias sc="vi ~/.ssh/config"
alias k=kubectl
alias d=docker
alias n=note
alias dc='docker compose'
