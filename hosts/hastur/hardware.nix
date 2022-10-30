# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config
, lib
, pkgs
, modulesPath
, ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    kernelPackages = pkgs.linuxPackages_latest;
  };


  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e86a6cfa-39cc-4dd9-b5d3-fee5e2613578";
    fsType = "btrfs";
    options = [ "subvol=root" "compress-force=zstd" "noatime" "discard=async" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/e86a6cfa-39cc-4dd9-b5d3-fee5e2613578";
    fsType = "btrfs";
    options = [ "subvol=home" "compress-force=zstd" "noatime" "discard=async" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/e86a6cfa-39cc-4dd9-b5d3-fee5e2613578";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress-force=zstd" "noatime" "discard=async" ];
  };
  fileSystems."/home/riro/exchange" = {
    device = "/dev/disk/by-uuid/B01E136B1E1329BC";
    fsType = "ntfs";
    options = [ "rw" "uid=1000" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F680-4A3F";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/swap/swapfile"; }
  ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}