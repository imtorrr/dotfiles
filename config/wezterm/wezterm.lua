local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

-- OS Detection
local is_darwin = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil
local is_windows = wezterm.target_triple:find("windows") ~= nil

-- Platform-specific defaults
if is_windows then
	config.default_domain = "WSL:Ubuntu-24.04"
end
config.default_cwd = wezterm.home_dir

-- Appearance
config.color_scheme = "Tokyo Night"
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular" })
config.font_size = is_darwin and 13 or 11
config.line_height = 1.1

-- Window
config.window_decorations = "RESIZE"
config.window_padding = {
	left = 8,
	right = 8,
	top = 8,
	bottom = 8,
}
config.initial_cols = 140
config.initial_rows = 38
config.window_background_opacity = 0.95
config.macos_window_background_blur = 30

-- Background gradient
config.window_background_gradient = {
	orientation = "Vertical",
	colors = {
		"#0f0c29",
		"#302b63",
		"#24243e",
	},
	interpolation = "Linear",
	blend = "Rgb",
	noise = 48,
	segment_size = 11,
	segment_smoothness = 1.0,
}

-- Tabs (minimal since tmux handles this)
config.enable_tab_bar = false
config.window_decorations = "RESIZE"

-- Cursor
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- Scrollback
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- Performance
config.animation_fps = 60
config.max_fps = 60
config.front_end = "WebGpu"

-- Key Bindings (minimal - tmux handles panes/windows)
local mod = is_darwin and "CMD" or "CTRL"

config.keys = {
	-- Font size
	{ key = "=", mods = mod, action = act.IncreaseFontSize },
	{ key = "-", mods = mod, action = act.DecreaseFontSize },
	{ key = "0", mods = mod, action = act.ResetFontSize },

	-- Copy/Paste
	{ key = "c", mods = mod, action = act.CopyTo("Clipboard") },
	{ key = "v", mods = mod, action = act.PasteFrom("Clipboard") },

	-- Search
	{ key = "f", mods = mod, action = act.Search("CurrentSelectionOrEmptyString") },

	-- Quick select (URL/hash/path picker)
	{ key = "Space", mods = mod, action = act.QuickSelect },

	-- Command palette
	{ key = "p", mods = mod .. "|SHIFT", action = act.ActivateCommandPalette },

	-- SSH launcher
	{ key = "s", mods = mod .. "|SHIFT", action = act.ShowLauncherArgs({ flags = "FUZZY|DOMAINS" }) },
}

-- SSH Domains
config.ssh_domains = {
	-- Example SSH domain configurations
	-- Uncomment and customize as needed
	-- {
	-- 	name = "example",
	-- 	remote_address = "example.com",
	-- 	username = "yourusername",
	-- 	-- remote_wezterm_path = "/path/to/wezterm", -- Optional: if wezterm is installed on remote
	-- },
	-- {
	-- 	name = "server",
	-- 	remote_address = "192.168.1.100",
	-- 	username = "yourusername",
	-- },
}

-- Quick select patterns
config.quick_select_patterns = {
	"https?://\\S+",
	"[0-9a-f]{7,40}",
	"[a-z0-9._-]+@[a-z0-9._-]+",
	"/[a-z0-9._-/]+",
}

-- Mouse bindings
config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = mod,
		action = act.OpenLinkAtMouseCursor,
	},
}

return config
