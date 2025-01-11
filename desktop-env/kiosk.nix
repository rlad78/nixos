{ config, pkgs, lib, ... }:
let
  cfg = config.arf;
in
{
  imports = [ ./base.nix ];

  options.arf.web-kiosk-url = with lib; mkOption {
    type = types.str;
    default = "https://google.com";
  };

  config = {
    users.users.kiosk = {
      isNormalUser = true;
    };

    environment.systemPackages = [ pkgs.firefox ];

    services.cage = {
      enable = true;
      user = "kiosk";
      program = "${pkgs.firefox}/bin/firefox -kiosk ${cfg.web-kiosk-url}";
    };
  };
}
