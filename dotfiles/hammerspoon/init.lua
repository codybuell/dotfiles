-------------------------------------------------------------------------------
--                                                                           --
--  configuration                                                            --
--                                                                           --
-------------------------------------------------------------------------------

-- disaable animations
hs.window.animationDuration = 0

-- define our grid
hs.grid.setGrid('24x24')
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0

-- configure logging (debug | info | ...)
local logLevel = 'info'
local log      = hs.logger.new('user log', logLevel)

-- gather screen information
local screenCount   = #hs.screen.allScreens()
local primaryScreen = hs.screen.primaryScreen()
local primaryMode   = primaryScreen:currentMode()
local primaryWidth  = primaryMode.w
local primaryHeight = primaryMode.h
local primaryWxH    = primaryMode.w .. "x" .. primaryMode.h

-- log our resolution to the console
log.i("detected resolution: " .. primaryWxH)

-- define our key combos
local mash     = {"cmd", "alt", "ctrl"}
local hyper    = {"cmd", "alt", "ctrl", "shift"}
local minimash = {"ctrl", "alt"}

-- standardize some grid positions 'x start, y start, grid dimension'
local grid = {
  -- genral
  topLeft           = '0,0 12x12',
  topRight          = '12,0 12x12',
  bottomRight       = '12,12 12x12',
  bottomLeft        = '0,12 12x12',
  fullScreen        = '0,0 24x24',
  halfFull          = '6,0 12x24',
  centeredBig       = '4,2 16x20',
  centeredSmall     = '8,6 8x12',
  goldenSmall       = '4,2 12x16',
  goldenLarge       = '4,2 16x20',
  portraitLarge     = '4,4 10x18',
  portraitSmall     = '4,4 8x14',
  -- tops
  topHalf           = '0,0 24x12',
  topThird          = '0,0 24x8',
  topTwoThirds      = '0,0 24x16',
  -- rights
  rightSixth        = '20,0 4x24',
  rightThird        = '16,0 8x24',
  right37P          = '15,0 9x24', --web browser widescreen
  rightHalf         = '12,0 12x24',
  right62P          = '9,0 15x24',
  rightTwoThirds    = '8,0 16x24',
  -- bottoms
  bottomHalf        = '0,12 24x12',
  bottomThird       = '0,16 24x8',
  bottomTwoThirds   = '0,8 24x16',
  -- lefts
  leftSixth         = '0,0 4x24',
  leftThird         = '0,0 8x24',
  left37P           = '0,0 9x24',
  leftHalf          = '0,0 12x24',
  left62P           = '0,0 15x24', -- terminal widescreen
  leftTwoThirds     = '0,0 16x24',
  leftThreeQuarters = '0,0 18x24',
  -- customs
  laptopLeftThreeQuarters  = '0,0 20x24',
  laptopLeftElevenTwewfths = '0,0 22x24',
  laptopGoldenLarge        = '2,2 20x20',
}

-- layout configuration
local layoutConfig = {
  ----------------
  --  pre hook  --
  ----------------
  _before_ = (function()
    -- hide('com.spotify.client')
  end),

  -----------------
  --  post hook  --
  -----------------
  _after_ = (function()
    -- make sure iterm appears in front of chrome
    activate('com.google.Chrome')
    activate('com.googlecode.iterm2')
  end),

  --------------
  --  chrome  --
  --------------
  ['com.google.Chrome'] = (function(window, forceScreenCount)
    if primaryWxH == "3840x1600" then -- 38" ultrawide
      hs.grid.set(window, grid.right37P)
    elseif primaryWxH == "2560x1440" then -- 27"
    --elseif then -- 27" + 24"
    else -- default (laptop)
      hs.grid.set(window, grid.laptopGoldenLarge)
    end
  end),

  --------------
  --  iterm2  --
  --------------
  ['com.googlecode.iterm2'] = (function(window, forceScreenCount)
--    local count = forceScreenCount or screenCount
--    if count == 1 then
--      hs.grid.set(window, grid.portraitSmall)
--    else
--      hs.grid.set(window, grid.leftHalf, hs.screen.primaryScreen())
--    end
--  hs.grid.MARGINX = 6
--  hs.grid.MARGINY = 5
    if primaryWxH == "3840x1600" then -- 38" ultrawide
      hs.grid.set(window, grid.left62P)
    elseif primaryWxH == "2560x1440" then -- 27" & 24"
      hs.grid.set(window, grid.fullScreen)
    else -- default (laptop)
      hs.grid.set(window, grid.fullScreen)
    end
--  hs.grid.MARGINX = 0
--  hs.grid.MARGINY = 0
  end),

}

-------------------------------------------------------------------------------
--                                                                           --
--  helpers                                                                  --
--                                                                           --
-------------------------------------------------------------------------------

