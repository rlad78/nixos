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
  };
  
  imports = [
    ./hardware-configuration.nix
    ./media-storage.nix
  ] ++ lib.lists.forEach [
    "/roles/snootflix.nix"
    "/system/systemd-boot.nix"
    "/hosts/common/nvidia.nix"
    "/services/romm.nix"
  ] (p: root-config-dir + p);

  networking.hostName = "snootflix";
  system.stateVersion = "25.11";
}
