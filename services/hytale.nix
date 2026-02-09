{ secrets, config, ... }:
let
  hytale-uid = 15520;
  hytale-gid = 15520;
in
{
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";
  users.users.richard.extraGroups = [ "docker" ];

  users.users.hytale = {
    isSystemUser = true;
    group = "hytale";
    uid = hytale-uid;
  };

  users.groups.hytale.gid = hytale-gid;

  systemd.tmpfiles.rules = [
    "d /hytale 0700 hytale hytale"
  ];

  virtualisation.oci-containers.containers = {
    hytale = {
      image = "indifferentbroccoli/hytale-server-docker";
      pull = "always";
      autoStart = true;
      extraOptions = [
        # "-it"
        # "--restart=unless-stopped"
        "--stop-timeout=30"
      ];
      volumes = [ "/hytale:/home/hytale/server-files" ];
      ports = [ "5520:5520/udp" ];
      environment = {
        PUID = "${toString hytale-uid}";
        PGID = "${toString hytale-gid}";
        SERVER_NAME = "Twilight";
        ENABLE_BACKUPS = "true";
        BACKUP_FREQUENCY = "90";  # minutes
        MAX_MEMORY = "12G";
      };
    };
  };
}
