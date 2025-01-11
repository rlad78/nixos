{ config, pkgs, lib, ... }:
let
  cfg = config.arf;
in
{
  options.arf.web-kiosk-url = with lib; mkOption {
    type = types.str;
    default = "https://google.com";
  };

  config = {
    users.users.kiosk = {
      isNormalUser = true;
    };

    environment.systemPackages = with pkgs; [
      chromium
    ];

    systemd.services."cage-tty1" = {
      after = [
        "systemd-user-sessions.service"
        "plymouth-start.service"
        "plymouth-quit.service"
        "systemd-logind.service"
        "getty@tty1.service"
        "network-online.target"
      ];
      wants = [
        "dbus.socket"
        "systemd-logind.service"
        "plymouth-quit.service"
        "network-online.target"
      ];
    };

    services.cage = {
      enable = true;
      user = "kiosk";
      program = "${pkgs.chromium}/bin/chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --kiosk ${cfg.web-kiosk-url}";
    };
  };
}
