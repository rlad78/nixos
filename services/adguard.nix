{ ... }:
{
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    mutableSettings = true;
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [ 53 ];
}
