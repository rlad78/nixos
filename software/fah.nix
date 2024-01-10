{ config, pkgs, ... }:

{
    services.foldingathome = {
        enable = true;
        user = "rcarte4";
        team = 60194;
        extraArgs = [
            "--allow=127.0.0.1 10.0.0.1-10.0.3.254 100.126.192.113 100.68.24.62"
            "--web-allow=10.0.0.1-10.0.3.254 100.126.192.113 100.68.24.62"
            "--password=FAHArfFAH@93"
        ];
    };

    networking.firewall.allowedTCPPorts = [ 7396 36330 ];
}
