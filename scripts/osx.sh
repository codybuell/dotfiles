#!/bin/bash
#
# OSX
#
# Set some sensible defaults so you don't have to muck with them later in
# system preferences and what not. You'll need to restart a number of processes
# afterwards (Finder, Dock, SystemUIServer, etc). May just be easier to restart
# manually to avoid accidentally borking running applications so that's what
# we're going to do here.
#
# Author(s): Cody Buell
#
# Revisions: 2016.07.16 Initial framework.
#
# Tools: - pmset         (power management utility)
#        - defaults      (configuring ~/Library/Preferences/ list files)
#                        * note that -g is shorthand for NSGlobalDomain
#        - systemsetup   (general system configurations)
#        - chflags       (changing file / folder meta data)
#        - tmutil        (time machine utility)
#        - nvram         (firmware nvram config utility)
#        - launchctl     (the osx service manager)

################################################################################
################################################################################
##                                                                            ##
##  Configuration                                                             ##
##                                                                            ##
##  Change the settings contained in this section to your preference.         ##
##                                                                            ##
################################################################################
################################################################################

# time machine
DisableTimeMachine='true'                     # turn off time machine?
DisableDiskPrompt='true'                      # disable use disk tm prompt?

# mail
CopyNameAndAddress='false'                    # copy name with email addr?
MailSendReplyAnimations='false'               # animate sends and replies?

# text edit
TextEditPlainTextDefault='true'               # use plain text by default?
ShowRuler='false'                             # show the text edit ruler?

# iphoto
AutoOpeniPhoto='false'                        # open iphoto automatically?

# ical
DefaultMeetingDuration='30'                   # default cal item minutes

# terminal
FocusFollowsMouse='true'                      # focus follows mouse?

# screenshots
ScrnShotsFolder='~/Google\ Drive/Screenshots' # where to save screenshots
ScreenshotDropshadows='false'                 # dropshadows on screenshots?
ScreenshotFormat='png'                        # bmp, gif, jpg, pdf, tiff

# finder
ShowLibraryFolder='true'                      # show ~/Library folder?
ShowFinderStatusBar='true'                    # show status bar in finder?
ShowFinderPathBar='true'                      # show path bar in finder?
FileExtWarning='false'                        # show warning on ext change?
ExpandSaveMenus='true'                        # default expand save menus?
ExpandPrintMenus='true'                       # default expand print menus?
ShowFileExtensions='true'                     # show all file extensions?
DSStoreOnNetwork='false'                      # .DS_Store file on rem vols?
SideBarIconSize='small'                       # small, medium, large

# dock
AppRunningLights='false'                      # dock app is running lights?
AutoHideDock='true'                           # auto hide the dock?
RemoveAllDockIcons='true'                     # clean out the dock?
HiddenAppsTranslucentIcons='true'             # translucent hidden app icons?
DockLaunchAnimations='false'                  # dock launch bounce animations?
DockHideDelay='none'                          # none, default, long
SingleAppMode='false'                         # enable single app mode?

# debug menus
SafariDebugMenu='true'                        # turn on safari debug menu?
AddressBookDebugMenu='true'                   # turn on addressbook debug?
iCalDebugMenu='true'                          # turn on ical debug menu?
AppStoreDebugMenu='true'                      # turn on app store debug?
DiskUtilityDebugMenu='true'                   # turn on disk utility debug?

# system
RunSMS='false'                                # keep the sms sensor on?
CrashReportsAsNotifications='true'            # crash reports to not. cent.?
LockSystemImmediately='true'                  # require passwd on ss start?
DefaultSaveToiCloud='false'                   # default icloud as save loc?
DisableDashboard='true'                       # disable the dashboard?
StandbyDelay='Never'                          # sleep time (minutes) or Never
SystemTimezone='America/New_York'             # `systemsetup -listtimezones`
UseNTP='true'                                 # use network time server
DisplaySleepTime='15'                         # display sleep delay in minutes
HDDSleepTime='Never'                          # hd sleep time (minutes) or Never
EnableSSHServer='true'                        # turn on ssh server?
WakeOnLan='false'                             # wake  with network admin pkt?
AutoRebootOnFreeze='true'                     # auto restart frozen system?
AllowRemoteScripting='false'                  # allow remote apple scripting?
AutoQuitPrinterWhenDone='true'                # auto close printer app when done

