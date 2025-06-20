{ config, pkgs, lib, hosts, ... }:
let
  local-addresses = with lib.attrsets; (this-host:
    mapAttrsToList (n: v: v.local-ip) (
      filterAttrs (n: v: hasAttrByPath ["local-ip"] v) (
        removeAttrs hosts [this-host]
      )
    )
  );
  tail-addresses = with lib.attrsets; (this-host:
    mapAttrsToList (n: v: v.tail-ip) (
      filterAttrs (n: v: hasAttrByPath ["tail-ip"] v) (
        removeAttrs hosts [this-host]
      )
    )
  );
  all-host-addresses = (this-host:
    (local-addresses this-host) ++ (tail-addresses this-host)
  );
in
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
      # manage remotely
      rpc-enabled = true;
      rpc-bind-address = "0.0.0.0";
      # rpc-whitelist = "10.0.0.*,10.0.1.*,10.0.2.111,10.0.3.*,100.126.192.113,100.68.24.62";
      rpc-whitelist = lib.strings.concatStringsSep "," (
        all-host-addresses config.networking.hostName
      );

      # allow for hostname instead of ip
      rpc-host-whitelist = "nixarf";

      # speed limits (in KB)
      alt-speed-up = 125;
      alt-speed-down = 2500;
      speed-limit-up = 1250;
      speed-limit-down = 6250;
      speed-limit-up-enabled = true;
      speed-limit-down-enabled = true;
      upload-slots-per-torrent = 1750;

      ## alt-speed (turtle) schedule
      ## 4AM to 10:30PM
      alt-speed-time-enabled = true;
      alt-speed-time-begin = 240;
      alt-speed-time-end = 1350;
    };
    
    openRPCPort = true;
    openPeerPorts = true;
  };
}
