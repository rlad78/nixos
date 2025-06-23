{ config, pkgs, lib, psonewserv, ... }:
let
  cfg = config.arf.pso;
  storage-gid = config.users.groups.storage.gid;
  source-dir = ./src/pso;
  config-file-source = source-dir + "/config.nix";

  needed-ports = [
    53
    5056
    5057
    5058
    5059
    9000
    9001
    9002
    9003
    9064
    9100
    9103
    9200
    9201
    9202
    9203
    9204
    9300
    9500
    10000
    11000
    11100
    11101
    11200
    12000
    12001
  ];
in
{
  options.arf.pso = with lib; {
    enable = mkEnableOption "";

    uid = mkOption {
      type = types.ints.u16;
      default = 7681;
    };

    workingDir = mkOption {
      type = types.path;
      default = /psonewserv;
    };

    server-name = mkOption {
      type = types.str;
      default = "newserv";
    };

    worker-threads = mkOption {
      type = types.ints.between 1 32;
      default = 1;
    };

    local-net-interface = mkOption {
      type = types.str;
    };

    external-ip = mkOption {
      type = types.str;
    };

    dns-listen-port = mkOption {
      type = types.port;
      default = 53;
    };

    banned-ip-ranges = mkOption {
      type = with types; listOf str;
      default = [];
    };

    allow-unregistered-users = mkOption {
      type = types.bool;
      default = true;
    };

    welcome-message = mkOption {
      type = types.str;
      default = "Welcome to ${cfg.server-name}!";
    };

    rare-item-notify = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = let
    config-text = import config-file-source {
      inherit lib;
      inherit (cfg) 
        server-name
        worker-threads
        local-net-interface
        external-ip
        dns-listen-port
        banned-ip-ranges
        allow-unregistered-users
        welcome-message
        rare-item-notify
      ;
    };

    config-file = pkgs.writeTextFile {
      name = "pso-config.yml";
      text = config-text;
    };

    compose-text = ''
      name: psonewserv
      services:
        newserv:
          image: newserv:latest
          container_name: newserv
          user: ${toString cfg.uid}:${toString storage-gid}
          volumes:
            - /etc/localtime:/etc/localtime:ro
            - ${toString cfg.workingDir}/players:/newserv/system/players
            - ${toString cfg.workingDir}/teams:/newserv/system/teams
            - ${toString cfg.workingDir}/licenses:/newserv/system/licenses
            - ${config-file}:/newserv/system/config.json
          restart: unless-stopped
          network_mode: host
    '';

    compose-file = pkgs.writeTextFile {
      name = "pso-compose.yml";
      text = compose-text;
    };
  in lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    environment.systemPackages = [ pkgs.docker-compose ];

    users.users.newserv = {
      group = "storage";
      isSystemUser = true;
      uid = cfg.uid;
    };

    systemd.tmpfiles.rules = [
      "d ${toString cfg.workingDir} 0750 newserv storage"
      "d ${toString cfg.workingDir}/players 0750 newserv storage"
      "d ${toString cfg.workingDir}/teams 0750 newserv storage"
      "d ${toString cfg.workingDir}/licenses 0750 newserv storage"
    ];

    networking.firewall = {
      allowedTCPPorts = needed-ports;
      allowedUDPPorts = needed-ports;
    };

    systemd.services.docker-pso = {
      script = ''
        ${pkgs.docker}/bin/docker build --build-arg RUN_USER=newserv -t newserv ${psonewserv} \
        && ${pkgs.docker-compose}/bin/docker-compose -f ${compose-file} up
      '';
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.service" "docker.socket" ];
    };
  };
}
