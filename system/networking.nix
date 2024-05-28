{ config, pkgs, hosts, ... }:
{
  # fix for nm-wait-online (https://github.com/NixOS/nixpkgs/issues/180175)
  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
    };
  };

  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
    externalInterface = hosts."${config.networking.hostName}".default-net-dev;
    # Lazy IPv6 connectivity for the container
    enableIPv6 = true;
  };
}
