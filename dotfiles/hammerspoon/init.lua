--------------------------------------------------------------------------------
--                                                                            --
--  Configuration                                                             --
--                                                                            --
--------------------------------------------------------------------------------

-- toggles extra print statements
DEBUG = false

-- define our key combos
local minimash = {"ctrl", "alt"}
local mash     = {"cmd", "alt", "ctrl"}
local hyper    = {"cmd", "alt", "ctrl", "shift"}

-- enable spotlight support (enable alternative names for applications)
hs.application.enableSpotlightForNameSearches(true)

-- placeholders for chaining
local lastSeenChain = nil
local lastSeenWindow = nil

-- disaable animations
hs.window.animationDuration = 0

-- define our grid
hs.grid.setGrid('24x24')
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0

-- gather screen information
local screenCount   = hs.screen.allScreens()
local primaryScreen = hs.screen.primaryScreen()
local primaryMode   = primaryScreen:currentMode()
local primaryName   = primaryScreen:name()
local primaryWxH    = primaryMode.w .. "x" .. primaryMode.h

-- standardize some grid positions 'x start, y start, grid dimension'
local grid = {
  -- genral
  topLeft                  = '0,0 12x12',
  topRight                 = '12,0 12x12',
  bottomRight              = '12,12 12x12',
  bottomLeft               = '0,12 12x12',
  fullScreen               = '0,0 24x24',
  halfFull                 = '6,0 12x24',
  centeredBig              = '4,2 16x20',
  centeredSmall            = '8,6 8x12',
  goldenSmall              = '4,2 12x16',
  goldenLarge              = '4,2 16x20',
  portraitLarge            = '4,4 10x18',
  portraitSmall            = '4,4 8x14',
  landscapeSmall           = '7,7 10x11',
  centeredMini             = '9.5,9 5x6',
  -- customs
  topLeftBig               = '0 0 10x13',
  bottomLeftSmall          = '0 14 10x11',
  -- tops
  topHalf                  = '0,0 24x12',
  topThird                 = '0,0 24x8',
  topTwoThirds             = '0,0 24x16',
  -- rights
  rightSixth               = '20,0 4x24',
  rightThird               = '16,0 8x24',
  rightHalf                = '12,0 12x24',
  rightTwoThirds           = '8,0 16x24',
  rightSeven12ths          = '10,0 14x24',
  -- bottoms
  bottomHalf               = '0,12 24x12',
  bottomThird              = '0,16 24x8',
  bottomTwoThirds          = '0,8 24x16',
  -- lefts
  leftSixth                = '0,0 4x24',
  leftThird                = '0,0 8x24',
  leftHalf                 = '0,0 12x24',
  leftTwoThirds            = '0,0 16x24',
  leftThreeQuarters        = '0,0 18x24',
  leftSeven12ths           = '0,0 14x24',
  -- customs
  widescreenRight37P       = '15,0 9x24',
  widescreenRight63P       = '9,0 15x24',
  widescreenLeft37P        = '0,0 9x24',
  widescreenLeft63P        = '0,0 15x24',
  laptopLeftThreeQuarters  = '0,0 20x24',
  laptopLeftElevenTwewfths = '0,0 22x24',
  laptopGoldenLarge        = '2,2 20x20',
}

