{ config, pkgs, ... }:

{
    services.foldingathome = {
        enable = true;
        user = "rcarte4";
        team = 60194;
    };

    networking.firewall.allowedTCPPorts = [ 7396 ];
}