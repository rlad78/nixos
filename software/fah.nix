{ config, pkgs, ... }:

{
    services.foldingathome = {
        enable = true;
        user = "rcarte4";
        team = 60194;
        extraArgs = [
            "--allow=10.0.0.1-10.0.3.254"
            "--web-allow=10.0.0.1-10.0.3.254"
        ];
    };

    networking.firewall.allowedTCPPorts = [ 7396 ];
}