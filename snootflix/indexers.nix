{ config, pkgs, lib, snootflix, machine, ... }:
let
  mkSonarrContainer = (name: octet: port: {
    privateNetwork = true;
    hostAddress = "192.168.${octet}.2";
    localAddress = "192.168.${octet}.10";
    forwardPorts = [{
      containerPort = 8989;
      hostPort = port;
      protocol = "tcp";
    }];

    autoStart = true;
    # ephemeral = true;
    # bindMounts = {
    #   "/host/config" = {
    #     hostPath = snootflix.mkConfPath [ "$(name)" ];
    #     isReadOnly = false;
    #   };
    #   "/host/snootflix" = {
    #     hostPath = snootflix.dirs.main;
    #     isReadOnly = false;
    #   };
    # };
    
    config = { config, pkgs, ... }: {
      users.groups."${snootflix.group}" = { gid=6969; };
      # systemd.tmpfiles.rules = [
      #   "d /host/config 0770 sonarr ${snootflix.group}"
      #   "d /host/snootflix 0770 sonarr ${snootflix.group}"
      # ];

      services.sonarr = {
        enable = true;
        openFirewall = true;
        group = "snootflix";
        # dataDir = "/host/config";
      };
      
      system.stateVersion = "23.11";
      networking.useHostResolvConf = lib.mkForce false;
    };
  });
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

   systemd.tmpfiles.rules = [
      # (snootflix.mkConfDir "radarr")
      (snootflix.mkConfDir "sonarr_anime")
      (snootflix.mkConfDir "sonarr_tv")
    ];
    
    # containers.sonarr_anime = mkSonarrContainer "sonarr_anime" "69" 8981;
    # containers.sonarr_tv = mkSonarrContainer "sonarr_tv" "79" 8982;

    containers.sonarr_anime = {
      privateNetwork = true;
      hostAddress = "192.168.69.2";
      localAddress = "192.168.69.10";
      forwardPorts = [{
        containerPort = 8989;
        hostPort = 8981;
        protocol = "tcp";
      }];

      autoStart = true;
      ephemeral = true;
      bindMounts = {
        "/host/config" = {
          hostPath = snootflix.mkConfPath [ "sonarr_anime" ];
          isReadOnly = false;
        };
        "/host/snootflix" = {
          hostPath = snootflix.dirs.main;
          isReadOnly = false;
        };
      };
      
      config = { config, pkgs, ... }: {
        users.groups."snootflix" = { gid=6969; };
        systemd.tmpfiles.rules = [
          "d /host/config 0770 sonarr snootflix"
          "d /host/snootflix 0770 sonarr snootflix"
        ];

        services.sonarr = {
          enable = true;
          openFirewall = true;
          group = "snootflix";
          dataDir = "/host/config";
        };
        
        system.stateVersion = "23.11";
        networking.useHostResolvConf = lib.mkForce false;
      };
    };

    networking = {
      nat = {
        enable = true;
        internalInterfaces = [ "ve-+" ];
        externalInterface = machine.eth-interface;
      };
      firewall.allowedTCPPorts = [ 8981 8982 ];
    };
}
