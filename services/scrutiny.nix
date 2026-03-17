{ config, pkgs, ... }:
{
  services.scrutiny = {
    enable = true;
    # package = pkgs.scrutiny;
    openFirewall = true;
    collector.enable = true;
    settings.web.listen.port = 9999;
  };
}
