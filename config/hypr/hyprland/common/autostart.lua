local function dir_exists(path)
    if path:sub(-1) ~= "/" then path = path .. "/" end
    local f = io.open(path, "r")
    if f then 
        f:close() 
        return true 
    else 
        return false 
    end
end

hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user enable --now hyprpolkitagent.service")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("uwsm-app -- hypridle")
	hl.exec_cmd("uwsm-app -- waybar -c ~/.config/waybar/hyprland.jsonc")
	hl.exec_cmd("uwsm-app -- swayosd-server")
	hl.exec_cmd("uwsm-app -- foot --server")
	hl.exec_cmd("uwsm-app -- waydroid session start")
	hl.exec_cmd("uwsm-app -- fcitx5 -r -d")
  hl.exec_cmd("uwsm-app -- vesktop --start-minimized")

  local wallpaper_dir = os.getenv("HOME") .. "/Wallpaper/"

  if dir_exists(wallpaper_dir) then
    hl.exec_cmd("uwsm-app -- swaybg -i ~/Wallpaper/current_wallpaper -m fill")
  else
    hl.config({ misc = {disable_hyprland_logo = false} })
  end

end)
