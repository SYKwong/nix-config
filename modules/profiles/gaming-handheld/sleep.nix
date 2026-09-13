{
  # Suspend-then-hibernate power management for handheld console
  services.logind.settings.Login = {
    HandlePowerKey = "suspend-then-hibernate";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "1h";
  };
}
