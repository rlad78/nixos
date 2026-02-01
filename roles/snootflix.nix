{ config, lib, pkgs, pkgs-unstable, hosts, secrets, ...}:
let
  root-config-dir = ./..;
  cfg = config.arf.snootflix;

  media-root-dir-name = "snoot";
  media-root-dir = "/${media-root-dir-name}";
  disks-target-name = "snoot-disks";

  sonarr-anime = {
    config-dir = "${config.nixarr.stateDir}/sonarr-anime";
    hostPort = 8981;
    uid = 8981;
    media-gid = config.users.groups.media.gid;
  };

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
  imports = lib.lists.forEach [
    "/system"
    "/desktop-env/no-desktop.nix"
    "/apps/cli"
    "/services/tailscale.nix"
    "/services/syncthing.nix"
    "/services/sshd.nix"
    "/services/scrutiny.nix"
  ] (p: root-config-dir + p);

  options.arf.snootflix = with lib; {
    mediaDiskPrefix = mkOption {
      type = types.str;
      default = "mediadisk";
    };

    stateRootDir = mkOption {
      type = types.path;
      default = /config;
    };
  };

  config = {
    arf = {
      gc = {
        enable = true;
        frequency = "weekly";
        older-than = 14;
      };
      nvidia.version = "production";
      inner-nat = true;
    };

    systemd.targets.${disks-target-name} = let
      media-mounts = with lib; lists.forEach (range 1 4) (
        n: "mnt-${cfg.mediaDiskPrefix}${toString n}.mount"
      );
    in {
      requires = [ "${media-root-dir-name}.mount" ] ++ media-mounts;
      after = [ "${media-root-dir-name}.mount" ] ++ media-mounts;
      bindsTo = [ "${media-root-dir-name}.mount" ] ++ media-mounts;
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services = let
      snoot-group-def = {
        bindsTo = [ "${disks-target-name}.target" ];
        partOf = [ "${disks-target-name}.target" ];
        after = [ "${disks-target-name}.target" ];
        wantedBy = [ "${disks-target-name}.target" ];
      };
    in lib.attrsets.genAttrs [
      "jellyfin"
      "jellyseerr"
      "prowlarr"
      "sonarr"
      "container@sonarr-anime"
      "sabnzbd"
      "transmission"
    ] (n: snoot-group-def);

    nixarr = {
      enable = true;
      mediaUsers = [ "richard" ];
      mediaDir = media-root-dir;
      stateDir = builtins.toString cfg.stateRootDir;

      jellyfin = {
        enable = true;
        package = pkgs-unstable.jellyfin;
        openFirewall = true;
        expose.https = {
          enable = false;
          domainName = "snootflix.com";
        };
      };

      jellyseerr = {
        enable = true;
        package = pkgs-unstable.jellyseerr;
        openFirewall = true;
        port = 5055;
        expose.https = {
          enable = false;
          domainName = "request.snootflix.com";
        };
      };

      prowlarr = {
        enable = true;
        package = pkgs-unstable.prowlarr;
        openFirewall = true;
        port = 9696;
      };

      radarr = {
        enable = true;
        package = pkgs-unstable.radarr;
        openFirewall = true;
        port = 7878;
      };

      recyclarr = {
        enable = true;
        package = pkgs-unstable.recyclarr;
        configuration = import ./snootflix_src/recyclarr.nix { inherit secrets; };
      };

      sabnzbd = {
        enable = true;
        package = pkgs.sabnzbd;
        guiPort = 6336;
        openFirewall = true;
        whitelistHostnames = [
          config.networking.hostName # tailscale
          hosts.${config.networking.hostName}.tail-ip
          # hosts.${config.networking.hostName}.local-ip
        ];
        whitelistRanges = [
          "10.69.0.0/22"
          "100.64.0.0/10" # tailscale
        ];
      };

      sonarr = {
        enable = true;
        openFirewall = true;
        port = 8989;
      };

      transmission = {
        enable = true;
        package = pkgs-unstable.transmission_4;
        extraAllowedIps = my-device-ips;
        flood.enable = true;
        extraSettings = {
          speed-limit-down = 37500;
          speed-limit-down-enabled = true;
          speed-limit-up = 37500;
          speed-limit-up-enabled = true;

          trash-can-enabled = false;
          trash-original-torrent-files = true;

          rpc-host-whitelist = "snootflix";
        };
      };
    };

    # sonarr-anime
    users.users.sonarr-anime = {
      isSystemUser = true;
      group = "media";
      uid = sonarr-anime.uid;
    };

    systemd.tmpfiles.rules = [
      "d ${sonarr-anime.config-dir} 0700 sonarr-anime media"
      "d ${media-root-dir}/library/anime 0775 streamer media"
      "d ${media-root-dir}/usenet/sonarr-anime 0775 usenet media"
      "d ${media-root-dir}/torrents/sonarr-anime 0755 torrenter media"
    ];

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
        sonarr-package = pkgs-unstable.sonarr;
        media-dir = media-root-dir;
      };
    in {
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
          package = fromHost.sonarr-package;
          openFirewall = true;
          user = fromHost.user.name;
          group = fromHost.group.name;
          dataDir = "${sonarr-anime.config-dir}";
        };

        networking.useHostResolvConf = lib.mkForce false;
        services.resolved.enable = true;

        system.stateVersion = "25.11";
      };
    };

    # add unmanic
    # add janitorr
    # add wizarr

  };
}
