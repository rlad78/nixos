{ config, pkgs, lib, machine }:
{
  virtualization.docker.enable = true;

  users.groups = {
    scurtiny = {};
  };

  users.users.scrutiny = {
    isSystemUser = true;
    group = "scrutiny";
  };

  systemd.tmpfiles.rules = [
    "d /scrutiny 0700 scrutiny scrutiny"
    "d /scrutiny/config 0700 scrutiny scrutiny"
    "d /scrutiny/influxdb2 0700 scrutiny scrutiny"
  ];

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    scrutiny = {
      image = "ghcr.io/analogj/scrutiny:master-omnibus";
      autoStart = true;
      user = "${builtins.toString config.users.users.scrutiny.uid}:${builtins.toString config.users.groups.scrutiny.gid}";
      volumes = [
        "/scrutiny/config:/opt/scrutiny/config"
        "scrutiny/influxdb2:/opt/scrutiny/influxdb"
        "/run/udev:/run/udev:ro"
      ];
      ports = [ "9999:8080" ];
      extraOptions = [
         "--pull=always"
         "--cap-add SYS_RAWIO"
      ] + lib.lists.forEach machine.drives (d: "--device=${d}");
    };
  };
}