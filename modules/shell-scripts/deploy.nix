{
  pkgs,
  config_path,
  ...
}:

pkgs.writeShellApplication {
  name = "deploy";

  runtimeInputs = [
    pkgs.coreutils
    pkgs.nixos-rebuild
    pkgs.openssh
  ];

  text = ''
    if [ "$#" -lt 1 ]; then
      echo "Usage: deploy <target_host> [switch|boot|test] [extra nixos-rebuild flags...]"
      echo ""
      echo "Available peer targets:"
      echo "  - legion-go   (Lenovo Legion Go)"
      echo "  - mini-pc-k8  (GMKtec K8 HTPC)"
      echo "  - framework16 (Framework Laptop 16)"
      echo ""
      echo "Examples:"
      echo "  deploy legion-go          # Build locally and activate live on target"
      echo "  deploy legion-go boot     # Build locally and stage for next boot"
      echo "  deploy mini-pc-k8         # Deploy to living room PC"
      exit 1
    fi

    TARGET="$1"
    ACTION="''${2:-switch}"
    shift 2 2>/dev/null || shift 1 2>/dev/null || true

    REPO="${config_path}"
    TARGET_HOST="''${TARGET}.local"

    echo "==> [INFO] Deploying ''${TARGET} (''${ACTION}) via SSH to root@''${TARGET_HOST}..."
    exec nixos-rebuild "''${ACTION}" --flake "''${REPO}#''${TARGET}" --target-host "root@''${TARGET_HOST}" "$@"
  '';
}
