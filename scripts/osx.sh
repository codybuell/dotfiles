#!/bin/bash
#
# OSX
#
# Script to customize OSX system configurations. A restart is required for all
# configurations to take effect. Note that this has not been thoroughly tested
# on all versions of OSX, so any conditional runs may also work for a previous
# version. For example all configs were initially written for El Capitan, then
# updated for Catalina. In this case any new config commands will check for
# Catalina, but may also work for the previous three releases as well.
#
# Towards the bottom of the script there is a hardcoded section, you will need
# to check and adjust those configs in addition to the settings contained in
# the 'Configuration' section at the top of this script.
#
# Lately there are a bunch of settings that appear to be correct in the various
# plist files but the settings just never take effect. This has been the case
# in Big Sur and Monterey with settings around login screen, keyboard layouts
# etc...
#
# Author(s): Cody Buell
#
# Requisite: - a path for screenshots, be sure to update the config below
#            - full disk access for terminal app
#            - desired default browser installed
#
# Tools: - pmset         (power management utility)
#        - systemsetup   (general system configurations)
#        - chflags       (changing file / folder meta data)
#        - tmutil        (time machine utility)
#        - nvram         (firmware nvram config utility)
#        - launchctl     (the osx service manager)
#        - defaults      (configuring ~/Library/Preferences/ plist files)
#                        * note that -g is shorthand for NSGlobalDomain
#                          which are defaults intended for all applications
#
#          defaults read -g                                  show all global
#          defaults read com.apple.finder                    show local
#          defaults read com.apple.finder AppleShowAllFiles  show local value
#          defaults find "NSStatusItem Preferred Position"   search all plists
#
# Coverage: - [?] Yosemite
#           - [?] El Capitan
#           - [?] Sierra
#           - [~] High Sierra
#           - [~] Mojave
#           - [X] Catalina
#           - [~] Big Sur
#           - [~] Monterey
#
# Usage: make osx
#        ./osx.sh
#        sh -c “$(curl -fsSL https://raw.githubusercontent.com/codybuell/dotfiles/master/scripts/osx.sh)”

# shellcheck source=./library.sh
source "${BASH_SOURCE%/*}/library.sh"

################################################################################
################################################################################
##                                                                            ##
##  Configuration                                                             ##
##                                                                            ##
##  Change the settings contained in this section to your preference.         ##
##                                                                            ##
################################################################################
################################################################################

# finder
ShowHiddenFiles="false"                       # show hidden files by default
ShowLibraryFolder="true"                      # show ~/Library folder?
ShowVolumesFolder="true"                      # show ~/Volumes folder?
ShowFinderStatusBar="true"                    # show status bar in finder?
ShowFinderPathBar="true"                      # show path bar in finder?
FileExtWarning="false"                        # show warning on ext change?
ExpandSaveMenus="true"                        # default expand save menus?
ExpandPrintMenus="true"                       # default expand print menus?
ShowFileExtensions="true"                     # show all file extensions?
DSStoreOnNetwork="false"                      # .DS_Store file on rem vols?
SideBarIconSize="small"                       # small, medium, large
ShowMountsOnDesktop="false"                   # show mounts on desktop
SpringLoading="true"                          # drag item over folders to open
FinderTargetLoc="file://${HOME}/Downloads/"   # new finder start location
FinderTarget="PfLo"                           # corresponds to FinderTargetLoc
                                              # "PfDe" file://${HOME}/Desktop/
                                              # "PfHm" file://${HOME}/
                                              # "PfDo" file://${HOME}/Documents
                                              # "PfLo" file://any/custom/path

# dock
AppRunningLights="false"                      # dock app is running lights?
AutoHideDock="true"                           # auto hide the dock?
RemoveAllDockIcons="true"                     # clean out the dock?
HiddenAppsTranslucentIcons="true"             # translucent hidden app icons?
DockLaunchAnimations="false"                  # dock launch bounce animations?
DockHideDelay="none"                          # none, default, long
SingleAppMode="false"                         # enable single app mode?
ShowDockRecents="false"                       # show recent applications
TileSize="40"                                 # dock size, 16 - 128
HoverHighlightStack="true"                    # grid view hover effect
MinMaxEffect="scale"                          # "scale" or "genie"
MinimizeToIcon="true"                         # minimize apps to their icon

