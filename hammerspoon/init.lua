local flux = require "flux"
local inspect = require "inspect"
local log = hs.logger.new('init.lua', 'debug')

-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({'ctrl'}, '`', nil, function() hs.reload() hs.application.get("Hammerspoon"):selectMenuItem("Reload Config") end)

hs.hotkey.bind({'ctrl'}, '1', nil, function() hs.reload() hs.application.get("Hammerspoon"):selectMenuItem("Console...") hs.application.launchOrFocus("Hammerspoon") end)

hs.urlevent.bind("restartHammerSpoon", function(eventName, params) hs.reload() hs.application.get("Hammerspoon"):selectMenuItem("Reload Config") end)

flux.restoreScreen()

hs.loadSpoon("Lunette")
spoon.Lunette:bindWebHooks()

hs.loadSpoon("Vim")
local v = spoon.Vim:new()

v:setDebug(true) -- uncoment this if you want some things printed to the hammerspoon console
v:start()

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

hs.notify.new({title='Hammerspoon', informativeText='Welcome back, Mr. Mroczka. Keyboard shortcuts have been enabled. 💪'}):send()
