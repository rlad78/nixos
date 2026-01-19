{ lib, ...}:
let
  root-config-dir = ./../..;
in
{
  arf.cli = {
    theme = "jonathan";
    plugins = [ "systemd" "z" ];
  };
  
  imports = [
    ./hardware-configuration.nix
  ] ++ lib.lists.forEach [
    "/roles/snootflix.nix"
    "/system/systemd-boot.nix"
  ] (p: root-config-dir + p);

  networking.hostName = "snootflix";
  system.stateVersion = "25.11";
}
