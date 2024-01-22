{ config, pkgs, lib, uncommon, ... }:

{
  services.tailscale.enable = true;
  services.tailscale.port = 41641;
  environment.systemPackages = with pkgs; [ tailscale ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  networking.firewall.allowedUDPPorts = [ 41641 ];
}
