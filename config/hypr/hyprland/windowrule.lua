-- =============================================================================
-- Display & Rendering
-- =============================================================================
hl.window_rule({
	name = "fullscreen-force-opaque",
	match = { fullscreen_state_client = 2 },
	force_rgbx = true,
	opaque = true,
})

-- =============================================================================
-- Centered Floating Windows
-- =============================================================================
local default_centered_float_size <const> = "(monitor_w*0.5) (monitor_h*0.5)"

local function apply_centered_float(rule_name, match_criteria, extra_properties)
	local rule_definition = {
		name = rule_name,
		match = match_criteria,
		float = true,
		center = true,
		size = default_centered_float_size,
	}
	if extra_properties then
		for property_key, property_value in pairs(extra_properties) do
			rule_definition[property_key] = property_value
		end
	end
	hl.window_rule(rule_definition)
end

local function float_and_center(window_address)
	local window_param = "address:" .. tostring(window_address)
	hl.dispatch(hl.dsp.window.float({ action = "set", window = window_param }))

	local monitor = hl.get_active_monitor()
	if monitor then
		local target_width <const> = math.floor((monitor.width / monitor.scale) * 0.5)
		local target_height <const> = math.floor((monitor.height / monitor.scale) * 0.5)
		hl.dispatch(hl.dsp.window.resize({
			x = target_width,
			y = target_height,
			relative = false,
			window = window_param,
		}))

		local center_x <const> = math.floor(monitor.x + target_width)
		local center_y <const> = math.floor(monitor.y + target_height)
		local cursor_delay_milliseconds <const> = 100

		hl.timer(function()
			hl.dispatch(hl.dsp.cursor.move({ x = center_x, y = center_y }))
		end, { timeout = cursor_delay_milliseconds, type = "oneshot" })
	end

	hl.dispatch(hl.dsp.window.center({ window = window_param }))
end

apply_centered_float("float-wrapped-tui", { class = "tui-float.*" })
apply_centered_float("media", { class = "^(qimgv|mpv)$" })
apply_centered_float("noctalia", { class = "dev.noctalia.Noctalia" })
apply_centered_float("zen-popups", { class = "zen-beta", initial_title = "^(Library|)" })

-- =============================================================================
-- Workspace Routing
-- =============================================================================
local function assign_workspace(rule_name, match_criteria, workspace_target, extra_properties)
	local rule_definition = {
		name = rule_name,
		match = match_criteria,
		workspace = workspace_target,
	}
	if extra_properties then
		for property_key, property_value in pairs(extra_properties) do
			rule_definition[property_key] = property_value
		end
	end
	hl.window_rule(rule_definition)
end

-- Workspace 1: Web browser
assign_workspace("browser", { class = "^(zen-beta|helium)$" }, 1)

-- Workspace 2: Terminal
assign_workspace("kitty", { class = "kitty" }, 2)

-- Workspace 3: Communication
local line_class <const> = "chrome-ophjlpahpchlmihnnnihgmmeilfjmjjc__index.html-Default"

assign_workspace("vesktop", { class = "vesktop" }, "3 silent", { opacity = 0.9 })
assign_workspace("line", { class = "^" .. line_class .. "$" }, "3 silent")

-- Automatically float secondary LINE instances (e.g. popout chats, dialogs)
hl.on("window.open", function(opened_window)
	if opened_window and opened_window.class == line_class then
		local all_windows = hl.get_windows()
		local line_window_count = 0
		for _, window in ipairs(all_windows) do
			if window.class == line_class then
				line_window_count = line_window_count + 1
			end
		end

		if line_window_count > 1 then
			float_and_center(opened_window.address)
		end
	end
end)

-- Workspace 4: Audio / Media
assign_workspace("amberol", { class = "io.bassi.Amberol" }, "4")
assign_workspace("feishin", { class = "feishin" }, "4")

-- =============================================================================
-- Gaming
-- =============================================================================
local gaming_workspace <const> = "5"

local function gaming_window(rule_name, match_criteria, extra_properties)
	assign_workspace(rule_name, match_criteria, gaming_workspace, extra_properties)
end

local function gaming_float(rule_name, match_criteria)
	apply_centered_float(rule_name, match_criteria, { workspace = gaming_workspace })
end

-- Steam client & games
gaming_window("steam", { class = "steam" })
gaming_window("steam-games", { initial_class = "^(steam_app_.*)$|^(gamescope)$" }, { maximize = true, float = false })
gaming_window("steam-subwindows", { class = "steam", title = "negative:^Steam$" }, { float = true, center = true })

-- Compatibility & Wine tools
gaming_float("protonfixes", { title = "ProtonFixes" })
gaming_float("protonqt", { class = "net.davidotek.pupgui2" })
gaming_float("protontricks", { title = "Protontricks" })
gaming_float("winetricks", { title = "^(Winetricks.*)$" })