# ux / ui
Appearance='graphite'                         # blue or graphite
AutoHideMenuBar='false'                       # auto hide the menu bar?
ShowScrollbars='Automatic'                    # WhenScrolling, Automatic, Always
MissionControlAnimation='fast'                # fast, off, or default
OpenCloseAnimations='false'                   # open and close animations?
QLOpenCloseAnimations='false'                 # quick look animations?
InfoOpenCloseAnimations='false'               # animate info windows?
FullScreenAnimations='false'                  # animate fullscreen switch?
AccellerateCocoa='true'                       # speed up cocoa resizings?
UseNaturalScrolling='false'                   # use natural scrolling?
AutoArrangeSpaces='false'                     # re-arrange spaces by use?
EnableSpacesJumpBack='true'                   # enable go to last space?
StartupNoise='false'                          # play osx boot noise?
ReduceTransparency='false'                    # turn off transparent menu bar?
TopRightCorner='12'                           # set hot corner, see below
BottomRightCorner='4'                         # set hot corner, see below
TopLeftCorner='5'                             # set hot corner, see below
BottomLeftCorner='6'                          # set hot corner, see below

# HOT CORNER OPTIONS
#
#  1  ->  disabled
#  2  ->  mission control
#  3  ->  application windows
#  4  ->  desktop
#  5  ->  start screensaver
#  6  ->  disable screensaver
#  7  ->  dashboard
#  10 ->  put display to sleep
#  11 ->  launchpad
#  12 ->  notification center

################################################################################
################################################################################
##                                                                            ##
##  Run It                                                                    ##
##                                                                            ##
##  Be careful about changing things in this section unless you know what     ##
##  you are doing...                                                          ##
##                                                                            ##
################################################################################
################################################################################

# get and keep sudo privs for duration of the script
sudo -v; while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

################
# TIME MACHINE #
################

# turn off time machine
[[ $DisableTimeMachine == 'true' ]] && {
  sudo tmutil disable
  sudo tmutil disablelocal
}

# toggle time machine prompt to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool $DisableDiskPrompt

########
# MAIL #
########

# copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in mail.app
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool $CopyNameAndAddress

# animate mail sends and replies
MailAnimations=`[[ $MailSendReplyAnimations == 'true' ]] && echo false || echo true`
defaults write com.apple.mail DisableReplyAnimations -bool $MailAnimations
defaults write com.apple.mail DisableSendAnimations -bool $MailAnimations

#############
# TEXT EDIT #
#############

# use rich or plain text by default in textedit
[[ $TextEditPlainTextDefault == 'true' ]] && {
  defaults write com.apple.TextEdit RichText -int 0
} || {
  defaults delete com.apple.TextEdit RichText > /dev/null 2>&1
}

# text edit ruler
Ruler=`[[ $ShowRuler == true ]] && echo 1 || echo 0`
defaults write com.apple.TextEdit ShowRuler $Ruler

##########
# IPHOTO #
##########

# automatically open iphoto when camera is plugged in
[[ $AutoOpeniPhoto == true ]] && {
  defaults -currentHost delete com.apple.ImageCapture disableHotPlug > /dev/null 2>&1
} || {
  defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
}

########
# ICAL #
########

# default ical meeting duration in mintues
defaults write com.apple.iCal "Default duration in minutes for new event" -int $DefaultMeetingDuration

############
# TERMINAL #
############

# focus follows the mouse in terminal, no need to click
defaults write com.apple.terminal FocusFollowsMouse -string "$FocusFollowsMouse"

###############
# SCREENSHOTS #
###############

# set where to save screenshots
defaults write com.apple.screencapture location "$ScrnShotsFolder"

# disable dropshadow in screenshots
DisableDrops=`[[ $ScreenshotDropshadows == 'true' ]] && echo false || echo true`
defaults write com.apple.screencapture disable-shadow -bool $DisableDrops

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "$ScreenshotFormat"

##########
# FINDER #
##########

# show or hide ~/Library folder
LibraryFlag=`[[ $ShowLibraryFolder == 'true' ]] && echo nohidden || echo hidden`
chflags $LibraryFlag ~/Library

# show status bar in finder windows
defaults write com.apple.finder ShowStatusBar -bool $ShowFinderStatusBar

# show path bar in finder windows
defaults write com.apple.finder ShowPathbar -bool $ShowFinderPathBar

