{
  # Permanently disable built-in Intel Bluetooth (8087:0029) at the USB stack
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="8087", ATTR{idProduct}=="0029", ATTR{authorized}="0"
  '';

  # Define custom ALSA Card Profile for mini PC chassis without phantom internal speaker/mic
  environment.etc."alsa-card-profile/mixer/profile-sets/k8-analog.conf".text = ''
    [General]
    auto-profiles = yes

    [Mapping analog-stereo]
    device-strings = front:%f
    channel-map = left,right
    paths-output = analog-output-headphones
    paths-input = analog-input-headphone-mic analog-input-mic
    priority = 15
  '';

  # Assign profile set to onboard Realtek audio controller so unplugged 3.5mm jack is marked unavailable
  services.pipewire.wireplumber.extraConfig."50-k8-audio" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          {
            "device.name" = "alsa_card.pci-0000_c6_00.6";
          }
        ];
        actions = {
          update-props = {
            "device.profile-set" = "k8-analog.conf";
          };
        };
      }
    ];
  };
}
