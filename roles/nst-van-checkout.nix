{ config, lib, pkgs, ... }:
let
  root-config-dir = ./..;
  # cfg = config.arf.van-checkout;
in
{
  imports = lib.lists.forEach [
    "/system"
    "/system/auto-rebuild.nix"
    "/desktop-env/plasma.nix"
    "/services/restart.nix"
  ] (p: root-config-dir + p);

  config = {
    arf = {
      gc = {
        enable = true;
        frequency = "weekly";
        older-than = 14;
      };
      restart = {
        enable = true;
        time = "02:00:00";
      };
    };

    services.displayManager.autoLogin = {
      enable = true;
      user = "richard";
    };

    environment.systemPackages = with pkgs; [ firefox ];
    networking.networkmanager.enable = true;

    systemd.user.services.nst-van-checkout = {
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.firefox}/bin/firefox -kiosk http://vcheckout.nst.clemson.edu:3000/";
      };
    };

  };
}
