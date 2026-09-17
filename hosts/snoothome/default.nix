{ lib, ... }:
let
  root-config-dir = ./../..;
in
{
  arf = {
    cli = {
      theme = "agnoster";
      plugins = [
        "systemd"
        "z"
      ];
    };
    builders = [ "nixarf" ];
  };

  imports = [
    ./hardware-configuration.nix
  ]
  ++ lib.lists.forEach [
    "/system"
    "/system/systemd-boot.nix"
    "/desktop-env/no-desktop.nix"
    "/apps/cli/editors.nix"
    "/apps/cli/internet.nix"
    "/apps/cli/utils.nix"
    "/services/tailscale.nix"
    "/services/sshd.nix"
    "/services/unifi.nix"
  ] (p: root-config-dir + p);

  networking.networkmanager.enable = true;
  networking.hostName = "snoothome";

  system.stateVersion = "26.05";
}
