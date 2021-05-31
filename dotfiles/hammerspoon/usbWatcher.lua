-- unset usbwatcher
local usbWatcher = nil

function usbDeviceCallback(data)
  -------------------
  --  general usb  --
  -------------------
  if (data["eventType"] == "added") then
    -- usb device has been connected
    -- hs.notify.show("USB", "Device connected", data["productName"])
  elseif (data["eventType"] == "removed") then
    -- usb device has been removed
    -- hs.notify.show("USB", "Device removed", data["productName"])
  end
    
  ---------------
  --  yubikey  --
  ---------------
  if string.match(data["productName"], "Yubikey") then
    if (data["eventType"] == "added") then
      -- wake the screen up
      -- os.execute("caffeinate -u -t 5")
      -- hack to activiate gpg card on yubikey
      os.execute("gpg --card-status > /dev/null")
      local pinentry = hs.dialog.textPrompt('please enter your pin', 'gpg pin', '', 'ok', 'cancel', true)
      -- hack to prompt for pin and cache for period of time
      -- os.execute("gpg -d ~/.gnupg/foo.gpg &> /dev/null")
      -- os.execute("osascript -e 'tell application \"Terminal\" to do script \"gpg -d ~/.gnupg/foo.gpg &> /dev/null\"'")
    elseif (data["eventType"] == "removed") then
      -- kill any pin caching (force gpg to reprompt for pin on next entry)
      -- os.execute("gpgconf --reload")
      -- hs.messages.iMessage("+000000000000", "Your Yubikey was just removed from your Work iMac.")
      -- os.execute("pmset displaysleepnow")
    end
  end
end

-- register the callback and start the usb watcher
usbWatcher = hs.usb.watcher.new(usbDeviceCallback)
usbWatcher:start()
