{ config, pkgs, lib, psonewserv, hosts, ... }:
let
  cfg = config.arf.pso;

  storage-gid = config.users.groups.storage.gid;
  source-dir = ./src/pso;
  host-default-netdev = config.networking.hostName;

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

    user = mkOption {
      type = types.str;
      default = "newserv";
    };

    uid = mkOption {
      type = types.ints.u16;
      default = if cfg.user == "newserv"
        then 7681
        else config.users.users.${cfg.user}.uid;
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

    compose-text = with lib; ''
      name: psonewserv
      services:
        newserv:
          image: newserv:latest
          container_name: newserv
          volumes:
            - /etc/localtime:/etc/localtime:ro
            - ${toString cfg.workingDir}/players:/newserv/system/players
            - ${toString cfg.workingDir}/teams:/newserv/system/teams
            - ${toString cfg.workingDir}/licenses:/newserv/system/licenses
            - ${config-file}:/newserv/system/config.json
          restart: unless-stopped
          ports:
            - 9053:53/udp
    '' + strings.concatStringsSep "\n" (
      lists.forEach (lists.remove 53 needed-ports) (
        x: "      - ${toString x}:${toString x}"
        )) + "\n";

    compose-file = pkgs.writeTextFile {
      name = "pso-compose.yml";
      text = compose-text;
    };
  in lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    environment.systemPackages = [ pkgs.docker-compose ];

    users.users.${cfg.user} = {
      group = "storage";
      isNormalUser = true;
      uid = cfg.uid;
      linger = true;
    };

    systemd.tmpfiles.rules = [
      "d ${toString cfg.workingDir} 0750 ${cfg.user} storage"
      "d ${toString cfg.workingDir}/players 0750 ${cfg.user} storage"
      "d ${toString cfg.workingDir}/teams 0750 ${cfg.user} storage"
      "d ${toString cfg.workingDir}/licenses 0750 ${cfg.user} storage"
      "d ${toString cfg.workingDir}/.docker 0750 ${cfg.user} storage"
    ];

    boot.kernel.sysctl = {
      "net.ipv4.conf.eth0.forwarding" = 1;
    };

    networking.firewall = {
      allowedTCPPorts = needed-ports;
      allowedUDPPorts = needed-ports;

      extraCommands = ''
        iptables -A PREROUTING -t nat -i ${host-default-netdev} -p UDP --dport 53 -j REDIRECT --to-port 9053
      '';
    };


    systemd.services.docker-pso = {
      preStart = ''
        ${pkgs.docker}/bin/docker build -t newserv ${psonewserv}
      '';
      script = ''
        ${pkgs.docker-compose}/bin/docker-compose -f ${compose-file} up
      '';
      postStart = ''
        ${pkgs.docker-compose}/bin/docker-compose -f ${compose-file} logs -f
      '';
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        User = cfg.user;
        WorkingDirectory = "${toString cfg.workingDir}/.docker";
        Type = "simple";
        RemainAfterExit = "yes";
        # NoNewPrivileges = "true";
        PrivateTmp = "true";
        TimeoutStartSec = "infinity";
        TimeoutStopSec = "100s";
      };
      environment = {
        DOCKER_HOST = "unix:///run/user/${toString cfg.uid}/docker.sock";
        XDG_RUNTIME_DIR = "/run/user/${toString cfg.uid}";
      };
    };
  };
}
