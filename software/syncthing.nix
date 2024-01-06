{ config, pkgs, lib, ... }:

let
    sync_dir = "/syncthing";
    addr_gen = {addr, port}: [
        ("tcp://" + addr + ":" + port)
        ("quic://" + addr + ":" + port)
    ];
    sync_addrs = addresses: port: lib.lists.flatten (
        lib.lists.forEach addresses (x: addr_gen { addr=x; port=port; })
    );
    all_devices = [ "silverblue-go" "Samsung S23" "snoothome" "the-doghouse" ];
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

    networking.firewall.allowedTCPPorts = [ 8384 ];

    services.syncthing = {
        enable = true;
        user = "syncthing";
        group = "syncthing";

        guiAddress = "0.0.0.0:8384";
        openDefaultPorts = true;

        settings = {
            devices = {
                "silverblue-go" = {
                    addresses = sync_addrs ["10.0.3.10" "100.126.192.113"] "22000";
                    id = "HWZTYWZ-3KK6OWJ-727AB6U-44K5TJF-E2F6NSK-K65WT5C-77UCPT6-7ZCTTAA";
                };
                "Samsung S23" = {
                    addresses = sync_addrs ["10.0.3.13" "100.68.133.55"] "22000";
                    id = "FVMMLEQ-E2J6XRX-G2OIBLH-7AVNNQI-4B2TUKN-VNIQB6U-5JTHPYI-MY4EOQP";
                };
                "snoothome" = {
                    addresses = sync_addrs [ "10.0.2.111" ] "40788";
                    id = "GD3K7RZ-QWETD4W-W34FV4W-KJZJS5O-3FEWHMH-LOBQGCA-QMUFSRH-QM6U5QV";
                };
                "the-doghouse" = {
                    addresses = sync_addrs [ "10.0.1.2" "100.68.24.62" ] "22000";
                    id = "35RITKL-BGKLWI3-RC3L3M5-R3OSQ4B-RZIVOTP-CS7H7UW-7ZKD2FX-ZLSB7QQ";
                };
            };

            folders = {
                notes = {
                    id = "qprzc-nackh";
                    devices = all_devices;
                    path = sync_dir + "/Notes";
                    label = "Notes";
                };
                snoothome_backups = {
                    id = "walwu-ctntf";
                    devices = all_devices;
                    path = sync_dir + "/snoothome_backups";
                    label = "snoothome-backups";
                };
                wallpapers = {
                    id = "im7nn-kztqd";
                    devices = all_devices;
                    path = sync_dir + "/wallpapers";
                    label = "Wallpapers";
                };
            };

            options = {
                urAccepted = 1;
                localAnnounceEnabled = true;
            };
        };
    };
}