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

utils.maximized_workaround = function()
    local ws = hl.get_active_workspace().tiled_layout
    
    if ws == "scrolling" then
      hl.dispatch(hl.dsp.layout("colresize +conf"))
    else
      hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized" }))
    end
end

utils.layout_bind = function(bind_table)
  return function ()
    local workspace = hl.get_active_workspace()
    local layout = workspace.tiled_layout
               
    if bind_table[layout] then
      hl.dispatch(bind_table[layout])
    end
  end
end

function utils.load_workspace_states()
    local states = {}
    local f = io.open(state_file, "r")
    if not f then return states end
    
    local content = f:read("*all")
    f:close()
    
    for k, v in content:gmatch('"([^"]+)"%s*:%s*"([^"]+)"') do
        states[k] = v
    end
    return states
end

function utils.save_workspace_states(states)
    local f = io.open(state_file, "w")
    if not f then return end
    
    local json_parts = {}
    for k, v in pairs(states) do
        table.insert(json_parts, string.format('  "%s": "%s"', k, v))
    end
    
    f:write("{\n" .. table.concat(json_parts, ",\n") .. "\n}")
    f:close()
end

function utils.toggle_workspace_layout()
    local workspace = hl.get_active_workspace()
    local workspace_id = tostring(workspace.id)
    local states = utils.load_workspace_states()
    local current_layout = states[workspace_id] or workspace.layout or "master"
    local next_layout = (current_layout == "master") and "scrolling" or "master"
    
    states[workspace_id] = next_layout
    utils.save_workspace_states(states)
    
    hl.workspace_rule({ workspace = workspace_id, layout = next_layout })
    hl.exec_cmd(string.format(
        "notify-send -t 1500 -a 'Hyprland' -h boolean:transient:true 'Layout Changed' 'Workspace %d layout is now: %s'",
          workspace_id, next_layout))
end

function utils.cycle_window(direction)
  direction = direction or "next"

  if "next" == direction then
    return utils.layout_bind({
      scrolling = hl.dsp.layout("focus r"),
      dwindle   = hl.dsp.window.cycle_next({"next = true"}),
      monocle   = hl.dsp.layout("cyclenext"),
      master    = hl.dsp.layout("cyclenext")
    })
  else
    return utils.layout_bind({
    scrolling = hl.dsp.layout("focus l"),
    dwindle   = hl.dsp.window.cycle_next({"next = false"}),
    monocle   = hl.dsp.layout("cycleprev"),
    master    = hl.dsp.layout("cycleprev")
  })
  end
end

return utils
