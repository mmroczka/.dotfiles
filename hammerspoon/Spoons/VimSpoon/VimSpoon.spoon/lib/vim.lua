local c = require("hs.canvas")

function getTotalScreenNum()
	local numScreens = 0
	for i,v in ipairs(hs.screen.allScreens()) do
		numScreens = numScreens + 1
	end
	return numScreens
end

function createNormalHUD(x, y)
  return c.new{x=x, y=y,h=22, w=100}:appendElements({ action = "fill", fillColor = { red=.125, green=.464, blue=.968 }, type = "rectangle" }, { action = "clip", type="text", text="NORMAL", textSize=15, textAlignment="center", frame = { h = 22, w = 100, x = 0, y = 1 } })
end

function createInsertHUD(x, y)
  return c.new{x=x,y=y,h=22,w=100}:appendElements( { action = "fill", fillColor = { red=.40, green=.518, blue=.145 }, type = "rectangle"}, { action = "clip", type="text", text="INSERT", textSize=15, textAlignment="center", frame = { h = 22, w = 100, x = 0, y = 1 } })
end

function createVisualHUD(x, y)
  return c.new{x=x,y=y,h=22,w=100}:appendElements( { action = "fill", fillColor = { red=.651, green=.188, blue=.369 }, type = "rectangle"}, { action = "clip", type="text", text="VISUAL", textSize=15, textAlignment="center", frame = { h = 22, w = 100, x = 0, y = 1 } })
end

function createVisualBlockHUD(x, y)
  return c.new{x=x,y=y,h=22,w=100}:appendElements( { action = "fill", fillColor = { red=.651, green=.188, blue=.369 }, type = "rectangle"}, { action = "clip", type="text", text="V-BLOCK", textSize=15, textAlignment="center", frame = { h = 22, w = 100, x = 0, y = 1 } })
end

function createNavigationHUD(x, y)
  return c.new{x=x,y=y,h=22,w=100}:appendElements( { action = "fill", fillColor = { red=.951, green=.188, blue=.369 }, type = "rectangle"}, { action = "clip", type="text", text="NAVIGATION", textSize=15, textAlignment="center", frame = { h = 22, w = 100, x = 0, y = 1 } })
end

function buildHUD()
	local MODES = {
		lastMode = "NORMAL",
		normals = {},
		inserts = {},
		visuals = {},
		visualblocks = {},
		navigations = {}
	}
	local numOfEachHUDTOMake = getTotalScreenNum()
	-- build MODES
	table.insert(MODES.normals, { createNormalHUD(1155, 0), createNormalHUD(-1555, 0) });
	table.insert(MODES.inserts, { createInsertHUD(1155, 0), createInsertHUD(-1555, 0) });
	table.insert(MODES.visuals, { createVisualHUD(1155, 0), createVisualHUD(-1555, 0) });
	table.insert(MODES.visualblocks, { createVisualBlockHUD(1155, 0), createVisualBlockHUD(-1555, 0) });
	table.insert(MODES.navigations, { createNavigationHUD(1155, 0), createNavigationHUD(-1555, 0) });

	return MODES
end

function mergeArrays(ar1, ar2)
	-- add each array value to a table, and send the iteration at the end
	local tmp = {}
	for _, v in ipairs(ar1) do
		tmp[v] = true
	end
	for _, v2 in ipairs(ar2) do
		tmp[v2] = true
	end
	local output = {}
	for k, v in pairs(tmp) do
		table.insert(output, k)
	end
	return output
end

function mergeTables(t1, t2)
	local output = {}
	for k, v in pairs(t1) do
		if t2[k] == nil then
			output[k] = v
		else
			outpu[k] = t2[k]
		end
	end

	for k, v in pairs(t2) do
		if output[k] == nil then
			output[k] = v
		end
	end
	return output
end

function delayedKeyPress(mod, char, delay)
	-- if needed you can do a delayed keypress by `delay` seconds
	return hs.timer.delayed.new(delay, function ()
		keyPress(mod, char)
	end)
end

function keyPress(mod, char)
	-- press a key for 1ms
	hs.eventtap.keyStroke(mod, char, 100)
end

function keyPressFactory(mod, char)
	-- return a function to press a certain key for 20ms
	return function () keyPress(mod, char) end
