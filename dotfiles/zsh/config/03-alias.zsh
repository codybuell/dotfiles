################################################################################
##                                                                            ##
##  Alias                                                                     ##
##                                                                            ##
################################################################################

###############
#  Overrides  #
###############

alias history="fc -lt '%Y-%m-%d %H:%M:%S' 1"

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