-- application start up positions
local layoutConfig = {
  -- 3840x1600: dell 38" ultrawide (U3818DW)
  -- 3840x2160: dell 32" std (U3219Q)
  -- 2560x1440: dell 27" std (U2713HM)
  -- 1920x1080: dell 24" std ()

  -- 'com.spotify.client'      Spotify
  -- 'com.google.Chrome'       Chrome
  -- 'com.googlecode.iterm2'   iTerm
  -- 'net.kovidgoyal.kitty'    Kitty
  -- 'io.alacritty'            Alacritty
  -- 'us.zoom.xos'             Zoom
  -- 'com.apple.Music'         Music

  -- pre hook
  _before_ = (function()
    -- Hide('com.spotify.client')
  end),

  -- post hook
  _after_ = (function()
    -- make sure iterm appears in front of chrome
    Activate('com.google.Chrome')
    Activate('net.kovidgoyal.kitty')
  end),

  -- kitty
  ['net.kovidgoyal.kitty'] = (function(window, _)
    if primaryWxH == "3840x2160" then
      hs.grid.set(window, grid.rightTwoThirds, hs.screen.primaryScreen())
    else
      hs.grid.set(window, grid.fullScreen, hs.screen.primaryScreen())
    end
  end),

  -- music
  ['com.apple.Music'] = (function(window, forceScreenCount)
    local newSpace, spacesAfter
    local spacesBefore = hs.spaces.allSpaces()
    local count = forceScreenCount or screenCount
    if count == 1 then
      newSpace = hs.spaces.addSpaceToScreen("Primary")
      spacesAfter = hs.spaces.allSpaces()
    else
      local screens = hs.screen.allScreens()
      newSpace = hs.spaces.addSpaceToScreen(screens[2])
      spacesAfter = hs.spaces.allSpaces()
    end
    if newSpace then
      local spaceId = FindNewSpace(spacesBefore, spacesAfter)
      hs.spaces.moveWindowToSpace(window, spaceId)
      hs.grid.set(window, grid.fullScreen)
      hs.spaces.gotoSpace(spaceId)
    else
      hs.grid.set(window, grid.fullScreen)
    end
  end),
}

--------------------------------------------------------------------------------
--                                                                            --
--  Helpers                                                                   --
--                                                                            --
--------------------------------------------------------------------------------

