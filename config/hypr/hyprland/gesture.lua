local utils = require("hyprland/utils")

hl.gesture({
	fingers = 3,
	direction = "up",
	action = utils.cycle_workspace("next"),
})

hl.gesture({
	fingers = 3,
	direction = "down",
	action = utils.cycle_workspace("prev"),
})

hl.gesture({
	fingers = 3,
	direction = "left",
	action = utils.cycle_window("next"),
})

hl.gesture({
	fingers = 3,
	direction = "right",
	action = utils.cycle_window("prev"),
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
