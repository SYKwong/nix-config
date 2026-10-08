-- Hyprland plugin configuration and loading

local plugin_candidates = {
	"/run/current-system/sw/lib/libscrolloverview.so",
}

local loaded_plugin = false
for _, path in ipairs(plugin_candidates) do
	local f = io.open(path, "r")
	if f then
		f:close()
		pcall(hl.plugin.load, path)
		loaded_plugin = true
		break
	end
end

if loaded_plugin and hl.plugin and hl.plugin.scrolloverview then
	hl.config({
		plugin = {
			scrolloverview = {
				gesture_distance = 150,
				scale = 0.5,
				workspace_gap = 20,
				layout = "auto",
				wallpaper = 2,
				blur = true,
				shadow = {
					enabled = true,
					range = 40,
				},
				input = {
					scroll_event_delay = 30,
					touchpad_scroll_factor = 2.0,
				},
			},
		},
	})

	-- Keybind
	hl.bind("SUPER + ALT + TAB", function()
		hl.plugin.scrolloverview.overview("toggle all")
	end, { description = "[Window] Niri-style overview / exposé" })

	-- Trackpad gesture
	hl.gesture({
		fingers = 3,
		direction = "up",
		action = function()
			hl.dispatch(hl.plugin.scrolloverview.overview("toggle all"))
		end,
	})

	-- Interactive keyboard and mouse submap while overview is open
	hl.define_submap("scrolloverview", function()
		-- Arrow navigation
		hl.bind("left", hl.plugin.scrolloverview.navigate("left"))
		hl.bind("right", hl.plugin.scrolloverview.navigate("right"))
		hl.bind("up", hl.plugin.scrolloverview.navigate("up"))
		hl.bind("down", hl.plugin.scrolloverview.navigate("down"))

		-- Vim navigation
		hl.bind("h", hl.plugin.scrolloverview.navigate("left"))
		hl.bind("l", hl.plugin.scrolloverview.navigate("right"))
		hl.bind("k", hl.plugin.scrolloverview.navigate("up"))
		hl.bind("j", hl.plugin.scrolloverview.navigate("down"))

		-- Selection & Exit
		hl.bind("return", hl.plugin.scrolloverview.overview("off"))
		hl.bind("kp_enter", hl.plugin.scrolloverview.overview("off"))
		hl.bind("escape", hl.plugin.scrolloverview.overview("off"))
		hl.bind("SUPER + ALT + TAB", hl.plugin.scrolloverview.overview("off"))

		-- Mouse controls
		hl.bind("mouse:272", function()
			hl.plugin.scrolloverview.overview("select")
			hl.plugin.scrolloverview.window("select")
			hl.plugin.scrolloverview.overview("off")
		end, { mouse = true })
		hl.bind("mouse:274", hl.plugin.scrolloverview.window("close"), { mouse = true })
	end)
end
