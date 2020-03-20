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

local HUD_TEXT = 'NORMAL'

local c = require("hs.canvas")
local NORMAL= c.new{x=1155,y=0,h=22,w=100}:appendElements( { action = "fill", fillColor = { red=.125, green=.464, blue=.968 }, type = "rectangle"}, { action = "clip", type="text", text="NORMAL", textSize=15, textAlignment="center", frame = { h = 22, w = 100, x = 0, y = 1 } })
local INSERT = c.new{x=1155,y=0,h=22,w=100}:appendElements( { action = "fill", fillColor = { red=.40, green=.518, blue=.145 }, type = "rectangle"}, { action = "clip", type="text", text="INSERT", textSize=15, textAlignment="center", frame = { h = 22, w = 100, x = 0, y = 1 } })
local VISUAL = c.new{x=1155,y=0,h=22,w=100}:appendElements( { action = "fill", fillColor = { red=.651, green=.188, blue=.369 }, type = "rectangle"}, { action = "clip", type="text", text="VISUAL", textSize=15, textAlignment="center", frame = { h = 22, w = 100, x = 0, y = 1 } })

local function getTotalScreenNum()
	local numScreens = 0
	for i,v in ipairs(hs.screen.allScreens()) do
		numScreens = numScreens + 1
	end
	return numScreens
end

local function buildHUDs()
	local MODES = {}
	local NORMALS = {}
	local VISUALS = {}
	local INSERTS = {}
	local numOfEachHUDTOMake = getTotalScreenNum()

	-- build MODES
	if numOfEachHUDTOMake == 2 then
		table.insert(NORMALS, c.new{x=1155,y=0,h=22,w=100}:appendElements( { action = "fill", fillColor = { red=.125, green=.464, blue=.968 }, type = "rectangle"}, { action = "clip", type="text", text="NORMAL", textSize=15, textAlignment="center", frame = { h = 22, w = 100, x = 0, y = 1 } }))
		table.insert(NORMALS, c.new{x=-1455,y=0,h=22,w=100}:appendElements( { action = "fill", fillColor = { red=.125, green=.464, blue=.968 }, type = "rectangle"}, { action = "clip", type="text", text="NORMAL", textSize=15, textAlignment="center", frame = { h = 22, w = 100, x = 0, y = 1 } }))
		table.insert(INSERTS, c.new{x=1155,y=0,h=22,w=100}:appendElements( { action = "fill", fillColor = { red=.40, green=.518, blue=.145 }, type = "rectangle"}, { action = "clip", type="text", text="INSERT", textSize=15, textAlignment="center", frame = { h = 22, w = 100, x = 0, y = 1 } }))
		table.insert(INSERTS, c.new{x=-1455,y=0,h=22,w=100}:appendElements( { action = "fill", fillColor = { red=.40, green=.518, blue=.145 }, type = "rectangle"}, { action = "clip", type="text", text="INSERT", textSize=15, textAlignment="center", frame = { h = 22, w = 100, x = 0, y = 1 } }))
	end

	table.insert(MODES, NORMALS)
	table.insert(MODES, INSERTS)
	for i,mode in ipairs(MODES) do
		for j,attr in ipairs(mode) do
			for k,ele in ipairs(attr) do
				print(inspect(ele))
			end
		end
	end
end

hs.urlevent.bind('VIM_MODE', function(eventName, params)
	if params["mode"] then
		mode = params["mode"]
		if mode ==  "NORMAL" then
			for i,v in ipairs(hs.screen.allScreens()) do
				print(inspect(i))
				print(inspect(v))
				hs.alert.show("NORMAL")
			end
			NORMAL:show()
			VISUAL:hide()
			INSERT:hide()
		elseif mode ==  "VISUAL" then
			for i,v in ipairs(hs.screen.allScreens()) do
				print(inspect(i))
				print(inspect(v))
				hs.alert.show("VISUAL")
			end
			NORMAL:hide()
			VISUAL:show()
			INSERT:hide()
		elseif mode ==  "INSERT" then
			for i,v in ipairs(hs.screen.allScreens()) do
				print(inspect("SCREEN " .. i))
				print(inspect(v))
				local mainRes = v:fullFrame()
				print(inspect(mainRes))
				hs.alert.show("INSERT", nil, v, 8)
			end
			NORMAL:hide()
			VISUAL:hide()
			INSERT:show()
		else
			hs.alert.show("WRONG PARAMETER IN URI")
		end
	end
end)


buildHUDs()


-- Bypass programs that won't let you paste into them by grabbing the clipboard's top contents and typing them "manually" with hammerspoon
-- hs.hotkey.bind({"cmd", "ctrl"}, "V", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)


-- automatic configuration reload
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

hs.notify.new({title='Hammerspoon', informativeText='Welcome back, Mr. Mroczka. Keyboard shortcuts have been enabled. 💪'}):send()
