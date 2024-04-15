{ config, pkgs, lib, machine, ... }:
with lib; let 
  cfg = config.arf.scrutiny;
in 
{
  options.arf.scrutiny = with types; {
    enable = mkOption {
      type = bool;
      default = false;
    };
    drives = mkOption {
      type = listOf path;
      default = [ /dev/sda ];
    };
    config-dir = mkOption {
      type = path;
      default = /scrutiny;
    };
    port = mkOption {
      type = port;
      default = 8080;
    };
  };

  config = {
    virtualisation.docker.enable = true;

    users.groups.scrutiny = {};

    users.users.scrutiny = {
      isSystemUser = true;
      group = "scrutiny";
    };

    systemd.tmpfiles.rules = [
      "d ${builtins.toString cfg.config-dir} 0700 scrutiny scrutiny"
      "d ${builtins.toString cfg.config-dir}/config 0700 scrutiny scrutiny"
      "d ${builtins.toString cfg.config-dir}/influxdb2 0700 scrutiny scrutiny"
    ];

    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers = {
      scrutiny = {
        image = "ghcr.io/analogj/scrutiny:master-omnibus";
        autoStart = true;
        user = "${builtins.toString config.users.users.scrutiny.uid}:${builtins.toString config.users.groups.scrutiny.gid}";
        volumes = [
          "${builtins.toString cfg.config-dir}/config:/opt/scrutiny/config"
          "${builtins.toString cfg.config-dir}/influxdb2:/opt/scrutiny/influxdb"
          "/run/udev:/run/udev:ro"
        ];
        ports = [ "${builtins.toString cfg.port}:8080" ];
        extraOptions = [
          "--pull=always"
          "--cap-add=SYS_RAWIO"
        ] ++ lib.lists.forEach cfg.drives (d: "--device=${builtins.toString d}");
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}