end

function complexKeyPressFactory(mods, keys)
	-- mods and keys are arrays and have to be the same length
	return function ()
		for i, v in ipairs(keys) do
			keyPress(mods[i], keys[i])
		end
	end
end

function printTable(table)
	print('\t------------  TABLE   --------------')
	for index, data in ipairs(table) do
		print('\t------------> '.. index .. '  =  ' .. data)
	end
	print('\t------------ END TABLE --------------')
end

function printTableAndData(table)
	print('\t------------  TABLE   --------------')
	for index, data in ipairs(table) do
		for key, value in pairs(data) do
			print('\t', key, value)
		end
	end
	print('\t------------ END TABLE --------------')
end

local Vim = {}

function Vim:new()
	newObj = {
				state = 'normal',
				keyMods = {}, -- these are like cmd, alt, shift, etc...
				commandMods = nil, -- these are like d, y, c, r in normal mode
				numberMods = 0, -- for # times to do an action
				prevKey = '7',
				debug = true,
				events = 0, -- flag for # events to let by the event mngr
				modals = buildHUD(),
			}

	self.__index = self
	return setmetatable(newObj, self)
end

function Vim:setDebug(val)
	self.debug = val
end

function Vim:showDebug(log)
	if self.debug then
		print(log)
	end
end


function Vim:showModals(modals)
	for i,data in pairs(modals) do
		for key, value in ipairs(data) do
			value:show()
		end
	end
end

function Vim:hideModals(modalGroupsToHide)
	for key,group in ipairs(modalGroupsToHide) do
		for i,data in pairs(group) do
			for key, value in ipairs(data) do
				value:hide()
			end
		end
	end
end

function Vim:setModal(mode)
	if mode == "normal" then
		self:showModals(self.modals.normals)
		self:hideModals({self.modals.inserts, self.modals.visuals, self.modals.navigations, self.modals.visualblocks})
	elseif mode == "insert" then
		self:showModals(self.modals.inserts)
		self:hideModals({self.modals.normals, self.modals.visuals, self.modals.navigations, self.modals.visualblocks})
	elseif mode == "visual" then
		self:showModals(self.modals.visuals)
		self:hideModals({self.modals.normals, self.modals.inserts, self.modals.navigations, self.modals.visualblocks})
	elseif mode == "visualblock" then
		self:showModals(self.modals.visualblocks)
		self:hideModals({self.modals.normals, self.modals.inserts, self.modals.visuals, self.modals.navigations})
	elseif mode == "navigation" then
		self:showModals(self.modals.navigations)
		self:hideModals({self.modals.normals, self.modals.inserts, self.modals.visuals, self.modals.visualblocks})
	end
end

function Vim:start()
	local selfPointer = self

	self.modal = hs.urlevent.bind("enterVimSpoon", function(eventName, params)
		selfPointer:setMode('normal')
	end)

	self.modal = hs.urlevent.bind("enterNavigationMode", function(eventName, params)
		selfPointer:setMode('navigation')
	end)

	self.modal = hs.urlevent.bind("enterVimSpoonVisualMode", function(eventName, params)
		selfPointer:setMode('visual')
	end)

	self.modal = hs.urlevent.bind("enterVimSpoonVisualBlockMode", function(eventName, params)
		selfPointer:setMode('visualblock')
	end)

	self.modal = hs.urlevent.bind("enterVimSpoonInsertMode", function(eventName, params)
		selfPointer:setMode('insert')
		self:showDebug('Previous key -> ' .. self.prevKey)
	end)

	selfPointer:setMode('insert')
end



