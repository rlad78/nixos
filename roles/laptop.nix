{ config, lib, pkgs, pkgs-unstable, ... }:
let
  root-config-dir = ./..;
  cfg = config.arf.laptop;
in
{
  imports = lib.lists.forEach [
    "/apps"
    "/system"
    "/system/printing.nix"
    "/services/syncthing.nix"
    "/services/tailscale.nix"
  ] (p: root-config-dir + p);

  options.arf.laptop = with lib; {
    fwupd = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    arf = {
      gc = {
        enable = true;
        frequency = "weekly";
        older-than = 14;
      };
      cli.plugins = [ "systemd" "z" ];
      builders = [ "nixarf" ];
    };

    boot.kernelPackages = pkgs-unstable.linuxKernel.packages.linux_zen;
    networking.networkmanager.enable = true;

    services.fwupd.enable = cfg.fwupd;
  };
}
