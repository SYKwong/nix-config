{
  pkgs,
  hostname,
  username,
  config_path,
  ...
}:

pkgs.writeShellApplication {
  name = "update-available";

  runtimeInputs = with pkgs; [
    git
    gawk
    coreutils
  ];

  text = ''
    MAX_ATTEMPTS=3
    ATTEMPT=1
    DELAY_SEC=10

    REPO="${config_path}"

    local_hash=$(git -C "$REPO" rev-parse main 2>/dev/null)
    remote_hash=""

    while [ "$ATTEMPT" -le "$MAX_ATTEMPTS" ]; do
      remote_hash=$(
        git -C "$REPO" ls-remote origin -h refs/heads/main 2>/dev/null |
        awk '{print $1}'
      )

      if [[ -n "$remote_hash" ]]; then
        break
      fi

      if [ "$ATTEMPT" -lt "$MAX_ATTEMPTS" ]; then
        echo "Network error or timeout. Retrying in $DELAY_SEC seconds... ($ATTEMPT/$MAX_ATTEMPTS)" >&2
        sleep "$DELAY_SEC"
      fi

      ((ATTEMPT++))
    done

    if [[ -z "$remote_hash" ]]; then
      echo "Error: Could not connect to remote repository after $MAX_ATTEMPTS attempts." >&2
      exit 2
    elif [[ "$local_hash" != "$remote_hash" ]]; then
      echo "update available $remote_hash"
      pkill -RTMIN+7 waybar
      exit 0
    else
      echo "no update at the moment"
      exit 1
    fi
  '';
}
