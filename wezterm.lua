-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- Themes you like include: ["pure"]
config.color_scheme = "Tokyo Night "

config.font_size = 22.0
-- config.window_decorations = "RESIZE"
config.window_background_opacity = 0.85
config.macos_window_background_blur = 80

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- and finally, return the configuration to wezterm
return config
