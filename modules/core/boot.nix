{ username, ... }:

{
  boot = {
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = true;
  };
### For Silent Boot 
### Silent Power Down Cannot Be Done Because of initrd 
  boot = {
    consoleLogLevel = 3;
    initrd.verbose = false;
    initrd.systemd.services.systemd-vconsole-setup.enable = false;
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "nowatchdog"
      "systemd.show_status=false"
      "vt.global_cursor_default=0"
    ];
    loader.timeout = 5;
    plymouth.enable = true;
    blacklistedKernelModules = [ "sp5100_tco" "iTCO_wdt" ];
    
  };
###
}

