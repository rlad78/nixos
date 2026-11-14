{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.arf.snootflix;
  hostConfig = config;

  sonarr-anime-uid = 8981;

  mediaUserCfg = {
    isSystemUser = true;
    group = "media";
  };
in
{
  systemd.tmpfiles.rules = [
    "d ${cfg.stateRootDir}/prowlarr 0700 prowlarr media"
    "d ${cfg.stateRootDir}/sonarr 0700 sonarr media"
    "d ${cfg.stateRootDir}/sonarr-anime 0700 sonarr-anime media"
  ];

  environment.systemPackages = with pkgs; [ recyclarr ];

  users.users.prowlarr = mediaUserCfg;
  services.prowlarr = {
    enable = true;
    dataDir = "${cfg.stateRootDir}/prowlarr";
    openFirewall = true;
  };

  users.users.radarr = mediaUserCfg;
  services.radarr = {
    enable = true;
    user = "radarr";
    group = "media";
    dataDir = "${cfg.stateRootDir}/radarr";
    openFirewall = true;
  };

  users.users.sonarr = mediaUserCfg;
  services.sonarr = {
    enable = true;
    user = "sonarr";
    group = "media";
    dataDir = "${cfg.stateRootDir}/sonarr";
    openFirewall = true;
  };

  users.users.sonarr-anime = mediaUserCfg // {
    uid = sonarr-anime-uid;
  };
  containers.sonarr-anime =
    let
      sonarr-package = pkgs.sonarr;
      state-version = config.system.stateVersion;
    in
    {
      autoStart = true;
      privateNetwork = true;
      hostAddress = cfg.networking.hostVirtualAddress;
      localAddress = cfg.networking.containerVirtualAddress;
      ephemeral = true;
      bindMounts = {
        "${cfg.mediaRootDir}" = {
          hostPath = cfg.mediaRootDir;
          isReadOnly = false;
        };
        "${cfg.stateRootDir}/sonarr-anime" = {
          hostPath = "${cfg.stateRootDir}/sonarr-anime";
          isReadOnly = false;
        };
      };
      forwardPorts = [
        {
          containerPort = 8989;
          hostPort = cfg.ports.sonarr-anime;
          protocol = "tcp";
        }
      ];

      config =
        { ... }:
        {
          users = {
            users.sonarr-anime = {
              uid = hostConfig.users.users.sonarr-anime.uid;
              isSystemUser = true;
              group = "media";
            };
            groups.media = {
              gid = hostConfig.users.groups.media.gid;
            };
          };
          services.sonarr = {
            enable = true;
            package = sonarr-package;
            openFirewall = true;
            user = "sonarr-anime";
            group = "media";
            dataDir = "${cfg.stateRootDir}/sonarr-anime";
          };

          networking.useHostResolvConf = lib.mkForce false;
          services.resolved.enable = true;

          system.stateVersion = state-version;
        };
    };
}
