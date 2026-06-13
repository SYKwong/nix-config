hl.window_rule({
	name = "float-wrapped-tui",
	match = {
		class = "tui-float.*",
	},
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

hl.window_rule({
	name = "float-satty",
	match = {
		title = "satty",
	},
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

hl.window_rule({
	name = "waydroid",
	match = {
		class = "(?i)*waydroid.*",
	},
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

hl.window_rule({
	name = "vesktop_opacity",
	match = {
		class = "vesktop",
	},
	opacity = 0.9,
})

hl.window_rule({
	name = "media",
	match = {
		class = "^(qimgv|mpv)$",
	},
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

hl.window_rule({
	name = "Line",
	match = {
		class = "^(chrome-ophjlpahpchlmihnnnihgmmeilfjmjjc__index.html-Default)$",
	},
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
	workspace = "3 silent",
})
