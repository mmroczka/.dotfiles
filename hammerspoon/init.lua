local flux = require "flux"
local inspect = require "inspect"
local log = hs.logger.new('init.lua', 'debug')

-- Use Control+` to reload Hammerspoon config
-- hs.hotkey.bind({'ctrl'}, '`', nil, function() hs.reload() hs.application.get("Hammerspoon"):selectMenuItem("Reload Config") end)

-- hs.hotkey.bind({'ctrl'}, '1', nil, function() hs.reload() hs.application.get("Hammerspoon"):selectMenuItem("Console...") hs.application.launchOrFocus("Hammerspoon") end)

hs.urlevent.bind("restartHammerSpoon", function(eventName, params) hs.reload() hs.application.get("Hammerspoon"):selectMenuItem("Reload Config") end)

flux.restoreScreen()

hs.loadSpoon("Lunette")
spoon.Lunette:bindWebHooks()

hs.loadSpoon("VimSpoon")
local v = spoon.VimSpoon:new()

v:setDebug(true) -- uncoment this if you want some things printed to the hammerspoon console
v:start()

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

hs.loadSpoon("MouseCircle")
spoon.MouseCircle:bindHotkeys({
    show = { { "alt" }, "f15" }
})

hs.notify.new({title='Hammerspoon', informativeText='Welcome back, Mr. Mroczka. Keyboard shortcuts have been enabled. 💪'}):send()

hs.loadSpoon("AllBrightness")
spoon.AllBrightness:start()

hs.urlevent.bind("CodeMode", function()
	hs.notify.new({title='Hammerspoon', informativeText='Code Mode'}):send()
end)

hs.urlevent.bind("Text-EditMode", function()
	hs.notify.new({title='Hammerspoon', informativeText='Text-Edit Mode'}):send()
end)

