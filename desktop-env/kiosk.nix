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
      bash
      chromium
      swayidle
      light
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

    systemd.services.swayidle = {
      enable = true;
      wantedBy = [ "graphical-session.target" ];
      unitConfig = {
        Description = "Idle manager for Wayland";
        Documentation = "man:swayidle(1)";
        ConditionEnvironment = "WAYLAND_DISPLAY";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      serviceConfig = with lib; {
        Type = "simple";
        Restart = "always";
        Environment = [ "PATH=${strings.makeBinPath [pkgs.bash]}" ];
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
        in "${meta.getExe pkgs.swayidle} -w ${strings.escapeShellArgs (concatMap mkTimeout timeouts)}";
      };
    };

    services.cage = {
      enable = true;
      user = "kiosk";
      program = "${pkgs.chromium}/bin/chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --kiosk ${cfg.web-kiosk-url}";
    };
  };
}
