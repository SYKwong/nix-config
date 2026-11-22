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

  # Only patch this exact rev so future flake.lock updates automatically drop the workaround.
  # Disables PR #93's global renderRect/renderTexture/scissor hooks that SIGSEGV on Hyprland v0.57.2.
  postPatch = lib.optionalString (src.rev or "" == "3eb62e3e0093d54cbdcf4f58c831b5b53b3b1ff2") ''
    substituteInPlace Window.cpp \
      --replace-fail 'void initDecorationRenderer() {' 'void initDecorationRenderer() { return;'
  '';

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
