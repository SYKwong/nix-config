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
