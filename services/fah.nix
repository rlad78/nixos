{ config, pkgs, lib, hosts, secrets, ... }:
let
  local-hosts = with lib.attrsets; filterAttrs (n: v: hasAttrByPath ["local-ip"] v) (removeAttrs hosts [config.networking.hostName]);
  tail-hosts = with lib.attrsets; filterAttrs (n: v: hasAttrByPath ["tail-ip"] v) (removeAttrs hosts [config.networking.hostName]);
  local-ips = lib.attrsets.mapAttrsToList (n: v: v.local-ip) local-hosts;
  tail-ips = lib.attrsets.mapAttrsToList (n: v: v.tail-ip) tail-hosts;
  all-ips = with lib.strings; (concatStringsSep " " (local-ips ++ tail-ips));
in
{
    services.foldingathome = {
        enable = true;
        user = "rcarte4";
        team = 60194;
        extraArgs = [
            ("--allow=127.0.0.1 " + all-ips)
            ("--web-allow=" + all-ips)
            "--password=${secrets.fah.password}"
        ];
    };

    networking.firewall.allowedTCPPorts = [ 7396 36330 ];
}