-- Window Count
--
-- Returns the number of standard, non-minimized windows in the application.
-- For Chrome, which has two windows per visible window on screen, but only one
-- window per minimized window.
-- 
function windowCount(app)
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

-- Hide
--
-- Hide the defined application by bundleID, eg 'com.googlecode.iterm2'
--
function hide(bundleID)
  local app = hs.application.get(bundleID)
  if app then
    app:hide()
  end
end

-- Activcate
--
-- Focuses the defined application by bundleID, eg 'com.googlecode.iterm2'
--
function activate(bundleID)
  local app = hs.application.get(bundleID)
  if app then
    app:activate()
  end
end

-- Can Manage Window
--
-- Returns the bundleID if the window can be managed.  Special handling for
-- iterm since windows without tile bars are non-standard.
--
function canManageWindow(window)
  local application = window:application()
  local bundleID = application:bundleID()

  return window:isStandard() or
    bundleID == 'com.googlecode.iterm2'
end

-- Internal Display
--
-- Returns the internal laptop display.
--
function internalDisplay()
  -- Fun fact: this resolution matches both the 13" MacBook Air and the 15"
  -- (Retina) MacBook Pro.
  return hs.screen.find('1440x900')
end

-- Activate Layout
--
-- Applies window layout as defined in the config above.  Used to call on
-- varying events (eg. new monitor plugged in or removed).
--
function activateLayout(forceScreenCount)
  -- before hook
  layoutConfig._before_()

  -- apply layouts
  for bundleID, callback in pairs(layoutConfig) do
    local application = hs.application.get(bundleID)
    if application then
      local windows = application:visibleWindows()
      for _, window in pairs(windows) do
        if canManageWindow(window) then
          callback(window, forceScreenCount)
        end
      end
    end
  end

  -- after hook
  layoutConfig._after_()
end

-------------------------------------------------------------------------------
--                                                                           --
--  event handling                                                           --
--                                                                           --
-------------------------------------------------------------------------------

function handleWindowEvent(window)
  if canManageWindow(window) then
    local application = window:application()
    local bundleID = application:bundleID()
    if layoutConfig[bundleID] then
      layoutConfig[bundleID](window)
    end
  end
end

local windowFilter=hs.window.filter.new()
windowFilter:subscribe(hs.window.filter.windowCreated, handleWindowEvent)

function handleScreenEvent()
  -- Make sure that something noteworthy (display count) actually
  -- changed. We no longer check geometry because we were seeing spurious
  -- events.
  local screens = hs.screen.allScreens()
  if not (#screens == screenCount) then
    screenCount = #screens
    activateLayout(screenCount)
  end
end

function initEventHandling()
  screenWatcher = hs.screen.watcher.new(handleScreenEvent)
  screenWatcher:start()
end

function tearDownEventHandling()
  screenWatcher:stop()
  screenWatcher = nil
end

initEventHandling()

-------------------------------------------------------------------------------
--                                                                           --
--  chaining                                                                 --
--                                                                           --
-------------------------------------------------------------------------------

local lastSeenChain = nil
local lastSeenWindow = nil

-- Chain the specified movement commands.
--
-- This is like the "chain" feature in Slate, but with a couple of enhancements:
--
--  - Chains always start on the screen the window is currently on.
--  - A chain will be reset after 2 seconds of inactivity, or on switching from
--    one chain to another, or on switching from one app to another, or from one
--    window to another.
--
function chain(movements)
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
      lastSeenAt < now - chainResetInterval or
      lastSeenWindow ~= id
    then
      sequenceNumber = 1
      lastSeenChain = movements
    elseif (sequenceNumber == 1) then
      -- At end of chain, restart chain on next screen.
      screen = screen:next()
    end
    lastSeenAt = now
    lastSeenWindow = id

    hs.grid.set(win, movements[sequenceNumber], screen)
    sequenceNumber = sequenceNumber % cycleLength + 1
  end
end

--
-- Key bindings.
--

--hs.hotkey.bind(minimash, 'up', chain({
--  grid.topHalf,
--  grid.topThird,
--  grid.topTwoThirds,
--}))

hs.hotkey.bind(mash, 'right', chain({
  grid.rightTwoThirds,
  grid.right62P,
  grid.rightHalf,
  grid.right37P,
  grid.rightThird,
}))

--hs.hotkey.bind({'ctrl', 'alt'}, 'down', chain({
--  grid.bottomHalf,
--  grid.bottomThird,
--  grid.bottomTwoThirds,
--}))

hs.hotkey.bind(mash, 'left', chain({
  grid.leftTwoThirds,
  grid.left62P,
  grid.leftHalf,
  grid.left37P,
  grid.leftThird,
}))

hs.hotkey.bind(mash, 'up', chain({
  grid.topLeft,
  grid.topRight,
  grid.bottomRight,
  grid.bottomLeft,
}))

--if primaryWxH == "1680x1050" then
  hs.hotkey.bind(mash, 'down', chain({
    grid.fullScreen,
    grid.halfFull,
    grid.laptopGoldenLarge,
    grid.centeredSmall,
  }))
--else
--  hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'down', chain({
--    grid.fullScreen,
--    grid.centeredBig,
--    grid.centeredSmall,
--  }))
--end

