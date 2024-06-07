{ config, pkgs, lib, hosts, ... }:
let
  mnt-prefix = "mediadisk";
  mergerfs-dir = "/snoot";

  sonarr-anime = {
    config-dir = "${config.nixarr.stateDir}/sonarr-anime";
    hostPort = 8981;
    uid = 990;
    media-gid = 994;
  };

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
  arf = {
    scrutiny = {
      enable = true;
      drives = [ /dev/nvme0n1 ] ++ disks-by-uuid;
      config-dir = /scrutiny;
      port = 9999;
    };
  };

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
      guiPort = 8080;
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

  services.tautulli = {
    enable = true;
    user = "tautulli";
    group = "media";
    openFirewall = true;
    port = 8888;
    dataDir = "${config.nixarr.stateDir}/tautulli";
  };

  users.users.tautulli = {
    isSystemUser = true;
    group = "media";
  };

  users.users.sonarr-anime = {
    isSystemUser = true;
    group = "media";
    uid = sonarr-anime.uid;
  };

  users.groups.media.gid = sonarr-anime.media-gid;

  containers.sonarr-anime = let
    fromHost = {
      user = rec {
        name = "sonarr-anime";
        uid = sonarr-anime.uid;
      };
      group = rec {
        name = "media";
        gid = sonarr-anime.media-gid;
      };
    };
  in {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.1.69";
    localAddress = "10.0.0.69";
    ephemeral = true;
    bindMounts = {
      "${mergerfs-dir}" = {
        hostPath = mergerfs-dir;
        isReadOnly = false;
      };
      "${sonarr-anime.config-dir}" = {
        hostPath = sonarr-anime.config-dir;
        isReadOnly = false;
      };
    };
    forwardPorts = [
      {
        containerPort = 8989;
        hostPort = sonarr-anime.hostPort;
        protocol = "tcp";
      }
    ];

    config = { config, pkgs, ... }: {
      users = {
        users."${fromHost.user.name}" = {
          uid = fromHost.user.uid;
          isSystemUser = true;
          group = fromHost.group.name;
        };
        groups."${fromHost.group.name}" = {
          gid = fromHost.group.gid;

        };
      };
      services.sonarr = {
        enable = true;
        openFirewall = true;
        user = fromHost.user.name;
        group = fromHost.group.name;
        dataDir = "${sonarr-anime.config-dir}";
      };
     system.stateVersion = "23.11";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8981 ];

  systemd.tmpfiles.rules = [
    "d ${config.services.plex.dataDir} 0700 streamer media"
    "d ${config.services.tautulli.dataDir} 0700 tautulli media"
    "d ${sonarr-anime.config-dir} 0700 sonarr-anime media"
    "d ${mergerfs-dir} 0775 root media"
    "d ${mergerfs-dir}/library/anime 0775 streamer media"
    "d ${mergerfs-dir}/usenet/sonarr-anime 0755 usenet media"
    "d ${mergerfs-dir}/torrents/sonarr-anime 0755 torrenter media"
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

