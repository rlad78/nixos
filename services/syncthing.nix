{ config, pkgs, lib, hosts, ... }:

let
    sync_dir = "/syncthing";
    addr_gen = {addr, port}: [
        ("tcp://" + addr + ":" + port)
        ("quic://" + addr + ":" + port)
    ];
    sync_addrs = addresses: port: lib.lists.flatten (
        lib.lists.forEach addresses (x: addr_gen { addr=x; port=port; })
    );

    syncthing-hosts = with lib.attrsets; filterAttrs (n: v: hasAttrByPath ["sync-id"] v) (removeAttrs hosts [config.networking.hostName]);
    syncthing-hosts-names = lib.attrsets.mapAttrsToList (n: v: n) syncthing-hosts;

    exists = name: attrset: lib.lists.optional (builtins.hasAttr name attrset) attrset.${name}; 
    get-host-ips = host: (exists "tail-ip" host) ++ (exists "local-ip" host);
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

    systemd.services.syncthing.serviceConfig.UMask = "0007";
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
            devices = with lib.attrsets; concatMapAttrs (n: v: {
              "${n}" = {
                addresses = sync_addrs (get-host-ips v) v.sync-port;
                id = v.sync-id;
              };
            }) syncthing-hosts;

            folders = {
                notes = {
                    id = "qprzc-nackh";
                    devices = syncthing-hosts-names;
                    path = sync_dir + "/Notes";
                    label = "Notes";
                };
                snoothome_backups = {
                    id = "walwu-ctntf";
                    devices = syncthing-hosts-names;
                    path = sync_dir + "/snoothome_backups";
                    label = "snoothome-backups";
                };
                wallpapers = {
                    id = "im7nn-kztqd";
                    devices = syncthing-hosts-names;
                    path = sync_dir + "/wallpapers";
                    label = "Wallpapers";
                };
                retro-saves = {
                  id = "h2xh7-wkhwu";
                  devices = syncthing-hosts-names;
                  path = sync_dir + "/retro_saves";
                  label = "RetroArch Saves";
                };
            };

            options = {
                urAccepted = 1;
                localAnnounceEnabled = true;
            };
        };
    };
}