--Move windows slightly
hs.hotkey.bind(minimash, 'down', hs.grid.pushWindowDown)
hs.hotkey.bind(minimash, 'up', hs.grid.pushWindowUp)
hs.hotkey.bind(minimash, 'left', hs.grid.pushWindowLeft)
hs.hotkey.bind(minimash, 'right', hs.grid.pushWindowRight)

hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'f1', (function()
  hs.alert('One-monitor layout')
  activateLayout(1)
end))

hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'f2', (function()
  hs.alert('Two-monitor layout')
  activateLayout(2)
end))

hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'f3', (function()
  hs.alert('Hammerspoon console')
  hs.openConsole()
end))


--
-- Screencast layout
--

function prepareScreencast()
  local screen = 'Color LCD'
  local top = {x=0, y=0, w=1, h=.92}
  local bottom = {x=.4, y=.82, w=.5, h=.1}
  local windowLayout = {
    {'iTerm2', nil, screen, top, nil, nil},
    {'Google Chrome', nil, screen, top, nil, nil},
    {'KeyCastr', nil, screen, bottom, nil, nil},
  }

  hs.application.launchOrFocus('KeyCastr')
  local chrome = hs.appfinder.appFromName('Google Chrome')
  local iterm = hs.appfinder.appFromName('iTerm2')
  for key, app in pairs(hs.application.runningApplications()) do
    if app == chrome or app == iterm or app:name() == 'KeyCastr' then
      app:unhide()
    else
      app:hide()
    end
  end
  hs.layout.apply(windowLayout)
end

-- `open hammerspoon://screencast`
hs.urlevent.bind('screencast', prepareScreencast)

--
-- Auto-reload config on change.
--

function reloadConfig(files)
  for _, file in pairs(files) do
    if file:sub(-4) == '.lua' then
      tearDownEventHandling()
      hs.reload()
    end
  end
end

local pathwatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', reloadConfig):start()

-------------------------------------------------------------------------------
--                                                                           --
--  modules                                                                  --
--                                                                           --
-------------------------------------------------------------------------------

-------------------------
--  control dbl-press  --
-------------------------

-- ctrlDoublePress = require("ctrlDoublePress")
-- ctrlDoublePress.timeFrame = 1
-- ctrlDoublePress.action = function()
--  -- launch  mission control with double tap of ctrl
--   hs.application.open('/Applications/Mission Control.app')
-- end

-------------------------
--  command dbl-press  --
-------------------------

cmdDoublePress = require("cmdDoublePress")
cmdDoublePress.timeFrame = 1
cmdDoublePress.action = function()
  -- launch  mission control with double tap of cmd
  hs.application.open('/Applications/Mission Control.app')
end

------------------
--  media keys  --
------------------

-- get the media keys to actually control itunes again...
MPD_COMMANDS = {PLAY = "toggle"; FAST = "next"; REWIND = "prev"}
AIRFOIL_EVENTS = {SOUND_UP = "+", SOUND_DOWN = "-"}
DEBUG_TAP = false
-- watching for special key presses
tap = hs.eventtap.new({hs.eventtap.event.types.NSSystemDefined}, function(event)
	if DEBUG_TAP then
		print("event tap debug got event:")
		print(hs.inspect.inspect(event:getRawEventData()))
		print(hs.inspect.inspect(event:getFlags()))
		print(hs.inspect.inspect(event:systemKey()))
	end

	local sys_key_event = event:systemKey()
	local delete_event  = false

	if not sys_key_event or not sys_key_event.down then
		return false
	elseif MPD_COMMANDS[sys_key_event.key] and not sys_key_event['repeat']
	then
		print("received media event" .. MPD_COMMANDS[sys_key_event.key])
		if MPD_COMMANDS[sys_key_event.key] == 'toggle' then
      hs.itunes.playpause()
    elseif MPD_COMMANDS[sys_key_event.key] == 'next' then
      hs.itunes.next()
    elseif MPD_COMMANDS[sys_key_event.key] == 'next' then
      hs.itunes.previous()
    end
	end
	return delete_event
end)
tap:start()

-------------------------------------------------------------------------------
--                                                                           --
--  spoons                                                                   --
--                                                                           --
-------------------------------------------------------------------------------
