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
		class = "Waydroid",
	},
	float = true,
	center = true,
	size = "(monitor_w*0.5) (monitor_h*0.5)",
})

hl.window_rule({
	name = "waydroid-app",
	match = {
		class = "waydroid.*",
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
  opacity = 0.9
})
