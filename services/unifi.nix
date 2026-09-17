{ config, lib, ... }:
let
  cfg = config.arf.unifi;
in
{
  options.arf.unifi = with lib; {
    ip = mkOption {
      type = types.str;
    };
  };

  config = {
    virtualisation.podman.enable = true;

    services.unifi-os-server = {
      enable = true;
      uosSystemIP = cfg.ip;
      openFirewallUiPort = true;
      openFirewallServicePorts = true;
    };
  };
}
