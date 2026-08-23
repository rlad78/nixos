{
  config,
  lib,
  pkgs,
  ...
}:
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
      cli.plugins = [
        "systemd"
        "z"
      ];
      builders = [ "nixarf" ];
    };

    # add udev rules for 8bitdo web updater
    services.udev.extraRules = ''
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2dc8", MODE="0666", GROUP="users", TAG+="uaccess"
    '';

    boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    networking.networkmanager.enable = true;

    services.fwupd.enable = cfg.fwupd;
  };
}
