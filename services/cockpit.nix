{ config, ... }:
{
  services.cockpit = {
    enable = true;
    openFirewall = true;
    port = 9090;
    showBanner = true;
    options = {
      AllowUnencrypted = false;
    };
    allowed-origins = [
      config.networking.hostName
    ];
}
