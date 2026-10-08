{
  lib,
  hyprlandPlugins,
  src,
}:

hyprlandPlugins.mkHyprlandPlugin {
  pluginName = "scrolloverview";
  version = src.shortRev or "dirty";

  inherit src;

  dontUseCmakeConfigure = true;
  dontUseMesonConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    mv scrolloverview.so $out/lib/libscrolloverview.so

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/yayuuu/hyprland-scroll-overview";
    description = "Niri-style scroll overview plugin for Hyprland";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
