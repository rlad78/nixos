{ config, pkgs, lib, ...}:
let
  cfg = config.arf;
  kiosk-user = "richard";
in
{
  options.arf.web-kiosk-url = with lib; mkOption {
    type = types.str;
    default = "https://google.com";
  };

  config = {
    services.seatd = {
      enable = true;
      group = "seat";
    };

    users.users.${kiosk-user}.extraGroups = [ "seat" ];

    environment.systemPackages = with pkgs; [
      chromium
      swayidle
      light
    ];

    fonts.packages = with pkgs; [
      noto-fonts-color-emoji
      noto-fonts-monochrome-emoji
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
      serviceConfig = {
        Restart = "always";
        RuntimeMaxSec = "3h";
      };
    };

    systemd.services.swayidle = {
      enable = true;
      after = [ "graphical.target" ];
      wantedBy = [ "graphical.target" ];
      partOf = [ "graphical.target" ];
      environment = {
        WAYLAND_DISPLAY = "wayland-0";
        XDG_RUNTIME_DIR = "/run/user/1000";
      };
      unitConfig = {
        Description = "Idle manager for Wayland";
        Documentation = "man:swayidle(1)";
      };
      serviceConfig = with lib; {
        Type = "simple";
        Restart = "always";
        User = "richard";
        Group = "users";
        ExecStartPre = "${pkgs.coreutils-full}/bin/sleep 10";
        ExecStart = let
          mkTimeout = t:
            [ "timeout" (toString t.timeout) t.command ]
            ++ optionals (t.resumeCommand != null) [ "resume" t.resumeCommand ];
          timeouts =
            let
              set_light = n: "${pkgs.light}/bin/light -S ${builtins.toString n}";
              default_light = 5;
              dim_light = 1;
            in
            [
              {
                timeout = 45;
                command = set_light dim_light;
                resumeCommand = set_light default_light;
              }
              {
                timeout = 60;
                command = set_light 0;
                resumeCommand = set_light default_light;
              }
            ];
        in "+${meta.getExe pkgs.swayidle} -w ${strings.escapeShellArgs (concatMap mkTimeout timeouts)}";
      };
    };

    services.cage = {
      enable = true;
      user = kiosk-user;
      program = "${pkgs.chromium}/bin/chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --kiosk ${cfg.web-kiosk-url}";
    };
  };
}
