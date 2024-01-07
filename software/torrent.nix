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

        # these can be any of the Transmission settings.json entries
        # https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
        settings = {
            rpc-enabled = true;
            rpc-bind-address = "0.0.0.0";
            rpc-whitelist = "10.0.0.*,10.0.1.*,10.0.2.111,10.0.3.*";
        };
        
        openRPCPort = true;
        openPeerPorts = true;
    };
}