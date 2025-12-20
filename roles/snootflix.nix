{ config, lib, pkgs, hosts, ...}:
let
  root-config-dir = ./..;
  cfg = config.arf.snootflix;

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
        openFirewall = true;
        expose.https = {
          enable = false;
          domainName = "snootflix.com";
        };
      };

      jellyseerr = {
        enable = true;
        openFirewall = true;
        port = 5055;
        expose.https = {
          enable = false;
          domainName = "request.snootflix.com";
        };
      };

      prowlarr = {
        enable = true;
        openFirewall = true;
        port = 9696;
      };

      radarr = {
        enable = true;
        openFirewall = true;
        port = 7878;
      };

      recyclarr = {
        enable = true;
        configuration = import ./snootflix_src/recyclarr.nix;
      };

      sabnzbd = {
        enable = true;
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

    # add sonarr-anime
    # add unmanic
    # add janitorr
    # add wizarr

  };
}
