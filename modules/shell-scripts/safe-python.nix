{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "safe-python";

  runtimeInputs = with pkgs; [
    bubblewrap
    python3
  ];

  text = ''
    exec bwrap \
      --ro-bind / / \
      --dev /dev \
      --proc /proc \
      --tmpfs /tmp \
      --unshare-net \
      --unshare-pid \
      --die-with-parent \
      python3 "$@"
  '';
}
