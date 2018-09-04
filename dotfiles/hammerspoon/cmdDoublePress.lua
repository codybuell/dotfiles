local alert    = require("hs.alert")
local timer    = require("hs.timer")
local eventtap = require("hs.eventtap")

local events   = eventtap.event.types

local module   = {}

-- Save this in your Hammerspoon configuration directiorn (~/.hammerspoon/) 
-- You either override timeFrame and action here or after including this file from another, e.g.
--
-- cmdDoublePress = require("cmdDoublePress")
-- cmdDoublePress.timeFrame = 2
-- cmdDoublePress.action = function()
--    do something special
-- end

-- how quickly must the two single cmd taps occur?
module.timeFrame = 1

-- what to do when the double tap of cmd occurs
module.action = function()
    alert("You double tapped cmd!")
end


-- Synopsis:

-- what we're looking for is 4 events within a set time period and no intervening other key events:
--  flagsChanged with only cmd = true
--  flagsChanged with all = false
--  flagsChanged with only cmd = true
--  flagsChanged with all = false


local timeFirstCmd, firstDown, secondDown = 0, false, false

-- verify that no keyboard flags are being pressed
local noFlags = function(ev)
    local result = true
    for k,v in pairs(ev:getFlags()) do
        if v then
            result = false
            break
        end
    end
    return result
end

-- verify that *only* the cmd key flag is being pressed
local onlyCmd = function(ev)
    local result = ev:getFlags().cmd
    for k,v in pairs(ev:getFlags()) do
        if k ~= "cmd" and v then
            result = false
            break
        end
    end
    return result
end

-- the actual workhorse

module.eventWatcher = eventtap.new({events.flagsChanged, events.keyDown}, function(ev)
    -- if it's been too long; previous state doesn't matter
    if (timer.secondsSinceEpoch() - timeFirstCmd) > module.timeFrame then
        timeFirstCmd, firstDown, secondDown = 0, false, false
    end

    if ev:getType() == events.flagsChanged then
        if noFlags(ev) and firstDown and secondDown then -- cmd up and we've seen two, so do action
            if module.action then module.action() end
            timeFirstCmd, firstDown, secondDown = 0, false, false
        elseif onlyCmd(ev) and not firstDown then         -- cmd down and it's a first
            firstDown = true
            timeFirstCmd = timer.secondsSinceEpoch()
        elseif onlyCmd(ev) and firstDown then             -- cmd down and it's the second
            secondDown = true
        elseif not noFlags(ev) then                        -- otherwise reset and start over
            timeFirstCmd, firstDown, secondDown = 0, false, false
        end
    else -- it was a key press, so not a lone cmd char -- we don't care about it
        timeFirstCmd, firstDown, secondDown = 0, false, false
    end
    return false
end):start()

return module
