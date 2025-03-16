{ config, lib, ... }:
let
  cfg = config.arf.rustdesk;
in
{
  options.arf.rustdesk = with lib; {
    publicIP = mkOption {
      type = types.strMatching ''[0-9]{2,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'';
    };
  };

  # ports 21114 - 21119 need to be open on router
  config.services.rustdesk-server = {
    enable = true;
    openFirewall = true;
    signal.enable = true;
    relay.enable = true;
    signal.relayHosts = [ cfg.publicIP ];
  };
}
