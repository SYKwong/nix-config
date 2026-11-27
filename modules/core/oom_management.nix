{
  systemd = {
    oomd = {
      enable = true;
      enableRootSlice = true;
      enableSystemSlice = true;
      enableUserSlices = true;
    };

    slices."nix-daemon".sliceConfig = {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "50%";
    };

    services.nix-daemon.serviceConfig = {
      Slice = "nix-daemon.slice";
      OOMScoreAdjust = 250;
    };
  };
}
