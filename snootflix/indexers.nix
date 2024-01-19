{ config, pkgs, ... }:

{
    services.prowlarr = {
        enable = true;
        openFirewall = true;
    };

    services.radarr = {
        enable = true;
        group = "snootflix";
        openFirewall = true;
    };

    # USE CONTAINERS FOR SONARR
    containers.sonarr-anime = {
        autoStart = true;
        ephemeral = true;
        bindMounts = {
            
        };
    };
    
}