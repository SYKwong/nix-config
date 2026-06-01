require("hyprland/common/environment")
require("hyprland/common/autostart")
require("hyprland/common/input")
require("hyprland/common/keybind")
require("hyprland/common/looknfeel")
require("hyprland/common/windowrule")
require("hyprland/common/layerrule")
require("hyprland/common/misc")

local utils = require("hyprland/common/utils")

local monitor_setting = {
	framework16 = function()
		hl.monitor({
			output = "eDP-1",
			mode = "2560x1600@165Hz",
			position = "auto",
			scale = "1.0",
		})
	end,
	desktop = function()
		hl.monitor({ output = "DP-1", mode = "2560x1440@144" })
	end,
	laptop = function()
		hl.monitor({ output = "eDP-1", mode = "1920x1080@60" })
	end,
}

local hostname = utils.get_hostname()
local host_monitor_setting = monitor_setting[hostname]

if host_monitor_setting then
	host_monitor_setting()
else
	hl.monitor({ output = "HDMI-1", mode = "1920x1080@60" })
end

local saved_states = utils.load_workspace_states()
for ws_id, layout_name in pairs(saved_states) do
  hl.workspace_rule({ workspace = ws_id, layout = layout_name })
end
