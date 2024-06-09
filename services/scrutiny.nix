{ config, pkgs, ... }:
{
  services.scrutiny = {
    enable = true;
    openFirewall = true;
    collector.enable = true;
    settings.web.listen.port = 9999;
  };
}
