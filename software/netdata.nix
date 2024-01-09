{ config, pkgs, ... }:

{   
    services.netdata = {
        enable = true;
        enableAnalyticsReporting = true;
    };

    networking.firewall.allowedTCPPorts = [ 19999 ];
}