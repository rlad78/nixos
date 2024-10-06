{ config, pkgs, pkgs-unstable, ... }:
{
  # requires https, dunno if you wanna bother with this over tandoor
  services.mealie = {
    # package = pkgs-unstable.mealie;
    enable = true;
    port = 8888;
  };

  networking.firewall.allowedTCPPorts = [ 8888 ];
}
