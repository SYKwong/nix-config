{ hostname, ... }:

let

  host_listeners = {
    framework16 = [
      # Trun off keyboard backlight after 5.5 minutes
      {
        timeout = 330;
        on-timeout = "kb-light-manager off 32ac 0012";
        on-resume = "kb-light-manager on 32ab 0012";
      }

      # Suspend after 10 minutes
      {
        timeout = 600;
        on-timeout = "systemctl suspend-then-hibernate";
      }
    ];
  };
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "noctalia msg session lock";
        before_sleep_cmd = "loginctl lock-session"; # lock before suspend
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'"; # wake up screen after suspend
      };

      listener = [
        # Reduce brightness after 2.5 minutes
        {
          timeout = 150;
          on-timeout = "brightnessctl -s set 5%"; # set monitor backlight to 10%
          on-resume = "brightnessctl -r"; # restore monitor backlight
        }

        # Lock screen after 5 minutes
        {
          timeout = 300;
          on-timeout = "loginctl lock-session"; # lock screen
        }

        # Turn off screen after 5.5 minutes
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })' ;; brightnessctl -r";
        }
      ]
      ++ host_listeners.${hostname};
    };
  };
}
