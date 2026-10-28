{
  lib,
  pkgs,
  ...
}:

{
  # Invalidate KDE Sycoca binary caches on profile activation to resolve the NixOS
  # 1970 timestamp issue where KDE applications fail to detect updated .desktop files.
  home.activation.pruneKsycoca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run rm -f $HOME/.cache/ksycoca6*
    run ${pkgs.systemd}/bin/systemctl --user try-restart plasma-dolphin.service 2>/dev/null || true
  '';
}
