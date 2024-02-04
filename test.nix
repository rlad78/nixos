{ config, pkgs, lib, machine, me, ... }:
let
  arrr-gen = (octet: port: {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.${octet}.10";
    localAddress = "192.168.${octet}.100";
    forwardPorts = [
      {
        containerPort = 8989;
        hostPort = port;
        protocol = "tcp";
      }
    ];
    config = { config, pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        inetutils
      ];

      services.sonarr = { 
        enable = true;
        openFirewall = true;
      };

      system.stateVersion = "23.11";

      networking.useHostResolvConf = lib.mkForce false;
    };
  });
in
{
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = machine.eth-interface;
  };

  containers.arrr1 = arrr-gen "69" 6969;
  containers.arrr2 = arrr-gen "99" 9999;
  networking.firewall.allowedTCPPorts = [ 6969 9999 ];
}
