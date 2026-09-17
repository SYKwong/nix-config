from collections.abc import Iterable
from typing import Any, Dict
from kitty.boss import Boss
from kitty.borders import Border, BorderColor, Borders, add_borders
from kitty.colors import parse_colors, patch_colors
from kitty.fast_data_types import current_focused_os_window_id, get_options, set_borders_rects
from kitty.layout.base import blank_rects_for_window
from kitty.typing_compat import LayoutType
from kitty.utils import color_as_int
from kitty.window import Window
from kitty.window_list import WindowList

ACTIVE_BG = "#1e1e2e"
ACTIVE_FG = "#cdd6f4"
INACTIVE_BG = "#11111b"
INACTIVE_FG = "#7f849c"

_active_colors, _ = parse_colors([f"background={ACTIVE_BG}", f"foreground={ACTIVE_FG}"])
_inactive_colors, _ = parse_colors([f"background={INACTIVE_BG}", f"foreground={INACTIVE_FG}"])

if not getattr(Window, "_watcher_wrapped", False):
    _orig_set_dynamic_color = Window.set_dynamic_color

    def _watcher_set_dynamic_color(window: Window, code: int, value: Any = "") -> None:
        tab = window.tabref() if hasattr(window, "tabref") else None
        if tab and len(tab) > 1 and window != tab.active_window:
            val_str = bytes(value).decode("latin1", "replace") if isinstance(value, (bytes, memoryview)) else str(value)
            if code in (10, 11, 110, 111) and not all(part == "?" for part in val_str.split(";")):
                return
        return _orig_set_dynamic_color(window, code, value)

    Window.set_dynamic_color = _watcher_set_dynamic_color
    Window._watcher_wrapped = True

if not getattr(Borders, "_watcher_wrapped", False):
    def _custom_borders_call(
        self: Borders,
        all_windows: WindowList,
        current_layout: LayoutType,
        tab_bar_rects: Iterable[Border],
        draw_window_borders: bool = True,
    ) -> None:
        opts = get_options()
        draw_active_borders = opts.active_border_color is not None
        rects: list[Border] = []
        groups = tuple(all_windows.iter_all_layoutable_groups(only_visible=True))
        window_blank_rects = set()
        for wg in groups:
            if wg.geometry:
                c = (color_as_int(wg.default_bg) << 8) | BorderColor.window_bg
                for br in blank_rects_for_window(wg.geometry):
                    rects.append(Border(*br, c))
                    window_blank_rects.add(br)
        for br in current_layout.blank_rects:
            if br not in window_blank_rects:
                rects.append(Border(*br, BorderColor.default_bg))
        rects.extend(tab_bar_rects)

        bw = 0
        if groups:
            bw = groups[0].effective_border()
        draw_borders = bw > 0 and draw_window_borders
        active_group = all_windows.active_group
        num_visible_groups = len(groups)

        if opts.draw_window_borders_for_single_window and num_visible_groups == 1:
            draw_minimal_borders = False
        else:
            draw_minimal_borders = opts.draw_minimal_borders and max(opts.window_margin_width) < 1

        os_window_focused = True
        if opts.draw_window_borders_for_single_window and num_visible_groups == 1:
            os_window_focused = current_focused_os_window_id() == self.os_window_id

        if draw_borders and not draw_minimal_borders:
            for i, wg in enumerate(groups):
                if wg is active_group and draw_active_borders and os_window_focused:
                    color = BorderColor.active
                else:
                    color = BorderColor.bell if wg.needs_attention else BorderColor.inactive
                add_borders(rects, color, wg)

        if draw_minimal_borders:
            for border_line in current_layout.get_minimal_borders(all_windows):
                rects.append(Border(*border_line.edges, border_line.color, border_line.window_id, border_line.horizontal))
        set_borders_rects(self.os_window_id, self.tab_id, rects)

    Borders.__call__ = _custom_borders_call
    Borders._watcher_wrapped = True


def on_focus_change(boss: Boss, window: Window, data: Dict[str, Any]) -> None:
    tab = window.tabref() if hasattr(window, "tabref") else None
    if not tab:
        return

    if len(tab) <= 1:
        patch_colors(_active_colors, windows=[window])
        return

    if not data.get("focused"):
        patch_colors(_inactive_colors, windows=[window])
        return

    patch_colors(_active_colors, windows=[window])
    other_windows = [w for w in tab if w.id != window.id]
    if other_windows:
        patch_colors(_inactive_colors, windows=other_windows)


def on_resize(boss: Boss, window: Window, data: Dict[str, Any]) -> None:
    old_geometry = data.get("old_geometry")
    if not old_geometry or old_geometry.xnum != 0 or old_geometry.ynum != 0:
        return

    tab = window.tabref() if hasattr(window, "tabref") else None
    if not tab:
        return

    if len(tab) <= 1:
        patch_colors(_active_colors, windows=[window])
        return

    active_win = tab.active_window
    if active_win:
        patch_colors(_active_colors, windows=[active_win])
        inactives = [w for w in tab if w.id != active_win.id]
        if inactives:
            patch_colors(_inactive_colors, windows=inactives)


def on_close(boss: Boss, window: Window, data: Dict[str, Any]) -> None:
    tab = window.tabref() if hasattr(window, "tabref") else None
    if not tab:
        return

    remaining_windows = [w for w in tab if w.id != window.id]
    if len(remaining_windows) == 1:
        patch_colors(_active_colors, windows=remaining_windows)
