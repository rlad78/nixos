{ config, pkgs, ...}:
let
  root-config-dir = ./../..;
in
{
  imports = [ root-config-dir + "/services/filebrowser.nix" ]

  services.nginx.virtualHosts."share.snootflix.com".locations."/" = {
    proxyPass = "http://127.0.0.1:9007";
    proxyWebsockets = true;
  };
}
