{ hostname, username, ... }:

let
  host_config = {
    framework16 = {
      output_monitor = "eDP-1";
      screen_width = 2560.0;
      screen_height = 1600.0;
      ui_scale = 1.25;

      idle_behaviors = {
        kb-backlight = {
          action = "command";
          command = "kb-light-manager off 32ac 0012";
          resume_command = "kb-light-manager on 32ac 0012";
          timeout = 330;
        };

        suspend-then-hibernate = {
          action = "command";
          command = "systemctl suspend-then-hibernate";
          timeout = 600;
        };
      };
    };

    mini-pc-k8 = {
      output_monitor = "HDMI-A-1";
      # 3840x2160 scaled 2x in Hyprland yields 1920x1080 logical dimensions
      screen_width = 1920.0;
      screen_height = 1080.0;
      ui_scale = 1.0;
      is_desktop = true;
    };
  };

  current_host_config =
    host_config.${hostname} or {
      output_monitor = "HDMI-A-1";
      screen_width = 1920.0;
      screen_height = 1080.0;
      ui_scale = 1.0;
    };

  lockscreen_login_box_width = current_host_config.screen_width * 0.15625;
  lockscreen_login_box_height = current_host_config.screen_height * 0.04375;
  lockscreen_login_box_cx = current_host_config.screen_width / 2;
  lockscreen_login_box_cy = current_host_config.screen_height / 2;

  lockscreen_margin = 60.0 * (current_host_config.ui_scale or 1.0);
  lockscreen_clock_width = current_host_config.screen_width * 0.20625;
  lockscreen_clock_height = current_host_config.screen_height * 0.17;
  lockscreen_clock_cx = lockscreen_margin + (lockscreen_clock_width / 2);
  lockscreen_clock_cy = lockscreen_margin + (lockscreen_clock_height / 2);

  idle_scale = if (current_host_config.is_desktop or false) then 3 else 1;
  idle_dim_timeout = 150 * idle_scale;
  idle_lock_timeout = 300 * idle_scale;
  idle_screen_off_timeout = 330 * idle_scale;

  wallpaper_directory = "/home/${username}/Wallpaper";
in

