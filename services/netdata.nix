{ config, pkgs, ... }:

{   
    services.netdata = {
        enable = false;
        enableAnalyticsReporting = true;
    };

    networking.firewall.allowedTCPPorts = [ 19999 ];
}
