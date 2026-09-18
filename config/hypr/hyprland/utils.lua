local utils = {}
local state_file = "/tmp/hypr_workspace_layouts.json"
local saved_window_states = {}

function utils.get_hostname()
	local handle = io.popen("hostname -s")
	local hostname = handle and handle:read("*a"):gsub("%s+", "") or "fallback-host"
	if handle then
		handle:close()
	end
	return hostname
end

local function launch_kitty(session_filename)
	local command = [[
        get_kitty_cwd() {
            [ -n "$1" ] || return 0
            local child_pid
            child_pid=$(pgrep -P "$1" | awk '{p2=p1; p1=$0} END{print p2}')
            readlink "/proc/${child_pid:-$1}/cwd"
        }

        get_dolphin_cwd() {
            local title dir
            title=$(echo "$1" | jq -r '.title // empty')
            dir="${title% — Dolphin}"
            dir="${dir% - Dolphin}"
            echo "$dir"
        }

        ACTIVE_WINDOW=$(hyprctl activewindow -j)
        ACTIVE_PID=$(echo "$ACTIVE_WINDOW" | jq -r '.pid // empty')
        APP_CLASS=$(echo "$ACTIVE_WINDOW" | jq -r '.class // empty')

        case "$APP_CLASS" in
            kitty)            CWD=$(get_kitty_cwd "$ACTIVE_PID") ;;
            org.kde.dolphin)  CWD=$(get_dolphin_cwd "$ACTIVE_WINDOW") ;;
            *)                CWD="" ;;
        esac

        if [ -n "$CWD" ] && [ ! -d "$CWD" ]; then
            CWD=""
        fi
    ]]

	if session_filename then
		command = command
			.. [[
            if [ -z "$CWD" ] || [ "$CWD" = "$HOME" ]; then
               CWD="$HOME/nix-config"
            fi
            kitty -d "${CWD:-$HOME}" --session "$HOME/.config/kitty/]]
			.. session_filename
			.. '"\n'
	else
		command = command .. 'kitty -d "${CWD:-$HOME}"\n'
	end

	hl.dispatch(hl.dsp.exec_cmd(command))
end

function utils.kitty_term()
	return function()
		launch_kitty()
	end
end

function utils.kitty_3pane()
	return function()
		launch_kitty("three-pane.session")
	end
end

function utils.load_workspace_states()
	local states = {}
	local file = io.open(state_file, "r")
	if not file then
		return states
	end

	local content = file:read("*all")
	file:close()

	for workspace_id, layout_name in content:gmatch('"([^"]+)"%s*:%s*"([^"]+)"') do
		states[workspace_id] = layout_name
	end
	return states
end

function utils.save_workspace_states(states)
	local file = io.open(state_file, "w")
	if not file then
		return
	end

	local json_parts = {}
	for workspace_id, layout_name in pairs(states) do
		table.insert(json_parts, string.format('  "%s": "%s"', workspace_id, layout_name))
	end

	file:write("{\n" .. table.concat(json_parts, ",\n") .. "\n}")
	file:close()
end

function utils.toggle_workspace_layout()
	local default_layout <const> = "scrolling"
	local secondary_layout <const> = "master"

	local workspace = hl.get_active_workspace()
	if not workspace then
		return
	end
	local workspace_id = tostring(workspace.id)
	local states = utils.load_workspace_states()
	local current_layout = states[workspace_id] or workspace.tiled_layout or default_layout
	local next_layout = (current_layout == default_layout) and secondary_layout or default_layout

	states[workspace_id] = next_layout
	utils.save_workspace_states(states)

	hl.workspace_rule({ workspace = workspace_id, layout = next_layout })
	hl.exec_cmd(
		string.format(
			"notify-send -t 1500 -a 'Hyprland' -h boolean:transient:true 'Layout Changed' 'Workspace %d layout is now: %s'",
			workspace_id,
			next_layout
		)
	)
end

local function get_tiled_windows_on_workspace(all_windows, target_workspace)
	local target_workspace_id = target_workspace and target_workspace.id
	local filtered_windows = {}
	for _, window in ipairs(all_windows) do
		if window.workspace and window.workspace.id == target_workspace_id and not window.floating then
			table.insert(filtered_windows, window)
		end
	end
	return filtered_windows
end

local function sort_column_major(windows_list)
	table.sort(windows_list, function(window_a, window_b)
		local window_a_x = tonumber(window_a.at.x)
		local window_a_y = tonumber(window_a.at.y)
		local window_b_x = tonumber(window_b.at.x)
		local window_b_y = tonumber(window_b.at.y)

		if window_a_x == window_b_x then
			return window_a_y < window_b_y
		end
		return window_a_x < window_b_x
	end)
end

local function find_window_index(windows_list, target_address)
	for index, window in ipairs(windows_list) do
		if window.address == target_address then
			return index
		end
	end
	return nil
end

local function get_wrapped_index(current_index, list_length, direction)
	local target_index = current_index

	if direction == "next" then
		target_index = current_index + 1
		if target_index > list_length then
			target_index = 1
		end
	else
		target_index = current_index - 1
		if target_index < 1 then
			target_index = list_length
		end
	end

	return target_index
end

local function cycle_scrolling(active_window, direction)
	local all_windows = hl.get_windows()
	local target_windows = get_tiled_windows_on_workspace(all_windows, active_window.workspace)

	if #target_windows <= 1 then
		return
	end

	sort_column_major(target_windows)

	local current_index = find_window_index(target_windows, active_window.address)
	if not current_index then
		return
	end

	local target_index = get_wrapped_index(current_index, #target_windows, direction)

	local target_window = target_windows[target_index]
	if target_window and target_window.address then
		local target_param = "address:" .. tostring(target_window.address)
		hl.dispatch(hl.dsp.focus({ ["window"] = target_param }))
	end
end

function utils.cycle_window(direction)
	direction = direction or "next"

	return function()
		local active_window = hl.get_active_window()
		if not active_window then
			return
		end

		local active_workspace = active_window.workspace
		if not active_workspace then
			return
		end

		local layout = active_workspace.tiled_layout

		if active_window.floating then
			hl.dispatch(hl.dsp.window.cycle_next())
			return
		end

		if layout == "scrolling" then
			cycle_scrolling(active_window, direction)
			return
		end

		local binds = {}

		if direction == "next" then
			binds.dwindle = hl.dsp.window.cycle_next({ "next = true" })
			binds.monocle = hl.dsp.layout("cyclenext")
			binds.master = hl.dsp.layout("cyclenext")
		else
			binds.dwindle = hl.dsp.window.cycle_next({ "next = false" })
			binds.monocle = hl.dsp.layout("cycleprev")
			binds.master = hl.dsp.layout("cycleprev")
		end

		if binds[layout] then
			hl.dispatch(binds[layout])
		end
	end
end

local function unfullscreen_if_fullscreened(window)
	if window.fullscreen ~= 0 then
		local mode = (window.fullscreen == 2) and "fullscreen" or "maximized"
		hl.dispatch(hl.dsp.window.fullscreen({ mode = mode }))
		return true
	end
	return false
end

function utils.custom_fullscreen()
	return function()
		local window = hl.get_active_window()
		if not window then
			return
		end

		local layout = window.workspace and window.workspace.tiled_layout
		if window.floating or layout ~= "scrolling" then
			hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized" }))
			return
		end

		if unfullscreen_if_fullscreened(window) then
			return
		end

		local monitor = hl.get_active_monitor()
		if not monitor then
			return
		end

		local logical_monitor_width <const> = monitor.width / monitor.scale
		local fullscreen_ratio_threshold <const> = 0.875
		local width_ratio = window.size.x / logical_monitor_width
		if width_ratio >= fullscreen_ratio_threshold then
			local saved_state = saved_window_states[window.address]
			saved_window_states[window.address] = nil

			local default_unfullscreen_width <const> = 0.5
			local target_width = (saved_state and saved_state.width) or default_unfullscreen_width
			hl.dispatch(hl.dsp.layout("colresize " .. tostring(target_width)))

			local all_windows = hl.get_windows()
			local tiled_windows = get_tiled_windows_on_workspace(all_windows, window.workspace)
			local current_x = tonumber(window.at.x)

			local has_left_column = false
			for _, tiled_window in ipairs(tiled_windows) do
				if tonumber(tiled_window.at.x) < current_x then
					has_left_column = true
					break
				end
			end

			if has_left_column then
				hl.dispatch(hl.dsp.focus({ direction = "left" }))
				hl.dispatch(hl.dsp.focus({ window = "address:" .. tostring(window.address) }))
			end
		else
			local col_width_quarter <const> = 0.25
			local col_width_half <const> = 0.5
			local col_width_three_quarters <const> = 0.75
			local col_width_full <const> = 1.0

			local width_quarter_threshold <const> = 0.375
			local width_three_quarters_threshold <const> = 0.625
			local previous_width = col_width_half
			if width_ratio < width_quarter_threshold then
				previous_width = col_width_quarter
			elseif width_ratio > width_three_quarters_threshold then
				previous_width = col_width_three_quarters
			end

			saved_window_states[window.address] = {
				width = previous_width,
			}
			hl.dispatch(hl.dsp.layout("colresize " .. tostring(col_width_full)))
		end
	end
end

function _G.spawn_floating_app(application_command)
	local active_monitor = hl.get_active_monitor()
	if active_monitor then
		local window_width = math.floor(active_monitor.width * 0.7)
		local window_height = math.floor(active_monitor.height * 0.7)
		local uwsm_command = "uwsm app -- " .. application_command

		hl.dispatch(
			hl.dsp.exec_cmd(uwsm_command, { float = true, size = { window_width, window_height }, center = true })
		)
	end
end

function utils.scrolling_consume_expel(direction)
	direction = direction or "next"

	return function()
		local workspace = hl.get_active_workspace()
		if not workspace then
			return
		end

		local layout = workspace.tiled_layout

		if layout ~= "scrolling" then
			return
		end

		if "next" == direction then
			hl.dispatch(hl.dsp.layout("consume_or_expel next"))
		else
			hl.dispatch(hl.dsp.layout("consume_or_expel prev"))
		end
	end
end

function utils.minimize_window()
	return function()
		hl.dispatch(hl.dsp.window.move({ workspace = "special:minimize", follow = false }))
	end
end

function utils.restore_window()
	return function()
		local minimized_workspace = hl.get_workspace("special:minimize")
		if not minimized_workspace then
			return
		end

		hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
		hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
	end
end

return utils
