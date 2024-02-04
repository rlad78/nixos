{ config, pkgs, lib, machine, me, ... }:
{
  networking.nat = {
    enable = true;
    internalInterfaces = [ "virt-+" ];
    externalInterface = machine.eth-interface;
  };

  containers.arrr = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.69.10";
    localAddress = "192.168.69.100";
    config = { config, pkgs, ... }: {
      services.sonarr = { 
        enable = true;
        openFirewall = true;
      };

      system.stateVersion = "23.11";

      networking.useHostResolvConf = mkForce false;
    };
  };  
}
