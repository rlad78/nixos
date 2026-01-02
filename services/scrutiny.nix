{ config, pkgs-unstable, ... }:
{
  services.scrutiny = {
    enable = true;
    package = pkgs-unstable.scrutiny;
    openFirewall = true;
    collector.enable = true;
    settings.web.listen.port = 9999;
  };
}
