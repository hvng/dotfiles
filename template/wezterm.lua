local wezterm = require 'wezterm'
local common_path = wezterm.home_dir .. "/dotfiles/common/wezterm.lua"
local config = dofile(common_path)
return config
