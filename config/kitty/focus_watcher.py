from typing import Any, Dict
from kitty.boss import Boss
from kitty.colors import parse_colors, patch_colors
from kitty.window import Window

ACTIVE_BG = "#1e1e2e"
ACTIVE_FG = "#cdd6f4"
INACTIVE_BG = "#11111b"
INACTIVE_FG = "#7f849c"

_active_colors, _ = parse_colors([f"background={ACTIVE_BG}", f"foreground={ACTIVE_FG}"])
_inactive_colors, _ = parse_colors([f"background={INACTIVE_BG}", f"foreground={INACTIVE_FG}"])


def on_focus_change(boss: Boss, window: Window, data: Dict[str, Any]) -> None:
    tab = next((t for t in boss.all_tabs if t.id == window.tab_id), None)
    if tab and len(tab) > 1:
        colors = _active_colors if data.get("focused") else _inactive_colors
    else:
        colors = _active_colors

    patch_colors(colors, windows=[window])
