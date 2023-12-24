{ lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
    "lz4"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=lz4"
    "zswap.zpool=zsmalloc"
  ];
  boot.initrd = {
    compressor = "zstd";
    compressorArgs = [ "-19" "-T0" ];
    systemd.enable = true;
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  disko.devices = {
    disk = {
      sda = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };

            root = {
              end = "-200M";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" "--csum xxhash64" ];
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress-force=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
                  };
                  "home" = {
                    mountOptions = [ "compress-force=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
                    mountpoint = "/home";
                  };
                  "nix" = {
                    mountOptions = [ "compress-force=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
                    mountpoint = "/nix";
                  };
                  "var" = {
                    mountOptions = [ "compress-force=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
                    mountpoint = "/var";
                  };
                };
              };
            };
            plainSwap = {
              size = "100%";
              content = {
                type = "swap";
                resumeDevice = true; # resume from hiberation from this device
              };
            };
          };
        };
      };
    };
  };
}