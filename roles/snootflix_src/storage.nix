{
  config,
  pkgs,
  lib,
  utils,
  ...
}:
let
  cfg = config.arf.snootflix;
  mount-target-name = "snoot-disks";
  target-services = [
    "jellyfin"
    "seerr"
    "prowlarr"
    "sonarr"
    "container@sonarr-anime"
    "sabnzbd"
    "transmission"
  ];

  btrfs-options = [
    "compress-force=zstd:11"
    "noatime"
    "autodefrag"
    "nofail"
  ];

  mergerfs-options = [
    "defaults"
    "minfreespace=500M"
    "category.create=mfs"
    "nofail"
  ];

  mkBtrfsDisk = label: {
    device = "/dev/disk/by-label/${label}";
    fsType = "btrfs";
    options = btrfs-options;
  };

  media-filesystems = builtins.listToAttrs (
    lib.imap1 (
      n: label: lib.nameValuePair "/mnt/${cfg.mediaDiskPrefix}${toString n}" (mkBtrfsDisk label)
    ) cfg.mediaDiskLabels
  );

  mergerfs-filesystem = {
    ${toString cfg.mediaRootDir} = {
      fsType = "fuse.mergerfs";
      device = "/mnt/${cfg.mediaDiskPrefix}*";
      noCheck = true;
      options = mergerfs-options;
    };
  };
in
{
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
  ];

  fileSystems = media-filesystems // mergerfs-filesystem;

  systemd.targets.${mount-target-name} =
    let
      mount-targets = map (dir: "${utils.escapeSystemdPath dir}.mount") (
        builtins.attrNames (media-filesystems // mergerfs-filesystem)
      );
    in
    {
      requires = mount-targets;
      after = mount-targets;
      bindsTo = mount-targets;
      wantedBy = [ "multi-user.target" ];
    };

  systemd.services =
    let
      disk-group-def = {
        bindsTo = [ "${mount-target-name}.target" ];
        partOf = [ "${mount-target-name}.target" ];
        after = [ "${mount-target-name}.target" ];
        wantedBy = [ "${mount-target-name}.target" ];
      };
    in
    lib.attrsets.genAttrs target-services (n: disk-group-def);
}
