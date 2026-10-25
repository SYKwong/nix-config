require("hyprland/autostart")
require("hyprland/environment")
require("hyprland/gesture")
require("hyprland/input")
require("hyprland/keybind")
require("hyprland/layerrule")
require("hyprland/layout")
require("hyprland/looknfeel")
require("hyprland/misc")
require("hyprland/plugin")
require("hyprland/windowrule")

local utils = require("hyprland/utils")
local workspacerule = require("hyprland/workspacerule")

-- For Noctalia Color templates
pcall(function()
	require("noctalia").apply_theme()
end)

local hosts = {
	framework16 = {
		monitor = {
			output = "eDP-1",
			mode = "2560x1600@165Hz",
			position = "0x0",
			scale = "1.0",
			cm = "dcip3",
		},
	},
	["mini-pc-k8"] = {
		monitor = {
			output = "HDMI-A-1",
			mode = "3840x2160@60Hz",
			position = "0x0",
			scale = "2",
		},
	},
	desktop = {
		monitor = { output = "DP-1", mode = "2560x1440@144", position = "0x0" },
	},
	laptop = {
		monitor = { output = "eDP-1", mode = "1920x1080@60", position = "0x0" },
	},
}

local hostname = utils.get_hostname()
local current_host = hosts[hostname] or {
	monitor = { output = "HDMI-1", mode = "1920x1080@60", position = "0x0" },
}

hl.monitor(current_host.monitor)

local secondary_monitor_top_reserved_gap = 20

hl.monitor({
	output = "HEADLESS-1",
	reserved_area = {
		top = secondary_monitor_top_reserved_gap,
		bottom = 0,
		left = 0,
		right = 0,
	},
})

for _, m in ipairs(hl.get_monitors()) do
	if m.name ~= current_host.monitor.output then
		local rate = math.floor((m.refresh_rate or m.refreshRate or 60) + 0.5)
		hl.monitor({
			output = m.name,
			mode = string.format("%dx%d@%dHz", m.width, m.height, rate),
			position = "auto-right",
			scale = tostring(m.scale),
			reserved_area = {
				top = secondary_monitor_top_reserved_gap,
				bottom = 0,
				left = 0,
				right = 0,
			},
		})
	end
end

workspacerule.setup(current_host.monitor.output)

local saved_states = utils.load_workspace_states()
for ws_id, layout_name in pairs(saved_states) do
	hl.workspace_rule({ workspace = ws_id, layout = layout_name })
end
