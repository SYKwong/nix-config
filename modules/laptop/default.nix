{
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "suspend-then-hibernate";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30min";
  };

  services.fprintd.enable = true;
  security.polkit.enable = true;
}
