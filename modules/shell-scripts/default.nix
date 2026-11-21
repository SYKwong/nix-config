{
  pkgs,
  hostname,
  username,
  ...
}:

let
  config_path = "/home/${username}/nix-config";

  logHelpers = ''
    if [ -t 1 ]; then
      BOLD="\033[1m"
      GREEN="\033[1;32m"
      BLUE="\033[1;34m"
      YELLOW="\033[1;33m"
      RED="\033[1;31m"
      RESET="\033[0m"
    else
      BOLD=""
      GREEN=""
      BLUE=""
      YELLOW=""
      RED=""
      RESET=""
    fi

    log_info() {
      printf "%b==> [INFO]%b %s\n" "$BLUE" "$RESET" "$*"
    }
    log_success() {
      printf "%b==> [OK]%b %s\n" "$GREEN" "$RESET" "$*"
    }
    log_warn() {
      printf "%b==> [WARN]%b %s\n" "$YELLOW" "$RESET" "$*"
    }
    log_error() {
      printf "%b==> [ERROR]%b %s\n" "$RED" "$RESET" "$*"
    }
  '';

  bwrapMaskSecrets = ''
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
  '';

  mkSafeNodeSandbox =
    commandName:
    pkgs.writeShellApplication {
      name = "safe-${commandName}";

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

        ${bwrapMaskSecrets}
        exec bwrap "''${BWRAP_ARGS[@]}" ${commandName} "$@"
      '';
    };

  common = {
    inherit
      pkgs
      hostname
      username
      config_path
      logHelpers
      bwrapMaskSecrets
      mkSafeNodeSandbox
      ;
  };

  rebuild = import ./rebuild.nix common;

  scripts = {
    inherit rebuild;
    post-install = import ./post-install.nix common;
    kb-light-manager = import ./kb-light-manager.nix common;
    rofi-keybinds = import ./rofi-keybinds.nix common;
    display-brightness = import ./display-brightness.nix common;
    hypr-virtual-monitor = import ./hypr-virtual-monitor.nix common;
    safe-python = import ./safe-python.nix common;
    safe-npm = import ./safe-npm.nix common;
    safe-npx = import ./safe-npx.nix common;
    update-system = import ./update-system.nix (common // { inherit rebuild; });
    update-wallpaper = import ./update-wallpaper.nix (common // { inherit rebuild; });
  };
in
{
  imports = [
    ./tui-wrap.nix
  ];

  environment.systemPackages = builtins.attrValues scripts;
}
