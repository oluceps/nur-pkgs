{ inputs, pkgs, data, lib, ... }:
[
  (inputs.nixpkgs
  + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix")
] ++ [

  {
    isoImage = {
      compressImage = true;
      squashfsCompression = "zstd -Xcompression-level 6";
    };
    programs.fish.enable = true;

    systemd.services.nix-daemon = {
      serviceConfig.LimitNOFILE = lib.mkForce 500000000;
      path = [ pkgs.netcat-openbsd ];
    };
    nix =
      {
        package = pkgs.nixVersions.stable;
        registry = {
          nixpkgs.flake = inputs.nixpkgs;
          self.flake = inputs.self;
        };
        settings = {

          keep-outputs = true;
          keep-derivations = true;
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
            "nur-pkgs.cachix.org-1:PAvPHVwmEBklQPwyNZfy4VQqQjzVIaFOkYYnmnKco78="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
            "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
            "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
            "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          ];
          substituters = (map (n: "https://${n}.cachix.org")
            [ "nix-community" "nur-pkgs" "hyprland" "helix" "nixpkgs-wayland" "anyrun" "ezkea" "devenv" ])
          ++
          [
            "https://cache.nixos.org"
            "https://cache.ngi0.nixos.org"
            "https://mirror.sjtu.edu.cn/nix-channels/store"
          ];
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
            "auto-allocate-uids"
            "cgroups"
            "repl-flake"
            "recursive-nix"
            "ca-derivations"
          ];
          auto-allocate-uids = true;
          use-cgroups = true;

          trusted-users = [ "root" ];
          # Avoid disk full
          max-free = lib.mkDefault (1000 * 1000 * 1000);
          min-free = lib.mkDefault (128 * 1000 * 1000);
          builders-use-substitutes = true;
        };

        daemonCPUSchedPolicy = lib.mkDefault "batch";
        daemonIOSchedClass = lib.mkDefault "idle";
        daemonIOSchedPriority = lib.mkDefault 7;


      };

    services = {
      sing-box.enable = true;
      pcscd.enable = true;
      openssh.enable = true;
    };

    environment.systemPackages = with pkgs;[
      (
        writeShellScriptBin "mount-os" ''
          #!/usr/bin/env bash
          echo "start mounting ..."
          sudo mkdir /mnt/{persist,etc,var,efi,nix}
          sudo mount -o compress=zstd,discard=async,noatime,subvol=nix /dev/$1 /mnt/nix
          sudo mount -o compress=zstd,discard=async,noatime,subvol=persist /dev/$1 /mnt/persist
          sudo mount /dev/nvme0n1p1 /mnt/efi
          sudo mount -o bind /mnt/persist/etc /mnt/etc
          sudo mount -o bind /mnt/persist/var /mnt/var
          echo "mount finished."
        ''
      )
      rage
      nftables
      tor
      iperf3
      i2p
      ethtool
      dnsutils
      autossh
      tcpdump
      sing-box
      netcat
      dog
      wget
      mtr-gui
      socat
      arti
      miniserve
      mtr
      wakelan
      q
      nali
      lynx
      nethogs
      restic
      w3m
      whois
      dig
      wireguard-tools
      curlHTTP3

      srm

      killall
      # common
      hexyl
      jq
      fx
      bottom
      lsd
      fd
      choose
      duf
      tokei
      procs


      lsof
      tree
      bat

      broot
      powertop
      ranger

      ripgrep

      qrencode
      lazygit
      b3sum
      unzip
      zip
      coreutils

      bpftools
      inetutils
      pciutils
      usbutils
    ] ++
    [ rage age-plugin-yubikey yubikey-manager yubikey-manager-qt gnupg cryptsetup ];
  }

]
