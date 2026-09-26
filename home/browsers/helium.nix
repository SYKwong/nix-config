{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  preferences = {
    browser = {
      custom_chrome_frame = false;
      show_forward_button = false;
      show_home_button = false;
    };
    helium = {
      browser = {
        centered_location_bar = true;
        layout = 2;
        minimal_location_bar = true;
        new_tab_next_to_active = false;
        rounded_frame = true;
        show_avatar_button = false;
        show_back_button = false;
        show_dynamic_new_tab_button = false;
        show_extensions_button = true;
        show_media_button = true;
        show_menu_button = true;
        show_reload_button = false;
        show_vertical_tabs_collapse_button = true;
        vertical_right_aligned = true;
        zen_mode = true;
        zen_mode_sidebar_pinned = false;
        zen_mode_top_chrome_pinned = true;
      };
      completed_onboarding = true;
      services = {
        schema_version = 1;
        user_consented = true;
      };
    };
    vertical_tabs = {
      collapsed_state = false;
      uncollapsed_width = 200;
    };
  };

  preferencesJson = pkgs.writeText "helium-preferences.json" (builtins.toJSON preferences);
in
{
  imports = [ inputs.helium.homeModules.default ];

  programs.helium = {
    enable = true;

    # CLI flags passed to the browser
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--enable-features=WaylandWindowDecorations"
      "--enable-wayland-ime=true"
    ];

    # Chrome Web Store extensions (installed via Helium's privacy proxy)
    extensions = [
      { id = "ophjlpahpchlmihnnnihgmmeilfjmjjc"; } # Line
    ];
  };

  home.activation.heliumPreferences = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    PREFS_FILE="$HOME/.config/net.imput.helium/Default/Preferences"
    mkdir -p "$(dirname "$PREFS_FILE")"
    if [ ! -f "$PREFS_FILE" ]; then
      echo '{}' > "$PREFS_FILE"
    fi
    ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$PREFS_FILE" "${preferencesJson}" > "$PREFS_FILE.tmp" && mv "$PREFS_FILE.tmp" "$PREFS_FILE"
  '';
}
