default:
    @just --list

# Rebuild, stage boot entry, and activate live system generation
switch:
    rebuild

# Build and stage next boot generation without switching live
boot:
    sudo nixos-rebuild boot --flake ".#$(hostname)"

# Format and lint repository via treefmt-nix
format:
    nix fmt

# Run formatting checks and verify flake evaluation
check:
    nix fmt -- --fail-on-change
    nix flake check --no-build

# Evaluate a single host's system toplevel derivation
eval host=`hostname`:
    nix eval ".#nixosConfigurations.{{ host }}.config.system.build.toplevel.drvPath"

# Build the custom NixOS installer ISO
build-iso:
    nix build .#nixosConfigurations.installer.config.system.build.isoImage

# Sync private wallpapers, update wallpapers input, rebuild, and open auto-merge MR
wallpaper:
    update-wallpaper

# Rekey all agenix secrets
rekey:
    cd secrets && agenix -r

# Force-run flake-update-verifier on demand
verify:
    flake-update-verifier --force
