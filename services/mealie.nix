{ config, pkgs, ... }:
{
  services.mealie = {
    enable = true;
    port = 8888;
  };

  networking.firewall.allowedTCPPorts = [ 8888 ];
}
