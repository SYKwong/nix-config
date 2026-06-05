local terminal = "kitty"
local fileManager = "yazi"
local app_launcher = "pkill -x rofi || rofi -show drun"
local reload_waybar = "pkill waybar; waybar -c ~/.config/waybar/hyprland.jsonc &"
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

-- Media key keybinds
-- Volume Control
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume raise"),
	{ repeating = true, description = "[Audio] Raise volume" }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume lower"),
	{ repeating = true, description = "[Audio] Lower volume" }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
	{ locked = true, description = "[Audio] Toggle mute" }
)

-- Screen Brightness
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("swayosd-client --brightness raise"),
	{ repeating = true, description = "[Display] Raise brightness" }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("swayosd-client --brightness lower"),
	{ repeating = true, description = "[Display] Lower brightness" }
)

-- Media Player Control (using playerctl)
hl.bind(
	"XF86AudioPlay",
	hl.dsp.exec_cmd(
		'playerctl play-pause && sleep 0.1 && [ "$(playerctl status)" = "Playing" ] && swayosd-client --custom-icon media-playback-start-symbolic || swayosd-client --custom-icon media-playback-pause-symbolic'
	),
	{ locked = true, description = "[Media] Toggle Play/Pause with OSD" }
)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "[Media] Next track" })
hl.bind(
	"XF86AudioPrev",
	hl.dsp.exec_cmd("playerctl previous"),
	{ locked = true, description = "[Media] Previous track" }
)
