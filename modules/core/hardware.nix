{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = true;
  };
  services.xserver.videoDrivers = [ "amdgpu" ];
}
