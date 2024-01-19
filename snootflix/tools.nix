{ config, pkgs, ... }:

{
    services.tautulli = {
        enable = true;
        openFirewall = true;
        group = "snootflix";
    };

    
}