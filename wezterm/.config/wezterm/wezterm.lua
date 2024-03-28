local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.adjust_window_size_when_changing_font_size = false
config.audible_bell = "Disabled"
config.color_scheme = "Tokyo Night"
config.font = wezterm.font("Hack Nerd Font")
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

return config
