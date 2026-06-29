hl.window_rule({
	name = "float-wrapped-tui",
	match = { class = "tui-float.*" },
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

hl.window_rule({
	name = "float-satty",
	match = { title = "satty" },
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

hl.window_rule({
	name = "waydroid",
	match = { class = "(?i)*waydroid.*" },
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

hl.window_rule({
	name = "vesktop_opacity",
	match = { class = "vesktop" },
	opacity = 0.9,
})

hl.window_rule({
	name = "media",
	match = { class = "^(qimgv|mpv)$" },
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

hl.window_rule({
	name = "Line",
	match = { class = "^(chrome-ophjlpahpchlmihnnnihgmmeilfjmjjc__index.html-Default)$" },
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
	workspace = "3 silent",
})

hl.window_rule({
	name = "steam",
	match = {
		class = "steam",
		title = "negative:^Steam$",
	},
	float = true,
	center = true,
})

hl.window_rule({
	name = "steam games",
	match = { initial_class = "^(steam_app_.*)$|^(gamescope)$" },
	maximize = true,
	float = false,
})

hl.window_rule({
	name = "protonfixes",
	match = { title = "ProtonFixes" },
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

hl.window_rule({
	name = "protonqt",
	match = { class = "net.davidotek.pupgui2" },
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

hl.window_rule({
	name = "Protontricks",
	match = { title = "Protontricks" },
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

hl.window_rule({
	name = "Protontricks",
	match = { title = "^(Winetricks.*)$" },
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

hl.window_rule({
	name = "fullscreen-force-opaque",
	match = { fullscreen_state_client = 2 },
	force_rgbx = true,
	opaque = true,
})
