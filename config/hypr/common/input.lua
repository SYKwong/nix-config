-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 1,
		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
		--xset r rate 200 35
		repeat_rate = 35,
		repeat_delay = 200,
		touchpad = {
			natural_scroll = true,
		},
	},
	cursor = {
		inactive_timeout = 1,
		no_hardware_cursors = true,
		persistent_warps = true,
	},
})
