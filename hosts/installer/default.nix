{
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:

let
  keys = import ../../secrets/keys.nix;
  userPublicKeys = builtins.attrValues keys.users;
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  networking = {
    hostName = "installer";
    wireless.enable = lib.mkForce false; # Let NetworkManager manage Wi-Fi interfaces
    networkmanager.enable = true;
  };

  # mDNS for zero-configuration local network resolution (installer.local)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # OpenSSH server with pre-authorized keys for passwordless remote login
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };

  # Pre-authorize workstation user public keys from secrets/keys.nix
  users.users.root.openssh.authorizedKeys.keys = userPublicKeys;
  users.users.nixos.openssh.authorizedKeys.keys = userPublicKeys;

  # Essential tools for inspection, partitioning, and automated provisioning
  environment.systemPackages = with pkgs; [
    curl
    git
    neovim
    p7zip
    parted
    tmux
  ];

  # Pre-embed a full, writable copy of the nix-config repository on the live ISO
  systemd.services.populate-nix-config = {
    description = "Populate local copy of nix-config repository on live environment";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = with pkgs; [
      coreutils
      git
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      DEST_DIR="/root/nix-config"
      if [ ! -d "$DEST_DIR" ]; then
        echo "Provisioning local nix-config repository to $DEST_DIR..."
        cp -r --no-preserve=mode,ownership "${inputs.self}" "$DEST_DIR"
        cd "$DEST_DIR"
        git init -b main
        git config user.name "NixOS Installer"
        git config user.email "installer@local"
        git config pull.rebase true
        git remote add origin "https://gitlab.com/kylekwong/nix-config.git"
        git add -A
        git commit -m "chore: snapshot nix-config from installer ISO" || true
        mkdir -p /home/nixos
        ln -sfn "$DEST_DIR" /home/nixos/nix-config
        echo "nix-config successfully provisioned at $DEST_DIR."
      fi
    '';
  };
}
