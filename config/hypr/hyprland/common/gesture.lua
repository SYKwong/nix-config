local utils = require("hyprland/common/utils")

hl.gesture({
  fingers = 4,
  direction = "horizontal",
  action = "workspace"
})

hl.gesture({
    fingers = 3,
    direction = "left",
    action = utils.cycle_window("next")
})

hl.gesture({
    fingers = 3,
    direction = "right",
    action = utils.cycle_window("prev")
})
