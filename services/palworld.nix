{ config, pkgs, ... }:
{
  virtualisation.docker.enable = true;
  users.users.richard.extraGroups = [ "docker" ];

  users.users.palworld = {
    isSystemUser = true;
    group = "palworld";
  };

  virtualisation.oci-containers.containers = {
    palworld = {
      image = "thijsvanloef/palworld-server-docker:latest";
      autoStart = true;
      user = "palworld:palworld";
      volumes = [
        "palworld_data:/palworld/"
      ];
      ports = [
        "8211:8211/udp"
        "27015:27015/udp"
      ];
      environment = {

      };
    };

  };
}
