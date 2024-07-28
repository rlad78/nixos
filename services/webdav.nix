{ config, pkgs, secrets, ... }:
let
  service-port = 5151;
in
{
  services.webdav = {
    enable = true;
    settings = {
      address = "0.0.0.0";
      port = 5151;
      auth = true;
      users = [
        secrets.webdav.user
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ service-port ];
}
