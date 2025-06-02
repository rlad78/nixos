{ config, pkgs, lib, ... }:
{
  services.xserver.enable = lib.mkDefault false;
  services.printing.enable = lib.mkDefault false;
  services.libinput.enable = lib.mkDefault false;

  # prevent suspend/hibernate (mostly for laptops)
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';
}
