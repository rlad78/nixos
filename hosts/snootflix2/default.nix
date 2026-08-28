{ lib, hosts, ... }:
let
  root-config-dir = ./../..;
in
{
  arf = {
    cli = {
      theme = "jonathan";
      plugins = [
        "systemd"
        "z"
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
    ./media-storage.nix
  ]
  ++ lib.lists.forEach [
    "/roles/snootflix.nix"
    "/system/systemd-boot.nix"
    "/hosts/common/nvidia.nix"
    "/services/romm.nix"
    "/services/mcp-nixos.nix"
    "/services/searxng.nix"
  ] (p: root-config-dir + p);

  # pub key for docker hermes ssh
  users.users.richard.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFYCF8xscUgYYkxKQ9sjSjKQ1D+cJDIVlJ7cIUI1rFCk hermes@snootflix"
  ];

  networking.hostName = "snootflix";
  system.stateVersion = "25.11";
}
