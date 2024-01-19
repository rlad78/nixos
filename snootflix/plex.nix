{ config, pkgs, ... }:

{
    services.plex = {
        enable = true;
        group = "snootflix";
        openFirewall = true;
    };
}