function Vim:handleKeyEvent(char, evt)
	-- check for text modifiers
	local modifiers = 'dcyrg'
	local stop_event = true -- stop event from propagating
	local keyMods = self.keyMods
	self:showDebug('\t--- handleKeyEvent -> '.. char)
	self:showDebug('\t--- handleKeyEvent -> previous key was --> '.. self.prevKey)
	if self.commandMods ~= nil and string.find('dcy', self.commandMods) ~= nil then
		-- using shift to delete and select things even in visual mode
		keyMods = mergeArrays(keyMods, {'shift'})
	end
	-- allows for visual mode too
	local movements = {
		D = complexKeyPressFactory({mergeArrays(keyMods, {'shift', 'cmd'}), keyMods}, {'right', 'delete'}),
		X = keyPressFactory(keyMods, 'delete'),
		['$'] = keyPressFactory(mergeArrays(keyMods, {'cmd'}), 'right'),
		['0'] = keyPressFactory(mergeArrays(keyMods, {'cmd'}), 'left'),
		b = keyPressFactory(mergeArrays(keyMods, {'alt'}), 'left'),
		e = keyPressFactory(mergeArrays(keyMods, {'alt'}), 'right'),
		h = keyPressFactory(keyMods, 'left'),
		j = keyPressFactory(keyMods, 'down'),
		k = keyPressFactory(keyMods, 'up'),
		l = keyPressFactory(keyMods, 'right'),
		w = complexKeyPressFactory({mergeArrays(keyMods, {'alt'}), keyMods}, {'right', 'right'}),
		x = keyPressFactory(keyMods, 'forwarddelete'),
	} -- movements to make

	local modifierKeys = {
		-- c = complexKeyPressFactory({{'cmd'}, {}, {}}, {'c', 'delete', 'i'}),
		-- d = complexKeyPressFactory({{'cmd'}, {}}, {'c', 'delete'}),
		-- r = complexKeyPressFactory({{}, {}}, {'forwarddelete', char}),
		y = complexKeyPressFactory({{'cmd'}, {}}, {'c', 'right'}),
	} -- keypresses for the modifiers after the movement

	local numEvents = {
		D = 2,
		X = 1,
		['$'] = 1,
		['0'] = 1,
		b = 1,
		c = 2,
		d = 2,
		e = 1,
		g = 2,
		h = 1,
		j = 1,
		k = 1,
		l = 1,
		r = 2,
		w = 2,
		x = 1,
		y = 2,
	} -- table of events the system has to let past for this

	if movements[char] ~= nil and self.commandMods ~= 'r' then
		-- do movement commands, but state-dependent
		self.events = numEvents[char]
		movements[char]() -- execute function assigned to this specific key
		stop_event = true
	elseif modifiers:find(char) ~= nil and self.commandMods == nil then -- if a modifier was pressed then turn that modifier on
		self:showDebug('\t--- handleKeyEvent: Modifier character: ' .. char)
		self.commandMods = char
		stop_event = true
		return stop_event
	end

	if self.commandMods ~= nil and modifiers:find(self.commandMods) ~= nil then
		-- do something related to modifiers
		-- run this block only after movement-related code
		self:showDebug('\t--- handleKeyEvent: Modifier in progress')
		if modifiers:find(char) == nil then
			self.events = self.events + numEvents[self.commandMods]
			modifierKeys[self.commandMods]()
			self.commandMods = nil
			-- reset
			self:setMode('normal')
		elseif char ~= 'r' and self.state == 'visual' then
			self.events = self.events + numEvents[self.commandMods]
			modifierKeys[self.commandMods]()
			self.commandMods = nil
			self:setMode('normal')
		end
	end

	if self.state == 'insert' then
		stop_event = false
	end
	self:showDebug("\t--- handleKeyEvent: Stop event = ".. tostring(stop_event))
	self.prevKey = char
	return stop_event
end

