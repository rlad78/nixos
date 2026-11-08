{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.arf.snootflix;

  mediaUserCfg = {
    isSystemUser = true;
    group = "media";
  };

  sonarr-anime-cfg = {
    # hostPort = 8981;
    uid = 8981;
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
    uid = sonarr-anime-cfg.uid;
  };
  containers.sonarr-anime =
    let
      fromHost = {
        user = {
          name = "sonarr-anime";
          uid = sonarr-anime-cfg.uid;
        };
        group = {
          name = "media";
          gid = config.users.groups.media.gid;
        };
        sonarr-package = pkgs.sonarr;
        media-dir = cfg.mediaRootDir;
        config-dir = cfg.stateRootDir;
        state-version = config.system.stateVersion;
      };
    in
    {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "10.0.0.10";
      localAddress = "10.0.0.69";
      ephemeral = true;
      bindMounts = {
        "${fromHost.media-dir}" = {
          hostPath = fromHost.media-dir;
          isReadOnly = false;
        };
        "${fromHost.config-dir}/sonarr-anime" = {
          hostPath = "${fromHost.config-dir}/sonarr-anime";
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
            package = fromHost.sonarr-package;
            openFirewall = true;
            user = fromHost.user.name;
            group = fromHost.group.name;
            dataDir = "${fromHost.config-dir}/sonarr-anime";
          };

          networking.useHostResolvConf = lib.mkForce false;
          services.resolved.enable = true;

          system.stateVersion = fromHost.state-version;
        };
    };
}
