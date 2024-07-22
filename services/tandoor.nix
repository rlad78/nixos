{ config, pkgs, ... }:
{
  services.tandoor-recipies = {
    enable = true;
    port = 7777;
    address = "0.0.0.0";
  };

  networking.firewall.allowedTCPPorts = [ 7777 ];
}
