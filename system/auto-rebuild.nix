{ pkgs, ... }:
let
  flake-dir = "/home/richard/nixos";

  flake-pull-script = pkgs.writeShellApplication {
    name = "flake-auto-pull";
    runtimeInputs = [ pkgs.git ];
    text = ''
      git pull -C /home/richard/nixos
    '';
  };
in
{
  system.autoUpgrade = {
    enable = true;
    flake = ../.;
    operation = "switch";
    dates = "Mon *-*-* 03:00:00";
    allowReboot = true;
    rebootWindow = {
      lower = "02:00";
      upper = "05:00";
    };
  };

  systemd.user.services.pull-flake = {
    serviceConfig.ExecStart = "${flake-pull-script}/bin/flake-auto-pull";
  };

  system.user.timers.pull-flake = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "Mon *-*-* 01:00:00";
  };
}