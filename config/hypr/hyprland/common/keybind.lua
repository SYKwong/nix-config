local terminal = "kitty"
local fileManager = "yazi"

local noc = "noctalia msg "
local app_launcher = noc .. "panel-toggle launcher"
local snip = noc .. "screenshot-region"

local volume_toggle = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
local volume_up = noc .. "volume-up"
local volume_down = noc .. "volume-down"

local brightness_up = noc .. "brightness-up"
local brightness_down = noc .. "brightness-down"

local media_toggle = noc .. "media toggle"
local media_next = noc .. "media next"
local media_prev = noc .. "media previous"

local lock_screen = noc .. "session lock"
local session_menu = noc .. "panel-toggle session"

local mainMod = "SUPER"

local utils = require("hyprland/common/utils")

-- Core Applications & Menus
hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd(app_launcher), { description = "[App] Launch Application Menu" })
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(utils.kitty_term), { description = "[App] Launch Kitty Terminal" })

-- Window & System Management
hl.bind(mainMod .. " + W", hl.dsp.window.close(), { description = "[Window] Close active window" })
hl.bind(
	mainMod .. " + F",
	hl.dsp.window.fullscreen({ mode = "maximized" }),
	{ description = "[Window] Maximize Window" }
)
hl.bind(
	mainMod .. " + SHIFT + F",
	hl.dsp.window.fullscreen({ mode = "fullscreen" }),
	{ description = "[Window] Fullscreen" }
)
hl.bind(
	mainMod .. " + SEMICOLON",
	utils.toggle_workspace_layout,
	{ description = "[Layout] Toggle layout of the current workspace" }
)
hl.bind(mainMod .. " + slash", hl.dsp.layout("colresize +conf"), { description = "[Layout] (Scrolling) Resize column" })

-- Screenshots
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(snip), { description = "[Screenshot] Capture area to file and clipboard" })

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

hl.bind(mainMod .. " + M ", utils.minimize_window(), { description = "[Window] Minimize window to a stack" })
hl.bind(
	mainMod .. " + SHIFT + M",
	utils.restore_window(),
	{ description = "[Window] Restore minimized window from the stack" }
)

-- Power
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(lock_screen), { description = "[Power] Lock Screen" })

hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd(session_menu), { description = "[Power] Session Menu" })

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(volume_up), { repeating = true, description = "[Audio] Raise volume" })
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(volume_down),
	{ repeating = true, description = "[Audio] Lower volume" }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(volume_toggle), { locked = true, description = "[Audio] Toggle mute" })

-- Screen Brightness
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd(brightness_up),
	{ repeating = true, description = "[Display] Raise brightness" }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd(brightness_down),
	{ repeating = true, description = "[Display] Lower brightness" }
)

-- Media Player Control (using playerctl)
hl.bind(
	"XF86AudioPlay",
	hl.dsp.exec_cmd(media_toggle),
	{ locked = true, description = "[Media] Toggle Play/Pause with OSD" }
)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(media_next), { locked = true, description = "[Media] Next track" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(media_prev), { locked = true, description = "[Media] Previous track" })
