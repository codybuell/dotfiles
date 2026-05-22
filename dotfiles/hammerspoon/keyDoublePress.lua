-- Key Double Press
--
-- Map a double press of the [key] key to an action. Save this in your
-- Hammerspoon configuration directory (~/.hammerspoon/) You either override
-- timeFrame and action here or after including this file from another, e.g.
--
--   keyDoublePress = require("keyDoublePress")
--   keyDoublePress.key = "cmd"
--   keyDoublePress.timeFrame = 2
--   keyDoublePress.action = function()
--      do something special
--   end
--
-- Allowed keys:
--   cmd
--   alt
--   shift
--   ctrl
--   fn
--
-- What we're looking for is 4 state transitions within a set time period
-- and no intervening other key events:
--   flagsChanged with only [key] = true   (first down)
--   flagsChanged with all = false         (first up)
--   flagsChanged with only [key] = true   (second down)
--   flagsChanged with all = false         (second up → fire action)
--
-- Duplicate events (e.g. from Universal Control) are absorbed by requiring
-- each transition to move to the next state — repeated downs or ups are
-- ignored rather than advancing the state machine.

local alert    = require("hs.alert")
local timer    = require("hs.timer")
local eventtap = require("hs.eventtap")

local module   = {}

local events = eventtap.event.types

-- states: 0=idle, 1=firstDown, 2=firstUp, 3=secondDown
local state = 0
local timeFirstKey = 0

-- default key to map if none specified
module.key = "cmd"

-- how quickly must the two single [key] taps occur
module.timeFrame = 1

-- what to do when the double tap of [key] occurs
local fallbackAction = function()
  alert("You double tapped " .. module.key .. "!")
end

-- verify that no keyboard flags are being pressed
local noFlags = function(ev)
  local result = true
  for _,v in pairs(ev:getFlags()) do
    if v then
      result = false
      break
    end
  end
  return result
end

-- verify that *only* the [key] key flag is being pressed
local onlyKey = function(ev)
  local result = ev:getFlags()[module.key]
  for k,v in pairs(ev:getFlags()) do
    if k ~= module.key and v then
      result = false
      break
    end
  end
  return result
end

-- setup the event tap watcher
module.eventWatcher = eventtap.new({events.flagsChanged, events.keyDown}, function(ev)
    -- if it's been too long, reset
    if (timer.secondsSinceEpoch() - timeFirstKey) > module.timeFrame then
        state = 0
        timeFirstKey = 0
    end

    if ev:getType() == events.flagsChanged then
        local keyDown = onlyKey(ev)
        local keyUp   = noFlags(ev)

        if keyDown and state == 0 then
            state = 1
            timeFirstKey = timer.secondsSinceEpoch()
        elseif keyUp and state == 1 then
            state = 2
        elseif keyDown and state == 2 then
            state = 3
        elseif keyUp and state == 3 then
            state = 0
            timeFirstKey = 0
            if module.action then module.action() else fallbackAction() end
        elseif not keyDown and not keyUp then
            state = 0
            timeFirstKey = 0
        end
        -- duplicate downs (keyDown in state 1 or 3) or duplicate ups
        -- (keyUp in state 0 or 2) are silently ignored
    else
        state = 0
        timeFirstKey = 0
    end
    return false
end):start()

return module
