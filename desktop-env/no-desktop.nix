{ config, pkgs, lib, ... }:
{
  services.xserver.enable = lib.mkDefault false;
  services.printing.enable = lib.mkDefault false;
  hardware.pulseaudio.enable = lib.mkDefault false;
  services.libinput.enable = lib.mkDefault false;
}
