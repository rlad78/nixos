{ lib, pkgs, ...}:
let
  root-config-dir = ./../..;
in
{
  arf = {
    cli = {
      theme = "jonathan";
      plugins = [ "systemd" "z" ];
    };
    nvidia.version = "legacy_580";
    romm = {
      enable = true;
      libraryDir = /snoot/romm;
      hosting = {
        enable = true;
        url = "retro.snootflix.com";
      };
    };
    pso = {
      enable = true;
      server-name = "phantasy-snoot";
      worker-threads = 5;
      local-net-interface = "eno1";
      external-ip = "97.89.132.36";
      allow-unregistered-users = true;
      welcome-message = "Ahoy sailors! Swab the scruvy off me poop deck.";
      rare-item-notify = true;
    };
  };
  
  imports = [
    ./hardware-configuration.nix
    ./media-storage.nix
  ] ++ lib.lists.forEach [
    "/roles/snootflix.nix"
    "/system/systemd-boot.nix"
    "/hosts/common/nvidia.nix"
    "/services/romm.nix"
    "/services/pso.nix"
  ] (p: root-config-dir + p);

  networking.hostName = "snootflix";
  system.stateVersion = "25.11";
}
