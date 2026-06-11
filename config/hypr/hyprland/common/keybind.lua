local terminal = "kitty"
local fileManager = "yazi"
local app_launcher = "pkill -x rofi || rofi -show drun"
local reload_waybar = "pkill waybar; waybar &"
local snip = 'grimblast -f copysave area && notify-send "Screenshot Saved to File and Clipboard"'
local snip_edit =
	'GRIMBLAST_EDITOR="satty --filename" grimblast edit area && notify-send "Screenshot Saved to File and Clipboard"'
local notification_center = "swaync-client -t"

local mainMod = "SUPER"

local utils = require("hyprland/common/utils")

-- Core Applications & Menus
hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd(app_launcher), { description = "[App] Launch Application Menu" })
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("rofi-menu"), { description = "[App] Launch Custom Rofi Menu" })
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(utils.kitty_term), { description = "[App] Launch Kitty Terminal" })
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(notification_center), { description = "[App] Toggle Notification Center" })

-- Window & System Management
hl.bind(mainMod .. " + W", hl.dsp.window.close(), { description = "[Window] Close active window" })
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(reload_waybar), { description = "[System] Reload Waybar configuration" })
hl.bind(mainMod .. " + F", utils.maximized_workaround, { description = "[Window] Maximize Window" })
hl.bind(
	mainMod .. " + SHIFT + F",
	hl.dsp.window.fullscreen({ mode = "fullscreen" }),
	{ description = "[Window] Fullscreen" }
)
hl.bind(
	mainMod .. " + L",
	utils.toggle_workspace_layout,
	{ description = "[Layout] Toggle layout of the current workspace" }
)

-- Screenshots
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(snip), { description = "[Screenshot] Capture area to file and clipboard" })
hl.bind(
	mainMod .. " + SHIFT + S",
	hl.dsp.exec_cmd(snip_edit),
	{ description = "[Screenshot] Capture area and edit with Satty" }
)

-- Workspace Cycling
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "e+1" }), { description = "[Workspace] Focus next workspace" })
hl.bind(
	mainMod .. " + SHIFT + TAB",
	hl.dsp.focus({ workspace = "e-1" }),
	{ description = "[Workspace] Focus previous workspace" }
)

-- Alt Tab (Window Cycling)
hl.bind("ALT + TAB", utils.cycle_window(), { description = "[Window] Cycle focus forward" })
hl.bind("ALT + SHIFT + TAB", utils.cycle_window("prev"), { description = "[Window] Cycle focus backward" })

-- Workspaces & Move Windows to Workspaces
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(
		mainMod .. " + " .. key,
		hl.dsp.focus({ workspace = i }),
		{ description = "[Workspace] Switch to workspace " .. i }
	)
	hl.bind(
		mainMod .. " + SHIFT + " .. key,
		hl.dsp.window.move({ workspace = i }),
		{ description = "[Workspace] Move active window to workspace " .. i }
	)
end

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), { description = "[Focus] Move focus left" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "[Focus] Move focus right" })
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), { description = "[Focus] Move focus up" })
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), { description = "[Focus] Move focus down" })

-- Move window with mainMod + SHIFT + arrow keys
hl.bind(
	mainMod .. " + SHIFT + left",
	hl.dsp.window.swap({ direction = "left" }),
	{ description = "[Window] Swap position left" }
)
hl.bind(
	mainMod .. " + SHIFT + right",
	hl.dsp.window.swap({ direction = "right" }),
	{ description = "[Window] Swap position right" }
)
hl.bind(
	mainMod .. " + SHIFT + up",
	hl.dsp.window.swap({ direction = "up" }),
	{ description = "[Window] Swap position up" }
)
hl.bind(
	mainMod .. " + SHIFT + down",
	hl.dsp.window.swap({ direction = "down" }),
	{ description = "[Window] Swap position down" }
)

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(
	mainMod .. " + mouse_down",
	hl.dsp.focus({ workspace = "e+1" }),
	{ description = "[Workspace] Scroll to next workspace" }
)
hl.bind(
	mainMod .. " + mouse_up",
	hl.dsp.focus({ workspace = "e-1" }),
	{ description = "[Workspace] Scroll to previous workspace" }
)

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { description = "[Mouse] Drag window to move" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { description = "[Mouse] Drag window to resize" })

-- Scrolling Only
-- Merge/Pop window from a column
hl.bind(
	mainMod .. " + comma",
	utils.scrolling_consume_expel("prev"),
	{ description = "[Window] Merge into the left column if alone, pops out if not" }
)
hl.bind(
	mainMod .. " + period",
	utils.scrolling_consume_expel("next"),
	{ description = "[Window] Merge into the right column if alone, pops out if not" }
)
