{ config, pkgs, ... }:
{
  services.tailscale.enable = true;
  networking.firewall.allowedUDPPorts = [ 41641 ];
}
