{ config, lib, ... }:
let
  root-config-dir = ./..;
  cfg = config.arf.laptop;
in
{
  options = with lib; {
    fwupd = mkOption {
      type = types.bool;
      default = true;
    };

    desktop = mkOption {
      type = types.enum [
        "gnome"
        "plasma"
        "cosmic"
      ];
      default = "plasma";
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

    imports = lib.lists.forEach [
      "/apps"
      "/system"
      "/system/printing.nix"
      "/desktop-env/${cfg.desktop}.nix"
      "/services/syncthing.nix"
      "/services/tailscale.nix"
    ] (p: root-config-dir + p);

    boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    networking.networkmanager.enable = true;

    services.fwupd.enable = cfg.fwupd;
  };
}
