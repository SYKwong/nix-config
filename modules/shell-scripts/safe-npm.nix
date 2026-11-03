{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "safe-npm";

  runtimeInputs = with pkgs; [
    bubblewrap
    coreutils
  ];

  text = ''
    NPM_CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/npm"
    mkdir -p "$NPM_CACHE_DIR" "$HOME/.npm"

    BWRAP_ARGS=(
      --ro-bind / /
      --tmpfs /tmp
      --bind "$PWD" "$PWD"
      --bind "$NPM_CACHE_DIR" "$HOME/.npm"
      --dev /dev
      --proc /proc
      --die-with-parent
      --clearenv
      --setenv PATH "$PATH:${pkgs.nodejs}/bin"
      --setenv HOME "$HOME"
      --setenv USER "''${USER:-$(id -un)}"
      --setenv TERM "''${TERM:-dumb}"
      --setenv LANG "''${LANG:-C.UTF-8}"
      --setenv TMPDIR "/tmp"
    )

    for secret_dir in \
      "$HOME/.ssh" \
      "$HOME/.gnupg" \
      "$HOME/.aws" \
      "$HOME/.azure" \
      "$HOME/.kube" \
      "$HOME/.config/gh" \
      "$HOME/.config/glab-cli" \
      "$HOME/.config/sops" \
      /run/agenix.d \
      /run/secrets
    do
      if [ -d "$secret_dir" ] && [ ! -L "$secret_dir" ]; then
        BWRAP_ARGS+=(--tmpfs "$secret_dir")
      fi
    done

    for secret_file in \
      "$HOME/.netrc" \
      "$HOME/.git-credentials" \
      "$HOME/.npmrc"
    do
      if [ -f "$secret_file" ]; then
        BWRAP_ARGS+=(--ro-bind /dev/null "$secret_file")
      fi
    done

    exec bwrap "''${BWRAP_ARGS[@]}" npm "$@"
  '';
}
