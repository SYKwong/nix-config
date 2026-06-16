local utils = require("hyprland/common/utils")

hl.gesture({
	fingers = 4,
	direction = "vertical",
	action = "workspace",
})

hl.gesture({
	fingers = 4,
	direction = "left",
	action = utils.minimize_window(),
})

hl.gesture({
	fingers = 4,
	direction = "right",
	action = utils.restore_window(),
})

hl.gesture({
	fingers = 3,
	direction = "down",
	action = "close",
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "scroll_move",
})
