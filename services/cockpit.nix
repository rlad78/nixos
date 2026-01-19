{ config, ... }:
let
  cockpit-port = 9090;
in
{
  services.cockpit = {
    enable = true;
    openFirewall = true;
    port = cockpit-port;
    showBanner = true;
    settings = {
      webService.AllowUnencrypted = true;
    };
    allowed-origins = [
      "https://${config.networking.hostName}:${builtins.toString cockpit-port}"
    ];
  };
}
