local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'Papercolor Dark (Gogh)'
config.colors = {
    background = 'black',
}

config.enable_tab_bar = false

config.enable_scroll_bar = true

config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

config.font = wezterm.font('%(FONT)', { weight = '%(FONT_VARIANT)' })
config.font_size = %(FONT_SIZE)

return config
