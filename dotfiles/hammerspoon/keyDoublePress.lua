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
-- What we're looking for is 4 events within a set time period and no
-- intervening other key events:
--   flagsChanged with only [key] = true
--   flagsChanged with all = false
--   flagsChanged with only [key] = true
--   flagsChanged with all = false

local alert    = require("hs.alert")
local timer    = require("hs.timer")
local eventtap = require("hs.eventtap")

local module   = {}

local events = eventtap.event.types
local timeFirstKey, firstDown, secondDown = 0, false, false

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
    -- if it's been too long; previous state doesn't matter
    if (timer.secondsSinceEpoch() - timeFirstKey) > module.timeFrame then
        timeFirstKey, firstDown, secondDown = 0, false, false
    end

    if ev:getType() == events.flagsChanged then
        if noFlags(ev) and firstDown and secondDown then   -- [key] up and we've seen two, so do action
            if module.action then module.action() else fallbackAction() end
            timeFirstKey, firstDown, secondDown = 0, false, false
        elseif onlyKey(ev) and not firstDown then          -- [key] down and it's a first
            firstDown = true
            timeFirstKey = timer.secondsSinceEpoch()
        elseif onlyKey(ev) and firstDown then              -- [key] down and it's the second
            secondDown = true
        elseif not noFlags(ev) then                        -- otherwise reset and start over
            timeFirstKey, firstDown, secondDown = 0, false, false
        end
    else                                                   -- it was a key press, not a lone [key] char, we don't care about it
        timeFirstKey, firstDown, secondDown = 0, false, false
    end
    return false
end):start()

return module
