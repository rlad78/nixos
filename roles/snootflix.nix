{ config, lib, pkgs, pkgs-unstable, hosts, ...}:
let
  root-config-dir = ./..;
  cfg = config.arf.snootflix;

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
    "/hosts/common/nvidia.nix"
    "/apps/cli"
    "/services/tailscale.nix"
    "/services/syncthing.nix"
    "/services/sshd.nix"
    "/services/scrutiny.nix"
  ] (p: root-config-dir + p);

  options.arf.snootflix = with lib; {
    mediaRootDir = mkOption {
      type = types.path;
      default = /snoot;
    };

    stateRootDir = mkOption {
      type = types.path;
      default = /snoot;
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

    nixarr = {
      enable = true;
      mediaUsers = [ "richard" ];
      mediaDir = builtins.toString cfg.mediaRootDir;
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
        configuration = import ./snootflix_src/recyclarr.nix;
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
        media-dir = builtins.toString cfg.mediaRootDir;
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
