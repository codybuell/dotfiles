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

################
#  Navigation  #
################

alias dt='cd ~/Desktop'
alias dl='cd ~/Downloads'

##################
#  Git Workflow  #
##################

###################
#  MacOS Aliases  #
###################

if [[ "$OSTYPE" == "darwin"* ]]; then
	alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
	alias showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
	alias hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
	alias finder='open .'
fi