# toggle warning when changing a files extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool $FileExtWarning

# toggle expanded save menus by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool $ExpandSaveMenus
defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool $ExpandSaveMenus

# toggle expanded print menus by default
defaults write -g PMPrintingExpandedStateForPrint -bool $ExpandPrintMenus
defaults write -g PMPrintingExpandedStateForPrint2 -bool $ExpandPrintMenus

# show all filename extensions in finder
defaults write -g AppleShowAllExtensions -bool $ShowFileExtensions

# avoid creating .DS_Store files on network volumes
DSStore=`[[ $DSStoreOnNetwork == 'true' ]] && echo false || echo true`
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool $DSStore

# set sidebar icon sizes
case $SideBarIconSize in
  'small' )
    defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1
    ;;
  'medium' )
    defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2
    ;;
  'large' )
    defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 3
    ;;
esac

########
# DOCK #
########

# toggle indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool $AppRunningLights

# toggle automatically hiding and showing the dock
defaults write com.apple.dock autohide -bool $AutoHideDock

# clean out all dock icons
[[ $RemoveAllDockIcons == 'true' ]] && {
  defaults delete com.apple.dock persistent-apps > /dev/null 2>&1
  defaults delete com.apple.dock persistent-others > /dev/null 2>&1
}

# make dock icons of hidden items translucent
defaults write com.apple.dock showhidden -bool $HiddenAppsTranslucentIcons

# dock launch animations
defaults write com.apple.dock launchanim -bool $DockLaunchAnimations

# dock closing delay
case $DockHideDelay in
  'none' )
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0
    ;;
  'default' )
    defaults delete com.apple.dock autohide-delay > /dev/null 2>&1
    defaults delete com.apple.dock autohide-time-modifier -float 0
    ;;
  'long' )
    defaults write com.apple.dock autohide-delay -float 0.15
    defaults write com.apple.dock autohide-time-modifier -float 0.15
    ;;
esac

# enable single app focus mode (click on icon in dock to focus)
defaults write com.apple.dock single-app -bool $SingleAppMode

###############
# DEBUG MENUS #
###############

# enable debug menu in safari
defaults write com.apple.Safari IncludeInternalDebugMenu -bool $SafariDebugMenu

# enable the debug menu in address book
defaults write com.apple.addressbook ABShowDebugMenu -bool $AddressBookDebugMenu

# enable the debug menu in ical
defaults write com.apple.iCal IncludeDebugMenu -bool $iCalDebugMenu

# enable the debug menu in appstore
defaults write com.apple.appstore ShowDebugMenu -bool $AppStoreDebugMenu

# disk utility debug menu
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool $DiskUtilityDebugMenu

##########
# SYSTEM #
##########

# configure the sudden motion sensor (stops disk when detecting a fall, or jostle)
SMSFlag=`[[ $RunSMS == 'true' ]] && echo 1 || echo 0`
sudo pmset -a sms $SMSFlag

# show crash reports in the notification center
NCCrash=`[[ $CrashReportsAsNotifications == 'true' ]] && echo 1 || echo 0`
defaults write com.apple.CrashReporter UseUNC $NCCrash

# require password immediately after sleep or screen saver begins
[[ $LockSystemImmediately == 'true' ]] && {
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0
}

# use icloud as the default save location
defaults write -g NSDocumentSaveNewDocumentsToCloud -bool $DefaultSaveToiCloud

# disable the dashboard
defaults write com.apple.dashboard mcx-disabled -boolean $DisableDashboard

# set seconds till system should go into standby
# sudo pmset -a standbydelay $StandbyDelay                   # in seconds
sudo systemsetup -setcomputersleep $StandbyDelay > /dev/null # in minutes, never or off

# set the systems timezone
sudo systemsetup -settimezone $SystemTimezone > /dev/null

# use ntp for setting time
NTPStatus=`[[ $UseNTP == 'true' ]] && echo On || echo Off`
sudo systemsetup -setusingnetworktime $NTPStatus > /dev/null

# set the display sleep time
sudo systemsetup -setdisplaysleep $DisplaySleepTime > /dev/null

# set hard drive sleep time
sudo systemsetup -setharddisksleep $HDDSleepTime > /dev/null

