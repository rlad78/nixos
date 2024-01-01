{ config, pkgs, ... }:

{
    services.foldingathome = {
        enable = true;
        user = "rcarte4";
        team = 60194;
        extraArgs = [
            "--web-allow=10.0.0.1/22"
        ];
    };

    networking.firewall.allowedTCPPorts = [ 7396 ];
}