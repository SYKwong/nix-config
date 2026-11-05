_:

{
  custom.systemd-services.flake-update-verifier.enable = true;

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

    # Assign profile set to onboard Realtek audio controller so unplugged 3.5mm jack is marked unavailable
    pipewire.wireplumber.extraConfig."50-k8-plus-audio" = {
      "monitor.alsa.rules" = [
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
      ];
    };
  };
}
