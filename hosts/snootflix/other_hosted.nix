{ config, lib, pkgs, ...}:
let
  root-config-dir = ./../..;
in
{
  arf = {
    romm = {
      enable = true;
      libraryDir = /snoot/romm_library;
      consoles = [
        "gba"
        "gbc"
        "nds"
        "n64"
        "genesis-slash-megadrive"
        "nes"
        "ps"
        "snes"
      ];
    };
  };

  imports =  lib.lists.forEach [
    "/filebrowser.nix"
    "/romm.nix"
  ] (p: root-config-dir + "/services" + p);

  services.nginx.virtualHosts = {
    "share.snootflix.com".locations."/" = {
      proxyPass = "http://127.0.0.1:9007";
      proxyWebsockets = true;
    };
    "retro.snootflix.com".locations."/" = {
      proxyPass = "http://127.0.0.1:7111";
      proxyWebsockets = true;
    };
  };
}