{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      accessibility = {
        inherit (current_host_config) ui_scale;
      };

      audio = {
        enable_sounds = false;
      };

      bar = {
        order = [ "default" ];
        default = {
          auto_hide = false;
          background_opacity = 0.0;
          border = "outline";
          border_width = 0.0;
          capsule = true;
          capsule_fill = "surface_variant";
          capsule_opacity = 1.0;
          capsule_padding = 6.0;
          capsule_thickness = 0.76;
          concave_edge_corners = false;
          contact_shadow = false;
          enabled = false;
          font_weight = 500;
          hover_highlight = true;
          layer = "top";
          margin_edge = 0;
          margin_ends = 30;
          margin_opposite_edge = 2;
          padding = 0;
          panel_overlap = 1;
          position = "top";
          radius = 12;
          radius_bottom_left = 12;
          radius_bottom_right = 12;
          radius_top_left = 12;
          radius_top_right = 12;
          reserve_space = true;
          scale = 1.0;
          shadow = false;
          show_on_workspace_switch = true;
          show_tooltip = false;
          smart_auto_hide = false;
          thickness = 34;
          widget_spacing = 6;

          start = [
            "workspaces"
            "media"
          ];
          center = [ "clock" ];
          end = [
            "group:utilities"
            "group:system"
            "session"
          ];

          monitor.primary = {
            match = current_host_config.output_monitor;
            enabled = true;
          };

          capsule_group = [
            {
              accordion = false;
              accordion_direction = "end";
              enabled = true;
              fill = "surface_variant";
              id = "utilities";
              members = [
                "tray"
                "clipboard"
                "notifications"
              ];
              opacity = 1.0;
              padding = 6.0;
            }

            {
              accordion = false;
              accordion_direction = "end";
              enabled = true;
              fill = "surface_variant";
              id = "system";
              members = [
                "network"
                "bluetooth"
                "volume"
                "battery"
              ];
              opacity = 1.0;
              padding = 6.0;
            }
          ];
        };
      };

      control_center = {
        calendar.show_events_card = false;
        shortcuts = [
          { type = "caffeine"; }
          { type = "nightlight"; }
          { type = "notification"; }
          { type = "power_profile"; }
        ];
        show_session_button = false;
        sidebar = "none";
        sidebar_section = "none";
      };
      desktop_widgets.enabled = false;
      idle = {
        behavior_order = [
          "dim"
          "lock"
          "screen-off"
          "kb-backlight"
          "suspend-then-hibernate"
        ];
        pre_action_fade_seconds = 0;
        behavior = {
          dim = {
            action = "command";
            command = "brightnessctl -s set 5%";
            resume_command = "brightnessctl -r";
            timeout = idle_dim_timeout;
          };

          lock = {
            action = "lock";
            enabled = true;
            timeout = idle_lock_timeout;
          };

          screen-off = {
            action = "screen_off";
            enabled = true;
            timeout = idle_screen_off_timeout;
          };
        }
        // (current_host_config.idle_behaviors or { });
      };
      location.auto_locate = true;

      lockscreen = {
        grace_period_seconds = 2;
      };

      lockscreen_widgets = {
        enabled = true;
        schema_version = 2;

        widget = {
          "lockscreen-login-box@${current_host_config.output_monitor}" = {
            box_width = lockscreen_login_box_width;
            box_height = lockscreen_login_box_height;
            cx = lockscreen_login_box_cx;
            cy = lockscreen_login_box_cy;
            output = current_host_config.output_monitor;
            rotation = 0.0;
            type = "login_box";

            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              center_password_text = true;
              input_opacity = 1.0;
              input_radius = 6.0;
              layout = "compact";
              show_caps_lock = true;
              show_password_reveal = false;
              show_unlock_hint = false;
            };
          };

          clock_main = {
            box_height = lockscreen_clock_height;
            box_width = lockscreen_clock_width;
            cx = lockscreen_clock_cx;
            cy = lockscreen_clock_cy;
            output = current_host_config.output_monitor;
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

      notification = {
        history_retention_hours = 24;
        layer = "overlay";
        filter = {
          kitty = {
            match = "kitty";
            play_sound = false;
          };
          sunshine = {
            match = "sunshine";
            play_sound = false;
            save_history = false;
            show_toast = false;
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
          lock_keys = true;
          nightlight = false;
        };
      };

      shell = {
        animation.enabled = false;
        button_borders = true;
        card_borders = true;
        input_borders = true;
        launch_apps_as_systemd_services = false;
        launch_apps_custom_command = "uwsm app -- $CMD";
        polkit_agent = true;
        popup_borders = true;
        popup_shadows = false;
        show_close_buttons = false;
        show_location = false;

        mpris.blacklist = [
          "firefox"
          "zen"
          "chromium"
          "chrome"
          "brave"
        ];

        launcher = {
          layout = "simple";
          categories = false;
          compact = true;
          fetch_exchange_rates = false;
          show_app_origin_indicator = false;
          sort_by_usage = false;
          track_usage = false;
          providers.session.global = true;
        };

        panel = {
          border_color = "primary";
          border_width = 2.0;
          control_center_placement = "floating";
          session_placement = "floating";
          session_position = "center";
          transparency_mode = "glass";
          wallpaper_placement = "floating";
          wallpaper_position = "center";
          wallpaper_show_names = false;
        };

        screenshot = {
          directory = "~/Pictures/Screenshots/";
          show_cursor = true;
        };
      };

      system.monitor.enabled = false;

      theme = {
        mode = "dark";
        source = "wallpaper";
        wallpaper_scheme = "m3-content";
        templates = {
          builtin_ids = [ "hyprland" ];
          enable_builtin_templates = true;
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
        clock.format = "{:%b %d %-I:%M%p}";
        media = {
          hide_album_art = true;
          title_scroll = "always";
          hide_when_no_media = true;
          hide_when_idle = true;
        };
        network = {
          show_label = false;
          vpn_status = "both";
        };
        notifications.hide_when_no_unread = true;
        tray = {
          drawer = true;
          pinned = [
            "Fcitx"
            "org.fcitx.Fcitx5"
          ];
        };
        workspaces.label_source = "name";
      };
    };
  };
}
