{ lib, pkgs, ... }:
let
  root-config-dir = ./../..;
in
{
  arf = {
    cli.theme = "kolo";
  };

  imports = [
    ./hardware-configuration.nix
  ]
  ++ lib.lists.forEach [
    "/roles/laptop.nix"
    "/system/jenn.nix"
    "/desktop-env/plasma.nix"
    "/system/systemd-boot.nix"
  ] (p: root-config-dir + p);

  # screen rotation support
  hardware.sensor.iio.enable = true;
  environment.systemPackages = [ pkgs.iio-sensor-proxy ];

  networking.hostName = "nixflip";
  system.stateVersion = "26.05";
}
