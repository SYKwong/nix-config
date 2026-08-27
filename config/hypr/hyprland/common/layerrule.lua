hl.layer_rule({
	name = "rofi_rules",
	match = {
		namespace = "rofi",
	},
	no_anim = true,
	blur = true,
	ignore_alpha = 0.1,
})

hl.layer_rule({
	name = "swaync_rules",
	match = {
		namespace = "swaync-control-center",
	},
	blur = true,
	ignore_alpha = 0.1,
})

hl.layer_rule({
	name = "noctalia",
	match = {
		namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
	},
	no_anim = true,
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})
