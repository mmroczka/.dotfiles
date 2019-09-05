local log = hs.logger.new('init.lua', 'debug')

-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({'ctrl'}, '`', nil, function()
  hs.reload()
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

-- Vim = require('vim_bindings')
-- local v = Vim:new()
-- v:start()

vim = hs.loadSpoon('VimMode')


hs.hotkey.bind({'ctrl'}, ';', function()
  vim:enter()
end)

vim = hs.loadSpoon('VimMode')
vim:disableForApp('iTerm2')
vim:enableKeySequence('j', 'k')
vim:disableForApp('Code')

require('windows')
require('panes')

hs.notify.new({title='Hammerspoon', informativeText='Welcome back, Mr. Mroczka. Keyboard shortcuts have been enabled. 💪'}):send()
