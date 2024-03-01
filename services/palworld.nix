{ config, pkgs, secrets, ... }:
let
  puid = 6969;
  pgid = 6969;
in
{
  virtualisation.docker.enable = true;
  users.users.richard.extraGroups = [ "docker" ];

  users.groups.palworld.gid = pgid;

  users.users.palworld = {
    isSystemUser = true;
    group = "palworld";
    uid = puid;
  };

  systemd.tmpfiles.rules = [
    "d /palworld 0700 palworld palworld"
  ];

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    palworld = {
      image = "thijsvanloef/palworld-server-docker:latest";
      autoStart = true;
      user = "${builtins.toString puid}:${builtins.toString pgid}";
      volumes = [
        "/palworld:/palworld"
      ];
      ports = [
        "8211:8211/udp"
        "27015:27015/udp"
      ];
      environment = {
        PUID = "${builtins.toString puid}";
        PGID = "${builtins.toString pgid}";
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
        PUBLIC_PORT = "8211";
        DELETE_OLD_BACKUPS = "true";
        OLD_BACKUP_DAYS = "14";
        UPDATE_ON_BOOT = "true";
        AUTO_REBOOT_ENABLED = "true";
        AUTO_REBOOT_CRON_EXPRESSION = "0 4 * * *";
        AUTO_REBOOT_WARN_MINUTES = "30";
        AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE = "true";
      };
    };

  };

  networking.firewall.allowedUDPPorts = [ 8211 27015 ];
}
