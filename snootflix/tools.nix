{ config, pkgs, snootflix, ... }:
{
    services.tautulli = {
        enable = true;
        openFirewall = true;
        group = "snootflix";
        dataDir = snootflix.mkConfPath [ "tautulli" ];
    };

    systemd.tmpfiles.rules = snootflix.mkConfDir "tautulli";
}