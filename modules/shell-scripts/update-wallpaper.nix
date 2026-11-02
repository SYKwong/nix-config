{
  pkgs,
  username,
  config_path,
  rebuild,
  ...
}:

pkgs.writeShellApplication {
  name = "update-wallpaper";

  runtimeInputs = [
    pkgs.coreutils
    pkgs.git
    pkgs.nix
    pkgs.openssh
    rebuild
  ];

  text = ''
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

    if [ "''${EUID}" -eq 0 ]; then
      log_error "Please run update-wallpaper as your regular user (not with sudo)."
      exit 1
    fi

    resolve_wallpaper_dir() {
      if [ -n "''${WALLPAPER_DIR:-}" ]; then
        echo "$WALLPAPER_DIR"
        return 0
      fi

      for candidate_path in \
        "/home/${username}/data/private-wallpaper" \
        "/home/${username}/Pictures/wallpaper" \
        "/home/${username}/Pictures/Wallpaper" \
        "/home/${username}/Pictures/wallpapers" \
        "/home/${username}/Pictures/Wallpapers" \
        "/home/${username}/Wallpaper" \
        "/home/${username}/wallpaper" \
        "/home/${username}/Wallpapers" \
        "/home/${username}/wallpapers"; do
        if [ -d "$candidate_path/.git" ]; then
          echo "$candidate_path"
          return 0
        fi
      done

      echo "/home/${username}/data/private-wallpaper"
    }

    REPO="${config_path}"
    WALLPAPER_DIR=$(resolve_wallpaper_dir)

    # Step 1: Push from the wallpaper repository
    log_info "Step 1/4: Checking wallpaper repository at ''${WALLPAPER_DIR}..."
    if [ ! -d "''${WALLPAPER_DIR}/.git" ]; then
      log_error "Wallpaper repository not found at ''${WALLPAPER_DIR} (no .git directory)."
      exit 1
    fi

    if [ -n "$(git -C "$WALLPAPER_DIR" status --porcelain)" ]; then
      log_info "Uncommitted changes detected in wallpaper repository; committing..."
      git -C "$WALLPAPER_DIR" add -A
      git -C "$WALLPAPER_DIR" commit -m "feat(wallpaper): update wallpapers $(date +'%Y-%m-%d %H:%M')"
    fi

    log_info "Pushing wallpaper repository to origin..."
    if ! git -C "$WALLPAPER_DIR" push origin HEAD; then
      log_error "Failed to push wallpaper repository to origin."
      exit 1
    fi
    log_success "Wallpaper repository pushed successfully."

    # Step 2: nix flake update wallpapers
    log_info "Step 2/4: Updating wallpapers flake input in ''${REPO}..."
    if [ ! -d "''${REPO}/.git" ]; then
      log_error "Nix configuration repository not found at ''${REPO}."
      exit 1
    fi

    ORIGINAL_BRANCH=$(git -C "$REPO" rev-parse --abbrev-ref HEAD)
    if [ -n "$(git -C "$REPO" status --porcelain)" ]; then
      log_error "nix-config has uncommitted changes. Please commit, stash, or discard them first."
      exit 1
    fi

    TIMESTAMP=$(date +'%Y%m%d-%H%M%S')
    UPDATE_BRANCH="wallpaper-update-''${TIMESTAMP}"

    if [ "$ORIGINAL_BRANCH" = "main" ]; then
      log_info "Fast-forwarding local main branch from origin..."
      git -C "$REPO" pull --ff-only origin main || log_warn "Could not fast-forward main; continuing on current commit."
      log_info "Creating dedicated update branch ''${UPDATE_BRANCH}..."
      git -C "$REPO" checkout -b "$UPDATE_BRANCH"
    else
      log_info "Currently on feature branch ''${ORIGINAL_BRANCH}; fetching latest origin/main..."
      git -C "$REPO" fetch origin main || log_warn "Could not fetch origin/main; branching from local origin/main."
      log_info "Creating dedicated update branch ''${UPDATE_BRANCH} from origin/main..."
      git -C "$REPO" checkout -b "$UPDATE_BRANCH" origin/main
    fi

    log_info "Running 'nix flake update wallpapers'..."
    if ! (cd "$REPO" && nix flake update wallpapers); then
      log_error "Failed to update wallpapers input."
      git -C "$REPO" checkout "$ORIGINAL_BRANCH"
      git -C "$REPO" branch -D "$UPDATE_BRANCH" 2>/dev/null || true
      exit 1
    fi

    if [ -z "$(git -C "$REPO" status --porcelain flake.lock)" ]; then
      log_info "flake.lock is already up to date with the latest wallpapers."
      git -C "$REPO" checkout "$ORIGINAL_BRANCH"
      git -C "$REPO" branch -D "$UPDATE_BRANCH" 2>/dev/null || true
      exit 0
    fi
    log_success "flake.lock successfully updated with new wallpaper revision."

    # Step 3: nrs (rebuild)
    log_info "Step 3/4: Rebuilding system live (rebuild / nrs)..."
    if ! rebuild; then
      log_error "System rebuild failed. Restoring repository state..."
      git -C "$REPO" checkout "$ORIGINAL_BRANCH"
      git -C "$REPO" branch -D "$UPDATE_BRANCH" 2>/dev/null || true
      exit 1
    fi
    log_success "System rebuilt and switched live."

    # Step 4: commit, push, and automerge
    log_info "Step 4/4: Committing, pushing, and creating auto-merge request..."
    (cd "$REPO" && nix fmt)

    COMMIT_MSG="chore(flake): update wallpapers $(date +'%Y-%m-%d')"
    git -C "$REPO" add flake.lock
    git -C "$REPO" commit -m "$COMMIT_MSG"

    log_info "Pushing update branch with GitLab push options for auto-merge..."
    if ! git -C "$REPO" push -u origin "$UPDATE_BRANCH" \
      -o merge_request.create \
      -o merge_request.target=main \
      -o merge_request.title="$COMMIT_MSG" \
      -o merge_request.description="Automated wallpaper update via update-wallpaper script." \
      -o merge_request.auto_merge \
      -o merge_request.remove_source_branch \
      -o merge_request.squash; then
      log_error "Failed to push update branch to origin."
      exit 1
    fi
    log_success "Pushed with GitLab push options (auto-merge requested)."

    log_info "Returning repository to ''${ORIGINAL_BRANCH}..."
    git -C "$REPO" checkout "$ORIGINAL_BRANCH"

    echo ""
    log_success "Wallpaper update pipeline finished successfully!"
    printf "    %b1. Wallpaper repository pushed%b\n" "$BOLD" "$RESET"
    printf "    %b2. flake.lock updated%b\n" "$BOLD" "$RESET"
    printf "    %b3. NixOS live switch completed%b\n" "$BOLD" "$RESET"
    printf "    %b4. MR submitted with auto-merge enabled%b\n" "$BOLD" "$RESET"
  '';
}
