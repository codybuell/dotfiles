hs.grid.setGrid('12x12') -- allows us to place on quarters, thirds and halves
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.window.animationDuration = 0 -- disable animations

local screenCount = #hs.screen.allScreens()
local logLevel = 'info' -- generally want 'debug' or 'info'
local log = hs.logger.new('buell', logLevel)

local primaryScreen = hs.screen.primaryScreen()
local primaryMode   = primaryScreen:currentMode()
local primaryWidth  = primaryMode.w
local primaryHeight = primaryMode.h
local primaryWxH    = primaryMode.w .. "x" .. primaryMode.h
--log.i(primaryMode)

local grid = {
  -- x start, y start, dimension
  topHalf = '0,0 12x6',
  topThird = '0,0 12x4',
  topTwoThirds = '0,0 12x8',
  rightHalf = '6,0 6x12',
  rightThird = '8,0 4x12',
  rightTwoThirds = '4,0 8x12',
  bottomHalf = '0,6 12x6',
  bottomThird = '0,8 12x4',
  bottomTwoThirds = '0,4 12x8',
  leftHalf = '0,0 6x12',
  leftThird = '0,0 4x12',
  leftTwoThirds = '0,0 8x12',
  leftThreeQuarters = '0,0 9x12',
  laptopLeftThreeQuarters = '0,0 10x12',
  laptopLeftElevenTwewfths = '0,0 11x12',
  topLeft = '0,0 6x6',
  topRight = '6,0 6x6',
  bottomRight = '6,6 6x6',
  bottomLeft = '0,6 6x6',
  fullScreen = '0,0 12x12',
  centeredBig = '2,1 8x10',
  centeredSmall = '4,3 4x6',
  goldenLarge = '2,1 8x10',
  laptopGoldenLarge = '1,1 10x10',
  goldenSmall = '2,1 6x8',
  portraitLarge = '2,2 5x9',
  portraitSmall = '2,2 4x7',
}

local layoutConfig = {
  _before_ = (function()
    hide('com.spotify.client')
  end),

  _after_ = (function()
    -- make sure iterm appears in front of chrome
    activate('com.google.Chrome')
    activate('com.googlecode.iterm2')
  end),

  ['com.google.Chrome'] = (function(window, forceScreenCount)
--    local count = forceScreenCount or screenCount
--    if count == 1 then
--      hs.grid.set(window, grid.goldenLarge)
--    else
--      -- First/odd windows go on the RIGHT side of the screen.
--      -- Second/even windows go on the LEFT side.
--      -- (Note this is the opposite of what we do with Canary.)
--      local windows = windowCount(window:application())
--      local side = windows % 2 == 0 and grid.leftHalf or grid.rightHalf
--      hs.grid.set(window, side, hs.screen.primaryScreen())
--    end
    if primaryWxH == "1440x900" then
      hs.grid.set(window, grid.laptopGoldenLarge)
    else
      hs.grid.set(window, grid.goldenLarge)
    end
  end),

  ['com.google.Chrome.canary'] = (function(window, forceScreenCount)
    local count = forceScreenCount or screenCount
    if count == 1 then
      hs.grid.set(window, grid.fullScreen)
    else
      -- First/odd windows go on the LEFT side of the screen.
      -- Second/even windows go on the RIGHT side.
      -- (Note this is the opposite of what we do with Chrome.)
      local windows = windowCount(window:application())
      local side = windows % 2 == 0 and grid.rightHalf or grid.leftHalf
      hs.grid.set(window, side, hs.screen.primaryScreen())
    end
  end),

  ['com.googlecode.iterm2'] = (function(window, forceScreenCount)
--    local count = forceScreenCount or screenCount
--    if count == 1 then
--      hs.grid.set(window, grid.portraitSmall)
--    else
--      hs.grid.set(window, grid.leftHalf, hs.screen.primaryScreen())
--    end
    hs.grid.MARGINX = 6
    hs.grid.MARGINY = 5
    -- if laptop screen, improve with screen dpi density check?
    if primaryWxH == "1440x900" then
      hs.grid.set(window, grid.laptopLeftElevenTwewfths)
    else
      hs.grid.set(window, grid.leftThreeQuarters)
    end
    hs.grid.MARGINX = 0
    hs.grid.MARGINY = 0
  end),

}

--
-- Utility and helper functions.
--

-- Returns the number of standard, non-minimized windows in the application.
--
-- (For Chrome, which has two windows per visible window on screen, but only one
-- window per minimized window).
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

function hide(bundleID)
  local app = hs.application.get(bundleID)
  if app then
    app:hide()
  end
