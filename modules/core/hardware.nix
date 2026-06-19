{
  hardware = {
    graphics.enable = true;
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = true;
    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
  };
  services.xserver.videoDrivers = [ "amdgpu" ];
}
