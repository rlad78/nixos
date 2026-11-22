{
  config,
  pkgs,
  lib,
  secrets,
  ...
}:
let
  cfg = config.arf.romm;
  consoles = import ./src/romm/consoles.nix;
  workingDir = toString cfg.workingDir;
  libraryDir = toString cfg.libraryDir;
  libraryRules = pkgs.writeText "romm-library-tmpfiles.conf" (
    lib.concatStringsSep "\n" (
      [
        "d ${libraryDir} 0775 ${cfg.user} storage - -"
        "d ${libraryDir}/roms 0775 ${cfg.user} storage - -"
        "d ${libraryDir}/bios 0775 ${cfg.user} storage - -"
      ]
      ++ map (x: "d ${libraryDir}/roms/${x} 0775 ${cfg.user} storage - -") consoles
      ++ map (x: "d ${libraryDir}/bios/${x} 0775 ${cfg.user} storage - -") consoles
    )
  );
in
{
  options.arf.romm = with lib; {
    enable = mkEnableOption "RomM";
    user = mkOption {
      type = types.str;
      default = "romm";
    };
    uid = mkOption {
      type = types.ints.u16;
      default = 7111;
    };
    port = mkOption {
      type = types.port;
      default = 7111;
    };
    workingDir = mkOption {
      type = types.path;
      default = /romm;
    };
    libraryDir = mkOption {
      type = types.path;
      default = "${toString cfg.workingDir}/library";
    };
    hosting = {
      enable = mkEnableOption "RomM reverse proxy";
      url = mkOption { type = types.str; };
    };
  };

  config = lib.mkIf cfg.enable {
    # Temporary: these values enter world-readable Nix store artifacts until sops-nix is configured.
    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";
    users.users.${cfg.user} = {
      group = "storage";
      isSystemUser = true;
      uid = cfg.uid;
    };
    systemd.tmpfiles.rules = [
      "d ${workingDir} 0775 ${cfg.user} storage"
    ]
    ++ map (x: "d ${workingDir}/${x} 0770 ${cfg.user} storage") [
      "assets"
      "config"
      "resources"
      "mysql"
      "redis"
    ];

    # The network persists across restarts; never delete it while containers use it.
    systemd.services.romm-network = {
      description = "Create the dedicated RomM Podman network";
      before = [
        "podman-romm-db.service"
        "podman-romm.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      path = [ config.virtualisation.podman.package ];
      script = ''
        podman network exists romm || podman network create romm
      '';
    };

    virtualisation.oci-containers.containers = {
      romm-db = {
        image = "docker.io/library/mariadb:latest";
        environment = {
          MARIADB_DATABASE = "romm";
          MARIADB_USER = "romm-user";
          MARIADB_ROOT_PASSWORD = secrets.romm.db-root;
          MARIADB_PASSWORD = secrets.romm.db;
        };
        volumes = [ "${workingDir}/mysql:/var/lib/mysql" ];
        networks = [ "romm" ];
        podman.sdnotify = "healthy";
        extraOptions = [
          "--health-cmd=healthcheck.sh --connect --innodb_initialized"
          "--health-start-period=30s"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=5"
        ];
      };
      romm = {
        image = "docker.io/rommapp/romm:5.4.1";
        user = "${toString cfg.uid}:${toString config.users.groups.storage.gid}";
        dependsOn = [ "romm-db" ];
        networks = [ "romm" ];
        environment = {
          DB_HOST = "romm-db";
          DB_NAME = "romm";
          DB_USER = "romm-user";
          DB_PASSWD = secrets.romm.db;
          ROMM_AUTH_SECRET_KEY = secrets.romm.ssl;
          IGDB_CLIENT_ID = secrets.romm.igdb-client;
          IGDB_CLIENT_SECRET = secrets.romm.igdb-secret;
          STEAMGRIDDB_API_KEY = secrets.romm.steamgrid-api;
          SCREENSCRAPER_USER = secrets.romm.screenscraper-user;
          SCREENSCRAPER_PASSWORD = secrets.romm.screenscraper-password;
          ENABLE_SCHEDULED_RESCAN = "true";
          SCHEDULED_RESCAN_CRON = "0 3 * * *";
          ENABLE_RESCAN_ON_FILESYSTEM_CHANGE = "true";
          RESCAN_ON_FILESYSTEM_CHANGE_DELAY = "5";
        };
        volumes = [
          "${workingDir}/resources:/romm/resources"
          "${workingDir}/redis:/redis-data"
          "${libraryDir}:/romm/library"
          "${workingDir}/assets:/romm/assets"
          "${workingDir}/config:/romm/config"
        ];
        ports = [ "${toString cfg.port}:8080" ];
      };
    };

    systemd.services.podman-romm-db = {
      requires = [ "romm-network.service" ];
      after = [ "romm-network.service" ];
      serviceConfig.TimeoutStartSec = lib.mkForce "180s";
    };
    systemd.services.podman-romm = {
      requires = [ "romm-network.service" ];
      after = [ "romm-network.service" ];
      bindsTo = [ "podman-romm-db.service" ];
      partOf = [ "podman-romm-db.service" ];
      unitConfig.RequiresMountsFor = [
        libraryDir
        workingDir
      ];
      # Create library directories only after its backing mount/target is available.
      serviceConfig.ExecStartPre = "${pkgs.systemd}/bin/systemd-tmpfiles --create ${libraryRules}";
    };

    security.acme = lib.mkIf cfg.hosting.enable {
      acceptTerms = true;
      defaults.email = "goobysc@gmail.com";
    };
    services.nginx = lib.mkIf cfg.hosting.enable {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      virtualHosts."${cfg.hosting.url}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          extraConfig = "client_max_body_size 0;";
        };
      };
    };
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.hosting.enable [
      80
      443
      cfg.port
    ];
  };
}
