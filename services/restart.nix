{ config, lib, pkgs, ... }:
let
  cfg = config.arf.restart;
in
{
  options.arf.restart = with lib; {
    enable = mkEnableOption "";
    time = mkOption {
      type = types.strMatching ''[0-9]{2}:[0-9]{2}:[0-9]{2}'';
      default = "00:00:00";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.autoRestart = {
      enable = true;
      description = "Simple Reboot";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.systemd}/bin/systemctl --force reboot";
      };
    };

    systemd.timers.autoRestart = {
      wantedBy = [ "timers.target" ];
      description = "Daily Reboot";
      timerConfig = {
        OnCalendar = "*-*-* ${cfg.time}";
        Unit = "autoRestart.service";
      };
    };
  };
}
