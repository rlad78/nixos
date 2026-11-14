{
  config,
  lib,
  pkgs,
  ...
}:
let
  flake-root-dir = ./..;
  cfg = config.arf.snootflix;

  mediaUserCfg = {
    isSystemUser = true;
    group = "media";
  };

  wizarr-cfg = {
    # hostPort = 5690;
    uid = 5690;
    gid = 5690;
  };
in
{
  imports =
    lib.lists.forEach [
      "/system"
      "/desktop-env/no-desktop.nix"
      "/apps/cli"
      "/services/sshd.nix"
      "/services/scrutiny.nix"
    ] (p: flake-root-dir + p)
    ++ [ ./snootflix_src ];

  options.arf.snootflix = with lib; {
    mediaDiskLabels = mkOption {
      type = types.listOf types.str;
    };

    mediaDiskPrefix = mkOption {
      type = types.str;
      default = "mediadisk";
    };

    mediaRootDir = mkOption {
      type = types.str;
      default = "/snoot";
    };

    stateRootDir = mkOption {
      type = types.str;
      default = "/config";
    };

    ports = {
      sonarr-anime = mkOption {
        type = types.port;
        default = 8981;
      };

      wizarr = mkOption {
        type = types.port;
        default = 5690;
      };

      seerr = mkOption {
        type = types.port;
        default = 5055;
      };
    };
  };

  config = {
    arf = {
      gc = {
        enable = true;
        frequency = "weekly";
        older-than = 14;
      };
      inner-nat = true;
    };

    environment.systemPackages = with pkgs; [
      sqlite
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.mediaRootDir} 0755 root media"
      "d ${cfg.mediaRootDir}/library 0755 root media"
      "d ${cfg.mediaRootDir}/library/movies 0775 root media"
      "d ${cfg.mediaRootDir}/library/shows 0775 root media"
      "d ${cfg.mediaRootDir}/library/anime 0775 root media"
      "d ${cfg.mediaRootDir}/library/christmas 0775 root media"
      "d ${cfg.mediaRootDir}/library/halloween 0775 root media"

      "d ${cfg.stateRootDir} 0750 root media"
      "d ${cfg.stateRootDir}/jellyfin 0700 jellyfin media"
      "d ${cfg.stateRootDir}/seerr 0700 seerr media"
      "d ${cfg.stateRootDir}/wizarr 0700 wizarr media"
    ];

    users.groups.media = { };

    users.users.jellyfin = mediaUserCfg;
    services.jellyfin = {
      enable = true;
      user = "jellyfin";
      group = "media";
      dataDir = "${cfg.stateRootDir}/jellyfin";
      openFirewall = true;
      hardwareAcceleration = {
        enable = true;
        device = "/dev/dri/renderD128";
        type = "nvenc";
      };
      transcoding = {
        enableHardwareEncoding = true;
        enableToneMapping = true;
        hardwareEncodingCodecs = {
          hevc = true;
        };
        hardwareDecodingCodecs = {
          vc1 = true;
          vp8 = true;
          vp9 = true;
          h264 = true;
          hevc = true;
          hevc10bit = true;
        };
      };
    };

    services.seerr = {
      enable = true;
      port = cfg.ports.seerr;
      # configDir = "${cfg.stateRootDir}/seerr";
      openFirewall = true;
    };

    users.groups.wizarr.gid = wizarr-cfg.gid;
    users.users.wizarr = {
      isSystemUser = true;
      uid = wizarr-cfg.uid;
      group = "wizarr";
    };

    virtualisation.oci-containers.containers = {
      "wizarr" = {
        image = "ghcr.io/wizarrrr/wizarr";
        extraOptions = [
          "--pull=always"
          "--network=host"
        ];
        ports = [ "${toString cfg.ports.wizarr}:5690" ];
        volumes = [ "${cfg.stateRootDir}/wizarr:/data" ];
        environment = {
          PUID = toString wizarr-cfg.uid;
          PGID = toString wizarr-cfg.gid;
          TZ = "America/New_York";
        };
      };
    };

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
    };

    services.nginx.virtualHosts = {
      "snootflix.com" = {
        serverAliases = [ "www.snootflix.com" ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
        };
      };
      "invite.snootflix.com".locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.ports.wizarr}";
        proxyWebsockets = true;
      };
      "request.snootflix.com".locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.ports.seerr}";
        proxyWebsockets = true;
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
      # 9091
    ];
  };
}
