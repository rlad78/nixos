{ config, lib, hosts, ... }:

let
    sync_dir = "/syncthing";
    emu_devices = ["nix-go" "NextArf" "nixarf" "nixps"];

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
    fromHostnames = hosts: lib.lists.intersectLists hosts syncthing-hosts-names;
in
{
#     users.groups = {
#         syncthing = {};
#     };
#
#     users.users.syncthing = {
#         isSystemUser = true;
#         group = "syncthing";
#     };

    systemd.services.syncthing.serviceConfig = {
        UMask = "0027";
        AmbientCapabilities = "CAP_CHOWN CAP_FOWNER";
    };

    systemd.tmpfiles.rules = [
        ("d " + sync_dir + " 0750 richard users")
    ];

    networking.firewall.allowedTCPPorts = [ 8384 ];

    services.syncthing = {
        enable = true;
        user = "richard";
        group = "users";
        dataDir = sync_dir;

        guiAddress = "0.0.0.0:8384";
        openDefaultPorts = true;

        settings = {
            devices = with lib.attrsets; concatMapAttrs (n: v: {
              "${n}" = {
                addresses = sync_addrs (get-host-ips v) "22000";
                id = v.sync-id;
              };
            }) syncthing-hosts;

            folders = {
                notes = {
                    id = "qprzc-nackh";
                    devices = syncthing-hosts-names;
                    path = sync_dir + "/Notes";
                    label = "Notes";
                    copyOwnershipFromParent = true;
                };
                wallpapers = {
                    id = "im7nn-kztqd";
                    devices = syncthing-hosts-names;
                    path = sync_dir + "/wallpapers";
                    label = "Wallpapers";
                };
                emulation = {
                  id = "5cqkv-ajy2x";
                  devices = fromHostnames emu_devices;
                  path = sync_dir + "/emulation";
                  label = "Emulation";
                };
            };

            options = {
                urAccepted = 1;
                localAnnounceEnabled = true;
            };
        };
    };
}
