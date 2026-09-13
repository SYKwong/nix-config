{ username, ... }:

{
  # Handheld Daemon for controller emulation, gyro, back buttons, TDP, and RGB
  services.handheld-daemon = {
    enable = true;
    user = username;
    adjustor.enable = true;
  };
}
