hl.layer_rule({
	name = "noctalia",
	match = {
		namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
	},
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})
