local utils = {}
local state_file = "/tmp/hypr_workspace_layouts.json"

utils.get_hostname = function()
	local handle = io.popen("hostname -s")
	local host = handle and handle:read("*a"):gsub("%s+", "") or "fallback-host"
	if handle then
		handle:close()
	end
	return host
end

utils.kitty_term = [[
    ACTIVE_PID=$(hyprctl activewindow | awk '/pid:/ {print $2}')
    if [ -n "$ACTIVE_PID" ]; then
        CHILD_PID=$(pgrep -P "$ACTIVE_PID" | awk '{p2=p1; p1=$0} END{print p2}')
        if [ -n "$CHILD_PID" ]; then
            CWD=$(readlink /proc/$CHILD_PID/cwd)
        else
            CWD=$(readlink /proc/$ACTIVE_PID/cwd)
        fi
    fi
    kitty -d "${CWD:-$HOME}"
]]

function utils.maximized_workaround()
	return function()
		local window = hl.get_active_window()
		if not window then
			return
		end

		if window.floating then
			hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized" }))
			return
		end

		local layout = window.workspace.tiled_layout

		if layout == "scrolling" then
			local fullscreen_state = window.fullscreen
			if fullscreen_state == 2 then
				hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen" }))
			else
				hl.dispatch(hl.dsp.layout("colresize +conf"))
			end
		else
			hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized" }))
		end
	end
end

function utils.load_workspace_states()
	local states = {}
	local f = io.open(state_file, "r")
	if not f then
		return states
	end

	local content = f:read("*all")
	f:close()

	for k, v in content:gmatch('"([^"]+)"%s*:%s*"([^"]+)"') do
		states[k] = v
	end
	return states
end

function utils.save_workspace_states(states)
	local f = io.open(state_file, "w")
	if not f then
		return
	end

	local json_parts = {}
	for k, v in pairs(states) do
		table.insert(json_parts, string.format('  "%s": "%s"', k, v))
	end

	f:write("{\n" .. table.concat(json_parts, ",\n") .. "\n}")
	f:close()
end

function utils.toggle_workspace_layout()
	local workspace = hl.get_active_workspace()
	if not workspace then
		return
	end
	local workspace_id = tostring(workspace.id)
	local states = utils.load_workspace_states()
	local current_layout = states[workspace_id] or workspace.tiled_layout or "master"
	local next_layout = (current_layout == "master") and "scrolling" or "master"

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
	local filtered_windows = {}
	for _, w in ipairs(all_windows) do
		if w.workspace == target_workspace and not w.floating then
			table.insert(filtered_windows, w)
		end
	end
	return filtered_windows
end

local function sort_column_major(windows_list)
	table.sort(windows_list, function(a, b)
		local ax = tonumber(a.at.x)
		local ay = tonumber(a.at.y)
		local bx = tonumber(b.at.x)
		local by = tonumber(b.at.y)

		if ax == bx then
			return ay < by
		end
		return ax < bx
	end)
end

local function find_window_index(windows_list, target_address)
	for i, window in ipairs(windows_list) do
		if window.address == target_address then
			return i
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

local function cycle_scrolling(active, direction)
	local all_windows = hl.get_windows()
	local target_windows = get_tiled_windows_on_workspace(all_windows, active.workspace)

	if #target_windows <= 1 then
		return
	end

	sort_column_major(target_windows)

	local current_index = find_window_index(target_windows, active.address)
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

function _G.spawn_floating_app(app)
	local m = hl.get_active_monitor()
	if m then
		local w = math.floor(m.width * 0.7)
		local h = math.floor(m.height * 0.7)
		local uwsm_command = "uwsm app -- " .. app

		hl.dispatch(hl.dsp.exec_cmd(uwsm_command, { float = true, size = { w, h }, center = true }))
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

return utils
