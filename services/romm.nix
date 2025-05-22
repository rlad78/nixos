{ pkgs, secrets, ... }:
let
  romm-dir = "/romm";

  romm-user = "romm";
  romm-uid = 7111;
  romm-group = "romm";
  romm-gid = 7111;

  romm-ext-port = 7111;

  compose-text = ''
    version: "3"

    services:
      romm:
        image: rommapp/romm:latest
        container_name: romm
        restart: unless-stopped
        user: ${toString romm-uid}:${toString romm-gid}
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
          - ${romm-dir}/resources:/romm/resources # Resources fetched from IGDB (covers, screenshots, etc.)
          - ${romm-dir}/redis:/redis-data # Cached data for background tasks
          - ${romm-dir}/library:/romm/library # Your game library. Check https://github.com/rommapp/romm?tab=readme-ov-file#folder-structure for more details.
          - ${romm-dir}/assets:/romm/assets # Uploaded saves, states, etc.
          - ${romm-dir}/config:/romm/config # Path where config.yml is stored
        ports:
          - ${toString romm-ext-port}:8080
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
          - ${romm-dir}/mysql:/var/lib/mysql
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
in
{
  virtualisation.docker.enable = true;
  environment.systemPackages = [ pkgs.docker-compose ];

  users.users.${romm-user} = {
    group = romm-group;
    isSystemUser = true;
    uid = romm-uid;
  };

  users.groups.romm.gid = romm-gid;

  systemd.tmpfiles.rules = [
    "d ${romm-dir} 0700 romm romm"
    "d ${romm-dir}/library 0700 romm romm"
    "d ${romm-dir}/assets 0700 romm romm"
    "d ${romm-dir}/config 0700 romm romm"
    "d ${romm-dir}/resources 0700 romm romm"
    "d ${romm-dir}/mysql 0700 romm romm"
    "d ${romm-dir}/redis 0700 romm romm"
  ];

  systemd.services.docker-compose-romm = {
    script = "${pkgs.docker-compose}/bin/docker-compose -f ${compose-file} up";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" "docker.socket" ];
  };
}
