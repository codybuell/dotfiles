-- Media Keys
--
-- Override media keys.  Used to control iTunes / Music app ONLY!! Also allows
-- you to actually pause the music with the play/pause button when receiving a
-- phone call, which for god only knows why, you can't do natively in OSX.
--
-- This has to exist as a separate module and imported with require() in your
-- .hamerspoon/init.lua file due to some bug that causes eventtaps to not work
-- when a grid is set or used in any way. Running it as a module however seems
-- to work without any issues.

local eventtap = require("hs.eventtap")

local module = {}

local events = eventtap.event.types

local musicMediaKeys = function(event)
  local data = event:systemKey()

  if DEBUG and data["key"] then
    -- log the key pressed
    print("key pressed: " .. data["key"])
  end

  -- ignore everything but media keys
  if data["key"] ~= "PLAY" and data["key"] ~= "NEXT" and data["key"] ~= "PREVIOUS" then
    return false, nil
  end

  -- handle action
  if data["down"] == false or data["repeat"] == true then
    if data["key"] == "PLAY" then
      if DEBUG then
        print("executing playpause")
      end
      hs.itunes.playpause()
      -- hs.applescript('tell application "Music" to playpause')
    elseif data["key"] == "NEXT" then
      if DEBUG then
        print("executing next")
      end
      hs.itunes.next()
      -- hs.applescript('tell application "Music" to next track')
    elseif data["key"] == "PREVIOUS" then
      if DEBUG then
        print("executing previous")
      end
      hs.itunes.previous()
      -- hs.applescript('tell application "Music" to previous track')
    end
  end

  -- consume event
  return true
end

module.eventWatcher = eventtap.new({events.systemDefined}, musicMediaKeys):start()

return module
