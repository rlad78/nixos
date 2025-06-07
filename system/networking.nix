{ config, pkgs, hosts, lib,... }:
let
  cfg = config.arf;
in
{
  options.arf = with lib; {
    no-nat = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    # fix for nm-wait-online (https://github.com/NixOS/nixpkgs/issues/180175)
    systemd.services.NetworkManager-wait-online = {
      serviceConfig = {
        ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
      };
    };

    networking = {
      networkmanager = {
        enable = true;
        unmanaged = lib.mkIf (!cfg.no-nat) [ "interface-name:ve-*" ];
      };
      nat = lib.mkIf (!cfg.no-nat) {
        enable = true;
        internalInterfaces = ["ve-+"];
        externalInterface = hosts."${config.networking.hostName}".default-net-dev;
        # Lazy IPv6 connectivity for the container
        enableIPv6 = true;
      };
    };
  };
}