# general ux / ui
Appearance="graphite"                         # blue or graphite
AutoHideMenuBar="false"                       # auto hide the menu bar?
ShowScrollbars="Automatic"                    # WhenScrolling, Automatic, Always
MissionControlAnimation="fast"                # fast, off, or default
OpenCloseAnimations="false"                   # open and close animations?
QLOpenCloseAnimations="false"                 # quick look animations?
InfoOpenCloseAnimations="false"               # animate info windows?
FullScreenAnimations="false"                  # animate fullscreen switch?
AccellerateCocoa="true"                       # speed up cocoa resizings?
UseNaturalScrolling="false"                   # use natural scrolling?
AutoArrangeSpaces="false"                     # re-arrange spaces by use?
EnableSpacesJumpBack="true"                   # enable go to last space?
StartupNoise="true"                           # play osx boot noise?
ReduceTransparency="false"                    # turn off transparent menu bar?
AnalogMenuBarClock="true"                     # use anlog menu clock
TopRightCorner="12"                           # set hot corner, see below
BottomRightCorner="4"                         # set hot corner, see below
TopLeftCorner="5"                             # set hot corner, see below
BottomLeftCorner="6"                          # set hot corner, see below

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

# system
CrashReportsAsNotifications="true"            # crash reports to not. cent.?
LockSystemImmediately="true"                  # require passwd on ss start?
DefaultSaveToiCloud="false"                   # default icloud as save loc?
DisableDashboard="true"                       # disable the dashboard?
StandbyDelay="30"                             # sleep time (minutes) or Never
SystemTimezone="America/New_York"             # `systemsetup -listtimezones`
UseNTP="true"                                 # use network time server
DisplaySleepTime="15"                         # display sleep delay in minutes
HDDSleepTime="Never"                          # hd sleep time (minutes) or Never
EnableSSHServer="true"                        # turn on ssh server?
WakeOnLan="true"                              # wake  with network admin pkt?
AutoRebootOnFreeze="false"                    # auto restart frozen system?
AllowRemoteScripting="false"                  # allow remote apple scripting?
AutoQuitPrinterWhenDone="true"                # auto close printer app when done

# login menu
ShowInputMenu="true"                          # show input menu for kb layouts
NameAndPasswordOnly="true"                    # no list of users, require un & pw
TriesUntilHint=0                              # 0 to disable hits, else 3

# debug menus
SafariDebugMenu="true"                        # turn on safari debug menu?
AddressBookDebugMenu="true"                   # turn on addressbook debug?
iCalDebugMenu="true"                          # turn on ical debug menu?
AppStoreDebugMenu="true"                      # turn on app store debug?
DiskUtilityDebugMenu="true"                   # turn on disk utility debug?

# screenshots
ScreenshotFolder="${HOME}/Library/Mobile\ Documents/com\~apple\~CloudDocs/Data/Resources/Screenshots"
ScreenshotDropshadows="false"                 # dropshadows on screenshots?
ScreenshotFormat="png"                        # bmp, gif, jpg, pdf, tiff

# time machine
DisableTimeMachine="true"                     # turn off time machine?
DisableDiskPrompt="true"                      # disable use disk tm prompt?

# mail
CopyNameAndAddress="false"                    # copy name with email addr?
MailSendReplyAnimations="false"               # animate sends and replies?

# text edit
TextEditPlainTextDefault="true"               # use plain text by default?
ShowRuler="false"                             # show the text edit ruler?

# iphoto
AutoOpeniPhoto="false"                        # open iphoto automatically?

# ical
DefaultMeetingDuration="30"                   # default cal item minutes

# terminal
FocusFollowsMouse="true"                      # focus follows mouse?

# miscellaneous
UseSmartQuotes="false"                        # enable smart quotes when typing
UseSmartDashes="false"                        # enable smart dashes when typing
CorrectSpellingAutomatically="false"          # auto fix spelling
CtrlWithScrollZoom="true"                     # use scroll + ctrl to zoom
ZoomFollowKeyboard="false"                    # follow kb focus when zoomed
EnableLocate="true"                           # turn on locate service

################################################################################
################################################################################
##                                                                            ##
##  Detect Environment                                                        ##
##                                                                            ##
##  Gather information aboout the current OSX version. Used to conditionally  ##
##  apply configurations.                                                     ##
##                                                                            ##
################################################################################
################################################################################

