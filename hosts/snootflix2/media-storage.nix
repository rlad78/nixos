{ lib, pkgs, ... }:
let
  btrfs-options = [
    "compress-force=zstd:11"
    "noatime"
    "autodefrag"
    "nofail"
  ];

  mkBtrfsDisk = label: {
    device = "/dev/disk/by-label/${label}";
    fsType = "btrfs";
    options = btrfs-options;
  };

  media-disk-prefix = "mediadisk";
  mergerfs-dir = "/snoot";
in
{
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
  ];

  fileSystems = {
    "/mnt/${media-disk-prefix}1" = mkBtrfsDisk "usb-4T-1";
    "/mnt/${media-disk-prefix}2" = mkBtrfsDisk "usb-4T-2";
    "/mnt/${media-disk-prefix}3" = mkBtrfsDisk "usb-2T-1";
    "/mnt/${media-disk-prefix}4" = mkBtrfsDisk "usb-2T-2";

    ${mergerfs-dir} = {
      fsType = "fuse.mergerfs";
      device = "/mnt/${media-disk-prefix}*";
      noCheck = true;
      options = [
        "defaults"
        "minfreespace=500M"
        "category.create=mfs"
        "nofail"
      ];
    };
  };
}