function Vim:eventWatcher(evt)
	-- stop an event from propagating through the event system
	local stop_event = true
	local evtChar = evt:getCharacters()
	local flags = evt:getFlags()
	local character = hs.keycodes.map[evt:getKeyCode()]
	local keyMods = self.keyMods

	self:showDebug('====== EventWatcher: pressed ' .. evtChar)
	local insertEvents = 'iIsaAoO'
	local commandMods = 'rcdyg'
	-- this function mostly handles the state-dependent events
	if self.events > 0 then
		self:showDebug('====== EventWatcher: event '.. self.events .. ' is occurring ')
		stop_event = false
		self.events = self.events - 1
	elseif evtChar == 'v' then
		-- if v key is hit, then go into visual mode
		self:setMode('visual')
		return stop_event
	elseif evtChar == ':' then
		-- do nothing for now because no ex mode
		self:setMode('ex')
		-- TODO: implement ex mode
	elseif evt:getKeyCode() == hs.keycodes.map['escape'] then
		-- get out of visual mode
		self:setMode('normal')
	elseif evtChar == 'u' then
		-- special undo key
		self.events = 1
		keyPress({'cmd'}, 'z')
	elseif character == 'r' and flags.ctrl then
		-- special redo key
		self.events = 1
		keyPress({'shift','cmd'}, 'z')
	elseif evtChar == 'C' then
		-- capital C
		self.events = 4
		complexKeyPressFactory({{'shift', 'cmd'}, {}}, {'right', 'delete'})()
		local selfRef = self
		hs.timer.delayed.new(0.01*self.events + 0.001, function ()
			selfRef:exitModal()
		end):start()
	elseif character == 'd' and flags.ctrl then
		-- scroll down
		self.events = 15
		for i = 0,15 do
		  keyPress(keyMods, 'down', 0)
		end
	elseif character == 'u' and flags.ctrl then
		-- scroll up
		self.events = 15
		for i = 0,15 do
		  keyPress(keyMods, 'up', 0)
		end
	elseif evtChar == 'p' then
		self.events = 1
		keyPress({'cmd'}, 'v')
		self:setMode('normal')
	elseif evtChar == 'P' then
		self.events = 3
		keyPress({'cmd'}, 'right')
		keyPress({}, 'return')
		keyPress({'cmd'}, 'v')
		self:setMode('normal')
	elseif evtChar == 'x' then
		self.events = 1
		keyPress(keyMods, 'forwarddelete')
		self:setMode('normal')
	elseif evtChar == 'X' then
		self.events = 1
		keyPress(keyMods, 'delete')
		self:setMode('normal')
	elseif evtChar == '/' then
		self.events = 1
		keyPress({'cmd'}, 'f')
		keyPress({}, 'i')
	elseif insertEvents:find(evtChar, 1, true) ~= nil and self.state == 'normal' and self.commandMods == nil then
		-- do the insert command
		self:showDebug('insertEvent occuring')
		self:insert(evtChar)
	elseif evtChar == 'G' then
		self.events = 1
		if self.state == 'normal' then
			keyPress({'cmd'}, 'down')
		else
			keyPress({'cmd', 'shift'}, 'down')
		end
	elseif evtChar == 'Y' then
		self.events = 3
		keyPress({'cmd', 'shift'}, 'right')
		keyPress({'cmd'}, 'c')
		keyPress({}, 'left')
	elseif self.state == 'normal' and self.commandMods == 'y' then
		-- wait for next key to determine what to yank
		self:showDebug('yankEvent is occuring')
		self:yank(evtChar)
	elseif (self.state == 'normal' or self.state == 'visual') and self.commandMods == 'g' then
		-- wait for next key to determine where to Go
		self:showDebug('GOTO event is occuring')
		self:goTo(evtChar)
	elseif self.state == 'normal' and self.commandMods == 'd' then
		-- wait for next key to determine what to delete
		self:showDebug('deleteEvent occuring')
		self:delete(evtChar)
	elseif self.state == 'normal' and self.commandMods == 'c' then
		-- wait for next key to determine what to change
		self:showDebug('changeEvent occuring')
		self:change(evtChar)
	elseif self.state == 'normal' and self.commandMods == 'r' then
		-- do the replace command
		self:showDebug('replaceEvent occuring')
		self:replace(evtChar, evt:getKeyCode())
	else
		-- anything else, literally
		self:showDebug('handling key press event for movement')
		stop_event = self:handleKeyEvent(evtChar, evt)
	end
	self:showDebug('====== EventWatcher: stop_event = ' .. tostring(stop_event).."\n\n")
	return stop_event
end

function Vim:insert(char)
	-- if is an insert event then do something
	-- ...
	self.events = 1
	if char == 's' then
		-- delete character and exit
		keyPress('', 'forwarddelete')
	elseif char == 'a' then
		keyPress('', 'right')
	elseif char == 'A' then
		keyPress({'cmd'}, 'right')
	elseif char == 'I' then
		keyPress({'cmd'}, 'left')
	elseif char == 'o' then
		self.events = 2
		complexKeyPressFactory({{'cmd'}, {}}, {'right', 'return'})()
	elseif char == 'O' then
		self.events = 3
		complexKeyPressFactory({{}, {'cmd'}, {}}, {'up', 'right', 'return'})()
	end

	local selfRef = self
	hs.timer.delayed.new(0.01*self.events + 0.001, function ()
		selfRef:exitModal()
	end):start()
