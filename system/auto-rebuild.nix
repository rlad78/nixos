{ ... }:
let
  flake-dir = "/home/richard/nixos";
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
}