detect_os_version() {
  MAJOR=$(sw_vers -productVersion | awk -F '.' '{print $1}')
  MINOR=$(sw_vers -productVersion | awk -F '.' '{printf("%02d\n", $2)}')
  NUMVER=${MAJOR}${MINOR}

  case "$MAJOR" in
  '10')
      case "$MINOR" in
      '00')
          OSVER='cheetah'
          ;;
      '01')
          OSVER='puma'
          ;;
      '02')
          OSVER='jaguar'
          ;;
      '03')
          OSVER='panther'
          ;;
      '04')
          OSVER='tiger'
          ;;
      '05')
          OSVER='leopard'
          ;;
      '06')
          OSVER='snow leopard'
          ;;
      '07')
          OSVER='lion'
          ;;
      '08')
          OSVER='mountain lion'
          ;;
      '09')
          OSVER='mavericks'
          ;;
      '10')
          OSVER='yosemite'
          ;;
      '11')
          OSVER='el capitan'
          ;;
      '12')
          OSVER='sierra'
          ;;
      '13')
          OSVER='high sierra'
          ;;
      '14')
          OSVER='mojave'
          ;;
      '15')
          OSVER='catalina'
          ;;
      esac
      ;;

  '11')
      OSVER='big sur'
      ;;
  '12')
      OSVER='monterey'
      ;;
  *)
      OSVER='unknown'
      ;;
  esac

  export OSVER
}

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

##########
# FINDER #
##########

# configure showing hidden files
defaults write com.apple.finder AppleShowAllFiles -bool $ShowHiddenFiles

# show or hide ~/Library folder
# todo: does not seem to be working on catalina, possibly earlier
LibraryFlag=$([[ $ShowLibraryFolder == 'true' ]] && echo nohidden || echo hidden)
sudo chflags "$LibraryFlag" ~/Library

# show or hide the /Volumes folder
# todo: does not seem to be working on catalina, possibly earlier
VolumesFlag=$([[ $ShowVolumesFolder == 'true' ]] && echo nohidden || echo hidden)
sudo chflags "$VolumesFlag" /Volumes

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
DSStore=$([[ $DSStoreOnNetwork == 'true' ]] && echo false || echo true)
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool "$DSStore"

# set sidebar icon sizes
case $SideBarIconSize in
  'small' )
    defaults write -g NSTableViewDefaultSizeMode -int 1
    ;;
  'medium' )
    defaults write -g NSTableViewDefaultSizeMode -int 2
    ;;
  'large' )
    defaults write -g NSTableViewDefaultSizeMode -int 3
    ;;
esac

# show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool $ShowMountsOnDesktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool $ShowMountsOnDesktop
defaults write com.apple.finder ShowMountedServersOnDesktop -bool $ShowMountsOnDesktop
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool $ShowMountsOnDesktop

# enable spring loading for all dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool $SpringLoading

# set the default finder start location
defaults write com.apple.finder NewWindowTarget -string "$FinderTarget"
defaults write com.apple.finder NewWindowTargetPath -string "$FinderTargetLoc"

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

# show recent applications in the dock
defaults write com.apple.dock show-recents -bool $ShowDockRecents

defaults write com.apple.dock tilesize -int $TileSize

# configure highlight hover effect for the grid view of a stack (dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool $HoverHighlightStack

# change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "$MinMaxEffect"

# minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool $MinimizeToIcon

###################
# GENERAL UX / UI #
###################

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
MenuHide=$([[ $AutoHideMenuBar == 'true' ]] && echo 1 || echo 0)
defaults write -g _HIHideMenuBar "$MenuHide"

# configure scrollbars
defaults write -g AppleShowScrollBars -string "$ShowScrollbars"

# speed up mission control animations
# todo: this stopped working somewhere around sierra
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
if [[ $QLOpenCloseAnimations == 'true' ]]; then
  defaults delete -g QLPanelAnimationDuration > /dev/null 2>&1
else
  defaults write -g QLPanelAnimationDuration -float 0
fi

# info window open close animation
defaults write com.apple.finder DisableAllAnimations -bool $InfoOpenCloseAnimations

# animate fullscreen transitions
if [[ $FullScreenAnimations == 'true' ]]; then
  defaults delete -g NSWindowResizeTime > /dev/null 2>&1
else
  defaults write -g NSWindowResizeTime -float 0.001
fi

# speed up cocoa application window resizing
if [[ $AccellerateCocoa == 'true' ]]; then
  defaults write -g NSWindowResizeTime -float 0.001
else
  defaults delete -g NSWindowResizeTime > /dev/null 2>&1
fi

# toggle the natural scrolling direction
defaults write -g com.apple.swipescrolldirection -bool $UseNaturalScrolling

# automatically re-arrange spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool $AutoArrangeSpaces