end

function Vim:replace(char, keycode)
	self.events = 3
	if keycode == hs.keycodes.map['space'] then
		self.events = 2
		keyPress({}, 'forwarddelete')
		keyPress({}, 'space')
	else
		complexKeyPressFactory({{'cmd'}, {}, {}}, {'c', 'forwarddelete', char})()
	end
	local selfRef = self
	selfRef:setMode('normal')
end

function Vim:delete(char, keycode)
	self.events = 1
	local keyMods = self.keyMods
	if self.commandMods ~= nil and string.find('dcy', self.commandMods) ~= nil then
		-- using shift to delete and select things even in visual mode
		keyMods = mergeArrays(keyMods, {'shift'})
	end
	if char == 'd' then
		self.events = 5
		complexKeyPressFactory({{'cmd'}, {'shift', 'cmd'}, {}, {}, {}}, {'right', 'left', 'delete', 'delete', 'down'})()
	elseif char == 'w' then
		self.events = 3
		complexKeyPressFactory({mergeArrays(keyMods, {'alt'}), keyMods, keyMods}, {'right', 'right', 'delete'})()
	elseif char == 'e' then
		self.events = 2
		complexKeyPressFactory({mergeArrays(keyMods, {'alt'}), keyMods}, {'right', 'delete'})()
	elseif char == 'b' then
		self.events = 2
		complexKeyPressFactory({mergeArrays(keyMods, {'alt'}), keyMods}, {'left', 'delete'})()
	end

	local selfRef = self
	selfRef:setMode('normal')
end

function Vim:change(char, keycode)
	self.events = 3
	if char == 'c' then
		complexKeyPressFactory({{'cmd'}, {'shift', 'cmd'}, {}}, {'right', 'left', 'delete'})()
	end
	local selfRef = self
	hs.timer.delayed.new(0.01*self.events + 0.001, function ()
		selfRef:exitModal()
	end):start()
end

function Vim:goTo(char, keycode)
	self.events = 1
	if char == 'g' then
		if self.state == 'normal' then
			keyPress({'cmd'}, 'up')
		else
			keyPress({'cmd', 'shift'}, 'up')
		end
	end
	local selfRef = self
	selfRef:setMode('normal')
end

function Vim:yank(char)
	self.events = 4
	if char == 'y' then
		keyPress({'cmd'}, 'left')
		keyPress({'cmd', 'shift'}, 'right')
		keyPress({'cmd'}, 'c')
		keyPress({}, 'left')
	end
	local selfRef = self
	selfRef:setMode('normal')
end

function Vim:exitModal()
	self.modal:exit()
end

function Vim:resetEvents()
	self.events = 0
end

function Vim:setMode(val)
	self.state = val
	-- TODO: change any other flags that are important for visual mode changes
	if val == 'visual' then
		self.keyMods = {'shift'}
		self.commandMods = nil
		self.numberMods = 0
		self.moving = false
		self:setModal("visual")
	elseif val == 'visualblock' then
		self.keyMods = {'shift'}
		self.commandMods = nil
		self.numberMods = 0
		self.moving = false
		self:setModal("visualblock")
	elseif val == 'normal' then
		self.keyMods = {}
		self.commandMods = nil
		self.numberMods = 0
		self.moving = false
		self:setModal("normal")
	elseif val == 'navigation' then
		self:setModal("navigation")
	elseif val == 'ex' then
		-- do nothing because this is not implemented
	elseif val == 'insert' then
		self:setModal("insert")
		-- do nothing because this is a placeholder
		-- insert mode is mainly for pasting characters or eventually applying
		-- recordings
		-- TODO: implement the recording feature
	end
end

-- what are the characters that end visual mode? y, p, x, d, esc

-- TODO: future implementations could use composition instead
-- TODO: add an ex mode into the Vim class using the chooser API

function Vim:disableForApp(appName)
--   self.appWatcher:disableApp(appName)
end

return Vim
