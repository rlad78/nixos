{ config, pkgs, pkgs-unstable, ... }:
{
  services.printing = {
    enable = true;
    drivers = with pkgs-unstable; [
      gutenprint
      gutenprintBin
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
