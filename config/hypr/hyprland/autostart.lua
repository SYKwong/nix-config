local function is_command_available(command_name)
	return os.execute("command -v " .. command_name .. " >/dev/null 2>&1") == true
end

hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm-app -- fcitx5 -r -d")
	hl.exec_cmd("uwsm-app -- foot --server")
	hl.exec_cmd("uwsm-app -- hyprsunset --identity")
	if is_command_available("steam") then
		hl.exec_cmd("uwsm-app -- steam -silent")
	end
	hl.exec_cmd("uwsm-app -- vesktop --start-minimized")
end)
