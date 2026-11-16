{
  pkgs,
  bwrapMaskSecrets,
  ...
}:

pkgs.writeShellApplication {
  name = "safe-python";

  runtimeInputs = with pkgs; [
    bubblewrap
    coreutils
  ];

  text = ''
    BWRAP_ARGS=(
      --ro-bind / /
      --dev /dev
      --proc /proc
      --tmpfs /tmp
      --unshare-net
      --unshare-pid
      --die-with-parent
      --clearenv
      --setenv PATH "$PATH:${pkgs.python3}/bin"
      --setenv HOME "$HOME"
      --setenv USER "''${USER:-$(id -un)}"
      --setenv TERM "''${TERM:-dumb}"
      --setenv LANG "''${LANG:-C.UTF-8}"
      --setenv TMPDIR "/tmp"
      --setenv PYTHONDONTWRITEBYTECODE "1"
    )

    if [ -n "''${PYTHONPATH:-}" ]; then
      BWRAP_ARGS+=(--setenv PYTHONPATH "$PYTHONPATH")
    fi

    if [ -n "''${VIRTUAL_ENV:-}" ]; then
      BWRAP_ARGS+=(--setenv VIRTUAL_ENV "$VIRTUAL_ENV")
    fi

    if [[ "$PWD" == /tmp/* ]]; then
      BWRAP_ARGS+=(--ro-bind "$PWD" "$PWD")
    fi

    for arg in "$@"; do
      if [[ "$arg" == /tmp/* ]] && [ -e "$arg" ]; then
        BWRAP_ARGS+=(--ro-bind "$arg" "$arg")
      fi
    done

    ${bwrapMaskSecrets}
    exec bwrap "''${BWRAP_ARGS[@]}" python3 "$@"
  '';
}