-- Print Table
--
-- Helper function to print tables.
--
function PrintTable(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. PrintTable(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

-- Find New Space
--
-- Compare spaces before and after and return the new space id.
--
function FindNewSpace(spacesBefore, spacesAfter)
  for screenID, spaces in pairs(spacesAfter) do
    local beforeSpaces = spacesBefore[screenID] or {}
    local afterSpaces = spaces

    -- create a set of space IDs before
    local beforeSet = {}
    for _, spaceID in ipairs(beforeSpaces) do
      beforeSet[spaceID] = true
    end

    -- find the new space ID in afterSpaces
    for _, spaceID in ipairs(afterSpaces) do
      if not beforeSet[spaceID] then
        return tonumber(spaceID)
      end
    end
  end

  return nil
end

-- Window Count
--
-- Returns the number of standard, non-minimized windows in the application.
-- For Chrome, which has two windows per visible window on screen, but only one
-- window per minimized window.
--
function WindowCount(app)
  local count = 0
  if app then
    for _, window in pairs(app:allWindows()) do
      if window:isStandard() and not window:isMinimized() then
        count = count + 1
      end
    end
  end
  return count
end

-- Internal Display
--
-- Returns the internal laptop display.
--
function InternalDisplay()
  -- Fun fact: this resolution matches both the 13" MacBook Air and the 15"
  -- (Retina) MacBook Pro.
  return hs.screen.find('1440x900')
end

-- Activate
--
-- Focuses the defined application by bundleID, eg 'com.googlecode.iterm2'
--
function Activate(bundleID)
  local app = hs.application.get(bundleID)
  if app then
    app:activate()
  end
end

-- Hide
--
-- Hide the defined application by bundleID, eg 'com.googlecode.iterm2'
--
function Hide(bundleID)
  local app = hs.application.get(bundleID)
  if app then
    app:hide()
  end
end

-- Activate Layout
--
-- Applies window layout as defined in the config above.  Used to call on
-- varying events (eg. new monitor plugged in or removed).
--
function ActivateLayout(forceScreenCount)
  -- before hook
  layoutConfig._before_()

  -- apply layouts
  for bundleID, callback in pairs(layoutConfig) do
    local application = hs.application.get(bundleID)
    if application then
      local windows = application:visibleWindows()
      for _, window in pairs(windows) do
        callback(window, forceScreenCount)
      end
    end
  end

  -- after hook
  layoutConfig._after_()
end

-- Handle Window Event
--
-- Hook for window events.  Used to apply layout configurations on window
-- events if a layout is defined for the bundle id.
--
function HandleWindowEvent(window, winname, event)
  local application = window:application()
  local bundleID = application:bundleID()
  if DEBUG then
    print('HANDLING WINDOW EVENT:')
    print('  window name:  ' .. winname)
    print('  window event: ' .. event)
    print('  bundle id:    ' .. bundleID)
  end
  if layoutConfig[bundleID] then
    layoutConfig[bundleID](window)
  end
end

-- Handle Screen Event
--
-- Hook for screen events.  Used to apply layout configurations on screens.
--
function HandleScreenEvent()
  -- Make sure that something noteworthy (display count) actually
  -- changed. We no longer check geometry because we were seeing spurious
  -- events.
  local screens = hs.screen.allScreens()
  if not (#screens == screenCount) then
    screenCount = #screens
    ActivateLayout(screenCount)
  end
end

-- Chain
--
-- This is like the "chain" feature in Slate, but with a couple of enhancements:
--
--  - Chains always start on the screen the window is currently on.
--  - A chain will be reset after 2 seconds of inactivity, or on switching from
--    one chain to another, or on switching from one app to another, or from one
--    window to another.
--
function Chain(movements)
  local chainResetInterval = 2 -- seconds
  local cycleLength = #movements
  local sequenceNumber = 1

  return function()
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local now = hs.timer.secondsSinceEpoch()
    local screen = win:screen()

    if
      lastSeenChain ~= movements or
      LastSeenAt < now - chainResetInterval or
      lastSeenWindow ~= id
    then
      sequenceNumber = 1
      lastSeenChain = movements
    elseif (sequenceNumber == 1) then
      -- At end of chain, restart chain on next screen.
      screen = screen:next()
    end
    LastSeenAt = now
    lastSeenWindow = id

    hs.grid.set(win, movements[sequenceNumber], screen)
    sequenceNumber = sequenceNumber % cycleLength + 1
  end
end

-- Reload Config
--
-- Auto-reload config on files change.
--
function ReloadConfig(files)
  for _, file in pairs(files) do
    if file:sub(-4) == '.lua' then
      hs.reload()
    end
  end
end

-- Prepare Screencast
--
-- Setup for a screen recording session.
--
-- TODO: clean this up, test it out, find a better mapping down below
-- target a specific final resolution and build to that...
function PrepareScreencast()
  local screen = 'Color LCD'

  -- unit rects: percentages of screen width and height btw 0..1
  -- local top = {x=0, y=0, w=1, h=.92}
  -- local bottom = {x=.4, y=.82, w=.5, h=.1}

  -- full-frame rects: pixel x, y, width, height
  local stdWindow   = hs.geometry.rect(10, -1200, 1920, 1080)
  local kcstrWindow = hs.geometry.rect(20, -180, 1900, 10)

  -- layout
  local windowLayout = {
    -- [0]: app name or hs.application obj
    -- [1]: window title or hs.window obj or func
    -- [2]: screen name, os hs.screen object or func w no params that returns hs.screen
    -- then one of the following...
    -- [3]: unit rect, or func which returns hs.window.moveToUnit()
    -- [4]: frame rect, or func which returns hs.screen:frame()
    -- [5]: full-frame rect, or a func which returns hs.screen:fullFrame()
    {'kitty', nil, screen, nil, nil, stdWindow},
    {'Google Chrome', nil, screen, nil, nil, stdWindow},
    {'KeyCastr', nil, screen, nil, nil, kcstrWindow},
  }

  -- hs.application.launchOrFocus('KeyCastr')
  hs.application.launchOrFocus('Google Chrome')
  hs.application.launchOrFocus('kitty')

  local chrome = hs.appfinder.appFromName('Google Chrome')
  local kitty = hs.appfinder.appFromName('kitty')

  -- hide everything but chrome, kitty, and keycastr
  for _, app in pairs(hs.application.runningApplications()) do
    if app == chrome or app == kitty or app:name() == 'KeyCastr' then
      app:unhide()
    else
      app:hide()
    end
  end

  -- apply the layout
  hs.layout.apply(windowLayout)
end

--------------------------------------------------------------------------------
--                                                                            --
--  Startup                                                                   --
--                                                                            --
--------------------------------------------------------------------------------

-- log our resolution to the console
if DEBUG then
  print("SCREENS DETECTED:")
  print("  " .. PrintTable(screenCount))
  print("PRIMARY SCREEN:")
  print("  name: ".. primaryName)
  print("  size: ".. primaryWxH)
end

-- watch and feed all windowCreated events to HandleWindowEvent
local windowFilter = hs.window.filter.new()
windowFilter:subscribe(hs.window.filter.windowCreated, HandleWindowEvent)

-- watch and feed all screenChanged events to HandleScreenEvent
local screenWatcher = hs.screen.watcher.new(HandleScreenEvent)
screenWatcher:start()

-- watch for media keys
require('mediaKeys')

-- cmd double press to launch mission control
local cmdDoublePress = require("keyDoublePress")
cmdDoublePress.key = "cmd"
cmdDoublePress.action = function()
  -- grab the host os version information
  local os = hs.host.operatingSystemVersion()
  local osMajorMinor = tonumber(os.major .. os.minor)
  -- launch  mission control with double tap of cmd
  if (osMajorMinor >= 1015 or os.major >= 11) then -- catalina or higher
    hs.application.open('/System/Applications/Mission Control.app')
  else
    hs.application.open('/Applications/Mission Control.app')
  end
end

-- watch hammerspoon directory for changes, auto reload config
local configWatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', ReloadConfig)
configWatcher:start()

--------------------------------------------------------------------------------
--                                                                            --
--  Mappings                                                                  --
--                                                                            --
--------------------------------------------------------------------------------

-- reset the layout
hs.hotkey.bind(mash, 'f1', (function()
  hs.alert('Reset layout')
  for _, app in pairs(hs.application.runningApplications()) do
    app:unhide()
  end
  local screens = hs.screen.allScreens()
  screenCount = #screens
  ActivateLayout(screenCount)
end))

-- one monitor layout
hs.hotkey.bind(mash, 'f2', (function()
  hs.alert('One-monitor layout')
  for _, app in pairs(hs.application.runningApplications()) do
    app:unhide()
  end
  ActivateLayout(1)
end))

-- two monitor layout
hs.hotkey.bind(mash, 'f3', (function()
  hs.alert('Two-monitor layout')
  for _, app in pairs(hs.application.runningApplications()) do
    app:unhide()
  end
  ActivateLayout(2)
end))

-- hamerspoon console
hs.hotkey.bind(mash, 'f4', (function()
  hs.alert('Hammerspoon console')
  hs.openConsole()
end))

-- prepare for a screencast
hs.hotkey.bind(hyper, 'space', PrepareScreencast)

-- move windows slightly
hs.hotkey.bind(minimash, 'down', hs.grid.pushWindowDown)
hs.hotkey.bind(minimash, 'up', hs.grid.pushWindowUp)
hs.hotkey.bind(minimash, 'left', hs.grid.pushWindowLeft)
hs.hotkey.bind(minimash, 'right', hs.grid.pushWindowRight)

-- mash right window chain
hs.hotkey.bind(mash, 'right', Chain({
  grid.rightThird,
  grid.widescreenRight37P,
  grid.rightHalf,
  grid.rightSeven12ths,
  grid.widescreenRight63P,
  grid.rightTwoThirds,
}))

-- mash left window chain
hs.hotkey.bind(mash, 'left', Chain({
  grid.leftThird,
  grid.widescreenLeft37P,
  grid.leftHalf,
  grid.leftSeven12ths,
  grid.widescreenLeft63P,
  grid.leftTwoThirds,
}))

-- mash up window chain
hs.hotkey.bind(mash, 'up', Chain({
  grid.topLeft,
  grid.topRight,
  grid.bottomRight,
  grid.bottomLeft,
}))

-- mash down window chain
hs.hotkey.bind(mash, 'down', Chain({
  grid.landscapeSmall,
  grid.centeredMini,
  grid.fullScreen,
  grid.halfFull,
  grid.laptopGoldenLarge,
  grid.centeredSmall,
}))
