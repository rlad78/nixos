{ config, pkgs, ... }:

{
    services.sabnzbd = {
        enable = true;
        group = "snootflix";
    };

    services.deluge = {
        enable = true;
        group = "snootflix";

        web = {
            enable = true;
            port = 8112;
            openFirewall = true;
        };
    };
}