local utils = {}

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

return utils
