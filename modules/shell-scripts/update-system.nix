{
  pkgs,
  username,
  config_path,
  logHelpers,
  ...
}:

pkgs.writeShellApplication {
  name = "update-system";

  runtimeInputs = [
    pkgs.coreutils
    pkgs.git
  ];

  text = ''
    ${logHelpers}
    REPO="${config_path}"
    cd "$REPO"

    STARTING_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    STASHED=false
    INTENT_TO_ADD_FILES=()

    cleanup() {
      local exit_code=$?
      if [ "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)" != "$STARTING_BRANCH" ]; then
        log_info "Returning to branch $STARTING_BRANCH..."
        git switch "$STARTING_BRANCH" || true
      fi

      if [ "$STASHED" = true ]; then
        log_info "Restoring stashed changes..."
        git stash pop || log_warn "Could not auto-pop stash; run 'git stash list' to inspect."
      fi

      if [ "''${#INTENT_TO_ADD_FILES[@]}" -gt 0 ]; then
        git add -N -- "''${INTENT_TO_ADD_FILES[@]}" || true
      fi

      if [ "$exit_code" -ne 0 ]; then
        echo ""
        printf "%bPress any key to exit...%b" "$BOLD" "$RESET"
        read -n 1 -s -r || true
        echo ""
      fi
      exit "$exit_code"
    }
    trap cleanup EXIT

    while IFS= read -r status_line; do
      if [[ "$status_line" == " A "* ]]; then
        INTENT_TO_ADD_FILES+=("''${status_line# A }")
      fi
    done < <(git status --porcelain)

    if [ "''${#INTENT_TO_ADD_FILES[@]}" -gt 0 ]; then
      git reset -- "''${INTENT_TO_ADD_FILES[@]}"
    fi

    if [ -n "$(git status --porcelain)" ]; then
      log_info "Stashing local changes before switching to main..."
      git stash push --include-untracked -m "update-system-temp-stash"
      STASHED=true
    fi

    if [ "$STARTING_BRANCH" != "main" ]; then
      log_info "Switching to main..."
      git switch main
    fi

    BEFORE_HASH=$(git rev-parse main)

    log_info "Fast-forwarding local main from origin..."
    git -c core.hooksPath=/dev/null -c core.fsmonitor=false pull --ff-only origin main

    AFTER_HASH=$(git rev-parse main)
    if [ "$BEFORE_HASH" = "$AFTER_HASH" ]; then
      log_info "Already up to date ($AFTER_HASH); skipping rebuild."
      "/etc/profiles/per-user/${username}/bin/noctalia" msg plugin local/git_sync:git_sync all refresh >/dev/null 2>&1 || true
      exit 0
    fi

    log_info "Running NixOS rebuild..."
    sudo /run/current-system/sw/bin/rebuild
  '';
}
