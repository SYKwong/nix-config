{ hostname, username, ... }:

let
  lockscreen_host_config = {
    framework16 = {
      output_monitor = "eDP-1";
      screen_width = 2560.0;
      screen_height = 1600.0;
    };
  };

  lockscreen_config =
    lockscreen_host_config.${hostname} or {
      output_monitor = "HDMI-A-1";
      screen_width = 1920.0;
      screen_height = 1080.0;
    };

  lockscreen_login_box_width = lockscreen_config.screen_width * 0.15625;
  lockscreen_login_box_height = lockscreen_config.screen_height * 0.04375;
  lockscreen_login_box_cx = lockscreen_config.screen_width / 2;
  lockscreen_login_box_cy = lockscreen_config.screen_height / 2;

  lockscreen_clock_width = lockscreen_config.screen_width * 0.20625;
  lockscreen_clock_height = lockscreen_config.screen_height * 0.17;
  lockscreen_clock_cx = lockscreen_config.screen_width * 0.103125;
  lockscreen_clock_cy = lockscreen_config.screen_height * 0.09;

  wallpaper_directory = "/home/${username}/Wallpaper";
in

{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      accessibility = {
        ui_scale = 1.25;
      };

      bar.default = {
        center = [ "group:g1" ];
        end = [
          "group:g2"
          "session"
        ];
        margin_edge = 0;
        margin_ends = 30;
        margin_opposite_edge = 2;
        padding = 0;
        start = [ "media" ];

        capsule_group = [
          {
            accordion = false;
            accordion_direction = "end";
            enabled = true;
            fill = "surface_variant";
            id = "g1";
            members = [
              "clock"
              "workspaces"
              "bluetooth"
              "network"
              "volume"
              "battery"
            ];
            opacity = 1.0;
            padding = 6.0;
          }

          {
            accordion = false;
            accordion_direction = "end";
            enabled = true;
            fill = "surface_variant";
            id = "g2";
            members = [
              "tray"
              "notifications"
              "clipboard"
            ];
            opacity = 1.0;
            padding = 6.0;
          }
        ];
      };

      control_center.calendar.show_events_card = false;
      desktop_widgets.enabled = false;
      idle.pre_action_fade_seconds = 0;
      location.auto_locate = true;

      lockscreen_widgets = {
        enabled = true;
        schema_version = 2;

        widget = {
          "lockscreen-login-box@${lockscreen_config.output_monitor}" = {
            box_width = lockscreen_login_box_width;
            box_height = lockscreen_login_box_height;
            cx = lockscreen_login_box_cx;
            cy = lockscreen_login_box_cy;
            output = lockscreen_config.output_monitor;
            rotation = 0.0;
            type = "login_box";

            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              center_password_text = false;
              input_opacity = 1.0;
              input_radius = 6.0;
              layout = "compact";
              show_caps_lock = true;
            };
          };

          clock_main = {
            box_height = lockscreen_clock_height;
            box_width = lockscreen_clock_width;
            cx = lockscreen_clock_cx;
            cy = lockscreen_clock_cy;
            output = lockscreen_config.output_monitor;
            rotation = 0.0;
            type = "clock";

            settings = {
              background_opacity = 0.0;
              center_text = false;
              color = "outline";
              format = "{:%m/%d}\\n{::%-I:%M %p}";
            };
          };
        };
      };

      osd = {
        background_opacity = 0.5;
        offset_x = 0;
        offset_y = 150;
        position = "bottom_center";
        position_vertical = "bottom_center";
        kinds = {
          lock_keys = false;
          nightlight = false;
        };
      };

      shell = {
        animation.enabled = false;
        button_borders = false;
        card_borders = false;
        input_borders = false;
        polkit_agent = true;
        popup_borders = false;
        popup_shadows = false;
        show_location = false;

        launcher = {
          categories = false;
          compact = true;
          fetch_exchange_rates = false;
          show_app_origin_indicator = false;
          sort_by_usage = false;
          providers.session.global = true;
        };

        panel = {
          session_placement = "floating";
          session_position = "center";
          transparency_mode = "glass";
          wallpaper_placement = "floating";
          wallpaper_position = "center";
        };

        screenshot.directory = "~/Pictures/Screenshots/";
      };

      system.monitor.enabled = false;

      theme = {
        builtin = "Catppuccin";
        community_palette = "Catppuccin Mocha Blue";
        source = "community";
        wallpaper_scheme = "m3-tonal-spot";
        templates = {
          enable_builtin_templates = false;
          enable_community_templates = false;
        };
      };

      wallpaper = {
        directory = wallpaper_directory;
        default.path = "${wallpaper_directory}/FnpKlkMaYAAga0Z.jpg";
      };

      weather = {
        enabled = true;
        refresh_minutes = 30;
        unit = "metric";
        effects = false;
      };

      widget = {
        clock.format = "{:%-I:%M %p}";
        media = {
          hide_album_art = true;
          title_scroll = "always";
        };
        network = {
          show_label = false;
          vpn_status = "both";
        };
        notifications.hide_when_no_unread = true;
      };
    };
  };
}
