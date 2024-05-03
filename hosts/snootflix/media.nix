{ config, pkgs, lib, ... }:
let
  disks-by-uuid = with lib.lists; forEach  [
    "3b5ccd1e-00ea-4dac-b27f-1c7822c737c4"
    "2f2168da-b5d0-4b06-bbb4-e70b042a412f"
    "feea2c5b-65c4-4368-8960-ca84fcaf1d42"
    "bd370bec-2c57-4c20-ac85-98a40421a3a0"
  ] (x: "/dev/disk/by-uuid/${x}");

  disks-with-mnt = with lib; lists.zipListsWith (
    a: b: {mnt = "/mnt/baydisk${builtins.toString b}"; uuid = a;}
  ) disks-by-uuid (lists.range 1 (builtins.length disks-by-uuid));
in
{
  nixarr = {
    enable = true;
    mediaDir = "/media";
    stateDir = "/config";
    sabnzbd = {
      enable = true;
      openFirewall = true;
      whitelistRanges = [ "10.0.0.0/23" "100.64.0.0/10" ];
    };
    sonarr.enable = true;
    radarr.enable = true;
    prowlarr.enable = true;
    transmission = {
      enable = true;
      extraAllowedIps = [ "10.0.1.*" "10.0.0.*" ];
      flood.enable = true;
    };
  };

  users.users.plex = {
    isSystemUser = true;
    group = "media";
  };

  services.plex = {
    enable = true;
    user = "plex";
    group = "media";
    dataDir = "/config/plex";
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d /config/plex 0770 plex media"
  ];

  # drive management
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
  ];

  # systemd.tmpfiles.rules = [
    # "d '/drivebay' 0770 root media"
  # ] ++ builtins.map (x: "d ${x.mnt} 0770 root media") disks-with-mnt;

  fileSystems = with lib; attrsets.mergeAttrsList (
    builtins.map (x: {${x.mnt} = {
      device = x.uuid;
      fsType = "ext4";
    };}) disks-with-mnt
  ) // {
    "/drivebay" = {
      fsType = "fuse.mergerfs";
      device = "/mnt/baydisk*";
      options = [ "minfreespace=500M" ];
    };
  };
}

