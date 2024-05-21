{ config, pkgs, lib, hosts, ... }:
let
  mnt-prefix = "mediadisk";
  mergerfs-dir = "/snoot";

  disks-by-uuid = with lib.lists; forEach  [
    "3b5ccd1e-00ea-4dac-b27f-1c7822c737c4"
    "2f2168da-b5d0-4b06-bbb4-e70b042a412f"
    "feea2c5b-65c4-4368-8960-ca84fcaf1d42"
    "ba7fc5c0-df48-4a5a-b20a-7e0b653b6060"
  ] (x: "/dev/disk/by-uuid/${x}");

  # -----

  disks-with-mnt = with lib; lists.zipListsWith (
    a: b: {mnt = "/mnt/${mnt-prefix}${builtins.toString b}"; uuid = a;}
  ) disks-by-uuid (lists.range 1 (builtins.length disks-by-uuid));

  my-device-ips = with lib; lists.unique (lists.flatten (
    builtins.map (a: attrsets.attrValues a) (
      builtins.map (x: attrsets.filterAttrs (
        n: v: builtins.elem n [ "tail-ip" "local-ip" ]) x) (
          builtins.attrValues hosts)
      )
    )
  );
in
{
  nixarr = {
    enable = true;
    mediaUsers = [ "richard" ];
    mediaDir = mergerfs-dir;
    stateDir = "/config";
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
    sabnzbd = {
      enable = true;
      openFirewall = true;
      whitelistRanges = [ "10.0.0.0/23" "100.64.0.0/10" ];
      guiPort = 9999;
    };
    sonarr.enable = true;
    radarr.enable = true;
    prowlarr.enable = true;
    transmission = {
      enable = true;
      extraAllowedIps = my-device-ips;
      flood.enable = true;
    };
  };

  services.plex = {
    enable = true;
    user = "streamer";
    group = "media";
    dataDir = "${config.nixarr.stateDir}/plex";
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d ${config.services.plex.dataDir} 0700 streamer media"
    "d ${mergerfs-dir} 0770 root media"
    "d ${mergerfs-dir}/library/anime 0770 streamer media"
  ];

  # drive management
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
    recyclarr
  ];

  fileSystems = with lib; attrsets.mergeAttrsList (
    builtins.map (x: {${x.mnt} = {
      device = x.uuid;
      fsType = "ext4";
      options = [ "defaults" "nofail" ];
    };}) disks-with-mnt
  ) // {
    ${mergerfs-dir} = {
      fsType = "fuse.mergerfs";
      device = "/mnt/${mnt-prefix}*";
      noCheck = true;
      options = [ "defaults" "nonempty" "allow_other" "use_ino" "minfreespace=100M" "category.create=mspmfs" ];
    };
  };
}