# enable jump to last space (four finger double tap)
defaults write com.apple.dock double-tap-jump-back -bool $EnableSpacesJumpBack

# boot up sound effect (you can view current nvram configs with nvram -xp)
if [[ $StartupNoise == 'true' ]]; then
  sudo nvram -d SystemAudioVolume
else
  sudo nvram SystemAudioVolume=' '
fi

# disable system sounds like the sceenshot shutter sound
defaults write 'Apple Global Domain' com.apple.sound.uiaudio.enabled -int 0

# transparent menu bar and other bits
if [[ $NUMVER -lt 1015 ]]; then
  defaults write com.apple.universalaccess reduceTransparency -bool $ReduceTransparency
fi

# configure menu clock to analog or digital
defaults write com.apple.menuextra.clock IsAnalog -bool $AnalogMenuBarClock

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

##########
# SYSTEM #
##########

# show crash reports in the notification center
NCCrash=$([[ $CrashReportsAsNotifications == 'true' ]] && echo 1 || echo 0)
defaults write com.apple.CrashReporter UseUNC "$NCCrash"

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
# sudo pmset -a standbydelay $StandbyDelay                     # in seconds
sudo systemsetup -setcomputersleep $StandbyDelay 2> /dev/null  # in minutes, never or off

# set the systems timezone
sudo systemsetup -settimezone $SystemTimezone 2> /dev/null

# use ntp for setting time
NTPStatus=$([[ $UseNTP == 'true' ]] && echo On || echo Off)
sudo systemsetup -setusingnetworktime "$NTPStatus" 2> /dev/null

# set the display sleep time
sudo systemsetup -setdisplaysleep $DisplaySleepTime 2> /dev/null

# set hard drive sleep time
sudo systemsetup -setharddisksleep $HDDSleepTime 2> /dev/null

# configure ssh server
SSHStatus=$([[ $EnableSSHServer == 'true' ]] && echo On || echo Off)
sudo systemsetup -setremotelogin "$SSHStatus" 2> /dev/null

# wake on lan
WOLStatus=$([[ $WakeOnLan == 'true' ]] && echo On || echo Off)
sudo systemsetup -setwakeonnetworkaccess "$WOLStatus" 2> /dev/null

# auto restart after system freeze
AutoRestartStatus=$([[ $AutoRebootOnFreeze == 'true' ]] && echo On || echo Off)
sudo systemsetup -setrestartfreeze "$AutoRestartStatus" 2> /dev/null

# allow remote scripting
ScriptingStatus=$([[ $AllowRemoteScripting == 'true' ]] && echo On || echo Off)
sudo systemsetup -setremoteappleevents "$ScriptingStatus" 2> /dev/null

# auto close printer application when done
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool $AutoQuitPrinterWhenDone

##############
# LOGIN MENU #
##############

# show input menu
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool $ShowInputMenu

# require username and password or show list of users
# TODO: Monterey does not seem to respect this. Gets set but not used, have to toggle in sys pref.
sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool $NameAndPasswordOnly

# configure password hints
sudo defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int $TriesUntilHint

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

###############
# SCREENSHOTS #
###############

# set where to save screenshots
defaults write com.apple.screencapture location "$ScreenshotFolder"

# disable dropshadow in screenshots
DisableDrops=$([[ $ScreenshotDropshadows == 'true' ]] && echo false || echo true)
defaults write com.apple.screencapture disable-shadow -bool "$DisableDrops"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "$ScreenshotFormat"

################
# TIME MACHINE #
################

# turn off time machine
# todo: automate granting of full disk access for terminal and iterm
[[ $DisableTimeMachine == 'true' ]] && {
  sudo tmutil disable
  if [[ $NUMVER -lt 1015 ]]; then
    sudo tmutil disablelocal
  fi
}

# toggle time machine prompt to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool $DisableDiskPrompt

########
# MAIL #
########

# copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in mail.app
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool $CopyNameAndAddress

# animate mail sends and replies
MailAnimations=$([[ $MailSendReplyAnimations == 'true' ]] && echo false || echo true)
defaults write com.apple.mail DisableReplyAnimations -bool "$MailAnimations"
defaults write com.apple.mail DisableSendAnimations -bool "$MailAnimations"

#############
# TEXT EDIT #
#############

# use rich or plain text by default in textedit
if [[ $TextEditPlainTextDefault == 'true' ]]; then
  defaults write com.apple.TextEdit RichText -int 0
else
  defaults delete com.apple.TextEdit RichText > /dev/null 2>&1
fi

