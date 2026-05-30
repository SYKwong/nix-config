local terminal = "kitty"
local fileManager = "yazi"
local app_launcher = "pkill -x rofi || rofi -show drun"
local reload_waybar = "pkill waybar; waybar -c ~/.config/waybar/hyprland.jsonc &"
local snip = 'grimblast -f copysave area && notify-send "Screenshot Saved to File and Clipboard"'
local snip_edit =
	'GRIMBLAST_EDITOR="satty --filename" grimblast edit area && notify-send "Screenshot Saved to File and Clipboard"'
local notification_center =  "swaync-client -t"

local mainMod = "SUPER"

local utils = require("hyprland/common/utils")

hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd(app_launcher))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("rofi-menu"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(utils.kitty_term))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(reload_waybar))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(snip))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(snip_edit))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(notification_center))
hl.bind(mainMod .. " + F", utils.maximized_workaround)
hl.bind(mainMod .. " + L", utils.toggle_layout, { description = "Toggle Master/Scrolling Layout" })

-- Cycle through workspace
hl.bind(mainMod .. " + TAB",         hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))

-- Alt Tab
hl.bind("ALT + TAB", hl.dsp.window.cycle_next(""))
hl.bind("ALT + TAB", hl.dsp.window.bring_to_top())
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next("prev"))
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.bring_to_top())

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move window with mainMod + SHIFT + arrow keys
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }))


-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Media key keybinds
-- Volume Control
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })

-- Screen Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { repeating = true })

-- Media Player Control (using playerctl)
hl.bind(
	"XF86AudioPlay",
	hl.dsp.exec_cmd(
		'playerctl play-pause && sleep 0.1 && [ "$(playerctl status)" = "Playing" ] && swayosd-client --custom-icon media-playback-start-symbolic || swayosd-client --custom-icon media-playback-pause-symbolic'
	),
	{ locked = true }
)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
