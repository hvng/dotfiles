local wezterm = require("wezterm")
local config = wezterm.config_builder()
-- config.color_scheme = "Atom" -- catppuccin-mocha, Atom
config.enable_tab_bar = false
config.scrollback_lines = 100000
config.font_size = 16
config.font = wezterm.font_with_fallback({
	"Menlo",
})
config.window_decorations = "TITLE | RESIZE"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.keys = {
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.DisableDefaultAssignment,
	},
}

local bg_dir = wezterm.home_dir .. "/assets"
config.background = {
	{
		source = {
			-- File = bg_dir .. "/x.jpg",
			File = bg_dir .. "/y.jpg",
		},
		repeat_x = "NoRepeat",
		width = "100%",
		hsb = { brightness = 0.1 },
	},
}

return config