# configure ssh server
SSHStatus=`[[ $EnableSSHServer == 'true' ]] && echo On || echo Off`
sudo systemsetup -setremotelogin $SSHStatus > /dev/null

# wake on lan
WOLStatus=`[[ $WakeOnLan == 'true' ]] && echo On || echo Off`
sudo systemsetup -setwakeonnetworkaccess $WOLStatus > /dev/null

# auto restart after system freeze
AutoRestartStatus=`[[ $AutoRebootOnFreeze == 'true' ]] && echo On || echo Off`
sudo systemsetup -setrestartfreeze $AutoRestartStatus

# allow remote scripting
ScriptingStatus=`[[ $AllowRemoteScripting == 'true' ]] && echo On || echo Off`
sudo systemsetup -setremoteappleevents $ScriptingStatus > /dev/null

# auto close printer application when done
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool $AutoQuitPrinterWhenDone

###########
# UX / UI #
###########

# set system appearance
case $Appearance in
  'blue' )
    defaults write -g AppleAquaColorVariant -int 1
    ;;
  'graphite' )
    defaults write -g AppleAquaColorVariant -int 6
    ;;
esac

# menu bar auto hide config
MenuHide=`[[ $AutoHideMenuBar == 'true' ]] && echo 1 || echo 0`
defaults write -g _HIHideMenuBar $MenuHide

# configure scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "$ShowScrollbars"

# speed up mission control animations
case $MissionControlAnimation in
  'fast' )
    defaults write com.apple.dock expose-animation-duration -float 0.1
    ;;
  'off' )
    defaults write com.apple.dock expose-animation-duration -int 0
    ;;
  'default' )
    defaults delete com.apple.dock expose-animation-duration > /dev/null 2>&1
    ;;
esac

# animate window opening and closing
defaults write -g NSAutomaticWindowAnimationsEnabled -bool $OpenCloseAnimations

# quick look animated opening and closing
[[ $QLOpenCloseAnimations == 'true' ]] && {
  defaults delete -g QLPanelAnimationDuration > /dev/null 2>&1
} || {
  defaults write -g QLPanelAnimationDuration -float 0
}

# info window open close animation
defaults write com.apple.finder DisableAllAnimations -bool $InfoOpenCloseAnimations

# animate fullscreen transitions
[[ $FullScreenAnimations == 'true' ]] && {
  defaults delete -g NSWindowResizeTime > /dev/null 2>&1
} || {
  defaults write -g NSWindowResizeTime -float 0.001
}

# speed up cocoa application window resizing
[[ $AccellerateCocoa == 'true' ]] && {
  defaults write -g NSWindowResizeTime -float 0.001
} || {
  defaults delete -g NSWindowResizeTime > /dev/null 2>&1
}

# toggle the natural scrolling direction
defaults write -g com.apple.swipescrolldirection -bool $UseNaturalScrolling

# automatically re-arrange spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool $AutoArrangeSpaces

# enable jump to last space (four finger double tap)
defaults write com.apple.dock double-tap-jump-back -bool $EnableSpacesJumpBack

# boot up sound effect (you can view current nvram configs with nvram -xp)
[[ $StartupNoise == 'true' ]] && {
  sudo nvram -d SystemAudioVolume
} || {
  sudo nvram SystemAudioVolume=' '
}

# transparent menu bar and other bits
defaults write com.apple.universalaccess reduceTransparency -bool $ReduceTransparency

# set top right screen corner → notification center
defaults write com.apple.dock wvous-tr-corner -int $TopRightCorner
defaults write com.apple.dock wvous-tr-modifier -int 0

# set bottom right screen corner → mission control
defaults write com.apple.dock wvous-br-corner -int $BottomRightCorner
defaults write com.apple.dock wvous-br-modifier -int 0

# set top left screen corner → start screen saver
defaults write com.apple.dock wvous-tl-corner -int $TopLeftCorner
defaults write com.apple.dock wvous-tl-modifier -int 0

# set bottom left screen corner → disable screen saver
defaults write com.apple.dock wvous-bl-corner -int $BottomLeftCorner
defaults write com.apple.dock wvous-bl-modifier -int 0

#####################
# MISC BITS TO SORT #
#####################

# allow text selection in quick look (sadly no longer working)
# defaults write com.apple.finder QLEnableTextSelection -bool true

# disable the “are you sure you want to open this application?” dialog
# defaults write com.apple.LaunchServices LSQuarantine -bool false

