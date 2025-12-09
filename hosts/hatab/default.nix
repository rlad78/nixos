{ config, lib, ... }:
let
  root-config-dir = ./../..;
in
{
  arf = {
    cli = {
      theme = "bira";
      plugins = [ "systemd" "z" ];
    };
    hass-tablet.page-url = "http://10.69.2.1:8123";
    builders = [ "nixarf" ];
  };

  imports = [
    ./hardware-configuration.nix
  ] ++ lib.lists.forEach [
    "/roles/hass-tablet.nix"
    "/hosts/common/wireless.nix"
    "/system/systemd-boot.nix"
  ] (p: root-config-dir + p);

  networking.hostName = "hatab";
  system.stateVersion = "24.11";
}
