-- Media key keybinds
-- Volume Control
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume raise"),
	{ repeating = true, description = "[Audio] Raise volume" }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume lower"),
	{ repeating = true, description = "[Audio] Lower volume" }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
	{ locked = true, description = "[Audio] Toggle mute" }
)

-- Screen Brightness
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("swayosd-client --brightness raise"),
	{ repeating = true, description = "[Display] Raise brightness" }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("swayosd-client --brightness lower"),
	{ repeating = true, description = "[Display] Lower brightness" }
)

-- Media Player Control (using playerctl)
hl.bind(
	"XF86AudioPlay",
	hl.dsp.exec_cmd(
		'playerctl play-pause && sleep 0.1 && [ "$(playerctl status)" = "Playing" ] && swayosd-client --custom-icon media-playback-start-symbolic || swayosd-client --custom-icon media-playback-pause-symbolic'
	),
	{ locked = true, description = "[Media] Toggle Play/Pause with OSD" }
)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "[Media] Next track" })
hl.bind(
	"XF86AudioPrev",
	hl.dsp.exec_cmd("playerctl previous"),
	{ locked = true, description = "[Media] Previous track" }
)
