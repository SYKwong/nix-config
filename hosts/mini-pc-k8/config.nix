_:

{
  custom.systemd-services.flake-update-verifier.enable = true;

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0 power_save_controller=N
  '';

  # Define custom ALSA Card Profile for GMKtec NucBox K8 Plus chassis without phantom internal speaker/mic
  environment.etc."alsa-card-profile/mixer/profile-sets/k8-plus-analog.conf".text = ''
    [General]
    auto-profiles = yes

    [Mapping analog-stereo]
    device-strings = front:%f
    channel-map = left,right
    paths-output = analog-output-headphones
    paths-input = analog-input-headphone-mic analog-input-mic
    priority = 15
  '';

  services = {
    # Permanently disable built-in Intel Bluetooth (8087:0029) at the USB stack
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="8087", ATTR{idProduct}=="0029", ATTR{authorized}="0"
    '';

    pipewire = {
      extraConfig.pipewire."10-clock" = {
        "context.properties" = {
          "default.clock.min-quantum" = 512;
        };
      };

      # Audio tuning and ALSA profile configuration for GMKtec K8 Plus
      wireplumber.extraConfig."50-k8-plus-audio" = {
        "monitor.alsa.rules" = [
          # Assign profile set to onboard Realtek audio controller so unplugged 3.5mm jack is marked unavailable
          {
            matches = [
              {
                "device.name" = "~alsa_card.pci.*";
                "device.product.id" = "0x15e3";
              }
            ];
            actions = {
              update-props = {
                "device.profile-set" = "k8-plus-analog.conf";
              };
            };
          }
          # Prevent buffer underruns and HDMI sleep cutouts on audio sinks
          {
            matches = [
              {
                "node.name" = "~alsa_output.*";
              }
            ];
            actions = {
              update-props = {
                "api.alsa.period-size" = 1024;
                "api.alsa.headroom" = 2048;
                "session.suspend-timeout-seconds" = 0;
              };
            };
          }
        ];
      };
    };
  };
}