# text edit ruler
Ruler=$([[ $ShowRuler == true ]] && echo 1 || echo 0)
defaults write com.apple.TextEdit ShowRuler "$Ruler"

##########
# IPHOTO #
##########

# automatically open iphoto when camera is plugged in
if [[ $AutoOpeniPhoto == true ]]; then
  defaults -currentHost delete com.apple.ImageCapture disableHotPlug > /dev/null 2>&1
else
  defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
fi

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

#################
# MISCELLANEOUS #
#################

# configure smart quotes
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool $UseSmartQuotes

# configure smart dashes
defaults write -g NSAutomaticDashSubstitutionEnabled -bool $UseSmartDashes

# auto fix spelling
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool $CorrectSpellingAutomatically

# use scroll gesture with the ctrl (^) modifier key to zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool $CtrlWithScrollZoom
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

# follow the keyboard focus while zoomed in
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool $ZoomFollowKeyboard

# enable the locate service
[[ $EnableLocate == true ]] && {
  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
}

################################################################################
################################################################################
##                                                                            ##
##  Hardcoded                                                                 ##
##                                                                            ##
##  Bits that have to be configured manually here.                            ##
##  TODO: make this stuff configurable at top of script.                      ##
##                                                                            ##
################################################################################
################################################################################

# menu bar: show bluetooth, airport, battery, text input, and clock
# todo: TextInput not showing up when reading config...
defaults write com.apple.systemuiserver menuExtras -array \
  "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
  "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
  "/System/Library/CoreServices/Menu Extras/Battery.menu" \
  "/System/Library/CoreServices/Menu Extras/TextInput.menu" \
  "/System/Library/CoreServices/Menu Extras/Volume.menu" \
  "/System/Library/CoreServices/Menu Extras/VPN.menu" \
  "/System/Library/CoreServices/Menu Extras/Clock.menu"

# when searching, search current folder by default (default is "SCev")
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist

# increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 60" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 60" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 60" ~/Library/Preferences/com.apple.finder.plist

# disable spotlight indexing for any volume that gets mounted and has not yet # been indexed before.
# use `sudo mdutil -i off "/volumes/foo"` to stop indexing any volume.
if [[ $NUMVER -lt 1015 ]]; then
  sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"
fi

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

# bump banner notification auto dismissal from 5 to 10 seconds
defaults write com.apple.notificationcenterui bannerTime -int 10

# load new settings before rebuilding the index
killall mds > /dev/null 2>&1

# make sure indexing is enabled for the main volume
sudo mdutil -i on / > /dev/null

# rebuild the index from scratch
sudo mdutil -E / > /dev/null

# add colemak to input sources
# defaults delete com.apple.HIToolbox AppleEnabledInputSources
# defaults write com.apple.HIToolbox AppleEnabledInputSources -array \
#   '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 0; "KeyboardLayout Name" = "U.S."; }'
# defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
#   '{ "Bundle ID" = "com.apple.CharacterPaletteIM"; InputSourceKind = "Non Keyboard Input Method"; }'
# defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
#   '{ "Bundle ID" = "com.apple.inputmethod.EmojiFunctionRowItem"; InputSourceKind = "Non Keyboard Input Method"; }'
# defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
#   '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 12825; "KeyboardLayout Name" = Colemak; }'
# defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
#   '{ "Bundle ID" = "com.apple.PressAndHold"; InputSourceKind = "Non Keyboard Input Method"; }'

# defaults write com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID -string "com.apple.keylayout.Colemak"

# defaults delete com.apple.HIToolbox AppleInputSourceHistory
# defaults write com.apple.HIToolbox AppleInputSourceHistory -array \
#   '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 12825; "KeyboardLayout Name" = Colemak; }'
# defaults write com.apple.HIToolbox AppleInputSourceHistory -array-add \
#   '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 0; "KeyboardLayout Name" = "U.S."; }'

# defaults delete com.apple.HIToolbox AppleSelectedInputSources
# defaults write com.apple.HIToolbox AppleSelectedInputSources -array \
#   '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 12825; "KeyboardLayout Name" = Colemak; }'
# defaults write com.apple.HIToolbox AppleSelectedInputSources -array-add \
#   '{ "Bundle ID" = "com.apple.inputmethod.EmojiFunctionRowItem"; InputSourceKind = "Non Keyboard Input Method"; }'
# TODO: setup caps map to escape https://apple.stackexchange.com/questions/13598/updating-modifier-key-mappings-through-defaults-command-tool

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