# display ascii control characters using caret notation in standard text views
# try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
# defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

# disable resume system-wide
# defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# disable automatic termination of inactive apps
# defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# set help viewer windows to non-floating mode
# defaults write com.apple.helpviewer DevMode -bool true

# reveal ip address, hostname, os version, etc. when clicking the clock in the login window
# sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# disable notification center and remove the menu bar icon
# launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

# set a custom wallpaper image. `defaultdesktop.jpg` is already a symlink, and
# all wallpapers are in `/library/desktop pictures/`. the default is `wave.jpg`.
# rm -rf ~/Library/Application Support/Dock/desktoppicture.db
# sudo rm -rf /System/Library/CoreServices/DefaultDesktop.jpg
# sudo ln -s /path/to/your/image /System/Library/CoreServices/DefaultDesktop.jpg

# trackpad: enable tap to click for this user and for the login screen
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# trackpad: map bottom right corner to right-click
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
# defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
# defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# disable auto-correct
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# stop itunes from responding to the keyboard media keys
# launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

# enable subpixel font rendering on non-apple lcds
# defaults write NSGlobalDomain AppleFontSmoothing -int 2

# enable hidpi display modes (requires restart)
# sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

# finder: allow quitting via ⌘ + q; doing so will also hide desktop icons
# defaults write com.apple.finder QuitMenuItem -bool true

# finder: show hidden files by default
# defaults write com.apple.finder AppleShowAllFiles -bool true

# display full posix path as finder window title
# defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# enable spring loading for directories
# defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# remove the spring loading delay for directories
# defaults write NSGlobalDomain com.apple.springing.delay -float 0

# disable disk image verification
# defaults write com.apple.frameworks.diskimages skip-verify -bool true
# defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
# defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# automatically open a new finder window when a volume is mounted
# defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
# defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
# defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# show item info near icons on the desktop and in other icon views
# /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
# /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
# /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

# show item info to the right of the icons on the desktop
# /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

# enable snap-to-grid for icons on the desktop and in other icon views
# /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
# /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
# /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# use list view in all finder windows by default
# four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
# defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# disable the warning before emptying the trash
# defaults write com.apple.finder WarnOnEmptyTrash -bool false

# enable airdrop over ethernet and on unsupported macs running lion
# defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# enable the macbook air superdrive on any mac
# sudo nvram boot-args="mbasd=1"

# expand the following file info panes:
# “General”, “Open with”, and “Sharing & Permissions”
# defaults write com.apple.finder FXInfoPanesExpanded -dict \
#   General -bool true \
#   OpenWith -bool true \
#   Privileges -bool true

# don’t group windows by application in mission control
# (i.e. use the old exposé behavior instead)
# defaults write com.apple.dock expose-group-by-app -bool false

# don’t show dashboard as a space
# defaults write com.apple.dock dashboard-in-overlay -bool true

# disable the launchpad gesture (pinch with thumb and three fingers)
# defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

# reset launchpad, but keep the desktop wallpaper intact
# find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete

# add ios & watch simulator to launchpad
# sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
# sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"

# show remaining battery time; hide percentage
# defaults write com.apple.menuextra.battery ShowPercent -string "NO"
# defaults write com.apple.menuextra.battery ShowTime -string "YES"

# automatically illuminate built-in macbook keyboard in low light
# defaults write com.apple.BezelServices kDim -bool true

# turn off keyboard illumination when computer is not used for 5 minutes
# defaults write com.apple.BezelServices kDimTime -int 300

# echo "Disable the warning before emptying the Trash"
# defaults write com.apple.finder WarnOnEmptyTrash -bool false

# echo "Enable snap-to-grid for desktop icons"
# /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# echo "Set language and text formats"
# Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, `en_GB` with `en_US`, and `true` with `false`.
# defaults write NSGlobalDomain AppleLanguages -array "en"
# defaults write NSGlobalDomain AppleLocale -string "en_GB@currency=GBP"
# defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
# defaults write NSGlobalDomain AppleMetricUnits -bool true

#####################
# SSD SPECIFIC BITS #
#####################

# disable hibernation (speeds up entering sleep mode)
# sudo pmset -a hibernatemode 0

