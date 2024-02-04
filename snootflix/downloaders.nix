{ config, pkgs, lib, snootflix, ... }:
{
    services.sabnzbd = {
        enable = true;
        group = "snootflix";
        configFile = snootflix.mkConfPath [ "sabnzbd" "sabnzbd.ini" ];
    };

    services.deluge = {
        enable = true;
        group = "snootflix";
        dataDir = snootflix.mkConfPath [ "deluge" ];
        web = {
            enable = true;
            port = 8112;
            openFirewall = true;
        };
    };

    systemd.tmpfiles.rules = (
      snootflix.mkDownloadDirs [ "nzb" "torrent" ]
      ++ [ 
        (snootflix.mkConfDir "sabnzbd")
        # (snootflix.mkConfDir "deluge")
      ]
    );
}
