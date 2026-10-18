{ pkgs, ... }:

let
  atuinAutoLogin = pkgs.writeShellScriptBin "atuin-auto-login" ''
    set -euo pipefail

    CREDS_FILE="/run/agenix/atuin-credentials"

    if ${pkgs.atuin}/bin/atuin status >/dev/null 2>&1; then
      exit 0
    fi

    if [ ! -f "$CREDS_FILE" ]; then
      exit 0
    fi

    ATUIN_USERNAME=$(grep -E '^ATUIN_USERNAME=' "$CREDS_FILE" | cut -d= -f2- | tr -d '"' | tr -d "'")
    ATUIN_PASSWORD=$(grep -E '^ATUIN_PASSWORD=' "$CREDS_FILE" | cut -d= -f2- | tr -d '"' | tr -d "'")
    ATUIN_KEY=$(grep -E '^ATUIN_KEY=' "$CREDS_FILE" | cut -d= -f2- | tr -d '"' | tr -d "'")

    if [ -z "$ATUIN_USERNAME" ] || [ -z "$ATUIN_PASSWORD" ] || [ -z "$ATUIN_KEY" ]; then
      exit 0
    fi

    echo "Attempting automatic Atuin login from agenix credentials..."
    if ${pkgs.atuin}/bin/atuin login -u "$ATUIN_USERNAME" -p "$ATUIN_PASSWORD" -k "$ATUIN_KEY"; then
      echo "Successfully logged into Atuin."
    else
      echo "Failed to log in to Atuin using agenix credentials."
      exit 1
    fi
  '';

  atuinToFish =
    pkgs.writers.writePython3Bin "atuin-to-fish"
      {
        flakeIgnore = [
          "E501"
          "W503"
          "W504"
        ];
      }
      ''
        import os
        import subprocess
        import sys
        import time

        # Ensure ATUIN_SESSION is present so atuin subcommands do not fail
        if "ATUIN_SESSION" not in os.environ:
            os.environ["ATUIN_SESSION"] = "atuin-sync-session"

        # Verify Atuin login status; attempt auto-login if unauthenticated
        status = subprocess.run(["atuin", "status"], capture_output=True, check=False)
        if status.returncode != 0:
            subprocess.run(["atuin-auto-login"], check=False)
            status = subprocess.run(["atuin", "status"], capture_output=True, check=False)

        if status.returncode != 0:
            print("Atuin is not logged in; skipping history sync.")
            sys.exit(0)

        # Sync with Atuin remote server with timeout
        try:
            sync_res = subprocess.run(
                ["atuin", "sync"],
                capture_output=True,
                timeout=10,
                check=False,
            )
            if sync_res.returncode != 0:
                err_text = (sync_res.stderr or b"").decode("utf-8", errors="replace").lower()
                invalid_phrases = ["unauthorized", "401", "could not load encryption key"]
                if any(phrase in err_text for phrase in invalid_phrases):
                    print("Atuin credentials or encryption key are invalid.")
                    sys.exit(2)
                print("Atuin sync failed or server unreachable; using local history.")
        except subprocess.TimeoutExpired:
            print("Atuin sync timed out after 10s; using local history.")

        fish_hist_path = os.path.expanduser("~/.local/share/fish/fish_history")
        existing_cmds = set()
        if os.path.exists(fish_hist_path):
            with open(fish_hist_path, "r", encoding="utf-8", errors="replace") as f:
                for line in f:
                    if line.startswith("- cmd:"):
                        existing_cmds.add(line[6:].strip())

        try:
            res = subprocess.run(
                ["atuin", "history", "list", "--cmd-only", "--print0"],
                capture_output=True,
                check=False,
            )
        except FileNotFoundError:
            sys.exit(0)

        if res.returncode != 0 or not res.stdout:
            sys.exit(0)

        new_cmds = []
        seen = set()
        for raw in res.stdout.split(b"\x00"):
            cmd = raw.decode("utf-8", errors="replace").strip()
            if cmd and cmd not in existing_cmds and cmd not in seen:
                seen.add(cmd)
                new_cmds.append(cmd)

        if not new_cmds:
            print("Fish suggestions are already up to date with Atuin.")
            sys.exit(0)

        now = int(time.time())
        try:
            with open(fish_hist_path, "a", encoding="utf-8") as f:
                for cmd in new_cmds:
                    escaped_cmd = cmd.replace("\r", "").replace("\n", "\\n")
                    f.write(f"- cmd: {escaped_cmd}\n  when: {now}\n")
            print(f"Synced {len(new_cmds)} new commands from Atuin into Fish suggestions.")
            subprocess.run(["fish", "-c", "builtin history merge"], capture_output=True, check=False)
        except Exception as e:
            print(f"Failed to append commands to Fish history: {e}")
            sys.exit(1)
      '';
in
{
  home.packages = [
    atuinAutoLogin
    atuinToFish
  ];

  systemd.user.services.atuin-auto-login = {
    Unit = {
      Description = "Auto-login to Atuin sync using agenix credentials";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${atuinAutoLogin}/bin/atuin-auto-login";
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    flags = [
      "--disable-up-arrow"
      "--disable-ctrl-r"
    ];
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
      style = "compact";
      inline_height = 20;
      show_preview = true;
    };
  };
}
