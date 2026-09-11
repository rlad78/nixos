{ ... }:
{
  services.unifi = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [ 8443 ];
}
