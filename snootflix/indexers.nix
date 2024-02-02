{ config, pkgs, lib, snootflix, ... }:
let
  sonarr-conf-paths = {
    anime = snootflix.mkConfPath [ "sonarr_anime" ];
    tv = snootflix.mkConfPath [ "sonarr_tv" ];
  };

  mkSonarrContainer = name: {
    autoStart = true;
    ephemeral = true;
    bindMounts = {
      "/host/config" = {
        hostPath = sonarr-conf-paths."${name}";
        isReadOnly = false;
      };
    };
    
    config = { config, pkgs, ... }: {
     
      users.groups."${snootflix.group}" = { gid=6969; };

      systemd.tmpfiles.rules = [
        "d /host/config 0770 sonarr snootflix"
      ];

      services.sonarr = {
        enable = true;
        openFirewall = true;
        group = "snootflix";
        dataDir = "/host/config";
      };
      
      system.stateVersion = "23.11";
    };
  };
in
{
    services.prowlarr = {
        enable = true;
        openFirewall = true;
    };

    services.radarr = {
        enable = true;
        group = "snootflix";
        openFirewall = true;
        dataDir = snootflix.mkConfPath [ "radarr" ];
    };

   systemd.tmpfiles.rules = (
      (snootflix.mkConfDir "radarr")
      ++ (snootflix.mkConfDir "sonarr_anime")
      ++ (snootflix.mkConfDir "sonarr_tv")
    );
    
}
