{ config, pkgs, ... }:
{
  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    hplipWithPlugin
  ];

  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };
}
