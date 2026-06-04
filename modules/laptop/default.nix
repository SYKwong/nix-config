{
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "suspend-then-hibernate";
    HoldoffTimeoutSec = "5";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30min";
  };

  services.fprintd.enable = true;
  security.polkit.enable = true;
}
