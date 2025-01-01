{ config, pkgs, secrets, ... }:
let
  filebrowser-uid = 7789;
  filebrowser-gid = 9877;

  filebrowser-ext-port = 9007;
in
{
  virtualisation.docker.enable = true;
  users.users.richard.extraGroups = [ "docker" ];

  users.groups.filebrowser.gid = filebrowser-gid;

  users.users.filebrowser = {
    isSystemUser = true;
    group = "filebrowser";
    uid = filebrowser-uid;
  };

  systemd.tmpfiles.rules = [
    "d /filebrowser 0750 filebrowser filebrowser"
    "d /filebrowser/srv 0750 filebrowser filebrowser"
    "f /filebrowser/filebrowser.db 0600 filebrowser filebrowser"
    "f /filebrowser/filebrowser.json 0600 filebrowser filebrowser"
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
