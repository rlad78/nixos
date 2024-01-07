{ config, pkgs, ... }:

{
    users.users.transmission = {
        isSystemUser = true;
        group = "storage";
    };

    systemd.tmpfiles.rules = [ "d /storage/torrents 0775 transmission storage" ];

    services.transmission = {
        enable = true;
        package = pkgs.transmission_4;
        group = "storage";
        home = "/storage/torrents";
        downloadDirPermissions = "775";
        openRPCPort = true;
        openPeerPorts = true;
    };
}