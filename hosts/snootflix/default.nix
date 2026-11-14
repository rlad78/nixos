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
    };
    # romm = {
    #   enable = true;
    #   libraryDir = /snoot/romm;
    # };
    cli = {
      theme = "jonathan";
      plugins = [
        "systemd"
        "z"
      ];
    };
    # romm = {
    #   enable = true;
    #   libraryDir = /snoot/romm;
    #   hosting = {
    #     enable = true;
    #     url = "retro.snootflix.com";
    #   };
    # };
    searxng = {
      bind-address = hosts.snootflix.tail-ip;
      waitForTailscale = true;
      port = 5454;
    };
  };

  imports = [
    ./hardware-configuration.nix
    # ./media-storage.nix
  ]
  ++ lib.lists.forEach [
    # "/roles/snootflix.nix"
    "/roles/new-snootflix.nix"
    "/services/tailscale.nix"
    "/system/systemd-boot.nix"
    "/hosts/common/nvidia.nix"
    # "/services/romm.nix"
    "/services/mcp-nixos.nix"
    "/services/searxng.nix"
  ] (p: root-config-dir + p);

  networking.hostName = "snootflix";
  system.stateVersion = "26.05";
}
