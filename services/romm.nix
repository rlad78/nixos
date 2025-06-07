{ config, pkgs, lib, secrets, ... }:
let
  cfg = config.arf.romm;
  romm-version = "3.10.1";
in
{
  options.arf.romm = with lib; {
    enable = mkEnableOption "";

    user = mkOption {
      type = types.str;
      default = "romm";
    };

    group = mkOption {
      type = types.str;
      default = "romm";
    };

    uid = mkOption {
      type = types.ints.u16;
      default = 7111;
    };

    gid = mkOption {
      type = types.ints.u16;
      default = cfg.uid;
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

    consoles = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = let
    compose-text = ''
      version: "3"

      services:
        romm:
          image: rommapp/romm:${romm-version}
          container_name: romm
          restart: unless-stopped
          user: ${toString cfg.uid}:${toString cfg.gid}
          environment:
            - DB_HOST=romm-db
            - DB_NAME=romm # Should match MARIADB_DATABASE in mariadb
            - DB_USER=romm-user # Should match MARIADB_USER in mariadb
            - DB_PASSWD=${secrets.romm.db} # Should match MARIADB_PASSWORD in mariadb
            - ROMM_AUTH_SECRET_KEY=${secrets.romm.ssl} # Generate a key with `openssl rand -hex 32`
            - IGDB_CLIENT_ID=${secrets.romm.igdb-client} # Generate an ID and SECRET in IGDB
            - IGDB_CLIENT_SECRET=${secrets.romm.igdb-secret} # https://docs.romm.app/latest/Getting-Started/Generate-API-Keys/#igdb
            - STEAMGRIDDB_API_KEY=${secrets.romm.steamgrid-api} # https://docs.romm.app/latest/Getting-Started/Generate-API-Keys/#steamgriddb
            - SCREENSCRAPER_USER=${secrets.romm.screenscraper-user} # Use your ScreenScraper username and password
            - SCREENSCRAPER_PASSWORD=${secrets.romm.screenscraper-password} # https://docs.romm.app/latest/Getting-Started/Generate-API-Keys/#screenscraper
          volumes:
            - ${toString cfg.workingDir}/resources:/romm/resources # Resources fetched from IGDB (covers, screenshots, etc.)
            - ${toString cfg.workingDir}/redis:/redis-data # Cached data for background tasks
            - ${toString cfg.libraryDir}:/romm/library # Your game library. Check https://github.com/rommapp/romm?tab=readme-ov-file#folder-structure for more details.
            - ${toString cfg.workingDir}/assets:/romm/assets # Uploaded saves, states, etc.
            - ${toString cfg.workingDir}/config:/romm/config # Path where config.yml is stored
          ports:
            - ${toString cfg.port}:8080
          depends_on:
            romm-db:
              condition: service_healthy
              restart: true

        romm-db:
          image: mariadb:latest
          container_name: romm-db
          restart: unless-stopped
          environment:
            - MARIADB_ROOT_PASSWORD=${secrets.romm.db-root}
            - MARIADB_DATABASE=romm
            - MARIADB_USER=romm-user
            - MARIADB_PASSWORD=${secrets.romm.db}
          volumes:
            - ${toString cfg.workingDir}/mysql:/var/lib/mysql
          healthcheck:
            test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
            start_period: 30s
            start_interval: 10s
            interval: 10s
            timeout: 5s
            retries: 5
    '';

    compose-file = pkgs.writeTextFile {
      name = "romm-compose.yml";
      text = compose-text;
    };

    required-working-dirs = [
      "assets"
      "config"
      "resources"
      "mysql"
      "redis"
    ];

    working-subdirs = lib.lists.forEach required-working-dirs (x:
      "d ${toString cfg.workingDir}/${x} 0770 romm romm"
    );

    console-subdirs = with lib.lists; forEach cfg.consoles (x:
      "d ${toString cfg.libraryDir}/roms/${x} 0775 romm romm"
    ) ++ forEach cfg.consoles (x:
      "d ${toString cfg.libraryDir}/bios/${x} 0775 romm romm"
    );
  in lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    environment.systemPackages = [ pkgs.docker-compose ];

    users.users.${cfg.user} = {
      group = cfg.group;
      isSystemUser = true;
      uid = cfg.uid;
    };

    users.groups.${cfg.group}.gid = cfg.gid;

    systemd.tmpfiles.rules = [
      "d ${toString cfg.workingDir} 0775 romm romm"
      "d ${toString cfg.libraryDir} 0775 romm romm"
      "d ${toString cfg.libraryDir}/roms 0775 romm romm"
      "d ${toString cfg.libraryDir}/bios 0775 romm romm"
    ] ++ working-subdirs ++ console-subdirs;

    systemd.services.docker-compose-romm = {
      script = "${pkgs.docker-compose}/bin/docker-compose -f ${compose-file} up";
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.service" "docker.socket" ];
    };
  };
}