# remove the sleep image file to save disk space
# sudo rm /private/var/vm/sleepimage
# create a zero-byte file instead…
# sudo touch /private/var/vm/sleepimage
# …and make sure it can’t be rewritten
# sudo chflags uchg /private/var/vm/sleepimage

# disable the sudden motion sensor as it’s not useful for ssds
# sudo pmset -a sms 0

################################################################################
################################################################################
##                                                                            ##
##  Need to Create Config Options                                             ##
##                                                                            ##
##  Stuff I'm too lazy to build config options for at the moment.             ##
##                                                                            ##
################################################################################
################################################################################

# menu bar: hide the time machine, volume, and user icons
for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
  defaults write "${domain}" dontAutoLoad -array \
    "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
    "/System/Library/CoreServices/Menu Extras/Volume.menu" \
    "/System/Library/CoreServices/Menu Extras/User.menu"
done

# menu bar: show bluetooth, airport, battery, text input, and clock
defaults write com.apple.systemuiserver menuExtras -array \
  "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
  "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
  "/System/Library/CoreServices/Menu Extras/Battery.menu" \
  "/System/Library/CoreServices/Menu Extras/TextInput.menu" \
  "/System/Library/CoreServices/Menu Extras/Clock.menu"

# keep the default blue highlight color
defaults delete -g AppleHighlightColor > /dev/null 2>&1

# remove open with menu duplicates
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

# disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# use scroll gesture with the ctrl (^) modifier key to zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

# follow the keyboard focus while zoomed in
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool false

# set desktop as the default location for new finder windows
# for `~/Desktop` use `PfDe` and `file://${HOME}/Desktop/"
# for other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads/"

# show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# when performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist

# increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 60" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 60" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 60" ~/Library/Preferences/com.apple.finder.plist

# show the /Volumes folder
sudo chflags nohidden /Volumes

# enable highlight hover effect for the grid view of a stack (dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# set the icon size of dock items to 36 pixels
defaults write com.apple.dock tilesize -int 36

# change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "scale"

# minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# enable spring loading for all dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# hide spotlight tray-icon (and subsequent helper)
sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search

# disable spotlight indexing for any volume that gets mounted and has not yet # been indexed before.
# use `sudo mdutil -i off "/volumes/foo"` to stop indexing any volume.
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"

# change indexing order and disable some search results
# yosemite-specific search results (remove them if you are using macos 10.9 or older):
#   MENU_DEFINITION
#   MENU_CONVERSION
#   MENU_EXPRESSION
#   MENU_SPOTLIGHT_SUGGESTIONS (send search queries to Apple)
#   MENU_WEBSEARCH             (send search queries to Apple)
#   MENU_OTHER
defaults write com.apple.spotlight orderedItems -array \
  '{"enabled" = 1;"name" = "APPLICATIONS";}' \
  '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
  '{"enabled" = 1;"name" = "DIRECTORIES";}' \
  '{"enabled" = 1;"name" = "PDF";}' \
  '{"enabled" = 1;"name" = "FONTS";}' \
  '{"enabled" = 0;"name" = "DOCUMENTS";}' \
  '{"enabled" = 0;"name" = "MESSAGES";}' \
  '{"enabled" = 0;"name" = "CONTACT";}' \
  '{"enabled" = 0;"name" = "EVENT_TODO";}' \
  '{"enabled" = 0;"name" = "IMAGES";}' \
  '{"enabled" = 0;"name" = "BOOKMARKS";}' \
  '{"enabled" = 0;"name" = "MUSIC";}' \
  '{"enabled" = 0;"name" = "MOVIES";}' \
  '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
  '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
  '{"enabled" = 0;"name" = "SOURCE";}' \
  '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
  '{"enabled" = 0;"name" = "MENU_OTHER";}' \
  '{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
  '{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
  '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
  '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

# load new settings before rebuilding the index
killall mds > /dev/null 2>&1

# make sure indexing is enabled for the main volume
sudo mdutil -i on / > /dev/null

# rebuild the index from scratch
sudo mdutil -E / > /dev/null

################################################################################
################################################################################
##                                                                            ##
##  Finish Up                                                                 ##
##                                                                            ##
##  Restart what we can safely, remind to reboot.                             ##
##                                                                            ##
################################################################################
################################################################################

# restart a few systems without hosing everything
for i in Dock Finder SystemUIServer; do
  killall $i
done

# reboot reminder
echo "Reboot for all changes to take effect."
