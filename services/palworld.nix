{ config, pkgs, secrets, ... }:
let
  palworld-uid = 6969;
  palworld-gid = 6969;

  host-game-port = 8211;
  forwarded-port = 8211;
in
{
  virtualisation.docker.enable = true;
  users.users.richard.extraGroups = [ "docker" ];

  users.groups.palworld.gid = palworld-gid;

  users.users.palworld = {
    isSystemUser = true;
    group = "palworld";
    uid = palworld-uid;
  };

  systemd.tmpfiles.rules = [
    "d /palworld 0700 palworld palworld"
  ];

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    palworld = {
      image = "thijsvanloef/palworld-server-docker:latest";
      extraOptions = [ "--pull=always" ];
      autoStart = true;
      volumes = [
        "/palworld:/palworld"
      ];
      ports = with builtins; [
        "${toString host-game-port}:8211/udp"
        "27015:27015/udp"
      ];
      environment = {
        PUID = "${builtins.toString config.users.users.palworld.uid}";
        PGID = "${builtins.toString config.users.groups.palworld.gid}";
        PORT = "8211";
        PLAYERS = "8";
        MULTITHREADING = "true";
        RCON_ENABLED = "true";
        RCON_PORT = "25575";
        TZ = "America/New_York";
        SERVER_PASSWORD = "${secrets.palworld.server_password}";
        ADMIN_PASSWORD = "${secrets.palworld.admin_password}";
        COMMUNITY = "false";
        SERVER_NAME = "Crescent";
        SERVER_DESCRIPTION = "Fun times with arf & Moon";
        PUBLIC_IP = "69.59.78.25";
        PUBLIC_PORT = builtins.toString forwarded-port;
        DELETE_OLD_BACKUPS = "true";
        OLD_BACKUP_DAYS = "14";
        UPDATE_ON_BOOT = "true";
        AUTO_REBOOT_ENABLED = "true";
        AUTO_REBOOT_CRON_EXPRESSION = "0 4 * * *";
        AUTO_REBOOT_WARN_MINUTES = "30";
        AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE = "true";
        # TARGET_MANIFEST_ID = "5441332432956841998";
        REST_API_ENABLED = "true";

        # WORLD CONFIG
        ENABLE_INVADER_ENEMY = "False";
        PLAYER_STAMINA_DECREASE_RATE = "0.100000";
        PAL_STAMINA_DECREASE_RATE = "0.100000";
        PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP = "2.000000";
        PAL_AUTO_HP_REGEN_RATE_IN_SLEEP = "2.000000";
        PAL_SPAWN_NUM_RATE = "1.250000";
        DEATH_PENALTY = "None";
        IS_START_LOCATION_SELECT_BY_MAP = "True";
        COOP_PLAYER_MAX_NUM = "8";
        PAL_EGG_DEFAULT_HATCHING_TIME = "1.200000";
        BASE_CAMP_WORKER_MAX_NUM = "20";
      };
    };

  };

  networking.firewall.allowedUDPPorts = [ host-game-port 27015 ];
}
