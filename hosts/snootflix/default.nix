{ lib, hosts, ... }:
let
  root-config-dir = ./../..;
in
{
  arf = {
    snootflix = {
      mediaDiskLabels = [
        "usb-4T-1"
        "usb-4T-2"
        "usb-2T-1"
        "usb-2T-2"
      ];
      mediaDiskServices = [
        "jellyfin"
        "seerr"
        "prowlarr"
        "sonarr"
        "container@sonarr-anime"
        "sabnzbd"
        "transmission"
        "podman-romm"
      ];
      bandwidth = {
        downMegabits = 900;
        upMegabits = 900;
      };
    };
    cli = {
      theme = "jonathan";
      plugins = [
        "systemd"
        "z"
      ];
    };
    nixBuilder = {
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDb+4coRe5EocasxqwkrjYxZBpFfhYXlcXXNpIxBzMdW root@nixpad"
      ];
    };
    romm = {
      enable = true;
      libraryDir = /snoot/romm;
      hosting = {
        enable = true;
        url = "retro.snootflix.com";
      };
    };
    searxng = {
      bind-address = hosts.snootflix.tail-ip;
      waitForTailscale = true;
      port = 5454;
    };
  };

  imports = [
    ./hardware-configuration.nix
  ]
  ++ lib.lists.forEach [
    "/roles/snootflix.nix"
    "/services/tailscale.nix"
    "/system/systemd-boot.nix"
    "/hosts/common/nvidia.nix"
    "/services/romm.nix"
    "/services/mcp-nixos.nix"
    "/services/searxng.nix"
    "/services/nix-builder-new.nix"
  ] (p: root-config-dir + p);

  networking.hostName = "snootflix";
  system.stateVersion = "26.05";
}
