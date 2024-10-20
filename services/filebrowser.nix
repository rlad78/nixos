{ config, pkgs, secrets, ... }:
let
  filebrowser-uid = 7789;
  filebrowser-group = "syncthing";
  filebrowser-gid = config.users.groups."${filebrowser-group}".gid;

  filebrowser-ext-port = 9007;
in
{
  virtualisation.docker.enable = true;
  users.users.richard.extraGroups = [ "docker" ];

  users.users.filebrowser = {
    isSystemUser = true;
    group = "syncthing";
    uid = filebrowser-uid;
  };

  systemd.tmpfiles.rules = [
    "d /filebrowser 0750 filebrowser ${filebrowser-group}"
    "d /filebrowser/srv 0750 filebrowser ${filebrowser-group}"
    "f /filebrowser/filebrowser.db 0600 filebrowser ${filebrowser-group}"
    "f /filebrowser/filebrowser.json 0600 filebrowser ${filebrowser-group}"
    "f /filebrowser/srv/success.txt 0640 filebrowser ${filebrowser-group} 'hello world!'"
  ];

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    filebrowser = {
      image = "filebrowser/filebrowser:latest";
      user = "${builtins.toString filebrowser-uid}:${builtins.toString filebrowser-gid}";
      autoStart = true;
      volumes = [
        "/filebrowser/srv:/srv"
        "/syncthing/emulation:/srv/emulation"
        "/filebrowser/filebrowser.db:/database.db"
        "/filebrowser/filebrowser.json:/filebrowser.json"
      ];
      ports = [ "${builtins.toString filebrowser-ext-port}:80" ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ filebrowser-ext-port ];
    allowedUDPPorts = [ filebrowser-ext-port ];
  };
}
