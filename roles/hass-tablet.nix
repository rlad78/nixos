{ config, lib, ... }:
let
  root-config-dir = ./..;
  cfg = config.arf.hass-tablet;
in
{
  options.arf.hass-tablet = with lib; {
    page-url = mkOption {
      type = types.str;
    };
  };

  config = {
    arf = {
      gc = {
        enable = true;
        frequency = "weekly";
        older-than = 14;
      };
      web-kiosk-url = cfg.page-url;
      restart = {
        enable = true;
        time = "02:00:00";
      };
    };

    imports = lib.lists.forEach [
      "/desktop-env/kiosk.nix"
      "/system"
      "/apps/cli"
      "/services/sshd.nix"
      "/services/restart.nix"
      "/services/tailscale.nix"
      "/services/syncthing.nix"
    ] (p: root-config-dir + p);
  };
}
