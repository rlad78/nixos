{ config, pkgs, ... }:
{
  virtualisation.docker.enable = true;
  users.users.richard.extraGroups = [ "docker" ];

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.stirlingpdf = {
    image = "frooodle/s-pdf:latest";
    ports = [ "5050:8080" ];
    environment = {
      DOCKER_ENABLE_SECURITY = "false";
      INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "false";
      LANGS = "en_US";
    };
  };

  networking.firewall.allowedTCPPorts = [ 5050 ];
}
