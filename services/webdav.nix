{ config, pkgs, secrets, ... }:
let
  service-port = 5151;
in
{
  services.webdav = {
    enable = true;
    settings = {
      address = "0.0.0.0";
      port = service-port;
      directory = "/webdav";
      modify = true;
      auth = true;
      users = [
        secrets.webdav.user
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /webdav 0770 webdav webdav"
  ];

  networking.firewall.allowedTCPPorts = [ service-port ];
}
