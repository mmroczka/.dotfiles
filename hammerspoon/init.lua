local flux = require "flux"
local inspect = require "inspect"
local log = hs.logger.new('init.lua', 'debug')

-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({'ctrl'}, '`', nil, function()
  hs.reload()
  hs.application.get("Hammerspoon"):selectMenuItem("Console...")
  hs.application.launchOrFocus("Hammerspoon")
end)

keyUpDown = function(modifiers, key)
  -- Un-comment & reload config to log each keystroke that we're triggering
  -- log.d('Sending keystroke:', hs.inspect(modifiers), key)

  hs.eventtap.keyStroke(modifiers, key, 0)
end

-- Subscribe to the necessary events on the given window filter such that the
-- given hotkey is enabled for windows that match the window filter and disabled
-- for windows that don't match the window filter.
--
-- windowFilter - An hs.window.filter object describing the windows for which
--                the hotkey should be enabled.
-- hotkey       - The hs.hotkey object to enable/disable.
--
-- Returns nothing.
enableHotkeyForWindowsMatchingFilter = function(windowFilter, hotkey)
  windowFilter:subscribe(hs.window.filter.windowFocused, function()
    hotkey:enable()
  end)

  windowFilter:subscribe(hs.window.filter.windowUnfocused, function()
    hotkey:disable()
  end)
end

local HYPER = {"ctrl", "option", "cmd", "shift"}


flux.restoreScreen()

hs.loadSpoon("Lunette")

spoon.Lunette:bindWebHooks()


-- example of how to load the vim-bindings file into your hammerspoon init

-- put vim_bindings.lua in your ~/.hammerspoon/ directory
hs.loadSpoon("Vim")
local v = spoon.Vim:new()

-- vim:disableForApp('Code')
-- vim:disableForApp('iTerm')
v:setDebug(true) -- uncoment this if you want some things printed to the hammerspoon console
v:start()

-- automatic configuration reload
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

hs.notify.new({title='Hammerspoon', informativeText='Welcome back, Mr. Mroczka. Keyboard shortcuts have been enabled. 💪'}):send()