end

function activate(bundleID)
  local app = hs.application.get(bundleID)
  if app then
    app:activate()
  end
end

function canManageWindow(window)
  local application = window:application()
  local bundleID = application:bundleID()

  -- Special handling for iTerm: windows without title bars are
  -- non-standard.
  return window:isStandard() or
    bundleID == 'com.googlecode.iterm2'
end

function internalDisplay()
  -- Fun fact: this resolution matches both the 13" MacBook Air and the 15"
  -- (Retina) MacBook Pro.
  return hs.screen.find('1440x900')
end

function activateLayout(forceScreenCount)
  layoutConfig._before_()

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

  layoutConfig._after_()
end

--
-- Event-handling
--

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

hs.hotkey.bind({'ctrl', 'alt'}, 'up', chain({
  grid.topHalf,
  grid.topThird,
  grid.topTwoThirds,
}))

hs.hotkey.bind({'ctrl', 'alt'}, 'right', chain({
  grid.rightHalf,
  grid.rightThird,
  grid.rightTwoThirds,
}))

hs.hotkey.bind({'ctrl', 'alt'}, 'down', chain({
  grid.bottomHalf,
  grid.bottomThird,
  grid.bottomTwoThirds,
}))

hs.hotkey.bind({'ctrl', 'alt'}, 'left', chain({
  grid.leftHalf,
  grid.leftThird,
  grid.leftTwoThirds,
}))

hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'up', chain({
  grid.topLeft,
  grid.topRight,
  grid.bottomRight,
  grid.bottomLeft,
}))

if primaryWxH == "1440x900" then
  hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'down', chain({
    grid.fullScreen,
    grid.laptopGoldenLarge,
    grid.centeredSmall,
  }))
else
  hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'down', chain({
    grid.fullScreen,
    grid.centeredBig,
    grid.centeredSmall,
  }))
end

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

--
-- Control Double Press
--

ctrlDoublePress = require("ctrlDoublePress")
ctrlDoublePress.timeFrame = 2
ctrlDoublePress.action = function()
  hs.application.open('/Applications/Mission Control.app')
end

--
-- Cmd Double Press
--

cmdDoublePress = require("cmdDoublePress")
cmdDoublePress.timeFrame = 2
cmdDoublePress.action = function()
  hs.application.open('/Applications/Mission Control.app')
end

--
-- Command Key Press (if cmd + key do that, else if cmd down and up with no modifier do our stuff)
--

-- local module = {}
-- module.showPopUp = false
-- module.leftCmdLayout = "English - Ilya Birman Typography"
-- module.rightCmdLayout = "Russian - Ilya Birman Typography"
-- 
-- 
-- module.eventwatcher1 = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(e)
-- 
--     local flags = e:getFlags()
-- 
--     if flags.cmd
--        and not (flags.alt or flags.shift or flags.ctrl or flags.fn)
--     then
--         module.cmdWasPressed = true
--         module.cmdShouldBeIgnored = false
--         return false;
--     end
-- 
--     if flags.cmd
--        and (flags.alt or flags.shift or flags.ctrl or flags.fn)
--        and module.cmdWasPressed
--     then
--         module.cmdShouldBeIgnored = true
--         return false;
--     end
-- 
--     if not flags.cmd
--     then
--         if module.cmdWasPressed
--        and not module.cmdShouldBeIgnored
--         then
--             local keyCode = e:getKeyCode()
-- 
--             if keyCode == 0x37 then
--                 hs.application.open('/Applications/Mission Control.app')
--                 -- hs.keycodes.setLayout(module.leftCmdLayout)
-- 
--         if module.showPopUp then
--             hs.alert.show("English", 0.2)
--         end
-- 
--         -- elseif keyCode == 0x36 then
--         --     hs.application.open('/Applications/Mission Control.app')
--         --     -- hs.keycodes.setLayout(module.rightCmdLayout)
-- 
--         -- if module.showPopUp then
--         --     hs.alert.show("Russian", 0.2)
--         -- end
--         end
--     end
-- 
--     module.cmdWasPressed = false
--     module.cmdShouldBeIgnored = false
--     end
-- 
--     return false;
-- end):start()
-- 
-- 
-- module.eventwatcher2 = hs.eventtap.new({"all", hs.eventtap.event.types.flagsChanged}, function(e)
-- 
--     local flags = e:getFlags()
-- 
--     if flags.cmd and module.cmdWasPressed then
--     module.cmdShouldBeIgnored = true
--     end
-- 
--     return false;
-- end):start()
