{ config, pkgs, lib, ... }:

let
    sync_dir = "/home/richard/syncthing";
    addr_gen = {addr, port}: [
        ("tcp://" + addr + ":" + port)
        ("quic://" + addr + ":" + port)
    ];
    sync_addrs = addresses: port: lib.lists.flatten (
        lib.lists.forEach addresses (x: addr_gen { addr=x; port=port; })
    );
in
{
    users.groups = {
        syncthing = {};
    };

    users.users.syncthing = {
        isSystemUser = true;
        group = "syncthing";
    };

    users.users.richard.extraGroups = [ "syncthing" ];

    systemd.tmpfiles.rules = [
        ("d " + sync_dir + " 0770 syncthing syncthing")
    ];

    services.syncthing = {
        enable = true;
        user = "syncthing";
        group = "syncthing":

        openDefaultPorts = true;

        settings = {
            devices = {
                "silverblue-go" = {
                    addresses = sync_addrs ["10.0.3.10" "100.126.192.113"] "22000";
                    id = "HWZTYWZ-3KK6OWJ-727AB6U-44K5TJF-E2F6NSK-K65WT5C-77UCPT6-7ZCTTAA";
                };
            };

            folders = {
                "/home/richard/syncthing/Notes" = {
                    id = "qprzc-nackh";
                    devices = [ "silverblue-go" ];
                    name = "Notes";
                };
            };

            options = {
                urAccepted = 1;
                localAnnounceEnabled = true;
            };
        };
    };
}