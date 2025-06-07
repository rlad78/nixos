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
    # the default for networking
    networking.networkmanager.enable = true;

    # fix for nm-wait-online (https://github.com/NixOS/nixpkgs/issues/180175)
    systemd.services.NetworkManager-wait-online = {
      serviceConfig = {
        ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
      };
    };

    networking = lib.mkIf (!cfg.no-nat) {
      nat = {
        enable = true;
        internalInterfaces = ["ve-+"];
        externalInterface = hosts."${config.networking.hostName}".default-net-dev;
        # Lazy IPv6 connectivity for the container
        enableIPv6 = true;
      };
      networkmanager.unmanaged = [ "interface-name:ve-*" ];
    };
  };
}
