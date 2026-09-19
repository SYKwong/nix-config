local utils = require("hyprland/utils")

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

local function app_launcher()
	local command = "noctalia msg panel-toggle launcher"
	hl.dispatch(hl.dsp.exec_cmd(command))
end

hl.gesture({
	fingers = 3,
	direction = "up",
	action = app_launcher,
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
